
_SCCWAVE_TEXT:
	db	"                                "
_SCC_SAMPLESTRING:
	db	"XXxx xx xx xx"
_sccwave_pnt:
	dw	0
	
	
_scc_waveform_col: 	db	0	;column we are editing
_scc_waveform_val: 	db  	0	; value at the column
;===========================================================
; --- update_sccsampleavebox
; Display the values
; 
;===========================================================
update_sccwave:
	; show the actual values
	ld	bc,	0x0800	; b = 16, c = 0

	; -- Init and store the display pos in PNT
	ld	hl,(80*17)+28+5
	ld	(_sccwave_pnt),hl
	;--- calculate the current wave pos in RAM
	ld	a,(instrument_waveform)	; get the current waveform
	ld	hl,_WAVESSCC
	and	a
	jr.	z,99f
	
	ld	de,32
0:
	add	hl,de
	dec	a
	jr.	nz,0b

99:

_uss_lineloop:	
	;each line
	ld	de,_SCC_SAMPLESTRING		
	
	; draw the line number
	ld	a,c
	call	draw_hex2			; draw hex line number

	ld	a,4
	add	c
	ld	c,a	
	push	bc				; store line+len
	
;	inc	de
	
	ld	a,(hl)			; value 1
	call	draw_hex2
	inc	hl
	inc	de
	
	ld	a,(hl)			; value 2
	call	draw_hex2
	inc	hl
	inc	de
	
	ld	a,(hl)			; value 1
	call	draw_hex2
	inc	hl
	inc	de
	
	ld	a,(hl)			; value 2
	call	draw_hex2
	inc	hl
	
	
	;--- show data
	push	hl			; store data pointer
	ld	hl,(_sccwave_pnt)	; get pnt pointer
	ld	de,80
	add	hl,de			; store new position
	ld	(_sccwave_pnt),hl
	
	ld	de,_SCC_SAMPLESTRING	; draw the string
	ld	b,13
	call	draw_label_fast	
	
	pop	hl

	pop	bc	
	djnz	_uss_lineloop
	
	; show the waveform visual
	ld	hl,(80*10)+47-80
	ld	(_sccwave_pnt),hl


	;--- calculate the current wave pos in RAM
	ld	a,(instrument_waveform)	; get the current waveform
	ld	hl,_WAVESSCC
	and	a
	jr.	z,99f
	
	ld	bc,32
0:
	add	hl,bc
	dec	a
	jr.	nz,0b

99:
	ld	c,112			;
_uswb_nextline
	push 	hl				; --- save wave start later reuse
	ld	b,31			; process 32 lines.
	ld	de,_SCCWAVE_TEXT	 
_uswb_loop:
	ld	a,(hl)
	bit	7,a
	jr.	nz,_uswb_negval

	;--- Value is > 128
_uswb_posval:
	bit	7,c
	jr.	z,0f			;--- we are in pos area
	;--- write 0 value
		ld	a,32
		jr.	_uswb_writeval	
0:	;--- value is pos
	;--- Check if value is bigger than c
	cp	c
	jr.	nc,0f
	;--- write 0 value	< value is smaller
		ld	a,32
		jr.	_uswb_writeval		
0:	;--- value is visible
	sub	16
	jp	p,2f
		; turned negative.
		add	16
		jr.	0f		
2:
	cp	c		; is the value a solid block or a partial block?
	jr.	c,0f
	or	15	
0:	
	and	0xf
	add	192
	jr.	_uswb_writeval	
	
	
	;--- Value is <= 128
_uswb_negval:
	bit	7,c
	jr.	nz,0f			;--- we are in neg area
	;--- write 0 value
		ld	a,32
		jr.	_uswb_writeval	
0:	;--- value is neg
	;--- Check if value is bigger than c
	sub	16
	cp	c
	jr.	c,0f
	;--- write 0 value	< value is smaller
		ld	a,32
		jr.	_uswb_writeval		
0:	;--- value is visible
	add	16
	jr.	nc,2f
		; turned negative.
		sub	16
		jr.	0f		
2:
	cp	c		; is the value a solid block or a partial block?
	jr.	nc,0f
	and	0	
0:	
	and	0xf
	add	192+15
	jr.	_uswb_writeval	

_uswb_writeval:
	;inc	a ; debug


	ld	(de),a
	inc	de
	inc	hl

	dec	b
	jp	p,_uswb_loop

	;line is build
	push	bc
	
	ld	hl,(_sccwave_pnt)
	ld	bc,80	
	add	hl,bc
	ld	(_sccwave_pnt),hl
	
	ld	de,_SCCWAVE_TEXT
	ld	b,32
	call	draw_label_fast

	pop	bc
	
	pop	hl

	ld	a,c
	sub	16
	ld	c,a
	cp	112
	jr.	nz,_uswb_nextline
	ret


;--- Translate column to cursor pos
hex_update_cursor:
	ld	(_scc_waveform_col),a
	call	flush_cursor
	ld	b,a
	;--- x pos
	and	$03
	ld	c,a
	add	a	; *2
	add	c	; *3
	add	35
	ld	(cursor_x),a
	;--- y pos
	srl	b	; div 2
	srl	b	; div 4
	ld	a,18
	add	b
	ld	(cursor_y),a

	xor	a
	ld	(_scc_waveform_val),a
	ret


