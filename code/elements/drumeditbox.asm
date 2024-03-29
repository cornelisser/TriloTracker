
;===========================================================
; --- draw_drumbox
; Display the drum area.  Without actual values 
; 
;===========================================================
draw_drumeditbox:

	; box around number, length, restart etc
	ld	hl,(80*6)+8
	ld	de,(49*256) + 3
	call	draw_box
	
	; box around macro lines
	ld	hl,(80*9)+0
	ld	de,(34*256) + 17
	call	draw_box	
;	
;	;box around waveform
;	ld	hl,(80*9)+32
;	ld	de,(48*256) + 17
;	call	draw_box	
;	;box around waveform data
;	ld	hl,(80*17)+32
;	ld	de,(15*256) + 9
;	call	draw_box	
;

	

	ld	hl,(80*6)+1+8
	ld	de,_LABEL_DRUMBOX
	call	draw_label
	
	ld	hl,(80*7)+2+8
	ld	de,_LABEL_DRUMTEXT
	call	draw_label
	ld	hl,(80*8)+2+8
	ld	de,_LABEL_DRUMTEXT2
	call	draw_label


	ld	hl,(80*9)+1
	ld	de,_LABEL_DRUMMACRO
	call	draw_label


;	ld	hl,(80*9)+1+28+4
;	ld	de,_LABEL_SAMPLEFORM
;	call	draw_label


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
	ld	de,0x0801	
	call	erase_colorbox
;	ld	hl,0x1908
;	ld	de,0x0401	
;	call	erase_colorbox

	ld	hl,0x1e08
	ld	de,0x1001	
	call	erase_colorbox
	ld	hl,0x2f08
	ld	de,0x0401	
	call	erase_colorbox
;	ld	hl,0x3408
;	ld	de,0x0401	
;	call	erase_colorbox

	; under the info top area
	ld	hl,0x0009
	ld	de,0x5012	
	call	draw_colorbox

	ld	hl,0x010a
	ld	de,0x0110	
	call	erase_colorbox	

	; macro data
	ld	hl,0x040a
	ld	de,0x1D10	
	call	erase_colorbox	

	;--- draw name numbers
	ld	a,"."
	ld	de,_LABEL_DRUMTEXT2SUB+2
	ld	(de),a
	
	ld	hl,(80*10)+40-1	
	ld	a,1
	
0:	
	ld	de,_LABEL_DRUMTEXT2SUB
	push	af
	push	hl
	call	draw_hex2
	ld	de,_LABEL_DRUMTEXT2SUB
	ld	b,3
	call	draw_label_fast
	pop	hl
	pop	af
	inc	a
	cp	16
	jr.	nz,99f
	;--- next column
	ld	hl,(80*9)+40+20-1	
99:
	;--- next row
	ld	bc,80
	add	hl,bc
	cp	MAX_DRUMS
	jr.	nz,0b
		
	ret
	
_LABEL_DRUMBOX:
	db	"Drummacro edit:",0
_LABEL_DRUMMACRO:
	db	"Macro:",$81,$81,$81,$81,$81,$81,$81,$81,$81,"B",$81,$81,$81,$81,$81,"H",$81,"S",$81,$81,$81,$81,$81,"T",$81,"C",0

_LABEL_DRUMTEXT:
	db	"Drm: Len: drumSet:  Name:            Oct:",0
_LABEL_DRUMTEXT2:	
	db	_ARROWLEFT," x",_ARROWRIGHT,32
	db	_ARROWLEFT,"xx",_ARROWRIGHT,32
	db	_ARROWLEFT,"xxxxxx",_ARROWRIGHT,0
_LABEL_DRUMTEXT2SUB:
	db	"                 ",_ARROWLEFT,"xx",_ARROWRIGHT,0

_LABEL_DRUMTYPES:
	db	"MCabin"
	db	"FMBios"

_DRUM_SAMPLESTRING:
	db	"   _____|---   .|--- . .|--- . ."
_udm_pntpos:	dw	0
;===========================================================
; --- update_drumeditbox
; Display the values
; 
;===========================================================
update_drumeditbox:
	;--- Make sure the cursor is inside the macro
	ld	a,(drum_len)
	inc 	a
	ld	b,a
	ld	a,(drum_line)
	cp	b
	jr.	c,99f
	call	reset_cursor_drumeditbox	
99:
	;--- Get the current drum macro
	ld	a,(drum_macro_offset)
	ld	c,a			; contains the line#
	ld	b,16		
	; add offset here somewhere
		
	; -- Init and store the display pos in PNT
	ld	hl,(80*9)+1			; start position
	ld	(_udm_pntpos),hl	

	;--- Calculate the position in RAM of current sample	
	call	_get_drum_start

	ld	a,(hl)
	ld	(drum_len),a
	inc	hl
