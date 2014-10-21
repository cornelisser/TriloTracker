;===================================
; show_cursor
; 
; shows a blinking cursor on screen
;===================================
show_cursor:


	ld	a,(cursor_type)
	and	a
	ret	z				; type 0 is no cursor
	
	;--- calculate PNT address of the cursor.
	ld	hl,_PNT
	ld	de,80
	ld	bc,(cursor_y)		; b = xpos, c = ypos
	ld	a,c
	and	a
	jr.	z,0f
_sc_loop:				; add lines to the pnt
	add	hl,de
	dec	a
	jr.	nz,_sc_loop
	
0:
	ld	e,b			; b is still 0
	add	hl,de			; add columns to the pnt

	push	hl			; store the PNT addres
	ld	de,cursor_buffer	; get the cursor buffer
	call	set_vdpread		
	pop	hl			; restore PNT address
	
	in	a,(0x98)		; get value of first char
	;-- check if cursor is still there
	cp	MOUSE_CHR		
	jr.	nc,0f			; jmp if a is a mouse or cursor char
	ld	(de),a		; store 3 char of pnt in cursor buffer
	in	a,(0x98)	
	inc	de
	ld	(de),a
	in	a,(0x98)	
	inc	de	
	ld	(de),a

0:
	call	set_vdpwrite
	
	ld	a,(cursor_type)
	ld	b,a
	
	ld	a,(cursor_timer)
	bit	5,a
	jr.	z,cursor_on
cursor_off:
	ld	hl,cursor_buffer
1:	ld	a,(hl)
	inc	hl
	out	(0x98),a
	djnz	1b	
	ret

cursor_on:
	ld	a,_CURSOR
1:
	out	(0x98),a
	djnz	1b
	ret
	
	
;===================================
; flush_cursor
; 
; shows a blinking cursor on screen
;===================================
flush_cursor:
	push	af

	
	ld	a,(cursor_type)
	and	a
	jr.	z,flush_cursor_END
	
	push	bc
	push	de
	push	hl	
	
	
	ld	hl,_PNT
	ld	de,80
	ld	bc,(cursor_y)		; b = xpos, c = ypos
	ld	a,c
	and	a
	jr.	z,0f
_fc_loop:				; add lines to the pnt
	add	hl,de
	dec	a
	jr.	nz,_fc_loop
	
0:
	ld	e,b			; b is still 0
	add	hl,de			; add columns to the pnt
	call	set_vdpwrite
	
	ld	a,(cursor_type)
	ld	b,a
	
	ld	hl,cursor_buffer
1:	ld	a,(hl)
	inc	hl
	out	(0x98),a
	djnz	1b	

	
	
	
	pop 	hl
	pop	de
	pop	bc
flush_cursor_END:
	ld	a,16
	ld	(cursor_timer),a

	pop	af
	ret
	
;===================================
; save_cursor
; 
; saves the current cursor
;===================================
save_cursor:

	ld	a,(cursorstack_depth)
	inc	a
	ld	(cursorstack_depth),a
;	call	cursor_debug

	ld	hl,(cursor_sp)
	
	ld	a,(cursor_x)
	ld	(hl),a
	inc	hl

	ld	a,(cursor_y)
	ld	(hl),a
	inc	hl

	ld	a,(cursor_type)
	ld	(hl),a
	inc	hl

	ld	a,(cursor_column)
	ld	(hl),a
	inc	hl

	ld	a,(cursor_input)
	ld	(hl),a
	inc	hl

	ld	a,(editsubmode)
	ld	(hl),a
	inc	hl
	
	ld	(cursor_sp),hl
	
	ret



;===================================
; restore_cursor
; 
; restores the saved cursor
;===================================
restore_cursor:

	ld	a,(cursorstack_depth)
	dec	a
	ld	(cursorstack_depth),a
;	call	cursor_debug


	call	flush_cursor
	
	ld	hl,(cursor_sp)
	dec	hl
	ld	a,(hl)
	ld	(editsubmode),a
	
	dec	hl
	ld	a,(hl)	
	ld	(cursor_input),a
	
	dec	hl
	ld	a,(hl)	
	ld	(cursor_column),a	
		
	dec	hl
	ld	a,(hl)	
	ld	(cursor_type),a
	
	dec	hl
	ld	a,(hl)
	ld	(cursor_y),a
	
	dec	hl
	ld	a,(hl)	
	ld	(cursor_x),a

	
	ld	(cursor_sp),hl
	
	ret	

cursorstack_init:
	xor	a
	ld	(cursorstack_depth),a
	ld	hl,cursor_stack
	ld	(cursor_sp),hl	
	ret
	
;cursor_debug:
;	ld	de,_CT_LABEL+6
;	ld	a,(cursorstack_depth)
;	call	draw_hex2
;	
;	ld	hl,(80*1)+44+4
;	ld	de,_CT_LABEL
;	call	draw_label
;
;	ret
;
;_CT_LABEL:
;	db	"STACK:00",0
cursorstack_depth:	
	db	0