;===========================================================
; --- draw_instrumentbox
; Display the instrument area.  Without actual values 
; 
;===========================================================
draw_instrumentbox:
	; inst box
	ld	hl,(80*1)+56
	ld	de,(24*256) + 8
	call	draw_box	
	ld	hl,(80*1)+57
	ld	de,_LABEL_TRACKINSBOX
	ld	b,12	
	call	draw_label_fast
	ld	hl,(80*1)+57+17
	ld	de,_LABEL_TRACKCINSBOX
	ld	b,4	
	call	draw_label_fast

	ld	hl,0x3801
	ld	de,0x1808
	call	draw_colorbox
	ld	hl,0x3902
	ld	de,0x1607
	call	erase_colorbox
	ld	hl,0x4b01
	ld	de,0x0201
	call	erase_colorbox


	call	build_instrument_list

	
	ret
		
_LABEL_TRACKINSBOX:
	db	"Instruments:"
_LABEL_TRACKCINSBOX:
	db	"( x)"

;===========================================================
; --- update_instrumentbox
;
; Display the pattern area values.
; 
;===========================================================
update_instrumentbox:

	ld	de,_LABEL_TRACKCINSBOX+2
	ld	a,(song_active_instrument)
	call	draw_fake_hex_sp
	
	ld	hl,(80*1)+57+17+2
	ld	de,_LABEL_TRACKCINSBOX+2
	ld	b,1
	call	draw_label_fast

	ld	hl,(80*2)+58
	ld	de,_LABEL_INSTRUMENTS
	ld	b,20	
	call	draw_label_fast
	ld	hl,(80*3)+58
	ld	de,_LABEL_INSTRUMENTS+20
	ld	b,20	
	call	draw_label_fast
	ld	hl,(80*4)+58
	ld	de,_LABEL_INSTRUMENTS+40
	ld	b,20	
	call	draw_label_fast
	ld	hl,(80*5)+58
	ld	de,_LABEL_INSTRUMENTS+60
	ld	b,20	
	call	draw_label_fast
	ld	hl,(80*6)+58
	ld	de,_LABEL_INSTRUMENTS+80
	ld	b,20	
	call	draw_label_fast
	ld	hl,(80*7)+58
	ld	de,_LABEL_INSTRUMENTS+100
	ld	b,20	
	call	draw_label_fast
	ld	hl,(80*8)+58
	ld	de,_LABEL_INSTRUMENTS+120
	ld	b,20	
	call	draw_label_fast
	
	ret


_LABEL_INSTRUMENTS:
	db	"x. ________________ "
	db	"x. ________________ "
	db	"x. ________________ "
	db	"x. ________________ "
	db	"x. ________________ "
	db	"x. ________________ "
	db	"x. ________________ "
	
	
;===============================================
; 
; Build the instruments view in RAM.
;
;===============================================
build_instrument_list:
	;--- Get the start of the instruments in [HL]
	ld	a,(song_instrument_offset)
	ld	l,a
	xor	a		; [a] to catch carry bit
	sla	l		; offset  *16
	sla	l
	sla	l
	sla	l
	adc	a,0		; only the 4th shift can cause carry
	ld	h,a
	ld	de,song_instrument_list-16
	add	hl,de
	
	;-- init
	ld	de,_LABEL_INSTRUMENTS
	ld	a,7
	ld	ixh,a
	
	
_bil_loop:
	ld	a,(song_instrument_offset)
	add	a,7
	sub	ixh
	
	call	draw_fake_hex_sp
	inc	de
	inc	de
	ld	bc,16
	ldir
	inc	de
	
	
	dec	ixh
	jr.	nz,_bil_loop

	;--- clear the current instrument highlight
	ld	hl,0x3902
	ld	de,0x1607
	call	erase_colorbox
	
	;-- draw the highlight	
	ld	a,(song_instrument_offset)
	ld	b,a
	ld	a,(song_active_instrument)
	;dec	a
	sub	b
	cp	8		; if >=8 then the current instrument is not visible
	jr.	nc,99f
	add	2
	ld	l,a
	ld	h,58
	ld	de,0x1401
	call	draw_colorbox
99:
	call	update_instrumentbox

	ret		


;===========================================================
; --- reset_cursor_instrumentbox
;
; Reset the cursor to the top left of the instrumentbox.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_instrumentbox:
	call	flush_cursor
;	ld	a,2
;	ld	(cursor_y),a
	ld	a,2
	ld	(cursor_type),a		
	ld	a,58	
	ld	(cursor_x),a
	
	ld	a,(song_instrument_offset)
	ld	b,a
	ld	a,(song_active_instrument)
	ld	c,a
	cp	b	
	jr.	c,1f		; is current instrument < offset

	ld	a,b
	add	6
	cp	c
	jr.	c,2f		;  current instrument > offset +6

3:	
	ld	a,c
	sub	b
	add	2
	ld	(cursor_y),a
	jr.	build_instrument_list	
	
;	instrument < offset	
1:	ld	(song_instrument_offset),a
	ld	a,2
	ld	(cursor_y),a
	jr.	build_instrument_list
	