;	ld	a,(hl)
;	ld	(drum_type),a
;	inc	hl	
	
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

_udm_lineloop:	
	;each line
	ld	de,_DRUM_SAMPLESTRING	
	
	;	check if we are at the end.
	ld	a,(drum_len)
	dec	a
	cp	c
	jr.	nc,0f
	; --- YES draw empty line
		inc	c				; increase line number
		push	bc				; store line+len	
		ld	a," "
		ld	b,32
10:		ld	(de),a
		inc	de
		djnz	10b
		jr.	55f
	;-- YES draw data!!!
0:	
	inc	de
	; draw the line number
	ld	a,c
	call	draw_hex2			; draw hex line number

	inc	c				; increase line number
	push	bc				; store line+len

	; --- continue
	; get info byte
	ld	b,(hl)			; store byte2 in b
	inc	hl
;	ld	c,(hl)			; store byte3 in c
;	inc	hl
	
	
	;--- Draw percussion bits.
	ex	de,hl
	bit	4,b				;- Basedrum bit
	jr.	z,99f
	ld	(hl),$FA
	jr.	88f
99:	
	ld	(hl),$0B
88:
	inc	hl
	bit	3,b				;- Snare bit
	jr.	z,99f
	ld	(hl),$FB
	jr.	88f
99:	
	ld	(hl),$1c
88:
	inc	hl	
	bit	2,b				;- TomTom
	jr.	z,99f
	ld	(hl),$FC
	jr.	88f
99:	
	ld	(hl),$1d
88:
	inc	hl	
	bit	1,b				;- Cymbal
	jr.	z,99f
	ld	(hl),$fd
	jr.	88f
99:	
	ld	(hl),$0c
88:
	inc	hl	
	bit	0,b				;- HiHat
	jr.	z,99f
	ld	(hl),$94
	jr.	88f
99:	
	ld	(hl),$11
88:
	ex	de,hl
	inc	de
	
	call	_dml_update_pair
	call	_dml_update_pair
	call	_dml_update_pair	

	
55:	; end of line making.
	push	hl			; store data pointer
	ld	hl,(_udm_pntpos)	; get pnt pointer
	ld	de,80
	add	hl,de			; store new position
	ld	(_udm_pntpos),hl
	

	ld	de,_DRUM_SAMPLESTRING	; draw the string
	ld	b,32;23+6-11+2
	call	draw_label_fast	
	
	pop	hl
	pop	bc	
	
	dec	b
	jr.	nz,_udm_lineloop

	;--- Macro info
	
	ld	de,_LABEL_DRUMTEXT2+1
	ld	a,(song_cur_drum)
	call	draw_hex2

	ld	de,_LABEL_DRUMTEXT2+5+1
	ld	a,(drum_len)
	call	draw_decimal
	

	ld	de,_LABEL_DRUMTEXT2SUB+18
	ld	a,(song_octave)
	call	draw_decimal

	;--- Drum type
	ld	de,_LABEL_DRUMTYPES+6
	ld	a,(drum_type)
	and	a
	jp	z,0f
	ld	de,_LABEL_DRUMTYPES
0:
	ld	b,6
	ld	hl,(80*8)+2+8+11
	call	draw_label_fast		
	
		
	;--- set the instrument name
	ld	a,(song_cur_drum)
	ld	l,a
	xor	a		; [a] to catch carry bit
	sla	l		; offset  *16
	sla	l
	sla	l
	sla	l
	adc	a,0		; only the 4th shift can cause carry
	ld	h,a
	ld	de,song_drum_list-16
	add	hl,de	
	ld	bc,16
	ld	de,_LABEL_DRUMTEXT2SUB
	ldir

	; draw nr + len
	ld	hl,(80*8)+2+8+1
	ld	de,_LABEL_DRUMTEXT2+1
	ld	b,8
	call	draw_label_fast
	
	;draw desscription + octave
	ld	hl,(80*8)+2+8+20
	ld	de,_LABEL_DRUMTEXT2SUB
	ld	b,21
	call	draw_label_fast
	call	update_drumnames
	ret



_dml_update_pair:
	ld	a,_VERTICAL_SMALL
	ld	(de),a
	inc	de
	
	;--- Tone
	ld	a,(hl)
	inc	hl
	and	a
	jr.	z,_dml_empty
	bit 	7,a
	jr.	z,_dml_note
	cp	192
	jr.	c,_dml_up
_dml_down:
	ld	b,a
	ld	a,'-'
	jr.	88f
	
	
_dml_up:
	ld	b,a
	ld	a,'+'
88:	
	ld	(de),a
	inc	de
	
	ld	a,b
	and	00111111b
	call	draw_hex2			; draw hex line number	
	inc	de
	jr.	1f

	
_dml_empty:
	;--- draw empty note value
	ld	a,"-"
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	inc	de
	jr.	1f
	

