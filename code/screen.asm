_UPLEFT			equ	130
_HORIZONTAL			equ	129
_UPRIGHT			equ	131
_VERTICAL			equ	128
_VERTICAL_SMALL		equ	135
_VERTICAL_DOUBLE		equ	134
_VERTICAL_STEP		equ	139
_ARROWLEFT			equ	176
_ARROWRIGHT			equ	177
_LOOPSIGN			equ	174
_TONE_OFF_SIGN		equ	241
_TONE_ON_SIGN		equ	242
_NOISE_OFF_SIGN		equ	243
_NOISE_ON_SIGN		equ	244
_ENV_OFF_SIGN		equ	245
_ENV_ON_SIGN		equ	246
_CMD_SIGN			equ	6*32-1
_CURSOR			equ	254


; ==========================================================	
	; --- clear_window
	; 
	; Clears the current screen (pnt and cnt)
	;
; ==========================================================	
clear_screen:
	ld 	hl,_PNT
	call	set_vdpwrite	

	ld	e,27
	ld	a,32
;	di
0:	;-- main loop
	ld	bc,0x5098
1:	;--- sub loop
		out	(c),a
		djnz 	1b
	; -- end sub loop
	dec	e
	jr	nz,0b
	; -- end main loop	

clear_cnt:
	ld 	hl,_CNT
	call	set_vdpwrite	
	
	ld	e,27
	ld	a,0
;	di
0:	;-- main loop
	ld	bc,0x0a98
1:	;--- sub loop
		out	(c),a
		djnz 	1b
	; -- end sub loop
	dec	e
	jr	nz,0b
	; -- end main loop	
	
	ei
	ret

; ==========================================================	
	; --- clear_files
	; 
	; Clears the files area in the file dialog 
	;
; ==========================================================	
clear_files:

	ld	b,20
	ld	hl,_PNT+(80*6)

0:	push	bc
	push	hl
	call	set_vdpwrite	

	ld	b,56
	ld	a,32

1:	;--- sub loop
		out	(0x98),a
		djnz 	1b
	; -- end sub loop
	pop	hl
	ld	bc,80
	add	hl,bc
	
	pop	bc
	djnz	0b
	ei
	ret	




; ==========================================================	
	; --- draw_label
	; 
	; Draw box 
	; HL = position in PNT (relative)
	; DE = pointer to the label text
; ==========================================================
draw_label:
	di
	
	ld 	bc,_PNT
	add	hl,bc
	call	set_vdpwrite			
	
draw_label_loop:
	ld	a,(de)
	cp	0
	jr.	z,draw_label_end	
	out	(0x98),a
	
	inc	de
	jr.	draw_label_loop
	
draw_label_end:
	ei
	ret

; ==========================================================	
	; --- draw_label_fast
	; 
	; Draw box 
	; HL = position in PNT (relative)
	; DE = pointer to the label text
	; BC = number of bytes to copy to vram
; ==========================================================
draw_label_fast:
	di
	push	bc
	ld 	bc,_PNT
	add	hl,bc	
	call	set_vdpwrite	
			
	ex	de,hl
	pop	bc
	ld	c,0x98
	
	otir
	ex	de,hl

	ei
	ret

; ==========================================================	
	; --- draw_fake_hex_sp
	; 
	; Prints the value at an address as 1 digit decimal value 
	; But value 0 is printed as '.'
	; Values can be larger than F
	; A = the value
	; DE = position (relative) to put the value in PNT
	; 
; ==========================================================
draw_fake_hex_sp:
	and	a
	jr.	nz,0f
	ld	a,'.'
	ld	(de),a
	inc	de
	ret
0:	
	cp	10
	jr.	nc,1f
	add	48
	ld	(de),a
	inc	de
	ret
1:
	add 	55
	ld	(de),a
	inc	de	
	ret
	
; ==========================================================	
	; --- draw_fake_hex_sp_small
	; 
	; Prints the value at an address as 1 digit decimal value 
	; But value 0 is printed as '.'
	; Values can be larger than F
	; A = the value
	; DE = position (relative) to put the value in PNT
	; 
; ==========================================================
draw_fake_hex_sp_small:
	and	a
	jr.	nz,0f
	ld	a,'.'
	ld	(de),a
	inc	de
	ret
