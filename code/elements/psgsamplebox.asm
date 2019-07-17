;===========================================================
; --- draw_samplebox
; Display the  area.  Without actual values 
; 
;===========================================================
draw_psgsamplebox:

	;--- Display the keyjazz chip
	ld	hl,_LABEL_keyjazz
	ld	a,(keyjazz_chip)


		dec	a
		jr.	nz,44f
		;-- psg
		ld	(hl),160
		inc	hl
		ld	(hl),161
		jr.	99f
44:
		dec	a
		jr.	nz,44f	
		;-- scc
		ld	(hl),162
		inc	hl
		ld	(hl),163	
		jr.	99f
		
44:
		;-- psg+scc
		ld	(hl),158
		inc	hl
		ld	(hl),159
		jr.	99f

99:

	; box around number, length, restart etc
	ld	hl,(80*6)+8
	ld	de,(49*256) + 3
	call	draw_box
	
	; box around macro lines
	ld	hl,(80*9)+0
	ld	de,(31*256) + 17
	call	draw_box	
	
	;box around waveform
	ld	hl,(80*9)+32
	ld	de,(48*256) + 17
	call	draw_box	
	;box around waveform data
	ld	hl,(80*17)+32
	ld	de,(15*256) + 9
	call	draw_box	


	

	ld	hl,(80*6)+1+8
	ld	de,_LABEL_SAMPLEBOX
	call	draw_label
	
	ld	hl,(80*7)+2+8
	ld	de,_LABEL_SAMPLETEXT
	call	draw_label
	ld	hl,(80*8)+2+8
	ld	de,_LABEL_SAMPLETEXT2
	call	draw_label


	ld	hl,(80*9)+1
	ld	de,_LABEL_SAMPPLEMACRO
	call	draw_label


	ld	hl,(80*9)+1+28+4
	ld	de,_LABEL_SAMPPLEFORM
	call	draw_label


	ld	hl,0x0806
	ld	de,0x3103	
	call	draw_colorbox	
	;ld	hl,0x0a08
	;ld	de,0x0501	
	;call	erase_colorbox	
	ld	hl,0x0f08
	ld	de,0x0401	
	call	erase_colorbox		
	ld	hl,0x1408
	ld	de,0x0401	
	call	erase_colorbox
	ld	hl,0x1908
	ld	de,0x0401	
	call	erase_colorbox

	ld	hl,0x1e08
	ld	de,0x1001	
	call	erase_colorbox
	ld	hl,0x2f08
	ld	de,0x0401	
	call	erase_colorbox
	ld	hl,0x3408
	ld	de,0x0401	
	call	erase_colorbox

	; under the info top area
	ld	hl,0x0009
	ld	de,0x5012	
	call	draw_colorbox

	ld	hl,0x010a
	ld	de,0x0110	
	call	erase_colorbox	

	; macro data
	ld	hl,0x040a
	ld	de,0x1a10	
	call	erase_colorbox	

	; hex wave values
	ld	hl,0x2312
	ld	de,0x0b08	
	call	erase_colorbox
	

	; decimal wave values
;	ld	hl,0x250a
;	ld	de,0x0810	
;	call	erase_colorbox
	
	;wavearea 
	ld	hl,0x2f0a
	ld	de,0x2010	
	call	erase_colorbox
	
	ret
	
_LABEL_SAMPLEBOX:
	db	"instrument edit:",0
_LABEL_SAMPPLEMACRO:
	db	"Macro:",0
_LABEL_SAMPPLEFORM:
	db	"waveForm:",0
;_LABEL_SAMPLEBARS:
;	db	"vol",0
_LABEL_SAMPLETEXT:
	db	"Ins: Len: Rst: Wav: Description:     Oct: Tst:",0
_LABEL_SAMPLETEXT2:	
	db	_ARROWLEFT," x",_ARROWRIGHT,32
	db	_ARROWLEFT,"xx",_ARROWRIGHT,32
	db	_ARROWLEFT,"xx",_ARROWRIGHT,32
	db	_ARROWLEFT,"xx",_ARROWRIGHT
_LABEL_SAMPLETEXT2SUB:
	db	"                  "
	db	_ARROWLEFT,"xx",_ARROWRIGHT,32		
	db	_ARROWLEFT
_LABEL_keyjazz:
	db	"  ",_ARROWRIGHT,0
_PSG_SAMPLESTRING:
;	db	" xxTN _xxx _xx _x **************** ***** *****",0
	db	"          [ 000]        X****"

_ups_pntpos:	dw	0
;_ups_tone:		dw	0
;_ups_noise:		db	0
;_ups_volume:	db	0