_dml_note:
	; Note
	push	hl
	;--- get pointer to the note labels.
	ld	hl,_LABEL_NOTES
	ld	b,0
	ld	c,a
	add	hl,bc
	add	hl,bc
	add	hl,bc

	;--- copy note label to [DE]
	ldi
	ldi
	ldi
	inc	de
	pop	hl


	
1:	
	; Volumes
	; Volume high
	ld	b,(hl)
	inc	hl
	
	ld	a,0xf0
	and	b
	jr.	nz,2f
	ld	a,'.'
	ld	(de),a
	inc	de
	jr.	0f
2:
	sra	a
	sra	a
	sra 	a
	sra	a
	call	draw_hex			; draw hex line number		
0:	
	inc	de
	; volume low
	ld	a,0x0f
	and	b
	jr.	nz,2f
	ld	a,'.'
	ld	(de),a
	inc	de
	jr.	0f
2:	
	call	draw_hex			; draw hex line number		
0:	
	ret

;===========================================================
; --- update_drumnames
; Display the drum macro names.
; 
;===========================================================
update_drumnames:

	ld	de,song_drum_list
	ld	hl,(80*10)+40+2
	ld	a,MAX_DRUMS-1
	
_udn_loop:	
	ld	b,16
	push	hl
	push	af
	call	draw_label_fast
	pop	af
	pop	hl
	cp	MAX_DRUMS-14	; check if we are at macro 16
	jr.	nz,99f
	;--- next column
	ld	hl,(80*10)+40+22-80
99:	;--- next line
	ld	bc,80
	add	hl,bc
	dec	a
	jr.	nz,_udn_loop
	
	;----- Show active drum
	; macro names (left)
	ld	hl,0x270a
	ld	de,0x130f	
	call	erase_colorbox	

	; macro names (right)
	ld	hl,0x3b0a
	ld	de,0x1304	
	call	erase_colorbox	

	ld	hl,$2709
	ld	de,0x1301	
	ld	a,(song_cur_drum)
	cp	16
	jr.	c,99f
	ld	h,$3b
	sub	15
99:
	add	l
	ld	l,a
	call	draw_colorbox	


	ret
	
;--- Get drum start
; return in HL that start of the drum data
;
_get_drum_start:
	push	bc
	ld	hl,drum_macros
	ld	a,(song_cur_drum)
	and	a
	jr.	z,99f
	ld	bc,DRUMMACRO_SIZE
88:
	add	hl,bc
	dec	a
	jr.	nz,88b
99:
	pop	bc
	ret	
	
	
	


		
		
draw_empty:
	ld	a,"_"
	ld	(de),a
	inc	de
	xor	a			; make sure nx flag
	ret
		
;===========================================================
; --- process_key_drumeditbox
;
; Process the input for the DRUM macro. 
; 
; 
;===========================================================
process_key_drumeditbox:
	
	ld	a,(key)
	and	a
	ret	z

	cp	_INS
	jr. 	nz,0f
	ld	a,(drum_line)
	cp	16
	jr.	nc,process_key_drumeditbox_END
	;-- increase len

	call _get_drum_start
	ld	a,(hl)
	cp	16
	jr.	nc,99f
	inc	a
	ld	(hl),a
99:	
	;--- move data 1 line down
	ld	a,(drum_line)
	ld	ixh,a
	ld	a,14
.line_loop:
	call	_move_drumlineup
	and	a
	jr.	z,88f
	dec	a
	cp	ixh
	jr.	nc,.line_loop
88:
	jr.	update_drumeditbox	
	
	
0:

	cp	_BACKSPACE
	jr.	nz,0f

	ld	a,(drum_line)
	inc	a
	ld	b,a
	call	_get_drum_start
	ld	a,(hl)
	cp	b		; check if we are at last line
	jr.	nz,1f

	; Backspace on last line
	cp	1
	jr.	z,process_key_drumeditbox_END
	
	dec	a
	ld	(hl),a	; Make the drum macro 1 step shorter
	dec	a
	ld 	(drum_line),a  ; go one line up
	call	flush_cursor
	ld	a,(cursor_y)   ; move cursor allong
	dec	a
	ld	(cursor_y),a	
	
	;--- update screen
	jr.	update_drumeditbox		
	
	;--- decrease len + remove line
1:
	;call	_get_drum_start  ; hl still points at start macro
	ld	a,(hl)
	cp	1
	jr.	z,99f
	dec	a
	ld	(hl),a
99:
	;--- move data 1 line down
	ld	a,(drum_line)
.line_loopdel:
	call	_move_drumlinedown
	inc	a
	cp	15
	jr.	z,88f
	jr.	.line_loopdel
88:	
	jr.	update_drumeditbox

	
