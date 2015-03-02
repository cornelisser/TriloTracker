;===========================================================
; --- draw_orderbox
; Display the order area.  Without actual values 
; 
;===========================================================
draw_orderbox:
	; Track seq box
	ld	hl,(80*1)+0
	ld	de,(9*256) + 8
	call	draw_box	
	ld	hl,(80*1)+1
	ld	de,_LABEL_TRACKSEQBOX
	ld	b,6	
	call	draw_label_fast
	ld	hl,0x0001
	ld	de,0x0808
	call	draw_colorbox
	ld	hl,0x0102
	ld	de,0x0707
	call	erase_colorbox	
;	ld	hl,0x4f03
;	ld	de,0x0106
;	call	draw_colorbox	
	
	;--- retrigger highlight position
	ld	a,(song_order_pos)
	dec	a
	ld	(song_order_pos_old),a
	
	call	update_orderbox		;build_order_list
	
	
	ret
		
_LABEL_TRACKSEQBOX:
	db	"orDer:"
	
;===========================================================
; --- updates_orderbox
; Display the order area.  Without actual values 
; 
;===========================================================
update_orderbox:
	;--- Only update if needed.
	ld	a,(song_order_update)
	ld	b,a
	ld	a,(song_order_pos)
	cp	b
	ret	z
	ld	(song_order_update),a

;	call	build_order_list
	ld	hl,(80*2)+1
	ld	de,_LABEL_ORDER
	ld	b,7	
	call	draw_label_fast
	ld	hl,(80*3)+1
	ld	de,_LABEL_ORDER+7
	ld	b,7	
	call	draw_label_fast
	ld	hl,(80*4)+1
	ld	de,_LABEL_ORDER+14
	ld	b,7	
	call	draw_label_fast
	ld	hl,(80*5)+1
	ld	de,_LABEL_ORDER+21
	ld	b,7	
	call	draw_label_fast
	ld	hl,(80*6)+1
	ld	de,_LABEL_ORDER+28
	ld	b,7	
	call	draw_label_fast
	ld	hl,(80*7)+1
	ld	de,_LABEL_ORDER+35
	ld	b,7	
	call	draw_label_fast	
	ld	hl,(80*8)+1
	ld	de,_LABEL_ORDER+42
	ld	b,7	
	call	draw_label_fast	
	
	jp	build_order_list
;	ret	
	

	
;===========================================================
; --- process_key_orderbox
;
; 
; 
;===========================================================
_order_input_timer:	db	0

process_key_orderbox:
	ld	a,(song_order_pos)
	ld	c,a	

99:
	ld	a,(key)
	
	; - ESCAPE