_PSG_VOL0:	db  32, 32, 32, 32, 32
_PSG_VOL1:	db 247, 32, 32, 32, 32
_PSG_VOL2:	db 246, 32, 32, 32, 32
_PSG_VOL3:	db 245, 32, 32, 32, 32
_PSG_VOL4:	db 245,247, 32, 32, 32
_PSG_VOL5:	db 245,246, 32, 32, 32
_PSG_VOL6:	db 245,245, 32, 32, 32
_PSG_VOL7:	db 245,245,247, 32, 32
_PSG_VOL8:	db 245,245,246, 32, 32
_PSG_VOL9:	db 245,245,245, 32, 32
_PSG_VOLA:	db 245,245,245,247, 32
_PSG_VOLB:	db 245,245,245,246, 32
_PSG_VOLC:	db 245,245,245,245, 32
_PSG_VOLD:	db 245,245,245,245,247
_PSG_VOLE:	db 245,245,245,245,246
_PSG_VOLF:	db 245,245,245,245,245
;===========================================================
; --- update_psgsamplebox
; Display the values
; 
;===========================================================
update_psgsamplebox:
	;--- Make sure the cursor is inside the macro
	ld	a,(instrument_len)
	ld	b,a
;	ld	a,(instrument_macro_offset)
;	ld	c,a
	ld	a,(instrument_line)
;	add	c
	cp	b
	jr.	c,99f
	call	reset_cursor_psgsamplebox	
99:
	;--- Get the current sample
	ld	a,(instrument_macro_offset)
	ld	c,a			; contains the line#
	ld	b,16		
	; add offset here somewhere
	
	
	; -- Init and store the display pos in PNT
	ld	hl,(80*9)+1			; start position
	ld	(_ups_pntpos),hl	
	
	
	;--- Calculate the position in RAM of current sample	
	call	_get_instrument_start
	
	ld	a,(hl)
	ld	(instrument_len),a
	inc	hl
	ld	a,(hl)
	ld	(instrument_loop),a
	inc	hl
	ld	a,(hl)
	ld	(instrument_waveform),a
	inc	hl
	
	;--- start at offset
	ld	a,c
	and	a
	jr.	z,4f
	ld	de,4
3:
	add	hl,de
	dec	a
	jr.	nz,3b	
	
4:	
	
	
_ups_lineloop:	
	;each line
	ld	de,_PSG_SAMPLESTRING	
	
	;	check if we are at the end.
	ld	a,(instrument_len)
	dec	a
	cp	c
	jr.	nc,0f
	; --- YES draw empty line
		inc	c				; increase line number
		push	bc				; store line+len	
		ld	a," "
		ld	b,23+6
10:		ld	(de),a
		inc	de
		djnz	10b
		jr.	55f
	;-- YES draw data!!!
0:	
	;--- Check if we are at loop pos
	ld	a,(instrument_loop)
	cp	c
	jr.	c,2f
	jr.	nz,1f
	ld	a,_LOOPSIGN
	jr.	3f
	
1:	ld	a," "
	jr.	3f	
2:	;--- looping area
	ld	a,191
3:	ld	(de),a
	inc	de
	
	; draw the line number
	ld	a,c
	call	draw_hex2			; draw hex line number

	inc	c				; increase line number
	push	bc				; store line+len

	; --- continue
	; get info bytes
	ld	b,(hl)			; store byte2 in b
	inc	hl
	ld	c,(hl)			; store byte3 in c
	inc	hl
	
	;--- tone indicator
	ld	a,_TONE_ON_SIGN
	bit	7,c				; 1 = Tone on.
	jr.	nz,1f	
	dec	a
1:
	ld	(de),a
	inc	de
	
	;--- noise indicator
	ld	a,_NOISE_ON_SIGN
	bit	7,b				; 1 = Noise on.
	jr.	nz,1f	
	dec	a
1:
	ld	(de),a
	inc	de	
	inc	de

	;---- tone deviation
	ld	a,"+";
1:	;- acc
	bit	6,c
	jr.	z,99f			; 0 = add
	;--- min
	ld	a,"-"			; 1 = subtract
99:	;--- add
	ld	(de),a	
	inc	de

	; the tone deviation values	
	ld	a,(hl)
	ex	af,af'	;'
	inc	hl
	ld	a,(hl)
	inc	hl

	call	draw_hex
	ex	af,af'		;'
	call	draw_hex2

	; the tone accumulation (for John)
	inc	de
	ld	a,"["
	ld	(de),a

	inc	de
	inc	de
	inc	de
	inc	de
	ld	a,"]"
	ld	(de),a
	inc	de
	inc	de

	; noise deviation
	ld	a,"_";151
	bit	6,b
	jr.	z,99f
	;-not base
	ld	a,"-"		;	add	a,2
0:
	bit	5,b
	jr.	nz,99f
	;- add
	ld	a,"+"		;	inc	a
99:	

	ld	(de),a
	inc	de

	ld	a,b
	and	0x1f
	call	draw_hex2

	inc	de
	
	;--- Volume	
	bit	5,c
	jr.	nz,0f		; 1= relative, 0=absolute
	;- base
	ld	a,"_"
	jr.	1f
