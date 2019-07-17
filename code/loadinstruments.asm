_DEFAULT_INS:
	db	"DEFAULT.IS",0

	
load_instruments:
	call	get_program_path
	
	ld	hl,_DEFAULT_INS
	ld	bc,11
	ldir

	call	reset_hook
	ld	(_catch_stackpointer),sp
	
	;--- open the file
	ld	de,buffer+256 	; +2 to skip drive name
	ld	a,00000001b		; NO write
;	ld	de,buffer
	ld	c,(_OPEN)
	call	DOS
	and	a	
	jr	nz,_li_error
	
	
	;--- file is found.
	call	open_insfile_direct

	ret
	
_li_error:
	ld	a,WIN_NODEFAULT
	call	window
	
	call	set_hook
	ret	





;--- gets the programms path.
; in buffer+256 [DE] points end path
;------------------------
get_program_path:
	;-- get location of TT.COM
	ld	c,$6b
	ld	hl,_ENV_PROGRAM
	ld	de,buffer+256
	ld	b,255
	call	DOS		; < 255-[B] is length value string returned.

	;--- get full path+filename length
	ld	a,255
	sub	b
	sub	_DEFAULT_CFGLEN
	
	;--- set name
	ld	de,buffer+256
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ret