;	cp	0x60	; [`]
;	jr.	z,77f
	cp	_ENTER
	jr.	z,77f
	cp	_ESC
	jr.	nz,0f
	; escape 
77:		xor	a
		ld	(editsubmode),a
		call	restore_cursor
		;call	reset_cursor_trackbox
		jr.	processkey_psgsampleeditor_END	
0:	
	; - INSERT POSITION
	cp	_INS
	jr.	nz,0f
	; insert entry 
		;--- Is there still room?
		ld	a,(song_order_len)
		cp	SONG_SEQSIZE
		jr.	z,processkey_psgsampleeditor_END

		
		;--- calc elements to move
		ld	b,a
		inc	a
		ld	(song_order_len),a

		;--- is control pressed?
		ld	a,(fkey)
		cp	_KEY_CTRL
		jr.	nz,1f
		ld	a,b			; point to the last postion
		ld	c,a

1:
		ld	hl,song_order+SONG_SEQSIZE-2	; point to order end
		ld	a,SONG_SEQSIZE-1			; number of elements to move
		sub	c
		ld	c,a
		ld	b,0
		ld	d,h
		ld	e,l
		inc	de
		
		;--- move them
		lddr
		
		; store new pattern number at new order position
		ld	b,(hl)
		inc	b
		
		ld	a,(song_order_pos)
		and	a
		jr.	nz,99f
		ld	b,0
99:		
		ld	a,(max_pattern)
		cp	b
		jr.	nc,99f		
		dec	b
99:		
		inc	hl
		ld	(hl),b
		
		;--- restart move?
		ld	a,(song_order_pos)
		ld	b,a
		ld	a,(song_order_loop)
		cp	b
		jr.	c,88f
		inc	a
		ld	(song_order_loop),a
		jr.	88f
		
0:
	; - DELETE
	cp	_DEL
	jr.	nz,0f
	; delete entry 
		ld	a,(song_order_len)
		dec	a
		jr.	z,processkey_psgsampleeditor_END
		
		;--- elements (pat#) to move
		ld	(song_order_len),a

		sub	c
		ld	b,a
		
		;--- do some extra work for last pattern deletion
		and	a
		jr.	nz,11f

		inc	b		; prevent 0xff loops
		; move current pat 1 up
		ld	a,(song_order_pos)
		dec	a
		ld	(song_order_pos),a
		;move cursor
		ld	a,(cursor_y)
		cp	2
		jr.	z,11f
		dec	a
		ld	(cursor_y),a
		
11:		
		ld	hl,song_order
		ld	a,c
		;inc	a
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
		ld	c,b
		ld	b,0
		ld	d,h
		ld	e,l
		inc	hl
		ldir

		;--- restart move?
		ld	a,(song_order_pos)
		inc	a
		ld	b,a
		ld	a,(song_order_loop)
		cp	b
		jr.	c,88f
		dec	a
		ld	(song_order_loop),a
		
		jr.	88f
		
	
0:


	cp	_KEY_RIGHT
	jr.	nz,0f
	;-- Increase pat#
		ld	hl,song_order
		ld	a,c
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
		ld	a,(hl)
		inc	a
		ld	b,a
		ld	a,(max_pattern)
		cp	b
		jr.	z,process_key_orderbox_END
		
		ld	(hl),b
		jr.	88f



0:
	cp	_KEY_LEFT
	jr.	nz,0f
	;-- Decrease pat#
		ld	hl,song_order
		ld	a,c
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
		ld	a,(hl)
		and	a
		jr.	z,process_key_orderbox_END
		
		dec	a
		ld	(hl),a
		jr.	88f

0:
	cp	_KEY_DOWN
	jr.	nz,0f
	;-- Move 1 pos down
		ld	a,(song_order_len)
		inc	c		
		cp	c
		jr.	z,process_key_orderbox_END
		ld	a,c
		ld	(song_order_pos),a
		ld	a,(cursor_y)
		cp	7	; check if we went out of screen
		jr.	z,88f
		inc	a
		ld	(cursor_y),a
		jr.	88f

88:
		ld	hl,song_order
		ld	a,(song_order_pos)
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
		ld 	a,(hl)
		ld	(song_pattern),a
		ld	a,255
		ld	(song_order_update),a
;		xor	a
;		ld	(song_pattern_offset),a
;		ld	(song_pattern_line),a
		call	update_patternbox
		call	update_trackbox
		call	update_orderbox
		jr.	process_key_orderbox_END
0:
	cp	_KEY_UP
	jr.	nz,0f
	;-- Move 1 pos up
		xor	a
		cp	c
		jr.	z,process_key_orderbox_END
		dec	c
		ld	a,c
		ld	(song_order_pos),a
		ld	a,(cursor_y)
		cp	2	; check if we went out of screen
		jr.	z,88b
		dec	a
		ld	(cursor_y),a		
		jr.	88b


0:
	; set loop pos
	cp	'r'
	jr.	z,2f
	cp	'R'
	jr.	nz,0f
2:
		ld	a,c
		ld	(song_order_loop),a
		jr.	88b
0:

;	;================================
;	; Input pattern nr.
;	;================================
;	cp	'0'
;	jr.	c,0f
;	cp	'9'+1
;	jr.	nc,0f
;		sub	48
;		ld	b,a
;		ld	a,(_order_input_timer)
;		and	a
;		jr.	z,77f
;		;--- High value
;			xor	a
;			ld	(_order_input_timer),a
;			ld	hl,song_order
;			ld	a,(menu_selection)
;			add	a,l
;			ld	l,a
;			jr.	nc,99f
;				inc	h
;99:						
;			ld	a,(hl)
;			and	a
;			jr.	z,88f
;			ld	c,a
;			xor	a
;99:
;			add	10
;			dec	c
;			jr.	nz,99b
;			
;88:			add	b
;			ld	(hl),a	
;			call	update_orderbox
;			jr.	process_key_orderbox_END		
;77:		;-- low value		
;			ld	a,32
;			ld	(_order_input_timer),a
;			ld	hl,song_order
;			ld	a,(menu_selection)
;			add	a,l
;			ld	l,a
;			jr.	nc,99f
;				inc	h
;99:						
;			ld	(hl),b
;			call	update_orderbox
;
;0:
;	;--- Decrease the timer
;	ld	a,(_order_input_timer)
;	and	a
;	jr.	z,99f
;		dec	a
;		ld	(_order_input_timer),a
;	ret




process_key_orderbox_END:
	xor	a
	ld	(_order_input_timer),a
	ret







;===========================================================
; --- reset_cursor_orderbox
;
; Reset the cursor to the top left of the orderbox.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_orderbox:
	call	flush_cursor
	ld	a,5
	ld	(cursor_x),a
	ld	a,3
	ld	(cursor_type),a		
	ld	a,(song_order_pos_old)
	add	2
	ld	(cursor_y),a
	ld	a,(song_order_pos)
	ld	(menu_selection),a	; Menu selection is used for order pos
	ret		
	
	
	
	
_LABEL_ORDER:
	db	"xxx_xxx"
	db	"xxx_xxx"
	db	"xxx_xxx"
	db	"xxx_xxx"
	db	"xxx_xxx"
	db	"xxx_xxx"
	db	"xxx_xxx"
_LABEL_ORDER_1:
	db	0x80
_LABEL_ORDER_2:
	db	0xbe
	
;===============================================
; 
; Build the order view in RAM.
;
;===============================================
build_order_list:
	;--- checks to keep cursor visisble
	ld	a,(song_order_offset)
	ld	b,a
	ld	a,(song_order_pos)
	cp	b
	jr.	nc,99f
	;---- cursor lower than offset
	;ld	b,a
	jr.	88f
99:
	;ld	c,a
	sub	b
	cp	6
	;ld	a,c
	jr.	c,77f
	;---- cursor higher than offset + 7
	add	b
	sub	5
	;ld	b,a

88:
	;ld	a,b
	ld	(song_order_offset),a
77:
	;--- Get the start of the orders in [HL]
	ld	a,(song_order_offset)
	ld	ixh,a
	dec	ixh
	ld	hl,song_order-1

	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	;-- init
	ld	de,_LABEL_ORDER
	ld	a,(song_order_loop)
	ld	c,a
	ld	b,0x07
	
	
_bol_loop:
	inc	ixh
	inc	hl
	ld	a,(song_order_len)
	dec	a
	cp	ixh
	jr.	c,_bol_empty
	ld	a,ixh
	push	bc	
	call	draw_decimal_3		
	pop	bc
	ld	a,ixh
	cp	c
	jr.	z,_bol_rst
	;--- no loop pos
	ld	a," "
	ld	(de),a
	jr.	1f
_bol_rst:
	ld	a,_LOOPSIGN
	ld	(de),a
	jr.	1f
_bol_empty:
	ld	a,7
	ld	ixl,a
	ld	a," "
_be_loop:	
	ld	(de),a
	inc	de
	dec	ixl
	jr.	nz,_be_loop
	jr.	2f		
1:
	inc	de
	ld	a,(hl)
	push	bc	
	call	draw_decimal_3		
	pop	bc
	
2:	djnz	_bol_loop

	;--- calculate the current order indicator
	ld	a,(song_order_pos_old)
	ld	c,a
	ld	a,(song_order_offset)
	ld	b,a
	ld	a,(song_order_pos)
	sub	b
	;--- only update if it is on a new line
	cp	c
	jr.	z,99f

	ld	(song_order_pos_old),a
	ex	af,af' ;'
	;--- clear the current order highlight
	ld	hl,0x0002
	ld	de,0x0807
	call	erase_colorbox
	
	;-- draw the highlight	
	ex	af,af'	;'
	add	2
	ld	l,a
	ld	h,1
	ld	de,0x0701
	call	draw_colorbox
99:
;	call	update_orderbox


;	;---- order position
;	ld	hl,80*2
;	ld	de,80
;	ld	a,(song_order_pos)
;	ld	b,a			; store current pos
;	; calculate step size dependant on the length/8
;	ld	a,(song_order_len)
;	rra	;/2
;	rra	;/4
;	rra	;/8
;	and	00011111b		; delete any carry flag bits
;	inc	a
;	ld	c,a
;_opi_loop:
;	cp	b
;	jp	nc,0f
;	add	hl,de
;	add	c
;	jp	_opi_loop
;	
;0:
;	ld	de,_LABEL_ORDER_2
;	ld	b,1
;	call	draw_label_fast
	ret
	
	
	