0:
	bit	4,c
	jr.	nz,99f	; 0 = add, 1=subtract

	;- add
	ld	a,"+"
	jr.	1f
99:	;- sub			
	ld	a,"-"
1:
	ld	(de),a
	inc	de

	ld	a,c
	and	0x0f
	call	draw_hex

	ld	a,c
	and	0x0f

	inc	de
	; volume bar
	push	hl
	ld	hl,_PSG_VOL0
	ld	bc,5
	and	0x0f
	jr.	z,1f
0:
	add	hl,bc
	dec	a
	jr.	nz,0b
1:	
	ld	bc,5
	ldir		
	pop hl	

55:	; end of line making,,,,,
	push	hl			; store data pointer
	ld	hl,(_ups_pntpos)	; get pnt pointer
	ld	de,80
	add	hl,de			; store new position
	ld	(_ups_pntpos),hl
	

	ld	de,_PSG_SAMPLESTRING	; draw the string
	ld	b,23+6
	call	draw_label_fast	
	
	pop	hl
	pop	bc	
	
	dec	b
	jr.	nz,_ups_lineloop


	ld	de,_LABEL_SAMPLETEXT2+2
	ld	a,(song_cur_instrument)
	call	draw_fake_hex_sp

	ld	de,_LABEL_SAMPLETEXT2+5+1
	ld	a,(instrument_len)
	call	draw_decimal
	
	ld	de,_LABEL_SAMPLETEXT2+11
	ld	a,(instrument_loop)
	call	draw_decimal
		
	ld	de,_LABEL_SAMPLETEXT2+16
	ld	a,(instrument_waveform)
	call	draw_decimal		
	
	ld	de,_LABEL_SAMPLETEXT2+16+22
	ld	a,(song_octave)
	call	draw_decimal

	;--- set the instrument name
	ld	a,(song_cur_instrument)
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
	ld	bc,16
	ld	de,_LABEL_SAMPLETEXT2SUB+1
	ldir


	ld	hl,(80*8)+2+8+1
	ld	de,_LABEL_SAMPLETEXT2+1
	ld	b,25+13+6
	call	draw_label_fast


	call	update_tonecum
	call	update_sccwave


	ret


update_tonecum:
	; -- Init and store the display pos in PNT
	ld	hl,(80*9)+13			; start position
	ld	(_ups_pntpos),hl	



	;--- init the cummulative tone deviation
	ld	de,0
	;--- there is an offset. calculate what we don't show
	;--- Calculate the position in RAM of current sample	
	call	_get_instrument_start
	ld	a,(hl)
	dec	a
	ld	ixh,a
	ld	bc,4
	add	hl,bc		; now we point at deviation type byte
	
	ld	bc,0	
_upsb_loop:
	push	bc
	ld	bc,0
	ld	a,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ex	de,hl
	and	64
	jr.	z,_upsb_add
	;-- sub
	xor	a
	sbc	hl,bc
	jr.	44f
_upsb_add:
	add	hl,bc
	
44:	
	ex	de,hl
	inc	hl
	inc	hl
	pop	bc
	ld	a,(instrument_macro_offset)
	inc	c
	cp	c
	jr.	nc,3f		; skip display
	;--- display the value
	push	de
	push	hl
	push	bc
	ex	de,hl
	ld	de,_PSG_SAMPLESTRING+12
	ld	a,h
	call	draw_hex
	ld	a,l
	call	draw_hex2
	
	ld	hl,(_ups_pntpos)
	ld	bc,80
	add	hl,bc
	ld	(_ups_pntpos),hl
	ld	de,_PSG_SAMPLESTRING+12
	ld	b,3
	call	draw_label_fast

	pop	bc
	pop	hl
	pop	de
	inc	b	
3:	
;	inc	c
	ld	a,ixh
	cp	c
	ret	c

	ld	a,16
	cp	b
	jr.	nc,_upsb_loop

	ret

;--- Move macro data 1 line down (delete row)
; in: [A] is the line to move down/delete
;
; need to preserve [A]
_move_macrolinedown:
	push	af
	;-- set hl to start macro data of current instrument
	call	_get_instrument_start
	dec	hl
	dec 	hl
	;-- jump to line ( input)
	pop	bc
	push	bc
	inc	b
	ld	de,4
.loop:
	add	hl,de
	djnz	.loop

	;--- copy the data to next line
	ld	d,h	
	ld	e,l
	ld	a,4
	add	a,l
	ld	l,a
	jr.	nc,.skip
	inc	h
.skip:
	ldi
	ldi
	ldi
	ldi
	
	;--- restore and return 	
	pop	af
	ret
	
;--- Move macro data 1 line up (insert row)
; in: [A] is the line to move up
;
; need to preserve [A]
_move_macrolineup:
	push	af
	;-- set hl to start macro data of current instrument
	call	_get_instrument_start
	dec	hl
	dec 	hl
	;-- jump to line ( input)
	pop	bc
	push	bc
	inc	b
	ld	de,4