0:	
	ld	(de),a
	inc	de	
	ret
	
	
	
; ==========================================================	
	; --- draw_hex_sp
	; 
	; Prints the value at an address as 1 digit decimal value 
	; But value 0 is printed as '.'
	; A = the value
	; DE = position (relative) to put the value in PNT
	; 
; ==========================================================
;draw_hex_sp:
;	and	a
;	jr.	nz,draw_hex
;	ld	a,"."
;	ld	(de),a
;	inc	de
;	ret

; ==========================================================	
	; --- draw_hex_sp_small
	; 
	; Prints the value at an address as 1 digit decimal value 
	; But value 0 is printed as '.'
	; A = the value
	; DE = position (relative) to put the value in PNT
	; 
; ==========================================================
draw_hex_sp_small:
	and	a
	jr.	nz,draw_hex_small
	ld	a,"."
	ld	(de),a
	inc	de
	ret

; ==========================================================	
	; --- draw_hex2_cmd
	; 
	; Prints the value at an address as 2 digit decimal value 
	; A =  the value
	; DE = position (relative) to put the value in PNT
	; 
	; Changes: AF
; ==========================================================
;draw_hex2_cmd:
;	push	af
;	and	0xf0
;	rrca
;	rrca
;	rrca
;	rrca	
;	call	draw_hex_small
;	pop	af
;	call	draw_hex_small
;	ret


; ==========================================================	
	; --- draw_hex
	; 
	; Prints the value at an address as 1 digit decimal value 
	; A = the value
	; DE = position (relative) to put the value in PNT
	; 
; ==========================================================
draw_hex:
	and	0x0f
draw_fakehex:	
	add	a,0x90
	daa
	adc	a,0x40
	daa
	ld	(de),a
	inc	de
	ret
	
	
; ==========================================================	
	; --- draw_hex_small
	; 
	; Prints the value at an address as 1 digit decimal value 
	; A = the value
	; DE = position (relative) to put the value in PNT
	; 
; ==========================================================
draw_hex_small:
	and	0x0f
	ld	(de),a
	inc	de
	ret	
	
	
; ==========================================================	
	; --- draw_hex2
	; 
	; Prints the value at an address as 2 digit decimal value 
	; A =  the value
	; DE = position (relative) to put the value in PNT
	; 
	; Changes: AF
; ==========================================================
draw_hex2:
	push	af
	and	0xf0
	rrca
	rrca
	rrca
	rrca	
	call	draw_hex
	pop	af
	call	draw_hex
	ret
	
	
	
	

; ==========================================================	
; --- conv_decimal
; 
; converts the value at HL into a 2 digit decimal at DE 
; HL = position of the value
; DE = postion  to put the 2 digit value value 
; 
; ==========================================================	

conv_decimal:

	ld	a,(hl)
draw_decimal:
	ex	de,hl
;	ld	hl,_dd_tmpstring
	
1:	ld	b,-10
	call	_dd_Num1
	ld	b,-1
	call	_dd_Num1

	ex	de,hl
;	ld	hl,_dd_tmpstring

	ret	
_dd_Num1:	
	ld	c,"0"-1
_dd_Num2:	
	inc	c
	add	a,b
	jr	c,_dd_Num2
	sbc	a,b
	ld	(hl),c
	inc	hl
	ret 

draw_decimal_3:
	ex	de,hl
	ld	b,-100
	call	_dd_Num1
	jr.	1b
	
	
;_dd_tmpstring:		
;	db	"XX",0		; temporary + delimiter

; ==========================================================	
	; --- draw_box
	; 
	; Draw box 
	; HL = position in PNT (relative)
	; D = width
	; E = height
; ==========================================================
draw_box:
	di

	ld 	bc,_PNT
	add	hl,bc
	call	set_vdpwrite		
	
	ld	a,_UPLEFT		; upperleft corner

draw_box_loop1:
	ld	b,d	
draw_box_loop0:

	; change on last pos
	dec	b
	jr.	nz,1f
	cp	_HORIZONTAL
	jr.	nz,0f
	ld	a,_UPRIGHT
	jr.	1f
0:
	cp	32
	jr.	nz,1f
	ld	a,_VERTICAL
	jr.	1f
	