0:	
	;--- key left
	cp	_KEY_LEFT
	jr.	nz,0f
	; column left
	ld	hl,_COLTAB_DRUMSAMPLE
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
	jr.	z,process_key_drumeditbox_END
	
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
	
	jr.	process_key_drumeditbox_END			
0:		
	;--- key right
	cp	_KEY_RIGHT
	jr.	nz,0f
	; column right
	call	next_drum_column

	call	update_drumeditbox
	jr.	process_key_drumeditbox_END			
0:		

	;--- key down
	cp	_KEY_DOWN
	jr.	nz,0f
	; row down
	ld	a,(drum_len)
	ld	b,a
	ld	a,(drum_line)
	inc	a
	cp	b
	jr.	nc,process_key_drumeditbox_END
	
	ld	(drum_line),a
	call	flush_cursor
	ld	a,(cursor_y)
	inc	a
	cp	26
	jr.	z,88f
	ld	(cursor_y),a
	jr.	77f			
88:	ld	a,(drum_macro_offset)
	inc	a
	ld	(drum_macro_offset),a
77:	call	update_drumeditbox
	jr.	process_key_drumeditbox_END		
99:	;-- see if we need to go to the next column
	ld	a,(drum_line)	
	cp	16
	jr.	nz,88f
	ld	a,(cursor_y)
	sub	15
	ld	(cursor_y),a
	ld	a,(cursor_x)
	add 	40
	ld	(cursor_x),a
88:	call	update_drumeditbox
	jr.	process_key_drumeditbox_END	
	
0:			
	;--- key up
	cp	_KEY_UP
	jr.	nz,0f
	; row up
	ld	a,(drum_line)
	and	a
	jr.	z,process_key_drumeditbox_END
	
	dec	a
	ld	(drum_line),a
	call	flush_cursor
	ld	a,(cursor_y)
	dec	a
	cp	9
	jr.	z,88f
	ld	(cursor_y),a
	jr.	77f			
88:	ld	a,(drum_macro_offset)
	dec	a
	ld	(drum_macro_offset),a
77:	call	update_drumeditbox
	jr.	process_key_drumeditbox_END						
99:	;-- see if we need to go to the next column
	ld	a,(drum_line)	
	cp	15
	jr.	nz,88f
	ld	a,(cursor_y)
	add	15
	ld	(cursor_y),a
	ld	a,(cursor_x)
	sub 	40
	ld	(cursor_x),a
88:	call	update_drumeditbox
	jr.	process_key_drumeditbox_END		

0:
	ld	b,a
	ld	a,(cursor_input)
	cp	5
	jr.	c,_drum_bits
	sub	5
	and	a
	jr.	z,_drum_note_deviation
	dec	a
	jr.	z,_drum_note_deviationhigh
	dec	a
	jr.	z,_drum_note_deviationlow
	dec	a
	jr.	z,_drum_vhigh
	dec	a
	jr.	z,_drum_vlow
	
process_key_drumeditbox_END:
	ret

;--- Move drum data 1 line down (delete row)
; in: [A] is the line to move down/delete
;
; need to preserve [A]
_move_drumlinedown:
	push	af
	;-- set hl to start macro data of current instrument
	call	_get_drum_start
	inc	hl
;	dec	hl
;	dec 	hl
	;-- jump to line ( input)
	pop	bc
	push	bc
	ld	de,7
.loop:
	add	hl,de
	djnz	.loop

	;--- copy the data to next line
	ld	d,h	
	ld	e,l
	ld	a,7
	add	a,l
	ld	l,a
	jr.	nc,.skip
	inc	h
.skip:
[7]	ldi
	
	;--- restore and return 	
	pop	af
	ret



;--- Move drum data 1 line up (insert row)
; in: [A] is the line to move up
;
; need to preserve [A]
_move_drumlineup:
	push	af
	;-- set hl to start drum data of current instrument
	call	_get_drum_start
;	inc	hl
	inc	hl
	;-- jump to line (input)
	pop	bc
	push	bc
	ld	de,7		; drum line size
.loop:
	add	hl,de
	djnz	.loop

	;--- copy the data to next line
	ld	d,h	
	ld	e,l
	ld	a,7
	add	a,e
	ld	e,a
	jr.	nc,.skip
	inc	d
.skip:
[7]	ldi
	;--- restore and return 	
	pop	af
	ret




	db	255	;end
_COLTAB_DRUMSAMPLE:
	db	0,1	; 0 = basedrum
	db	1,1	; 1 = snare
	db	2,1	; 2 = tomtom
	db	3,1	; 3 = cymbal
	db	4,2	; 4 = highhat
	; bd registers
	db	5,1	; 5 = note/deviation
	db	6,1	; 6 = note/deviationhigh
	db	7,4	; 7 = note/deviationlow
	db	9,2	; 9 = volume low
	; hh/sn registers
	db	5,1	; 5 = note/deviation
	db	6,1	; 6 = note/deviationhigh
	db	7,2	; 7 = note/deviationlow
	db	8,2	; 8 = volume high
	db	9,2	; 9 = volume low
	; tom/cy registers
	db	5,1	; 5 = note/deviation
	db	6,1	; 6 = note/deviationhigh
	db	7,2	; 7 = note/deviationlow
	db	8,2	; 8 = volume high
	db	9,255	; 9 = volume low	
	
	
	