.loop:
	add	hl,de
	djnz	.loop

	;--- copy the data to next line
	ld	d,h	
	ld	e,l
	ld	a,4
	add	a,e
	ld	e,a
	jr.	nc,.skip
	inc	d
.skip:
	ldi
	ldi
	ldi
	ldi
	;--- restore and return 	
	pop	af
	ret
	
	


;--- Get instrument start
; return in HL that start of the instrument data
;
_get_instrument_start:
	push	bc
	ld	hl,instrument_macros
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,99f
	ld	bc,INSTRUMENT_SIZE
88:
	add	hl,bc
	dec	a
	jr.	nz,88b
99:
	pop	bc
	ret

;===========================================================
; --- process_key_psgsamplebox
;
; Process the input for the PSG sample. 
; 
; 
;===========================================================
process_key_psgsamplebox:
	
	ld	a,(key)
	and	a
	ret	z


	;--- INS key to insert macro line
	cp	_INS
	jr.	nz,0f
	ld	a,(instrument_line)
	cp	31			; check if we are at last line
	jr.	nc,process_key_psgsamplebox_END
	;--- increase len
	
	;--- get the location in RAM
	call	_get_instrument_start	
	;inc	hl
	ld	a,(hl)
	cp	32
	jp	nc,99f
	inc	a
	ld	(hl),a
	ld	(instrument_len),a
99:
	;--- move data 1 line down
	ld	a,(instrument_line)
	ld	ixh,a
	ld	a,30		; start from end to current line
.line_loop:
	call	_move_macrolineup
	and	a
	jp	z,88f
	dec	a
	cp	ixh
	jr.	nc,.line_loop
88:	
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END	

0:	
	;--- DEL key to delete macro line
	cp	_DEL
	jr.	nz,0f
	ld	a,(instrument_line)
	inc	a
	ld	b,a
	ld	a,(instrument_len)
	cp	b			; check if we are at last line
	jr.	nz,1f
	
	cp	1	
	jr.	z,process_key_psgsamplebox_END
	
	call	_get_instrument_start
	ld	a,(hl)
	dec	a
	ld	(hl),a
	dec	a
	ld	(instrument_line),a
	;-- restart move
	inc	hl		
	ld	b,a
	ld	a,(hl)
	and	a
	jp	z,99f
	cp	b
	jp	c,99f
	dec	(hl)
99:	
	;--- update screen
	call	flush_cursor
	ld	a,(cursor_y)
	dec	a
	ld	(cursor_y),a
	
	
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END	
	
	;--- decrease len
1:	
	;--- get the location in RAM
	call	_get_instrument_start	
	;inc	hl
	ld	a,(hl)
	cp	1
	jp	z,99f
	dec	a
	ld	(hl),a
	ld	(instrument_len),a

99:	
	;--- check for moving restart
	ld	b,(hl)
	inc	hl
	ld	a,(hl)
	cp	b
	jp	c,99f
	dec	b
	ld	(hl),b
99:
	;--- move data 1 line down
	ld	a,(instrument_line)
;	ld	ixh,a
;	ld	a,30		; start from end to current line
.line_loopdel:
	call	_move_macrolinedown
	inc	a
	cp	31
	jp	z,88f
	jr.	.line_loopdel
88:	
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END	
	
				
0:	
	;--- key left
	cp	_KEY_LEFT
	jr.	nz,0f
	; column left
	ld	hl,_COLTAB_PSGSAMPLE
	ld	a,(cursor_column)
	add	a
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h	
99:
	; check if we are at the end?
	dec	hl
	ld	a,(hl)
	cp	255
	jr.	z,process_key_psgsamplebox_END
	
	; get the displacement)
	ld	b,a
	call	flush_cursor
	ld	a,(cursor_x)
	sub	b
	ld	(cursor_x),a
	
	;set the new input type and cursor.
	dec	hl
	ld	a,(hl)
	ld	(cursor_input),a
	ld	hl,cursor_column
	dec	(hl)
	
	jr.	process_key_psgsamplebox_END			
0:		
	;--- key right
	cp	_KEY_RIGHT
	jr.	nz,0f
	; column right
_psgsamright:
	ld	hl,_COLTAB_PSGSAMPLE
	ld	a,(cursor_column)
	add	a
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h	
99:
	; check if we are at the end?
	inc	hl
	ld	a,(hl)
	cp	255
	jr.	z,44f
	
	; get the displacement)
	ld	b,a
	call	flush_cursor
	ld	a,(cursor_x)
	add	b
	ld	(cursor_x),a
	
	;set the new input type and cursor.
	inc	hl
	ld	a,(hl)
	ld	(cursor_input),a
	and	a
	ld	a,1
	jr.	nz,99f
	ld	a,3	
99:	
	ld	(cursor_type),a
	ld	hl,cursor_column
	inc	(hl)