1:
	inc	b	



	out	(0x98),a
	
	; changed on pos > 1
	cp	_UPLEFT		; if is upleftcorner thern	
	jr.	nz,0f
	ld	a,_HORIZONTAL
	jr.	1f
0:	
	cp	_VERTICAL	; if is vertical line then space
	jr.	nz,0f
	ld	a,32			; space	
	jr.	1f
0:
1:

	djnz	draw_box_loop0


	;loop lines
	dec	e
	jr.	z,draw_box_end
	
	ld	bc,80
	add	hl,bc
	ld 	bc,_PNT
	call	set_vdpwrite
	ld	a,_VERTICAL			
	jr.	draw_box_loop1


draw_box_end:
	ei
	ret




; ==========================================================	
	; --- draw_colorbox
	; 
	; Draw box 
	; H = x pos
	; L = y pos
	; D = width
	; E = height
; ==========================================================
draw_colorbox:
	; --- get maskleft
	ld	a,h
	and	0x07
	and	a
	jr.	nz,0f
	ld	a,255
	jr.	1f
0:	
	ld	b,a
	ld	a,255
	
_dc_maskleft_loop:
		srl	a
		djnz	_dc_maskleft_loop
1:	ld	(cb_maskleft),a

	; --- get maskright (7-(x+(w-1)) & 0x07)	
	ld	a,d
	dec	a
	add	h
	and	0x07
	cp	7
	jr.	nz,0f
	ld	a,0
	jr.	1f
0:	ld	b,a
	ld	a,7
	sub	b


	ld	b,a
	ld	a,255	
	
_dc_maskright_loop:
		sla	a
		djnz	_dc_maskright_loop
1:	ld	(cb_maskright),a
	
	; --- calculate the full cnt bytes to copy
	ld	a,h
	and	0xf8
	ld	b,a		; store in b the full bytes
	ld	a,h
	add	d
	and	0xf8
	sub	b
[3]	srl	a		; divide by 8
	dec	a		; 255 is begin and end in same byte
				; 0 is no full bytes to copy
				; >0 full bytes to copy inbetween masks
	ld	(cb_fullbytes),a	

	; --- Calculate start address
	ld	c,h		; x in c
	ld	b,l		; y in b
	ld	hl,_CNT
	ld	a,b
	and	a
	jr.	z,0f

_dc_start_loop:
	ld	a,l
	add	10		; every line adds 10 bytes to the addres
	ld	l,a
	jr.	nc,1f
	inc	h
1:
	djnz	_dc_start_loop	
0:
	ld	a,c		; add the x pos.
	and	0xf8
[3]	srl	a	
	add	l
	ld	l,a
	jr.	nc,1f
	inc	h
1:
	; now we have start addres in the cnt in HL
	ld	c,e	; # lines to plot
	
	; --- get way to copy
	ld	a,(cb_fullbytes)
	cp	255
	jr.	z,_cp_clip_copy
	
	; --- 'normal' copy
_cb_copyloop_main:	
	push	hl
	call	set_vdpread
	in	a,(0x98)
	ld	b,a
	ld	a,(cb_maskleft)
	or	b
	ld	b,a
	
	pop	hl
	push	hl
	call	set_vdpwrite
	
	ld	a,b
	out	(0x98),a
	ld	a,(cb_fullbytes)
	and	a
	ld	b,a
	pop	hl
	push	hl
	inc	hl
	jr.	z,0f

	add	a,l
	ld	l,a
	jr.	nc,9f
	inc	h
9:
	ld	a,255
_cb_copyloop:
	out	(0x98),a
	djnz	_cb_copyloop
0:	
	ld	d,h
	ld	e,l
	call	set_vdpread
	in	a,(0x98)
	ld	b,a
	ld	a,(cb_maskright)
	or	b
	ld	b,a
	
	ex	de,hl	
	call	set_vdpwrite
	ld	a,b	
	out	(0x98),a
	
	pop 	hl
	ld	de,10
	add	hl,de
	
	dec	c
	jr.	nz,_cb_copyloop_main
	ei
	ret
	