;	db	5,5	; 5 = note
;;	db	6,1	; 6 = freq high
;	db	7,1	; 7 = freq mid
;	db	8,2	; 8 = freq low
;	db	9,2	; 9 = vol low
;	db	10,255	; 10 = vol high
;;	db	11,2	; 11= noise deviation add type
;;	db	13,255;1	; 12= volume
;;	db	12,255	; 13= volume add type

;--------------------
; Process the ryhtm bits.
;--------------------
_drum_bits:
	ld	a,b
	cp	_ENTER
	jr.	nz,0f

	ld	a,(cursor_input)
	inc	a
	ld	b,a
	ld	d,100000b
99:
	sra	d
	djnz	99b

	call	get_drumsample_location
	ld	a,(hl)
	xor	d
	ld	(hl),a
	jr.	update_drumeditbox		

0:	
	cp	"b"
	jr.	z,99f
	cp	"B"
	jr.	nz,0f
	;--- basedrum
99:	ld	d,10000b
	jr.	_db_update
0:
	cp	"s"
	jr.	z,99f
	cp	"S"
	jr.	nz,0f
	;--- snare
99:	ld	d,1000b
	jr.	_db_update
0:
	cp	"t"
	jr.	z,99f
	cp	"T"
	jr.	nz,0f
	;--- tomtom
99:	ld	d,100b
	jr.	_db_update
0:
	cp	"c"
	jr.	z,99f
	cp	"C"
	jr.	nz,0f
	;--- cymbal
99:	ld	d,10b
	jr.	_db_update
0:
	cp	"H"
	jr.	z,99f
	cp	"h"
	jr.	nz,0f
	;--- hihat
99:	ld	d,1b
_db_update:
	call	get_drumsample_location
	ld	a,(hl)
	xor	d
	ld	(hl),a
	jr.	update_drumeditbox		
0:
	ret

_drum_note_deviation:	
	ld	a,b
	cp	_DEL
	jr.	nz,1f
	call	get_drumsample_track_location
	ld	(hl),0
	jr.	update_drumeditbox
1:	
	cp	'+'
	jr.	nz,0f
	; + found
	call 	get_drumsample_track_location
;	inc	hl	; skip percusion bits
	ld	a,(hl)
	and	00111111b
	or	10000000b
	ld	(hl),a
	;call	next_drum_column
	jr.	update_drumeditbox
	
0:	cp	'-'
	jr.	nz,_drum_note
	; - found
	call	get_drumsample_track_location
;	inc	hl	; skip percusion bits
	ld	a,(hl)
	or	11000000b
	ld	(hl),a
	;call	next_drum_column
	jr.	update_drumeditbox
	

_drum_note_deviationhigh:
	ld	a,b
	cp	_DEL
	jr.	nz,1f
	call	get_drumsample_track_location
	ld	(hl),0
	jr.	update_drumeditbox
1:	
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,update_drumeditbox	
	cp	'4'+1	; smaller than 4?
	jr.	nc,update_drumeditbox
	sub 	'0'
[4]	add	a
	ld	d,a	
	call	get_drumsample_track_location
	ld	a,(hl)
	and	11001111b
	or	d
	ld	(hl),a
	;call	next_drum_column
	jr.	update_drumeditbox	
	
	
_drum_note_deviationlow:	
	;deviation low (x0-xf)	
	ld	a,b
	cp	_DEL
	jr.	nz,1f
	call	get_drumsample_track_location
	ld	(hl),0
	jr.	update_drumeditbox
1:	
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
	jr.	nc,update_drumeditbox
	sub	'A'-10

22:
	ld	d,a	
	call	get_drumsample_track_location
	ld	a,(hl)
	and	11110000b
	or	d
	ld	(hl),a
	;call	next_drum_column
	jr.	update_drumeditbox


_drum_vhigh:
	;deviation low (x0-xf)	
	ld	a,b
	cp	_DEL
	jr.	nz,1f
	call	get_drumsample_track_location
;	dec	hl
	ld	a,(hl)
	and	00001111b
	ld	(hl),a
	jr.	update_drumeditbox
1:	
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
	jr.	nc,update_drumeditbox
	sub	'A'-10

22:
[4]	add	a
	ld	d,a	
	call	get_drumsample_track_location
;	dec	hl
	ld	a,(hl)
	and	00001111b
	or	d
	ld	(hl),a