44:	
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END			
0:		

	;--- key down
	cp	_KEY_DOWN
	jr.	nz,0f
	; row down
	ld	a,(instrument_len)
	ld	b,a
	ld	a,(instrument_line)
	inc	a
	cp	b
	jr.	nc,process_key_psgsamplebox_END
	
	ld	(instrument_line),a
	call	flush_cursor
	ld	a,(cursor_y)
	inc	a
	cp	26
	jr.	z,88f
	ld	(cursor_y),a
	jr.	77f			
88:	ld	a,(instrument_macro_offset)
	inc	a
	ld	(instrument_macro_offset),a
77:	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END		
99:	;-- see if we need to go to the next column
	ld	a,(instrument_line)	
	cp	16
	jr.	nz,88f
	ld	a,(cursor_y)
	sub	15
	ld	(cursor_y),a
	ld	a,(cursor_x)
	add 	40
	ld	(cursor_x),a
88:	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END	
	
0:		
	;--- key up
	cp	_KEY_UP
	jr.	nz,0f
	; row up
	ld	a,(instrument_line)
	and	a
	jr.	z,process_key_psgsamplebox_END
	
	dec	a
	ld	(instrument_line),a
	call	flush_cursor
	ld	a,(cursor_y)
	dec	a
	cp	9
	jr.	z,88f
	ld	(cursor_y),a
	jr.	77f			
88:	ld	a,(instrument_macro_offset)
	dec	a
	ld	(instrument_macro_offset),a
77:	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END						
99:	;-- see if we need to go to the next column
	ld	a,(instrument_line)	
	cp	15
	jr.	nz,88f
	ld	a,(cursor_y)
	add	15
	ld	(cursor_y),a
	ld	a,(cursor_x)
	sub 	40
	ld	(cursor_x),a
88:	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END		



0:
	;--- check for keyjazz
	ld	b,a
	ld	a,(keyjazz)
	and	a
	jr.	nz,process_key_keyjazz	
	ld	a,b	


	;--- Loop
	cp	"r"
	jr.	z,88f
	cp	"R"
	jr.	nz,0f
88:
	;--- get the location in RAM
	call	_get_instrument_start
	
	inc	hl

	ld	a,(instrument_line)
	ld	(hl),a
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END		
0:


	;===================
	;
	; T O N E ena/dis 
	;
	;===================
	;--- Check if the key pressed is t or T
	cp	"t"	
	jr.	z,1f
	cp	"T"
	jr.	nz,0f
	;--- get the location in RAM
1:	call	get_psgsample_location
	
	inc	hl		; 2nd byte has T
	ld	a,(hl)
	xor	128
	ld	(hl),a
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END

0:	
	;===================
	;
	; N O I S E ena/dis 
	;
	;===================
	;--- Check if the key pressed is n or N
	cp	"n"	
	jr.	z,1f
	cp	"N"
	jr.	nz,0f
	;--- get the location in RAM
1:	call	get_psgsample_location	
	
			; 1st byte has N
	ld	a,(hl)
	xor	128
	ld	(hl),a
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END



0:
	;=====================
	;
	; Addition deviation
	;
	;=====================
	cp	"+"
	jr.	z,1f
	cp	"-"
	jr.	z,1f
	cp	"_"
	jr.	z,1f
	cp	"="
	jr.	nz,0f
	ld	a,"_"

	; save the key
1:	ld	d,a
	call	get_psgsample_location
	;--- what are we editing
	ld	a,(cursor_input)
	cp	9
	jr.	c,_pkp_freq
	cp	13
	jr.	nz,_pkp_noise

	;-- set volume deviation
_pkp_vol:
	inc	hl
	ld	e,(hl)
;	ld	e,a
	
	ld	a,d
	cp	"+"
	jr.	nz,1f
	set	5,e
	res	4,e
	jr.	2f
1:
	cp	"-"
	jr.	nz,1f
	set	5,e
	set	4,e
	jr.	2f	

1:	
	res	5,e
2:
	ld	(hl),e

	jr.	update_psgsamplebox
	;end
	
	;-- set freq deviation	
_pkp_freq:
	inc	hl
	ld	e,(hl)
	
	ld	a,d
	cp	"-"
	jr.	z,1f
	res	6,e	
	jr.	3f
1:	
	set	6,e
	jr.	3f
		
	
	
_pkp_noise:
	ld	a,(hl)
	and	0x9f
	ld	e,a
	
	ld	a,d
	cp	"+"
	jr.	nz,1f
	ld	a,64
	jr.	2f
1:
	cp	"-"
	jr.	nz,1f
	ld	a,64+32
	jr.	2f	

3:
1:	xor	a
2:
	or	e
	ld	(hl),a

	jr.	update_psgsamplebox
	;end