;===========================================================
; --- process_key_sccwavebox
;
; Process the input for the scc sample. 
; 
; 
;===========================================================
process_key_sccwavebox_hex:
	ld	a,(key)
	and	a
	ret	z

	cp	_ESC
	jr.	nz,0f
		jr.	restore_cursor
0:
	cp	_KEY_LEFT
	jr.	nz,0f
		ld	a,(_scc_waveform_col)
		and	a
		jr.	nz,99f
		;-- wrap around
		ld	a,32		
99:		
		dec	a
		jr.	hex_update_cursor
0:
	cp	_KEY_RIGHT
	jr.	nz,0f
		ld	a,(_scc_waveform_col)
		cp	31
		jr.	c,99f
		;--- wrap around
		ld	a,255
99:
		inc	a
		jr.	hex_update_cursor
0:
	cp	_KEY_UP
	jr.	nz,0f
		ld	a,(_scc_waveform_col)
		cp	4
		ret	c
		sub	4
		jr.	hex_update_cursor
0:
	cp	_KEY_DOWN
	jr.	nz,0f
		ld	a,(_scc_waveform_col)
		cp	28
		ret	nc
		add	4
		jr.	hex_update_cursor
0:
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	22f
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	22f
99:	
	cp	'A'
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
;	ld	d,a
22:	
	ld	d,a
	ld	a,(_scc_waveform_val)
	sla	a
	sla	a
	sla	a
	sla	a
	or	d
	ld	(_scc_waveform_val),a
	call	update_waveform_val
0:
	ret

;===========================================================
; --- process_key_sccwavebox
;
; Process the input for the scc sample. 
; 
; 
;===========================================================
process_key_sccwavebox_edit:
	
	ld	a,(key)
	and	a
	ret	z

	cp	_ESC
	jr.	nz,0f
	
		jr.	restore_cursor

0:
	cp	_KEY_LEFT
	jr.	nz,0f
	;---	move 1 column to the left	
		ld	a,(_scc_waveform_col)
		and	a
		jr.	z,process_key_sccwavebox_edit_END
		dec	a
		ld	(_scc_waveform_col),a
		call	flush_cursor
		ld	a,(cursor_x)
		dec	a
		ld	(cursor_x),a
		jr.	get_waveform_val
		
0:	
	cp	_KEY_RIGHT
	jr.	nz,0f
	;---	move 1 column to the right	
		ld	a,(_scc_waveform_col)
		cp	31
		jr.	nc,process_key_sccwavebox_edit_END
		inc	a
		ld	(_scc_waveform_col),a
		call	flush_cursor
		ld	a,(cursor_x)
		inc	a
		ld	(cursor_x),a
		jr.	get_waveform_val
0:	
	cp	_KEY_UP
	jr.	nz,0f
	;---	increase value by 1
		ld	b,1
		ld	a,(skey)
		cp	1
		jr.	z,99f
		ld	b,8
99:		ld	a,(_scc_waveform_val)
	;	cp	0x7f
	;	jr.	z,process_key_sccwavebox_edit_END ; max reached
		; value is still positive
		add	a,b
		
		jr.	update_waveform_val
	
0:	
	cp	_KEY_DOWN
	jr.	nz,0f
	;---	decrease value by 1
		ld	b,1
		ld	a,(skey)
		cp	1
		jr.	z,99f
		ld	b,8
99:		ld	a,(_scc_waveform_val)
	;	cp	0x7f
	;	jr.	z,process_key_sccwavebox_edit_END ; max reached
		; value is still positive
		sub	a,b
		jr.	update_waveform_val
	
0:

	;--- check for keyjazz
	ld	b,a
	ld	a,(keyjazz)
	and	a
	jr.	nz,process_key_keyjazz	
	ld	a,b



	ret

process_key_sccwavebox_edit_END:
	ret


update_waveform_val:
	ld	(_scc_waveform_val),a
	;show the column value
	ld	a,(instrument_waveform)
	ld	h,0
	ld	l,a
	add	hl,hl		;2
	add	hl,hl		;4
	add	hl,hl		;8
	add	hl,hl		;16
	add	hl,hl		;32
	ld	bc,_WAVESSCC
	add	hl,bc
	ld	a,(_scc_waveform_col)
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:	
	ld	a,(_scc_waveform_val)
	ld	(hl),a
	call	update_sccwave
	ret


get_waveform_val:
	ld	a,(instrument_waveform)
	ld	h,0
	ld	l,a
	add	hl,hl		;2
	add	hl,hl		;4
	add	hl,hl		;8
	add	hl,hl		;16
	add	hl,hl		;32
	ld	bc,_WAVESSCC
	add	hl,bc
	ld	a,(_scc_waveform_col)
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:	
	ld	a,(hl)
	ld	(_scc_waveform_val),a
	call	update_sccwave
	ret

