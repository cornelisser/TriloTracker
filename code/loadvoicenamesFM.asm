_VOICE_VRAM_START:	equ	$2c00

load_voicenames:
	;-- get location of TT.COM
	call	get_program_path
	add	_DEFAULT_CFGLEN	
	dec	de
	dec	de
	dec	de
	ex	hl,de
	;--- set extension .DAT
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
	