0:
	;===================
	; INPUT is FREQ high
	;
	; FREQ	high
	;
	;===================
	;--- Check if we are in a envelope ena/dis column
	ld	b,a
	ld	a,(cursor_input)
	cp	4
	ld	a,b
	jr.	nz,0f
		
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

	; get the location in RAM
	call	get_psgsample_location
	inc	hl
	inc	hl
	ld	c,(hl)	
	inc	hl
	ld	b,(hl)		; bc now contains the freq value

	;--- set the new high value
	ld	a,b
	and	0xf0
	or	d	

44:	

	ld	(hl),a
	jr.	_psgsamright
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END		

	
0:

	;===================
	; INPUT is FREQ mid
	;
	; FREQ	mid
	;
	;===================
	;--- Check if we are in a envelope ena/dis column
	ld	b,a
	ld	a,(cursor_input)
	cp	5
	ld	a,b
	jr.	nz,0f
	
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
	
22:	
	rlca
	rlca
	rlca
	rlca
	ld	d,a	

	; get the location in RAM
	call	get_psgsample_location
	inc	hl
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)		; bc now contains the freq value
	
	;--- set the new high value
	ld	a,c
	and	0x0f
	or	d	

44:	
	dec	hl
	ld	(hl),a
	jr.	_psgsamright
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END			
	
	
	
0:
	;===================
	; INPUT is FREQ low
	;
	; FREQ	low
	;
	;===================
	;--- Check if we are in a envelope ena/dis column
	ld	b,a
	ld	a,(cursor_input)
	cp	6
	ld	a,b
	jr.	nz,0f
		
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
	ld	d,a
22:	
	ld	d,a	

	; get the location in RAM
	call	get_psgsample_location
	inc	hl
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)		; bc now contains the freq value
	
	;--- set the new high value
	ld	a,c
	and	0xf0
	or	d	

44:	
	dec	hl
	ld	(hl),a
;	jr.	_psgsamright
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END			
	
	
	

0:
	;===================
	; INPUT is Noise high
	;
	; N O I S E high
	;
	;===================
	;--- Check if we are in a noise high column
	ld	b,a
	ld	a,(cursor_input)
	cp	9
	ld	a,b
	jr.	nz,0f
	
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'1'+1	; smaller than 1?
	jr.	c,1f
	cp	'9'+1	; number but out of range?
	jr.	nc,0f
	ld	a,"1" ; 1 is max value for high byte
1:	sub	33
	and	0x10	
	ld	d,a	

	; get the location in RAM
	call	get_psgsample_location

	ld	a,(hl)
	and	0xef
	or	d

	ld	(hl),a
99:	jr.	_psgsamright
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END			
	
0:
	;===================
	; INPUT is NOISE low
	;
	; NOISE	low
	;
	;===================
	;--- Check if we are in a noiselow column
	ld	b,a
	ld	a,(cursor_input)
	cp	10
	ld	a,b
	jr.	nz,0f
		
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

	; get the location in RAM
	call	get_psgsample_location

	ld	a,(hl)
	and	0xf0
	or	d
	ld	(hl),a
;	jr.	_psgsamright
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END			
	
	
	

0:	
	;===================
	; INPUT is Volume
	;
	; V O L U M E
	;
	;===================
	;--- Check if we are in an volume column
	ld	a,(cursor_input)
	cp	13			; 4 = volume type
	ld	a,b
	jr.	nz,0f
	cp	_DEL
	jr.	nz,99f
	ld	a,'0'	
	
99:	
	;--- Check if the key pressed is in the envelope range
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	_psgvolfound
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	_psgvolfound
99:	
	cp	'A'
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
	ld	d,a
_psgvolfound:	
	ld	d,a
	
	;--- get the location in RAM
	call	get_psgsample_location

	inc	hl		;(2nd byte)
	ld	a,(hl)
	and	0xf0
	or	d
	ld	(hl),a
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END
	
0:
	;===================
	; INPUT is volume addition
	;
	; VOLUME addition
	;
	;===================
	;--- Check if we are in a volume add type column
	ld	b,a
	ld	a,(cursor_input)
	cp	13
	ld	a,b
	jr.	nz,0f
	
	;--- check for space.
	cp	_ENTER
	jr.	nz,0f
	
	;--- get the location in RAM
	call	get_psgsample_location
	
	inc	hl
	ld	a,(hl)
	and	16+8
	jr.	nz,12f
	add	8
12:
	add	8
	and	16+8
	ld	b,a
	ld	a,(hl)
	and	0xe7	
	or	b
	ld	(hl),a
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_END	
0:




process_key_psgsamplebox_END:
	ret



;===========================================================
; --- get_psgsample_location:
;
; returns in hl the start ofthe current sample line.
; Changes: A, HL and BC
;===========================================================
get_psgsample_location:
	;--- get the location in RAM
	call	_get_instrument_start
	
	inc	hl
	inc	hl
	inc	hl	
	
	;--- add the current line to the start of the sample
	ld	a,(instrument_line)
	and	a
	ret	z
	ld	bc,4		; b is 0
88:
	add	hl,bc
	dec	a
	jr.	nz,88b
	
	ret




