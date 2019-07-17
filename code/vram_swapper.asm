;---- VRAM code/data swapper.
SWAP_VRAMSTART		equ	0xa000
SWAP_RAMSTART		equ	0x8000 - (SWAP_REPLAY_END-SWAP_REPLAY)
SWAP_WIN_VRAMSTART	equ	0x0000

swap_block		db	255		; current loaded block from VRAM

swap_block_list:
		;-- block 0
		dw SWAP_VRAMSTART				; source
		dw (SWAP_REPLAY_END-SWAP_REPLAY)	; size
		;-- block 1
		dw SWAP_VRAMSTART+(SWAP_REPLAY_END-SWAP_REPLAY)	; source
		dw SWAP_MBM_IMP_END-SWAP_MBM_IMP			; size		
		;-- block 2
		dw SWAP_VRAMSTART+(SWAP_REPLAY_END-SWAP_REPLAY)+(SWAP_MBM_IMP_END-SWAP_MBM_IMP)	; source
		dw SWAP_XM_IMP_END-SWAP_XM_IMP	
		;-- block 3
		dw SWAP_VRAMSTART+(SWAP_REPLAY_END-SWAP_REPLAY)+(SWAP_MBM_IMP_END-SWAP_MBM_IMP)+(SWAP_XM_IMP_END-SWAP_XM_IMP)	; source
		dw SWAP_CONFIG_END-SWAP_CONFIG		
		;-- block 4
		dw SWAP_VRAMSTART+(SWAP_REPLAY_END-SWAP_REPLAY)+(SWAP_MBM_IMP_END-SWAP_MBM_IMP)+(SWAP_XM_IMP_END-SWAP_XM_IMP)+(SWAP_CONFIG_END-SWAP_CONFIG)	; source
		dw SWAP_TRACK_END-SWAP_TRACK		; size
		;-- block 5
		dw SWAP_VRAMSTART+(SWAP_REPLAY_END-SWAP_REPLAY)+(SWAP_MBM_IMP_END-SWAP_MBM_IMP)+(SWAP_XM_IMP_END-SWAP_XM_IMP)+(SWAP_CONFIG_END-SWAP_CONFIG)+(SWAP_TRACK_END-SWAP_TRACK)	; source
		dw SWAP_INSFILE_END-SWAP_INSFILE		; size
		;-- block 6
		dw SWAP_VRAMSTART+(SWAP_REPLAY_END-SWAP_REPLAY)+(SWAP_MBM_IMP_END-SWAP_MBM_IMP)+(SWAP_XM_IMP_END-SWAP_XM_IMP)+(SWAP_CONFIG_END-SWAP_CONFIG)+(SWAP_TRACK_END-SWAP_TRACK)+(SWAP_INSFILE_END-SWAP_INSFILE)    ; source
		dw SWAP_FILE_END-SWAP_FILE        ; size
IFDEF	TTSCC
ELSE	
		;-- block 7
		dw SWAP_VRAMSTART+(SWAP_REPLAY_END-SWAP_REPLAY)+(SWAP_MBM_IMP_END-SWAP_MBM_IMP)+(SWAP_XM_IMP_END-SWAP_XM_IMP)+(SWAP_CONFIG_END-SWAP_CONFIG)+(SWAP_TRACK_END-SWAP_TRACK)+(SWAP_INSFILE_END-SWAP_INSFILE)+(SWAP_FILE_END-SWAP_FILE)    ; source
		dw SWAP_VOICEMAN_END-SWAP_VOICEMAN        ; size
		;-- block 8
		dw SWAP_VRAMSTART+(SWAP_REPLAY_END-SWAP_REPLAY)+(SWAP_MBM_IMP_END-SWAP_MBM_IMP)+(SWAP_XM_IMP_END-SWAP_XM_IMP)+(SWAP_CONFIG_END-SWAP_CONFIG)+(SWAP_TRACK_END-SWAP_TRACK)+(SWAP_INSFILE_END-SWAP_INSFILE)+(SWAP_FILE_END-SWAP_FILE)+(SWAP_VOICEMAN_END-SWAP_VOICEMAN)    ; source
		dw SWAP_DRUM_END-SWAP_DRUM        ; size
		;-- block 7
		dw SWAP_VRAMSTART+(SWAP_REPLAY_END-SWAP_REPLAY)+(SWAP_MBM_IMP_END-SWAP_MBM_IMP)+(SWAP_XM_IMP_END-SWAP_XM_IMP)+(SWAP_CONFIG_END-SWAP_CONFIG)+(SWAP_TRACK_END-SWAP_TRACK)+(SWAP_INSFILE_END-SWAP_INSFILE)+(SWAP_FILE_END-SWAP_FILE)    ; source
		dw SWAP_VOICEMAN_END-SWAP_VOICEMAN        ; size
		;-- block 8
		dw SWAP_VRAMSTART+(SWAP_REPLAY_END-SWAP_REPLAY)+(SWAP_MBM_IMP_END-SWAP_MBM_IMP)+(SWAP_XM_IMP_END-SWAP_XM_IMP)+(SWAP_CONFIG_END-SWAP_CONFIG)+(SWAP_TRACK_END-SWAP_TRACK)+(SWAP_INSFILE_END-SWAP_INSFILE)+(SWAP_FILE_END-SWAP_FILE)+(SWAP_VOICEMAN_END-SWAP_VOICEMAN)    ; source
		dw SWAP_DRUM_END-SWAP_DRUM        ; size		