;	instrument-7 > offset
2:	
	ld	a,c
	sub	6
	ld	(song_instrument_offset),a
	ld	a,2
	ld	(cursor_y),a
	jr.	build_instrument_list
	
	
process_key_instrumentbox:
	ld	a,(song_instrument_offset)
	ld	c,a
	ld	a,(key)

	;--- Check if edit is ended.
	cp	_ESC
	jr.	nz,0f
;		ld	a,0
;		ld	(editsubmode),a

		call	restore_cursor

;		;call	reset_cursor_instrumentbox
		jr.	process_key_instrumentbox_END
0:	
	;--- Key_left - prev 7 instruments	
	cp	_KEY_LEFT
	jr.	nz,0f
		ld	a,c
		cp	0		
		jr.	z,process_key_instrumentbox_END
		cp	7
		jr.	nc,88f
		;--- less than 7 to go
		xor	a
		jr.	2f
		;--- more than 7 to go		
88:		sub	6
		dec	a
2:		
		ld	(song_instrument_offset),a
		call	build_instrument_list
		jr.	process_key_instrumentbox_END	
0:
	;--- Key_right - next 7 instruments	
	cp	_KEY_RIGHT
	jr.	nz,0f
		ld	a,c
		cp	32-7		
		jr.	z,process_key_instrumentbox_END
		cp	32-13
		jr.	c,88f
		;--- less than 7 to go
		ld	a,32-7
		jr.	2b
		;--- more than 7 to go		
88:		add	8
		dec	a
		jr.	2b

0:	
	;--- Key_down - next instrument	
	cp	_KEY_DOWN
	jr.	nz,0f
		ld	a,(cursor_y)
		cp	8
		jr.	nc,_ioffup
		;--- increase the cursor
		inc	a
		ld	(cursor_y),a
		call	flush_cursor
		call	build_instrument_list
		jr.	process_key_instrumentbox_END
_ioffup:
		ld	a,c
		cp	32-7
		jr.	z,process_key_instrumentbox_END
		inc	a
		jr.	2b
0:
	;--- Key_up - prev instrument	
	cp	_KEY_UP
	jr.	nz,0f
		ld	a,(cursor_y)
		cp	3
		jr.	c,_ioffdown
		;--- increase the cursor
		dec	a
		ld	(cursor_y),a
		call	flush_cursor
		call	build_instrument_list
		jr.	process_key_instrumentbox_END
_ioffdown:
		ld	a,c
		dec	a
		cp	255
		jr.	z,process_key_instrumentbox_END
		jr.	2b
0:
	;--- Select instrument	
	cp	_SPACE
	jr.	z,1f
	cp	_ENTER
	jr.	nz,0f	
1:	
		ld	a,(cursor_y)
		dec	a
		dec	a

		add	c
		ld	(song_active_instrument),a
		ld	(tmp_cur_instrument),a
		and	a
		jr.	z,99f
		ld	(song_cur_instrument),a
99:		call	build_instrument_list
		ld	a,0
		ld	(editsubmode),a
		
		call	restore_cursor
;		;call	reset_cursor_instrumentbox
		jr.	process_key_instrumentbox_END
	
0:	
	;--- Check if the key pressed is in the range
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	_ifound
99:	
	cp	'a'
	jr.	c,99f
	cp	'v'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	_ifound
99:	
	cp	'A'
	jr.	c,91f
	cp	'V'+1
	jr.	nc,91f
	sub	'A'-10
	
_ifound:	
		ld	b,a
		ld	(song_active_instrument),a
		ld	(tmp_cur_instrument),a
		and	a
		jr.	z,99f				; only set instrument if >0		
		ld	(song_cur_instrument),a
		
		

99:		
		cp	c
		jp	c,1f	; instrument < offset?
		sub	c
		cp	7	
		jp	nc,99f	; not visible now
		ld	a,c		; vissible not change offset
		jp	1f
99:		
		ld	a,b
		cp	$1a
		jp	c,1f	; instrument < 'P'
		ld	a,$19
	
1:		; set the offset
		ld	(song_instrument_offset),a
		;call	flush_cursor
		ld	a,0
		ld	(editsubmode),a

		call	restore_cursor

		call	build_instrument_list
		jr.	process_key_instrumentbox_END	
91:
0:





process_key_instrumentbox_END:

	ld	a,(editsubmode)
	and	a
	ret	nz

;	ld 	a,(song_cur_instrument)
;	and	a
;	jr.	nz,99f
;	inc	a
;	ld	(song_cur_instrument),a
;99:
	ld	a,(editmode)
	cp	1		; 1= instrument
	ret	nz	

		;--- if  mode is instrument editor 
;	ld	a,(tmp_cur_instrument)
;	and	a
;	jr.	nz,99f
;
;	;-- avoid setting instrument 0 in editor.
;	inc	a
;	ld	(song_cur_instrument),a
;	ld	(tmp_cur_instrument),a

;99:	
	call	update_psgsamplebox
	call	update_instrumentbox
;	call	flush_cursor
;	jr.	reset_cursor_psgsamplebox

	ret