;	call	next_drum_column
	jr.	update_drumeditbox

_drum_vlow:	
	;deviation low (x0-xf)	
	ld	a,b
	cp	_DEL
	jr.	nz,1f
	call	get_drumsample_track_location
	;dec	hl
	ld	a,(hl)
	and	11110000b
	ld	(hl),a
	jr.	update_drumeditbox
1:

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
	jr.	nc,update_drumeditbox
	sub	'A'-10

22:
	ld	d,a	
	call	get_drumsample_track_location
;	dec	hl
	ld	a,(hl)
	and	11110000b
	or	d
	ld	(hl),a
;	call	next_drum_column
	jr.	update_drumeditbox
	
	
	
_drum_note:
	;---- now get the note		
	ld	a,(key_value)
	;get the note octave addittion
	ld	b,0		
	cp	88   ; SHIFT?
	jr.	c,99f
	inc	b
	sub	88
99:	
	;- Note under this keys?
	cp	48			
	jr.	nc,0f
	cp	$16	; -R-
	jr.	z,0f
	
	;--- Get the note value of the key pressed
	ld	hl,_KEY_NOTE_TABLE
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	;--- Get the octave
	ld	a,(song_octave)
	add	b
	ld	b,a
	
	ld	a,(hl)
;	inc	a
	;--- Only process values != 255
	cp	255
	jr.	z,0f
	
	;--- Add the octave
	; but not for these;
	cp	97
	jr.	nc,77f
	and	a
	jr.	z,77f
	sub	12
88:
	add	12
	djnz	88b
	;--- Check if we are not outside the 8th ocatave
	cp	97
	jr.	nc,0f
	
77:	
	ld	d,a
	call	get_drumsample_track_location
;	inc	hl

;	sla	d
;	ld	a,(hl)
;	and	0x01
;	or	d
	ld	(hl),d
;	call	_drum_jr._to_vol			; set cursor at (first) volume entry
	jr.	update_drumeditbox		

0:
	ret	


;_drum_fmed:	; deviation high (0x-7x)
;	ld	a,b
;	; is it a number?
;	cp	'0'	; bigger than 0 
;	jr.	c,0f	
;	cp	'7'+1	; smaller than 9?
;	jr.	nc,0f
;	sub 	'0'
;
;99:	
;[4]	add	a
;	ld	d,a	
;	call	get_drumsample_location
;	inc	hl
;	inc	hl
;	ld	a,(hl)
;	and	0x8f
;	or	d
;	ld	(hl),a
;	call	update_drumeditbox		
;	ld	a,_KEY_RIGHT
;	ld	(key),a
;	jr.	process_key_drumeditbox		
;0:
;	jr.	_dm_posneg
;;	ret		

;_drum_flow:	;deviation low (x0-xf)	
;	ld	a,b
;	; is it a number?
;	cp	'0'	; bigger than 0 
;	jr.	c,99f	
;	cp	'9'+1	; smaller than 9?
;	jr.	nc,99f
;	sub 	'0'
;	jr.	22f
;99:	
;	cp	'a'
;	jr.	c,99f
;	cp	'f'+1
;	jr.	nc,99f
;	sub	'a'-10
;	jr.	22f
;99:	
;	cp	'A'
;	jr.	c,0f
;	cp	'F'+1
;	jr.	nc,0f
;	sub	'A'-10
;;	ld	d,a
;22:	
;	ld	d,a	
;	call	get_drumsample_location
;	inc	hl
;	inc	hl
;	ld	a,(hl)
;	and	0xf0
;	or	d
;	ld	(hl),a
;	call	update_drumeditbox		
;	ld	a,_KEY_RIGHT
;	ld	(key),a
;	jr.	process_key_drumeditbox
;0:
;
;_dm_posneg:
;	cp	"-"
;	jr.	nz,99f
;	ld	d,$80
;	jr.	1f
;	
;99:
;	cp	"+"
;	jr.	nz,99f
;	ld	d,0
;	
;1:
;	call	get_drumsample_location
;	inc	hl
;	inc	hl
;	ld	a,(hl)
;	and	0x7f
;	or	d
;	ld	(hl),a
;	call	update_drumeditbox		
;99:	
;	ret		

;_drum_vlow:	
;	ld	a,b
;	; is it a number?
;	cp	'0'	; bigger than 0 
;	jr.	c,99f	
;	cp	'9'+1	; smaller than 9?
;	jr.	nc,99f
;	sub 	'0'
;	jr.	22f
;99:	
;	cp	'a'
;	jr.	c,99f
;	cp	'f'+1
;	jr.	nc,99f
;	sub	'a'-10
;	jr.	22f
;99:	
;	cp	'A'
;	jr.	c,0f
;	cp	'F'+1
;	jr.	nc,0f
;	sub	'A'-10
;;	ld	d,a
;22:	
;	ld	d,a	
;	call	get_drumsample_location
;	inc	hl
;	inc	hl
;	inc	hl
;	ld	a,(hl)
;	and	0xf0
;	or	d
;	ld	(hl),a
;	call	update_drumeditbox		
;	ld	a,_KEY_RIGHT
;	ld	(key),a
;	jr.	process_key_drumeditbox
;0:
;	ret		

