_VOICE_VRAM_START:	equ	$2c00

load_voicenames:
	;-- get location of TT.COM
	ld	c,$6b
	ld	hl,_ENV_PROGRAM
	ld	de,buffer+256
	ld	b,255
	call	DOS		; < 255-[B] is length value string returned.

	;--- get full path+filename length
	ld	a,255
	sub	b
	ld	b,a
	
	;--- set extension .DAT
	sub	4
	ld	hl,buffer+256
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	(hl),"D"
	inc	hl
	ld	(hl),"A"
	inc	hl
	ld	(hl),"T"
	inc	hl
	
	;--- open the file
	ld	de,buffer+256 	; +2 to skip drive name
	ld	a,00000001b		; NO write
;	ld	de,buffer
	ld	c,(_OPEN)
	call	DOS
	and	a
	jp	nz,_loadvoices_end
	
	;-- store handle
	ld	a,b
	ld	(disk_handle),a
	
	
	;--- load the first 2048 byte
	ld	de,buffer
	ld	hl,2048
	call	read_file
	
	and	a
	jp	nz,_loadvoices_end
	
	;--- Copy the data to VRAM
	ld	de,_VOICE_VRAM_START
	ld	hl,buffer
	ld	bc,2048
	call	swap_loadvram
	
	;--- load the 2nd 2048 byte
	ld	de,buffer
	ld	hl,2048
	call	read_file
	
	and	a
	jp	nz,_loadvoices_end
	
	;--- Copy the data to VRAM
	ld	de,_VOICE_VRAM_START+2048	
	ld	hl,buffer
	ld	bc,2048
	call	swap_loadvram

_loadvoices_end:
	call	close_file
	ret
	

