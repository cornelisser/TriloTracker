_MBM_WILDCARD:
	db	"*.MBM",0

patterns_to_load:
	db	0

;===========================================================
; --- open_mbmmfile
;
; Open an mbmfile. HL needs to point to the file
; Data is loaded into the current song
;===========================================================	
open_mbmfile:
	ld	(_catch_stackpointer),sp
	call	reset_hook

	ld	a,00000001b		; NO write
	call	open_file
	;--- Check for errors
	and	a
	jr.	nz,catch_diskerror
	
	ld	a,b
	ld	(disk_handle),a

	;--- Get the song length 
	ld	de,song_order_len
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror
	
	;----- CHECK IF THIS IS AN EDIT file.
	ld	a,(song_order_len)
	inc	a
	jr.	nz,0f			; reread when edit file.

	;--display a message that this is not a USER mbm file.
		ld	hl,_WIN_MBM_USER_ERROR
		call	window_custom
		jr.	_open_mbmfile_stop
0:
	ld	(song_order_len),a
	;--- Skip 
	ld	de,buffer
	ld	hl,162
	call	read_file
	jr.	nz,catch_diskerror

	;--- Get start instruments 
	ld	de,buffer
	ld	hl,32		; store temp i nfirst 32 bytes of buffer
	call	read_file
	jr.	nz,catch_diskerror

	;--- Skip 
	ld	de,buffer+32
	ld	hl,10
	call	read_file
	jr.	nz,catch_diskerror

	;--- Tempo 
	ld	de,song_speed
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror
	
	;--- TT is twice as fast -2
	ld	a,(song_speed)
	dec	a
	add	a
	ld	(song_speed),a
	
	;--- Skip 
	ld	de,buffer+32
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror
	
	;--- Track name 
	ld	de,song_name
	ld	hl,41
	call	read_file
	jr.	nz,catch_diskerror

	;--- Clear the rest of the name/by
	ld	de,song_name+40
	ld	b,64-40
	xor	a
88:	ld	(de),a
	inc	de
	djnz	88b


	;--- Skip 
	ld	de,buffer+32
	ld	hl,9
	call	read_file
	jr.	nz,catch_diskerror

	;--- Get the start instruments 
	ld	de,buffer+32
	ld	hl,9
	call	read_file
	jr.	nz,catch_diskerror
	
	;--- Skip 
	ld	de,buffer+32+9
	ld	hl,109
	call	read_file
	jr.	nz,catch_diskerror	
	
	;--- Get the song loop position
	ld	de,song_order_loop
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror	
	
	;--- Get the song pattern order
	ld	de,song_order
	ld	a,(song_order_len)

	ld	l,a
	ld	h,0
	call	read_file
	jr.	nz,catch_diskerror	

	;--- decrease each pat# in the order
	ld	hl,song_order
	ld	a,(song_order_len)
	ld	b,a
44:	
	ld	a,(max_pattern)
	inc	a
	cp	(hl)
	ld	a,(hl)
;	cp	SONG_MAXPAT+1		;dont allow pat# that are to high
	jr.	nc,99f
	ld	a,1
99:
	dec	a
	ld	(hl),a
	inc	hl
	djnz	44b

	;--- get pointer to first pattern
	ld	de,buffer+32+9
	ld	hl,2	
	call	read_file
	jr.	nz,catch_diskerror	
	ld	hl,(buffer+32+9)
	ld	a,(song_order_len)
	
	ld	bc,$178+2		; +2 because we read the first pointer ;)
	add	a,c
	ld	c,a
	jr.	nc,99f
	inc	b
99:
	xor	a		; to be sure
	sbc	hl,bc
	;--get number of patterns to load ;)
	ld	a,l
	srl	a
	inc	a
	ld	(patterns_to_load),a
	
	;--- skip the 
	ld	de,buffer+32+10	
	call	read_file
	jr.	nz,catch_diskerror	
	
	;---- Now read the patterns.
	ld	a,0
0:	
	;--- patterns to load
	push	af
	ld	a,(patterns_to_load)
	ld	b,a
	pop	af	
	cp	b
	jr.	nc,_open_mbmfile_end


;	cp	SONG_MAXPAT		; stop reading if we reached max pat#
	ld	hl,max_pattern
	cp	(hl)
	jr.	nc,_open_mbmfile_end
	
	push	af	
	call	load_mbmpattern
	
	pop	af
	inc	a
	jr.	0b
	



_open_mbmfile_end:

;	ld	a,(current_song)
	call	set_songpage
	;---- init the rest
	
	;--- we can only loop in TT.
	ld	a,(song_order_loop)
	cp	$ff
	jr.	nz,0f
	xor	a
	ld	(song_order_loop),a	