;_drum_vhigh:	
;	ld	a,b
;	; is it a number?
;	cp	'0'	; bigger than 0 
;	jr.	c,99f	
;	cp	'9'+1	; smaller than 9?
;	jr.	nc,99f
;	sub 	'0'
;	jr.	22f
;99:	
;	cp	'a'
;	jr.	c,99f
;	cp	'f'+1
;	jr.	nc,99f
;	sub	'a'-10
;	jr.	22f
;99:	
;	cp	'A'
;	jr.	c,0f
;	cp	'F'+1
;	jr.	nc,0f
;	sub	'A'-10
;;	ld	d,a
;22:	
;	add	a
;	add	a
;	add	a
;	add	a
;	
;	ld	d,a	
;	call	get_drumsample_location
;	inc	hl
;	inc	hl
;	inc	hl
;	ld	a,(hl)
;	and	0x0f
;	or	d
;	ld	(hl),a
;	jr.	update_drumeditbox		
;0:
;	ret		
;

;=============================
; Set the cursor at the next drum column 
; 
;=============================
next_drum_column:
	ld	hl,_COLTAB_DRUMSAMPLE
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
	ret
	

_drum_jr._to_vol:
	call	next_drum_column
	ld	a,(cursor_input)
	cp	8				; 8 or 9 is volume
	jr.	c,_drum_jr._to_vol
	ret
	
	
	
;===========================================================
; --- get_drumsample_track_location:
;
; returns in hl the start ofthe current track in the sample line.
; Changes: A, HL and BC
;===========================================================
get_drumsample_track_location:	
	call	get_drumsample_location
	inc	hl
	ld	a,(cursor_column)		
	ld	b,0
	cp	8			; < column 8
	jr.	c,_gdstl_add
	inc	b
	cp	9			; < column 9
	jr.	c,_gdstl_add
	inc	b	
	cp	12			; < column 12
	jr.	c,_gdstl_add
	inc	b
	cp	14			; < column 14
	jr.	c,_gdstl_add
	inc	b	
	cp	17			; < column 17
	jr.	c,_gdstl_add
	inc	b
	
_gdstl_add:
	ld	a,b
	add	a,l
	ld	l,a
	jr.	nc,0f
	inc	h
0:
	ret
;===========================================================
; --- get_drumsample_location:
;
; returns in hl the start ofthe current sample line.
; Changes: A, HL and BC
;===========================================================
get_drumsample_location:
	;--- get the location in RAM
	call	_get_drum_start
	
	inc	hl	; length
;	inc	hl
	
	
	;--- add the current line to the start of the sample
	ld	a,(drum_line)
	and	a
	ret	z
	ld	bc,7		; b is 0
88:
	add	hl,bc
	dec	a
	jr.	nz,88b
	
	ret



;===========================================================
; --- process_key_drumtype
;
;  
;===========================================================
process_key_drumtype:
	ld	a,(key)
	cp	_ESC
	jr.	nz,0f
		call	restore_cursor
		jr. process_key_drumtype_END
0:
	;--- Toggle	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	z,44f
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		
		ld	a,(drum_type)
		inc	a
		and	1
		ld	(drum_type),a
		call	drum_defaults_set	
		call	update_drumeditbox
0:
process_key_drumtype_END:
	ret


;===========================================================
; --- process_key_macrobox_octave
;
;  
;===========================================================
process_key_drumeditbox_octave:
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
		jr.	process_key_drumeditbox_octave_END
0:		
	;--- Key_up - Pattern down	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
44:		dec	c
		ld	a,c
		jr.	z,process_key_drumeditbox_octave_END
88:		ld	(song_octave),a
		call	update_drumeditbox
		jr.	process_key_drumeditbox_octave_END	
0:
	;--- Key_down - Pattern up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		ld	a,c
		cp	7
		jr.	nc,process_key_drumeditbox_octave_END
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
		call	update_drumeditbox
		jr.	process_key_drumeditbox_octave_END
0:	
process_key_drumeditbox_octave_END:
	ret


;===========================================================
; --- process_key_macrobox_len
;
;
;===========================================================
process_key_drumeditbox_len:
	;get drum macro location in RAM
	call	_get_drum_start
	
	ld	a,(key)
	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		
	call	restore_cursor
	jr.	update_drumeditbox
0:		
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
	;--- len down