;===========================================================
; --- process_key_psgsamplebox_waveform
;
;
;===========================================================
process_key_psgsamplebox_waveform:
	;--- get the location in RAM
	call	_get_instrument_start
	
	inc	hl
	inc	hl
	
	ld	a,(instrument_waveform)
	ld	c,a
	ld	a,(key)

	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		jr.	restore_cursor
	
0:	
	cp	_KEY_LEFT
	jr.	nz,0f
	;--- sample nr down
		ld	a,c
		and	a
		ret	z
		dec	a
		ld	(instrument_waveform),a
		ld	(hl),a
		jr.	update_psgsamplebox
0:
	cp	_KEY_RIGHT
	jr.	nz,0f
	;--- sample nr up
		ld	a,c
		cp	32
		ret	nc
		inc	a
		ld	(hl),a
		ld	(instrument_waveform),a
		jr.	update_psgsamplebox

0:	ret


;===========================================================
; --- process_key_psgsamplebox_octave
;
;
;===========================================================
process_key_psgsamplebox_octave:
	ld	a,(song_octave)
	ld	c,a
	ld	a,(key)

	;--- Check if edit is ended.
	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		call	restore_cursor
		;call	reset_cursor_trackbox
		jr.	process_key_psgsamplebox_octave_END
0:		
	;--- Key_up - Pattern down	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
44:		dec	c
		ld	a,c
		jr.	z,process_key_psgsamplebox_octave_END
88:		ld	(song_octave),a
		call	update_psgsamplebox
		jr.	process_key_psgsamplebox_octave_END	
0:
	;--- Key_down - Pattern up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		ld	a,c
		cp	7
		jr.	nc,process_key_psgsamplebox_octave_END
		inc	a
		jr.	88b	
0:
	;---- number key
	cp	"1"
	jr.	c,0f
	cp	"8"
	jr.	nc,0f

		sub	48
		ld	(song_octave),a
		call	restore_cursor
		call	update_psgsamplebox
		jr.	process_key_psgsamplebox_octave_END
		
	

0:	
process_key_psgsamplebox_octave_END:
	ret






;===========================================================
; --- process_key_psgsamplebox_len
;
;
;===========================================================
process_key_psgsamplebox_len:
	;--- get the location in RAM
	call	_get_instrument_start
	
	ld	a,(instrument_loop)
	inc	a
	ld	b,a
	ld	a,(instrument_len)
	ld	c,a


	ld	a,(key)

	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		
	call	restore_cursor
	jr.	update_psgsamplebox
	
0:	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
	;--- len down
44:		ld	a,c
		cp	1
		ret	z
		dec	a
		ld	(hl),a
		cp	b
		jr.	nc,update_psgsamplebox
		dec	a
		inc	hl
		ld	(hl),a
		jr.	update_psgsamplebox		
		
0:
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
	;--- sample nr up
44:		ld	a,c
		cp	32
		ret	nc
		inc	a
		ld	(hl),a
		jr.	update_psgsamplebox

0:	ret

;===========================================================
; --- process_key_psgsamplebox_loop
;
;
;===========================================================
process_key_psgsamplebox_loop:
	;--- get the location in RAM
	call	_get_instrument_start	
	inc	hl

	ld	a,(instrument_len)
	ld	b,a
	ld	a,(instrument_loop)
	ld	c,a
	ld	a,(key)

	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		jr.	restore_cursor
	
0:	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
	;--- sample nr down
44:		ld	a,c
		and	a
		ret	z
		dec	a
		cp	c
		ld	(hl),a
		jr.	update_psgsamplebox
0:
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
	;--- sample nr up
44:		ld	a,c
		cp	32
		ret	nc
		inc	a
		cp	b
		jr.	nc,0f
		ld	(hl),a
		jr.	update_psgsamplebox

0:	ret

;===========================================================
; --- process_key_description
;
; Process the song name input
; 
;===========================================================
process_key_psgsamplebox_description:
	
	;--- Set the start of the instrument name.
	ld	a,(song_cur_instrument)
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
0:	
		
	ld	a,(key)
	;--- Check if edit is ended.
	cp	_ESC
	jr.	z,44f
	cp	_ENTER
	jr.	nz,0f	
44:		;ld	a,0
		;ld	(editsubmode),a
		call	restore_cursor
		;call	reset_cursor_psgsamplebox
		jr.	process_key_psgsamplebox_description_END

0:
	;--- Check for RIGHT
	cp	_KEY_RIGHT
	jr.	nz,99f
		ld	a,(cursor_x)
		cp	30+15
		jr.	nc,process_key_psgsamplebox_description_END
		call	flush_cursor
		inc	a
		ld	(cursor_x),a
		jr.	process_key_psgsamplebox_description_END			