0:
	;-set initial values
	ld	a,(song_order)	; get first pattern
	ld	b,a
	call	set_patternpage
	inc	hl	;--- skip first channel
	inc	hl
	inc	hl
	inc	hl

	ld	b,6
	ld	de,buffer+32		; buffer+9 contains start instruments
88:	ld	a,(de)
	inc	hl

	call	_lm_instrument
	inc	hl
	inc	hl
	inc	de
	djnz	88b

	; --- Set the first pattern in the order after loading	
	ld	a,(song_order)
	ld	(song_pattern),a
	
	call	close_file
	
	call	set_hook

	;--- start the channel manager
	ld	hl,_MBM_chans
	call	channel_manager
	ret
_MBM_chans:
	db	"D123456X"	


;---- used for import errors.
_open_mbmfile_stop:
	call	close_file
	call	set_hook
	ret





	;--- get the correct voices
	; input [A] contains the local voice#
	;       [HL] points to current chan at instrument
_lm_instrument:
	push	de
	ld	de,buffer-2		; instrument# start at 1
	add	a
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	; get the voice#
	ld	a,(de)
	inc	a		; in TT voice 0 does not exist
	cp	$11		; only allow 1 software voice
	jr.	c,99f
		ld	a,$10
99:	ld	(hl),a
	inc	hl
	;-- check if there is already a volume
	ld	a,(hl)
	and	$f0
	jr.	nz,_lm_ins_skip

	inc	de
	;--- get the volume
	ld	a,(de)
	ld	d,a

	
	; msx music volumes are reversed.
	ld	a,$f
	sub	d
	;--- set volume in high 4 bits
	sla	a
	sla	a
	sla	a
	sla	a
	ld	d,a
	ld	a,(hl)
	and	$0f
	or	d
	ld	(hl),a
_lm_ins_skip:	
	pop	de
	ret



	
;===========================================================
; --- load_mbmpattern
;
; Read (compressed) mb1.4 patterns
; input:	[A] contains the patternnumber
;===========================================================	
_MB_LINE:	db 0,0,0,0,0,0,0,0,0,0,0,0,0
_drumnote_table:
		db 25,37,25,13,13,13,13,13
		
load_mbmpattern:
	ld	b,a
	call	set_patternpage
	
	;--- 16 lines per pattern
	ld	b,16		; process 16 lines
_lmp_line:	
	push	hl		; store the actual pattern pointer
	;--- for each line decompress a line (to 12 bytes)
	ld	c,13
	ld	hl,_MB_LINE
_lmp_chan_d:
	;-- read 1 byte
	push	bc
	push	hl
	ld	de,buffer+32+10	
	ld	hl,1
	call	read_file
	pop	hl
	pop	bc
	
	jr.	nz,catch_diskerror

	;--- decompress?
	ld	a,(buffer+32+10)
	cp	243			; is byte uncompressed?
	jr.	nc,0f
	ld	(hl),a
	inc	hl

	dec	c
	jr.	nz,_lmp_chan_d
	jr.	2f
	
0:	;--- decompress
	sub	242		; get bytes to decompress
1:	ld	(hl),0
	inc	hl
	dec	c
	dec	a
	jr.	nz,1b	
	
	ld	a,c
	and	a
	jr.	nz,_lmp_chan_d
	
	
2:	;--- process the decompressed line to TT patternline
	pop	hl			; restore pattern pointer

	;--- Put drums in the first channel
	
	ld	a,(_MB_LINE+11)
	and	$0f
	jr.	z,3f		; jmp if no drum data
	;-- there are drums
	push	bc
	push	af
	ld	bc,_drumnote_table-1	; drum start at 1
	and	7
	add	c
	ld	c,a
	jr.	nc,99f
	inc	b
99:
	ld	a,(bc)
	ld	(hl),a    ;C-2?
	inc	hl
	
	pop	af
	pop	bc
	
	add	16		; drum instruments start at 17 in TT
	cp	32		; make sure we stay in max instruments range.
	jr.	c,99f
	ld	a,31			
99:	
	ld	(hl),a
	jr.	4f
3:
	inc	hl	;-- skip 1st channel
4:	inc	hl	;-- perhaps use this later for drums
	inc	hl
	
;---- PROCESS CMD CHANNEL
	ld	a,(_MB_LINE+12)
	and	a
	jp	z,_mbi_endcmd
	
	;-- tempo
	cp	24
	jr.	nc,0f
	dec	a
	add	a
	ld	c,a
	ld	a,48
	sub	c
	ld	(hl),a
	dec	hl
	ld	a,(hl)
	and	$F0
	add	$0f
	ld	(hl),a
	inc	hl
	jr.	_mbi_endcmd
0:
	;--- end pattern
	cp	24
	jp	nz,0f
	dec	hl
	ld	a,(hl)
	and	$f0
	add	$d
	ld	(hl),a
	inc	hl
	jr.	_mbi_endcmd
	
	;--- transpose.
0:	cp	49
	jp	c,_mbi_endcmd
	;--- not implemented yet. Is this needed??
	
	
	
