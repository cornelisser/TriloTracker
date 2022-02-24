;Note: A 12 cycle wait (at 3.58 Mhz) is required after all address and data writes.
MUSKB_ADDRESS	equ	$c0
MUSKB_DATA		equ	$C1

musickb_matrix		ds	8,$ff
musickb_matrix_old	ds	8,$ff
;===========================================================
; --- musickb_handler
;
; Reads the key on the musical keyboard (Music Module or Toshiba)  
;===========================================================
musickb_handler:
	;--- reset key pressed to false
	xor	a
	ld	(music_key_on),a
	;--- Read and store the matrix
	ld	b,8				; read 8 row
	ld	c,1				; row#
	ld	de,musickb_matrix
.loop:
	ld	a,6
	out 	(MUSKB_ADDRESS),a		; set reg 6
	ld	a,c				; 4 cycles
	rlc	c				; 8 cycles 
	out 	(MUSKB_DATA),a		; Write matrix row.
	ex	af,af				; 4 cycles Dummy opcode
	ld	a,5				; 8 cycles
	out 	(MUSKB_ADDRESS),a		; set reg 5	
	bit   0,(hl)			; 12 cycles Dummy opcode
	in	a,(MUSKB_DATA)		; Retrieve matrix row
	ld	(de),a			; store the matrix
	cp	$ff
	jp	z,99f
	ld	a,1				; Set key press to true for any vaue != $FF
	ld	(music_key_on),a
99:
	inc	de	
	djnz	.loop
	
	;--- Handle matrix changes
	ld	hl,musickb_matrix_old
	ld	de,musickb_matrix
	ld	b,8				; 8 rows to check
	
.loop2:
	ld	a,(de)			; get new values
	ld	c,a
	xor	(hl)				; erase non changed bits
	and	(hl)				; erase key release transistions
	ld	(hl),c	
	call	nz,_getkey			; if a new key is pressed
	inc	de
	inc	hl
	djnz	.loop2

	ret

;----
; Process the matrix value to get the key(s) and place 
; the result in de key value
;----
_getkey:
	push	bc
	push	hl
	push	af
	;--- calculate the offset of the key
	ld	a,b
	add	a
	add	a
	add	a			; *8
	ld	c,a			; store row in c
	
	ld	b,8			; check 8 bits
	pop	af			; restore pressed key bits
.loop:
	rra				; rotate bit0 to carry flag
	call	c,.found		; a bit is found 	
	dec	c			; increase base value
	djnz	.loop

	pop	hl
	pop	bc
	ret

.found:	
	ex	af,af'
	ld	hl,_MKBMATRIX_MM-1
	ld	a,c
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(hl)
	ld	(music_buf_key),a
	ex	af,af'
	ret
	
	
	

;===========================================================
; --- musickb_readkey
;
; Return the current keypress. But only once while it is
; pressed.
; 
; Out: 
;	[A] the note value
;     Returns Z flag when no key
;===========================================================
musickb_readkey:
	ld	a,(music_key_on)
	and	a
	jp	z,2f
	ld	a,(music_buf_key_old)
	ld	b,a
	ld	a,(music_buf_key)
	cp	b
	jp	z,1f

	ld	(music_buf_key_old),a
	jp	0f
1:	
	xor	a
	
0:	ld	(music_key),a
	ret	
	
2:
	ld	(music_buf_key_old),a
	ld	(music_key),a
	ret
;	ld	b,a
;	ld	a,(music_buf_key_old)
;	cp	b
;	jp	nz,.keyfound
;.nokeyfound:
;	xor	a
;	ld	(music_key),a
;	ret
	
;.keyfound:
;	ld	a,b
;;	ld	(music_buf_key_old),a
;	ld	(music_key),a
;	ret
	

;===========================================================
; --- musickb_translatematrix
;
; Reads the key value from the music keyboard matrix.
; 
; In: 
;	[C] the column
;	[B] inverted column (7=0, 6 = 1 etc) 
;===========================================================
;musickb_translatematrix:
;	ld	hl,_MKBMATRIX_MM
;	ld	a,b	; calculate row offset
;	add 	a	;*2
;	add	a	;*4
;	add	a	;*8
;	add	a,c	; add the column
;	add	a,l
;	ld	l,a
;	jr.	nc,99f
;	inc 	h
;99:
;	ld	a,(hl)
;	ld	(music_buf_key),a
;	ret


_MKBMATRIX_MM:
	db	0,	0,	0,	1+72,	12+72,11+72,10+72,9+60	;---	---	---	C 7	B 7	A#7	A 7	G#6 	row 7
	db	8+60,	7+60,	6+60,	5+60,	4+60,	3+60,	2+60,	1+60	;G 6	F#6	F 6	E 6	D#6	D 6	C#6	C 6 	row 6
	db	12+60,11+60,10+60,9+48,	8+48,	7+48,	6+48,	5+48	;B 6	A#6	A 6	G#5	G 5	F#5	F 5	E 5 	row 5
	db	4+48,	3+48,	2+48,	1+48,	12+48,11+48,10+48,9+36	;D#5	D 5	C#5	C 5	B 5	A#5	A 5	G#4 	row 4
	db	8+36,	7+36,	6+36,	5+36,	4+36,	3+36,	2+36,	1+36	;G 4	F#4	F 4	E 4	D#4	D 4	C#4	C 4 	row 3
	db	12+36,11+36,10+36,9+24,	8+24,	7+24,	6+24,	5+24	;B 4	A#4	A 4	G#3	G 3	F#3	F 3	E 3 	row 2
	db	4+24,	3+24,	2+24,	1+24,	12+24,11+24,10+24,9+12	;D#3	D 3	C#3	C 3	B 3	A#3	A 3	G#2 	row 1
	db	8+12,	7+12,	6+12,	5+12,	4+12,	3+12,	2+12,	1+12	;G 2	F#2	F 2	E 2	D#2	D 2	C#2	C 2 	row 0


;_MKBMATRIX_OTHER:
;	db	0,	1+60,	12+60,11+60,0,	10+60,9+48,	8+48	;---	C 6	B 6	A#6	---	A 6	G#5	G 5	row 7
;	db	0,	7+48,	6+48,	5+48,	0,	4+48,	3+48,	2+48	;---	F#5	F 5	E 5	---	D#5	D 5	C#5
;	db	0,	1+48,	12+48,11+48,0,	10+48,9+36,	8+36	;---	C 5	B 5	A#5	---	A 5	G#4	G 4
;	db	0,	7+36,	6+36,	5+36,	0,	4+36,	3+36,	2+36	;---	F#4	F 4	E 4	---	D#4	D 4	C#4
;	db	0,	1+36,	12+36,11+36,0,	10+36,9+24,	8+24	;---	C 4	B 4	A#4	---	A 4	G#3	G 3
;	db	0,	7+24,	6+24,	5+24,	0,	4+24,	3+24,	2+24	;---	F#3	F 3	E 3	---	D#3	D 3	C#3
;	db	0,	1+24,	12+24,11+24,0,	10+24,9+12,	8+12	;---	C 3	B 3	A#3	---	A 3	G#2	G 2
;	db	0,	7+12,	6+12,	5+12,	0,	4+12,	3+12,	2+12	;C 2	F#2	F 2	E 2	---	D#2	D 2	C#2	row 0
	

	
	
	