ENDIF
;---------------------
; swap_loadvram
;
; loads data from RAM/ROM into VRAM
; [HL] - source
; [DE] - dest VRAM
; [BC] - size

swap_loadvram:
	;--- set VRAM write address
	ex	de,hl			; set dest to HL
	call	set_vdpwrite
	ex	de,hl
	
	di
	ld	a,b		; store C in A this is the number of 256 bytes to loop
	ex	af,af'	;'
	ld	a,c
	ld	b,a
	ex	af,af'	;'
	inc	a		; add one to loop correct.
	ld	c,0x98
	
_slv_loop:
	otir			; write [B] bytes to VRAM
	
;	ld	b,0xff
	dec	a		; decrease # of cycles to write.
	jr.	nz,_slv_loop
	
	ei
	ret
 
;---------------------
; swap_loadelementblock
;
; reads data from VRAM into RAM
; [A] - block nr
swap_loadelementblock:
	;--- make sure no replayer is triggered
	ld	hl,replay_mode
	ld	(hl),0
	ld	hl,swap_block_list
	add	a
	add	a			;*4
	add	a,l			
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	;-- load VRAM source
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc 	hl
	ex	de,hl
	call	set_vdpread
	
	di
	ex	de,hl
	ld	b,(hl)
	inc	hl
	ld	d,(hl)
	inc	d	

	ld	c,0x98
	ld	hl,SWAP_ELEMENTSTART
	jr.	_srv_loop
	
	
	
;---------------------
; swap_loadblock
;
; reads data from VRAM into RAM
; [A] - block nr
swap_loadblock:
	;--- make sure no replayer is triggered
	ld	hl,replay_mode
	ld	(hl),0
	ld	hl,swap_block_list
	add	a
	add	a			;*4
	add	a,l			
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	;-- load VRAM source
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc 	hl
	ex	de,hl
	call	set_vdpread
	
	di
	ex	de,hl
	ld	b,(hl)
	inc	hl
	ld	d,(hl)
	inc	d	

	ld	c,0x98
	ld	hl,SWAP_RAMSTART
	
_srv_loop:
	inir  		; write [B] bytes to VRAM
	
	
;	ld	b,0xff
	dec	d		; decrease # of cycles to write.
	jr.	nz,_srv_loop
	
	ei
	ret
	
;---------------------
; swap_loadwindow
;
; reads data from VRAM into RAM
; [HL] VRAM source
swap_loadwindow:
	call	set_vdpread

	
	di
	ld	b,low WIN_MAX_SIZE
	ld	d,high WIN_MAX_SIZE
	
	;-- if B == 0 then do not increase D
	ld	a,b
	and	a
	jp	z,99f
	inc	d
99:
	ld	c,0x98
	ld	hl,_WINDOW_BUFFER
	
_slw_loop:
	inir  		; write [B] bytes to VRAM
	
	
;	ld	b,0xff
	dec	d		; decrease # of cycles to write.
	jr.	nz,_slw_loop
	
	ei
	ret