44:		ld	a,(hl)
		cp	1
		ret	z
		dec	a
		ld	(hl),a
		jr.	update_drumeditbox		

0:		
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
	;--- sample nr up
44:		ld	a,(hl)
		cp	16
		ret	z
		inc	a
		ld	(hl),a
		jr.	update_drumeditbox

0:	ret


;===========================================================
; --- process_key_macrobox_type
;
;
;===========================================================
;process_key_drumeditbox_type:
;	;get drum macro location in RAM
;	call	_get_drum_start
;	inc	hl
;	
;	ld	a,(key)
;	cp	_ENTER
;	jr.	z,44f
;	cp	_ESC
;	jr.	nz,0f
;44:		
;	call	restore_cursor
;	jr.	update_drumeditbox
;0:		
;	cp	_KEY_DOWN
;	jr.	z,44f
;	cp	_KEY_LEFT
;	jr.	nz,0f
;	;--- len down
;44:		ld	a,(hl)
;		cp	0
;		jr.	nz,33f
;		ld	a,3
;33:		dec	a
;		ld	(hl),a
;		jr.	update_drumeditbox		
;
;0:		
;	cp	_KEY_UP
;	jr.	z,44f
;	cp	_KEY_RIGHT
;	jr.	nz,0f
;	;--- sample nr up
;44:		ld	a,(hl)
;		cp	2
;		jr.	c,33f
;		ld	a,-1
;33:		inc	a
;		ld	(hl),a
;		jr.	update_drumeditbox
;
;0:	ret





;===========================================================
; --- process_key_description
;
; Process the song name input
; 
;===========================================================
process_key_drumeditbox_description:
	;--- Set the start of the drum name.
	ld	a,(song_cur_drum)
	ld	l,a
	xor	a		; [a] to catch carry bit
	sla	l		; offset  *16
	sla	l
	sla	l
	sla	l
	adc	a,0		; only the 4th shift can cause carry
	ld	h,a
	ld	de,song_drum_list-16
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
		;call	reset_cursor_macrobox
		jr.	process_key_drumeditbox_description_END

0:
	;--- Check for RIGHT
	cp	_KEY_RIGHT
	jr.	nz,99f
		ld	a,(cursor_x)
		cp	30+15
		jr.	nc,process_key_drumeditbox_description_END
		call	flush_cursor
		inc	a
		ld	(cursor_x),a
		jr.	process_key_drumeditbox_description_END			
99:	
	
	;--- Check for LEFT
	cp	_KEY_LEFT
	jr.	nz,99f
		ld	a,(cursor_x)
		cp	31
		jr.	c,process_key_drumeditbox_description_END
		call	flush_cursor
		dec	a
		ld	(cursor_x),a
		jr.	process_key_drumeditbox_description_END
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
		call	update_drumeditbox
		jr.	process_key_drumeditbox_description_END

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
		call	update_drumeditbox
		jr.	process_key_drumeditbox_description_END	

99:
	;--- All other (normal) keys
	cp	32
	jr.	c,process_key_drumeditbox_description_END
	cp	128
	jr.	nc,process_key_drumeditbox_description_END
	
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
	call	update_drumeditbox
	jr.	process_key_drumeditbox_description_END
		
			
process_key_drumeditbox_description_END
;	call	build_instrument_list
	ret



;===========================================================
; --- reset_cursor_macrobox
;
; Reset the cursor to the top left of the pattern.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_drumeditbox:
	
	ld	a,(editsubmode)
	and	a
	jr.	nz,0f	
	;--- Sample edit
		ld	a,1
		ld	(cursor_type),a
		ld	a,10
		ld	(cursor_y),a
		ld	a,4
		ld	(cursor_x),a
		xor	a
		ld	(drum_line),a
		ld	(drum_macro_offset),a
		inc	a 
		ld	(cursor_type),a	
		ld	a,0		; start at db bit
		ld	(cursor_input),a
		xor	a
		ld	(drum_line),a
		ld	a,0
		ld	(cursor_column),a
		ret
0:
	dec	a
	jr.	nz,0f
	;--- Waveform.
		jr.	99f	
0:
	dec	a
	jr.	nz,0f
	;--- Drum length
		ld	a,3+5+8
		ld	(cursor_x),a
		ld	a,2
		ld	(cursor_type),a	
		jr.	99f		
0:
	dec	a
	jr.	nz,0f
	;--- Drum ???
		jr.	99f	
0:	
	dec	a
	jr.	nz,0f
	;--- OCtave 
		ld	a,3+5+6+7+9+18
		ld	(cursor_x),a
		ld	a,2
		ld	(cursor_type),a	
		jr.	99f
0:	
	dec	a
	jr.	nz,0f
	;--- Drumtype
		ld	a,3+5+8+5
		ld	(cursor_x),a
		ld	a,2
		ld	(cursor_type),a	
		jr.	99f		
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