_cp_clip_copy:
	push	hl

	ld	a,(cb_maskleft)
	ld	b,a
	ld	a,(cb_maskright)
	and	b
	ld	b,a

	call	set_vdpread
	in	a,(0x98)

	or	b
	ld	b,a
	
	pop	hl
	push	hl
	call	set_vdpwrite
	
	ld	a,b
	out	(0x98),a	

	pop 	hl
	ld	de,10
	add	hl,de
	
	dec	c
	jr.	nz,_cp_clip_copy	
	ei
	ret

; ==========================================================	
	; --- erase_colorbox
	; 
	; Draw box 
	; H = x pos
	; L = y pos
	; D = width
	; E = height
; ==========================================================
erase_colorbox:
	; --- get maskleft
	ld	a,h
	and	0x07
	and	a
	jr.	nz,0f
	ld	a,255
	jr.	1f
0:	
	ld	b,a
	ld	a,255
	
_ecb_maskleft_loop:
		srl	a
		djnz	_ecb_maskleft_loop
1:	
	xor	255
	ld	(cb_maskleft),a

	; --- get maskright (7-(x+(w-1)) & 0x07)	
	ld	a,d
	dec	a
	add	h
	and	0x07
	cp	7
	jr.	nz,0f
	ld	a,0
	jr.	1f
0:	ld	b,a
	ld	a,7
	sub	b


	ld	b,a
	ld	a,255	
	
_ecb_maskright_loop:
		sla	a
		djnz	_ecb_maskright_loop
1:	
	xor	255
	ld	(cb_maskright),a
	
	; --- calculate the full cnt bytes to copy
	ld	a,h
	and	0xf8
	ld	b,a		; store in b the full bytes
	ld	a,h
	add	d
	and	0xf8
	sub	b
[3]	srl	a		; divide by 8
	dec	a		; 255 is begin and end in same byte
				; 0 is no full bytes to copy
				; >0 full bytes to copy inbetween masks
	ld	(cb_fullbytes),a	

	; --- Calculate start address
	ld	c,h		; x in c
	ld	b,l		; y in b
	ld	hl,_CNT
	ld	a,b
	and	a
	jr.	z,0f

_ecb_start_loop:
	ld	a,l
	add	10		; every line adds 10 bytes to the addres
	ld	l,a
	jr.	nc,1f
	inc	h
1:
	djnz	_ecb_start_loop	
0:
	ld	a,c		; add the x pos.
	and	0xf8
[3]	srl	a	
	add	l
	ld	l,a
	jr.	nc,1f
	inc	h
1:
	; now we have start addres in the cnt in HL
	ld	c,e	; # lines to plot
	
	; --- get way to copy
	ld	a,(cb_fullbytes)
	cp	255
	jr.	z,_ecb_clip_copy
	
	; --- 'normal' copy
_ecb_copyloop_main:	
	push	hl
	call	set_vdpread
	in	a,(0x98)
	ld	b,a
	ld	a,(cb_maskleft)
	and	b
	ld	b,a
	
	pop	hl
	push	hl
	call	set_vdpwrite
	
	ld	a,b
	out	(0x98),a
	ld	a,(cb_fullbytes)
	and	a
	ld	b,a
	pop	hl
	push	hl
	inc	hl
	jr.	z,0f

	add	a,l
	ld	l,a
	jr.	nc,9f
	inc	h
9:
	ld	a,0
_ecb_copyloop:
	out	(0x98),a
	djnz	_ecb_copyloop
0:	
	ld	d,h
	ld	e,l
	call	set_vdpread
	in	a,(0x98)
	ld	b,a
	ld	a,(cb_maskright)
	and	b
	ld	b,a
	
	ex	de,hl	
	call	set_vdpwrite
	ld	a,b	
	out	(0x98),a
	
	pop 	hl
	ld	de,10
	add	hl,de
	
	dec	c
	jr.	nz,_ecb_copyloop_main
	ei
	ret
	

_ecb_clip_copy:
	push	hl

	ld	a,(cb_maskleft)
	ld	b,a
	ld	a,(cb_maskright)
	or	b
	ld	b,a

	call	set_vdpread
	in	a,(0x98)

	and	b
	ld	b,a
	
	pop	hl
	push	hl
	call	set_vdpwrite
	
	ld	a,b
	out	(0x98),a	

	pop 	hl
	ld	de,10
	add	hl,de
	
	dec	c
	jr.	nz,_ecb_clip_copy	
	ei
	ret