99:	
	
	;--- Check for LEFT
	cp	_KEY_LEFT
	jr.	nz,99f
		ld	a,(cursor_x)
		cp	31
		jr.	c,process_key_psgsamplebox_description_END
		call	flush_cursor
		dec	a
		ld	(cursor_x),a
		jr.	process_key_psgsamplebox_description_END
99:
	;--- Backspace
	cp	_BACKSPACE
	jr.	nz,99f
		; get location in RAM
		ld	b,a
		ld	a,(cursor_x)
		sub	30
		add	a,l
		ld	l,a
		jr.	nc,88f
		inc	h
88:
		; move cursor (if possible)
		ld	a,(cursor_x)
		cp	31
		jr.	c,77f		
		dec	a
		ld	(cursor_x),a
77:		
		ld	(hl),32
		call	update_psgsamplebox
		jr.	process_key_psgsamplebox_description_END

99:
	;--- Delete
	cp	_DEL
	jr.	nz,99f
		ld	a,(cursor_x)
		sub	30
		add	a,l
		ld	l,a
		jr.	nc,88f
		inc	h	
88:	
		ld	(hl)," "
		call	update_psgsamplebox
		jr.	process_key_psgsamplebox_description_END	

99:
	;--- All other (normal) keys
	cp	32
	jr.	c,process_key_psgsamplebox_description_END
	cp	128
	jr.	nc,process_key_psgsamplebox_description_END
	
	ld	b,a
	ld	a,(cursor_x)
	sub	30
	add	a,l
	ld	l,a
	jr.	nc,88f
	inc	h
88:
		ld	a,(cursor_x)
		cp	30+15
		jr.	nc,99f
		call	flush_cursor
		inc	a
		ld	(cursor_x),a
99:	ld	(hl),b
	call	update_psgsamplebox
	jr.	process_key_psgsamplebox_description_END
		
			
process_key_psgsamplebox_description_END
	call	build_instrument_list
	ret





;===========================================================
; --- reset_cursor_psgsamplebox
;
; Reset the cursor to the top left of the pattern.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_psgsamplebox:
	call	flush_cursor
	
	ld	a,(editsubmode)
	and	a
	jr.	nz,0f	
	;--- Sample edit
		ld	a,1
		ld	(cursor_type),a
		ld	a,10
		ld	(cursor_y),a
		ld	a,8+15;4
		ld	(cursor_x),a
		xor	a
		ld	(instrument_line),a
		ld	(instrument_macro_offset),a
		inc	a 
		ld	(cursor_type),a	
		ld	a,13		; get volume type value
		ld	(cursor_input),a
		xor	a
		ld	(instrument_line),a
		ld	a,5
		ld	(cursor_column),a
		ret
0:
	dec	a
	jr.	nz,0f
	;--- Waveform.
		ld	a,3+5+6+9+3
		ld	(cursor_x),a
		ld	a,2
		ld	(cursor_type),a	
		jr.	99f	
0:
	dec	a
	jr.	nz,0f
	;--- Sample length
		ld	a,3+5+8
		ld	(cursor_x),a
		ld	a,2
		ld	(cursor_type),a	
		jr.	99f		
0:
	dec	a
	jr.	nz,0f
	;--- Sample loop
		ld	a,3+5+6+7
		ld	(cursor_x),a	
		ld	a,2
		ld	(cursor_type),a	
		jr.	99f	
0:	
	dec	a
	jr.	nz,0f
	;--- OCtave 
		ld	a,3+5+6+9+6+19
		ld	(cursor_x),a	
		ld	a,2
		ld	(cursor_type),a	
		jr.	99f	
0:	
	dec	a
	jr.	nz,0f
	;--- Wave editor 
		ld	a,3+5+6+9+6+13+5
		ld	(cursor_x),a
		xor	a
		ld	(_scc_waveform_col),a
		call	get_waveform_val	
		ld	a,1
		ld	(cursor_type),a
		ld	a,10+7
		jr.	88f	
0:
	dec	a
	jr.	nz,0f
	;--- Instrument description 
		ld	a,3+5+6+7+9
		ld	(cursor_x),a	
		ld	a,1
		ld	(cursor_type),a	
		jr.	99f		
0:
99:	ld	a,8
88:	ld	(cursor_y),a
	ret

	db	255	;end
_COLTAB_PSGSAMPLE:
;	db	0,1	; 0 = ena/dis tone
;	db	1,2	; 1 = ena/dis noise
;	db	2,2	; 2 = ena/dis envelope
;	db	3,1	; 3 = pos/neg freq deviation
	db	4,1	; 4 = freq deviation high
	db	5,1	; 5 = freq deviation mid
	db	6,3+6	; 6 = freq deviation low
	;db	7,2	; 7 = freq deviation add type
;	db	8,1	; 8 = pos/neg noise deviation
	db	9,1	; 9 = noise deviation high
	db	10,3	; 6 = noise deviation low
;	db	11,2	; 11= noise deviation add type
	db	13,255;1	; 12= volume
;	db	12,255	; 13= volume add type