_mbi_endcmd:	
	inc	hl

	ld	de,_MB_LINE	
	ld	c,6		; only process 1st 6 channels
_lmp_chan:
	
	ld	a,(de)
	;--- empty, NOTE or REST?
	cp	98		
	jr.	nc,0f
	ld	(hl),a
	inc	hl
	inc	hl
	inc	hl
	inc	hl	
	jr.	2f
0:	;--- Instrument change?
	cp	114
	jr.	nc,0f
	sub	97
	inc	hl
	call	_lm_instrument
	inc	hl
	inc	hl
	jr.	2f		
0:	;--- Volume change	
	cp	177
	jr.	nc,0f
	sub	114  
	sub	63
	neg	
	;--- translate volume
	rla
	rla	
	and	$f0
	inc	hl
	inc	hl
	ld	(hl),a
	inc	hl
	inc	hl
	jr.	2f
0:	;--- panning
	cp	180
	jr.	nc,0f
	inc	hl
	inc	hl	
	inc	hl
	inc	hl	
	jr.	2f
0:	;--- note link
	cp	199
	jr.	nc,0f
	sub	180
	inc	hl
	inc	hl
	inc	hl
	cp	9
	jr.	c,99f
	sub	9
	or	$10
99:	
	ld	(hl),a
	dec	hl
	ld	a,(hl)
	and	$f0
	add	$03
	ld	(hl),a
	inc	hl
	inc	hl
	jr.	2f

0:	;---pitch
	cp	218
	jr.	nc,0f
	inc	hl
	inc	hl
	inc	hl
	sub	199		
	cp	9
	jr.	c,99f
	;-- slide up
	sub	9
	or	$10
	ld	(hl),a
	dec	hl
	ld	a,(hl)
	and	$f0
	add	a,1
	ld	(hl),a
	jr.	88f
99: 	;--- slide down	
	ld	(hl),a
	dec	hl
	ld	a,(hl)
	and	$f0
	add	a,2
	ld	(hl),a
88:
	inc	hl
	inc	hl
	jr.	2f
	
0: 	;--- brightness neg
	cp	224
	jp	nc,0f
	inc	hl
	inc	hl	
	inc	hl
	inc	hl
	jr.	2f	
	
0:	;--- detune
	cp	230
	jr.	nc,0f
	inc	hl
	inc	hl	
	inc	hl
	inc	hl
	cp	227
	jp	nc,_mb_detp
_mb_detn:
	sub	224-7
	add	$60		; E6y
	jr.	44f
_mb_detp:
	sub	227
	add	$60		; E6y
44:	ld	(hl),a
	dec	hl
	ld	a,(hl)
	and	$f0
	add	$E	
	ld	(hl),a
	inc	hl
	jr.	2f

0: 	;--- brightness pos/sustain
	cp	238
	jp	nc,0f
	inc	hl
	inc	hl	
	inc	hl
	inc	hl
	jr.	2f
	
0:	;--- modulation
	cp	238
	jr.	nz,0f
	inc	hl
	inc	hl
	ld	a,4
	ld	(hl),a
	inc	hl
	ld	a,$21
	ld	(hl),a
	inc	hl
	jr.	2f
	
0:	;-- for now skip other stuff
	inc	hl
	inc	hl	
	inc	hl
	inc	hl	
	
2:	
	inc	de
	dec	c
	jr.	nz,_lmp_chan

	inc	hl
	inc	hl	
	inc	hl
	inc	hl

	;--- PROCESS POSSIBLE PATTERN END.
	inc	de	;--- chan8
	inc	de	;--- chan9
	inc	de	;--- 
	inc	de
	inc	de
	inc	de

	ld	a,(de)
	cp	24
	jr.	nz,99f
	;--- set pattern end
	ld	de,30
	xor	a
	sbc	hl,de
	ld	a,(hl)
	and	$f0
	add	$d
	ld	(hl),a
	add	hl,de	
99:	
	dec	b
	jr.	nz,_lmp_line
	
	;--- Add end of pattern
	ld	de,30
	xor	a
	sbc	hl,de
	ld	a,(hl)
	and	$f0
	add	$d
	ld	(hl),a
	add	hl,de	

	ret



_WIN_MBM_USER_ERROR:
	;-- box
	dw	(80*12)+20		; HL = position in PNT (relative)
	dw	0x2808		; D = width; E = height
	;-- color
	dw	0x140c		; H = x pos	; L = y pos
	dw	0x2808		; D = width ; E = height
	;-- text
	dw	(80*12)+22
	db	"[MBM IMPORT ERROR]",0,0
	db	"The MBM song is stored in EDIT format.",0
	db	"The import routine only supports MBM",0
	db	"stored in USER format",0,0
	db	"Press any key to stop import",0,255
	db	255
;	db	_OPTION_CLOSE