;WINDOW.ASM
; Used for generic windows.

WIN_MAX_SIZE		equ	420		; maximun length of data for a message window 

window_shown:		db	1			; if != 0 a error window was shown.
_WINDOW_BUFFER:		ds 	WIN_MAX_SIZE			; for the window message loaded from VRAM



window_custom:		;--- WINDOW CUSTOM can be used directly with in HL the message DATA
				;--- This can be used by non standard tt parts that can be seperated	
	call	set_hook
	jr.	_win_cust_cont	
;=======================================================
; window
;
; display a window with text and some optional choices
;
; in: [A] window type / error message
; out: [A] the key pressed.
;=======================================================
window:
	;-- most of the time we call this function when doing disk access.
	;-- So we need to restore the custom ISR
	call	set_hook
	
	cp	$80
	jr.	c,_window_normal

	push	af
	
	;-- check which type of error to show
	cp	$CB		; file exists. Overwrite question.
	jr.	nz,99f
	ld	hl,(WINDOW_DOS_LIST+2)
	jr 88f
99:	
	ld	hl,(WINDOW_DOS_LIST)
88:	call	swap_loadwindow
	pop	af

	ld	b,a
	ld	c,_EXPLAIN
	ld	de,_WINDOW_BUFFER + (_WINDOW_ERROR_OK_LABEL-_WINDOW_ERROR_OK)
	call	DOS
	
	;-- remove the 255 value from the explain. 
	ld	b,64
	ld	hl,_WINDOW_BUFFER + (_WINDOW_ERROR_OK_LABEL-_WINDOW_ERROR_OK)
12:	ld	a,(hl)
	cp	255
	jr.	nz,23f
	ld	(hl),32		; replace it with a space.
23:
	inc	hl
	djnz 	12b	

	jr.	_window_continue
	
_window_normal:
	;--- get location where the data is
	add	a
	ld	hl,WINDOW_TT_LIST
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	call	swap_loadwindow	
	
	
_window_continue:
	ld	hl,_WINDOW_BUFFER	
	
	
_win_cust_cont:
	;--- Set the window shown indicator
	ld	a,255
	ld	(window_shown),a


	;--- get the window box dimensions
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl

	push	hl
	ld	h,b
	ld	l,c
	
	call	draw_box

	pop	hl

	;--- get the window color box
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl

	push	hl
	ld	h,b
	ld	l,c
	
	push	bc
	push	de
	call	draw_colorbox
		
	pop	de
	pop	bc
	dec	d
	dec	d
	dec	e
	dec	e
	inc	b
	inc	c
	ld	h,b
	ld	l,c

	call	erase_colorbox
		
	pop	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ex	de,hl
0:	
	ld	a,(de)
	cp	255
	jr.	z,_window_end

	push	hl	
	call	draw_label
	inc	de
	
	pop	hl
	ld	a,80
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	jr.	0b
	
	


_window_end:
	halt
	call	read_key
	ld	a,(key)
	and	a
	jr.	nz,_window_end
99:	
	halt
	call	read_key
	ld	a,(key)
	and	a
	jr.	z,99b


	
	ret


_OPTION_CLOSE		equ	0	; [CLOSE] 'button'
_OPTION_YESNO		equ	1	; [Y or N] 'option'.


WIN_FILE_CORRUPT		equ	0	
WIN_WARN_LESS_RAM		equ	1
WIN_WARN_DELETE		equ	2
WIN_STARTUP			equ	3
WIN_INSERTDISK		equ	4
WIN_NODEFAULT		equ	5
WIN_NOSCC			equ	6
	
WINDOW_TT_LIST:
	dw	_WINDOW_FILECORRUPT	-SWAP_WIN_START+SWAP_WIN_VRAMSTART
	dw	_WINDOW_LESSRAM		-SWAP_WIN_START+SWAP_WIN_VRAMSTART
	dw	_WINDOW_DELETE		-SWAP_WIN_START+SWAP_WIN_VRAMSTART
	dw	_WINDOW_STARTUP		-SWAP_WIN_START+SWAP_WIN_VRAMSTART
	dw	_WINDOW_INSERT		-SWAP_WIN_START+SWAP_WIN_VRAMSTART
	dw	_WIN_NODEFAULT		-SWAP_WIN_START+SWAP_WIN_VRAMSTART
	dw	_WIN_NOSCC			-SWAP_WIN_START+SWAP_WIN_VRAMSTART
WINDOW_DOS_LIST:
	dw	_WINDOW_ERROR_OK		-SWAP_WIN_START+SWAP_WIN_VRAMSTART
	dw	_WINDOW_ERROR_YN		-SWAP_WIN_START+SWAP_WIN_VRAMSTART






;--------
; This data will be loaded into VRAM and retrieved into the WINDOW_BUFFER when needed.
;--------
SWAP_WIN_START:

_WINDOW_FILECORRUPT:
	;-- box
	dw	(80*12)+20		; HL = position in PNT (relative)
	dw	0x2808		; D = width; E = height
	;-- color
	dw	0x140c		; H = x pos	; L = y pos
	dw	0x2808		; D = width ; E = height
	;-- text
	dw	(80*12)+22
	db	"[TT ERROR]",0,0
	db	"The file you loaded is corrupt.",0,0,0,0
	db	"Press any key to continue",0,255
	db	255
	db	_OPTION_CLOSE

_WINDOW_LESSRAM:
	;-- box
	dw	(80*12)+20		; HL = position in PNT (relative)
	dw	0x2808		; D = width; E = height
	;-- color
	dw	0x140c		; H = x pos	; L = y pos
	dw	0x2808		; D = width ; E = height
	;-- text
	dw	(80*12)+22
	db	"[TT WARNING]",0,0
	db	"The song loaded is larger than the",0
	db	"available number of patterns.",0
	db	"Not all patterns are loaded!",0,0
	db	"Press any key to continue",0,255
	db	_OPTION_CLOSE

_WINDOW_DELETE:
	;-- box
	dw	(80*12)+20		; HL = position in PNT (relative)
	dw	0x2808		; D = width; E = height
	;-- color
	dw	0x140c		; H = x pos	; L = y pos
	dw	0x2808		; D = width ; E = height
	;-- text
	dw	(80*12)+22
	db	"[TT WARNING]",0,0
	db	"Are you sure you want to delete",0
	db	"this file?",0,0,0
	db	"Continue and delete? [Y/N]",0,255
	db	_OPTION_CLOSE

_WINDOW_INSERT:
	;-- box
	dw	(80*12)+20		; HL = position in PNT (relative)
	dw	0x2808		; D = width; E = height
	;-- color
	dw	0x140c		; H = x pos	; L = y pos
	dw	0x2808		; D = width ; E = height
	;-- text
	dw	(80*12)+22
	db	"[MSX-DOS]",0,0
	db	"Please insert disk",0
	db	0,0,0
	db	"Press any key to continue",0,255
	db	_OPTION_CLOSE



	
_WINDOW_ERROR_OK:
	;-- box
	dw	(80*12)+7		; HL = position in PNT (relative)
	dw	0x4207		; D = width; E = height
	;-- color
	dw	0x070c		; H = x pos	; L = y pos
	dw	0x4207		; D = width ; E = height
	;-- text
	dw	(80*12)+9
	db	"[MSX-DOS ERROR]",0,0
_WINDOW_ERROR_OK_LABEL:
	ds	64,"."
	db	0
	db	"Press any key to continue",0,255
	db	_OPTION_CLOSE
		
_WINDOW_ERROR_YN:
	;-- box
	dw	(80*12)+7		; HL = position in PNT (relative)
	dw	0x4207		; D = width; E = height
	;-- color
	dw	0x070c		; H = x pos	; L = y pos
	dw	0x4207		; D = width ; E = height
	;-- text
	dw	(80*12)+9
	db	"[MSX-DOS ERROR]",0,0
_WINDOW_ERROR_YN_LABEL:
	ds	64,"."
	db	0
	db	"Continue? [Y/N]",0,255
	db	_OPTION_YESNO	
	

_WINDOW_STARTUP:
	;-- box
	dw	(80*05)+7		; HL = position in PNT (relative)
	dw	0x420e		; D = width; E = height
	;-- color
	dw	0x0705		; H = x pos	; L = y pos
	dw	0x420e		; D = width ; E = height
	;-- text
	dw	(80*6)+9
	db	"TriloTracker ",VERSION," (c) ",YEAR,".",0
	db	0
	db	"Code          : Richard Cornelisse (Huey)",0
	db	"Add. code     : Arturo Ragozini (ARTRAG)",0
	db	"Design        : John Hassink, Inverse Phase",0
	db	"Testers       : John Hassink, Gryzor87, Inverse Phase",0
	db	"Special Thanks: BiFi, Hap, Quibus, msd and all beta testers.",0            
	db	0
	db	"For more information go to: www.trilobyte-msx.com\\TriloTracker",0
	db	0,0
	db	"Press any key to continue.",0,255

_WIN_NODEFAULT:
	;-- box
	dw	(80*12)+20		; HL = position in PNT (relative)
	dw	0x2808		; D = width; E = height
	;-- color
	dw	0x140c		; H = x pos	; L = y pos
	dw	0x2808		; D = width ; E = height
	;-- text
	dw	(80*12)+22
	db	"[TT ERROR]",0,0
	db	"Could not load the default",0
	db	"instrument set (DEFAULT.IS).",0,0,0
	db	"Press any key to continue",0,255
	db	255
	db	_OPTION_CLOSE
	
_WIN_NOSCC:
	;-- box
	dw	(80*10)+20		; HL = position in PNT (relative)
	dw	0x2808		; D = width; E = height
	;-- color
	dw	0x140a		; H = x pos	; L = y pos
	dw	0x2808		; D = width ; E = height
	;-- text
	dw	(80*10)+22
	db	"[TT WARNING]",0,0
	db	"Could not detect an SCC chip.",0,0,0,0
	db	"Press any key to continue",0,255
	db	255
	db	_OPTION_CLOSE	
	
	
SWAP_WIN_END: