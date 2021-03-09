
;===========================================================
; --- draw_samplebox
; Display the sample area.  Without actual values 
; 
;===========================================================
draw_samplebox:
	; box around number, length, restart etc
	ld	hl,(80*6)+8
	ld	de,(49*256) + 3
	call	draw_box
	
	; box around macro lines
	ld	hl,(80*9)+0
	ld	de,(48*256) + 17
	call	draw_box	


	ld	hl,(80*6)+1+8
	ld	de,_LABEL_SAPMPLEBOX
	call	draw_label
	
	ld	hl,(80*7)+2+8
	ld	de,_LABEL_SAPMPLETEXT
	call	draw_label

	ld	hl,(80*23)+9
	ld	de,_LABEL_SAMPLE_KB
	call	draw_label


	ld	hl,(80*9)+1
	ld	de,_LABEL_SAPMPLEMACRO
	call	draw_label


;	ld	hl,(80*9)+1+28+4
;	ld	de,_LABEL_SAMPPLEFORM
;	call	draw_label


	ld	hl,0x0806
	ld	de,0x3103	
	call	draw_colorbox	
	;ld	hl,0x0a08
	;ld	de,0x0501	
	;call	erase_colorbox
		
;	ld	hl,0x1408
;	ld	de,0x0801	
;	call	erase_colorbox
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

      ;-- memory row
	ld	hl,0x0a18
	ld	de,0x1f01	
	call	erase_colorbox	

	; sample edit values	
	ld	hl,0x170c
	ld	de,0x0504	
	call	erase_colorbox

	; sample edit values	
	ld	hl,0x330a
	ld	de,0x1010	
	call	erase_colorbox



	
	; macro data
;	ld	hl,0x090a
;	ld	de,0x2610	
;	call	erase_colorbox	
		
	ret
	
_LABEL_SAPMPLEBOX:
	db	"Sample edit:",0
_LABEL_SAPMPLEMACRO:
	db	"Sample:",0

_LABEL_SAPMPLETEXT:
	db	"Sam:                Description:     Oct:",0
_LABEL_SAMPLE_NR:	
	db	_ARROWLEFT,"0x",_ARROWRIGHT,0
_LABEL_SAMPLE_OCT:
	db	_ARROWLEFT,"xx",_ARROWRIGHT,0
_LABEL_SAMPLE_KB:
	db	  	 "0 - - - 4 - - - 8 - - - 12- - - 16kB",0
_LABEL_SAMPLE_MEMORY:
	db	"Memory:[                               ]",0
_LABEL_SAMPLE_NOTE: 
	db	"Base note:     x-x",0
_LABEL_SAMPLE_START: 
	db	"Start offset: ",_ARROWLEFT,"+00",_ARROWRIGHT,0
_LABEL_SAMPLE_END: 
	db	"End offset:   ",_ARROWLEFT,"-00",_ARROWRIGHT,0
_LABEL_SAMPLE_LOOP: 
	db	"Loop offset:  ",_ARROWLEFT,"-00",_ARROWRIGHT,0
_sample_SAMPLESTRING:
	db	"   _____|---   .|--- . .|--- . ."
_udm_pntpos:	dw	0
;===========================================================
; --- update_samplebox
; Display the values
; 
;===========================================================
update_samplebox:
	;--- Sample info
	ld	de,_LABEL_SAMPLE_NR+2
	ld	a,(sample_current)
	call	draw_hex
	ld	de,_LABEL_SAMPLE_OCT+1
	ld	a,(song_octave)
	call	draw_decimal

	; draw nr 
	ld	de,_LABEL_SAMPLE_NR
	ld	hl,(80*8)+8+2
	ld	b,4
	call	draw_label_fast

	;--- draw sample name
	ld	de,sample_names
	ld	a,(sample_current)
[3]	add	a			; times 8
	add	a,e
	ld 	e,a
	jp	nc,99f
	inc	d
99:
	ld	hl,(80*8)+1+8+21	
	ld	b,8
	call	draw_label_fast

	;draw description + octave
	ld	hl,(80*8)+1+8+38
	ld	de,_LABEL_SAMPLE_OCT
	ld	b,4
	call	draw_label_fast

	;-- Draw memory usage
	ld	hl,_LABEL_SAMPLE_MEMORY+8
	ld	a,(sample_end+1)  			; high byte
	sub	$80
	srl	a	
	ld	b,31
	ld	c,173
.memory_loop:
	and	a
	jp	nz,99f
	ld	c,'-'
	inc	a
99:
	ld	(hl),c
	inc	hl
	dec	a
	djnz	.memory_loop


	;--- Draw sample names
	ld	de,sample_names
	ld	hl,(80*10)+51
	xor	a
	ld	ixh,a
.name_loop:
	push	hl
	ld	b,8
	call	draw_label_fast	
	pop	hl
	ld	a,80
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	inc	ixh
	ld	a,ixh
	cp	16
	jp	nz,.name_loop


	;---- Draw sample base notes
	ld	ixh,16
	ld	bc,sample_offsets
	ld	hl,(80*10)+60

.note_loop:
	ld	a,(bc)
	push	bc
	push	hl
	ld	de,_LABEL_SAMPLE_NOTE+15
	ld	hl,_LABEL_NOTES
	ld	b,0
	ld	c,a
	add	hl,bc
	add	hl,bc
	add	hl,bc
	;--- copy note label to [DE]
[3]	ldi

	ld	de,_LABEL_SAMPLE_NOTE+15
	pop	hl
	push	hl
	ld	b,3
	call	draw_label_fast
	pop	hl
	pop	bc
	;--- output to next line
	ld	a,80
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	;--- next tone value
	inc	bc
	inc	bc
	inc	bc
	inc	bc


	dec	ixh
	jp	nz,.note_loop



	;draw memory usage
	ld	hl,(80*24)+2
	ld	de,_LABEL_SAMPLE_MEMORY
	call	draw_label

	;--- tone - note
	ld	de,sample_offsets
	ld	a,(sample_current)
[2]	add	a			; times 4
	add	a,e
	ld 	e,a
	jp	nc,99f
	inc	d
99:
	ld	a,(de)
	ld	de,_LABEL_SAMPLE_NOTE+15
	ld	hl,_LABEL_NOTES
	ld	b,0
	ld	c,a
	add	hl,bc
	add	hl,bc
	add	hl,bc

	;--- copy note label to [DE]
[3]	ldi

	ld	de,_LABEL_SAMPLE_NOTE
	ld	hl,(80*12)+1+8	
	call	draw_label
	ld	de,_LABEL_SAMPLE_START
	ld	hl,(80*13)+1+8	
	call	draw_label
	ld	de,_LABEL_SAMPLE_END
	ld	hl,(80*14)+1+8	
	call	draw_label
	ld	de,_LABEL_SAMPLE_LOOP
	ld	hl,(80*15)+1+8	
	call	draw_label

	ret

;===========================================================
; --- process_key_samplebox
;
; Process the input for the sample macro. 
; 
; 
;===========================================================
process_key_samplebox:
	
	ld	a,(key)
	and	a
	ret	z

	cp	_KEY_DOWN
	jp	nz,0f

	ld	a,(editsubmode)
	cp	3
	jp	z,process_key_samplebox_END
	inc	a
	ld	(editsubmode),a
	call	flush_cursor
	ld	a,(cursor_y)
	inc	a
	ld	(cursor_y),a

	jp	process_key_samplebox_END
0:
	cp	_KEY_UP
	jp	nz,0f

	ld	a,(editsubmode)
	and	a
	jp	z,process_key_samplebox_END
	dec	a
	ld	(editsubmode),a
	call	flush_cursor
	ld	a,(cursor_y)
	dec	a
	ld	(cursor_y),a
	jp	process_key_samplebox_END
0:

process_key_samplebox_END:
	ret

	


;===========================================================
; --- process_key_macrobox_octave
;
;  
;===========================================================
process_key_samplebox_octave:
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
		jr.	process_key_samplebox_octave_END
0:		
	;--- Key_up - Pattern down	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
44:		dec	c
		ld	a,c
		jr.	z,process_key_samplebox_octave_END
88:		ld	(song_octave),a
		call	update_samplebox
		jr.	process_key_samplebox_octave_END	
0:
	;--- Key_down - Pattern up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		ld	a,c
		cp	7
		jr.	nc,process_key_samplebox_octave_END
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
		call	update_samplebox
		jr.	process_key_samplebox_octave_END
0:	
process_key_samplebox_octave_END:
	ret



;===========================================================
; --- reset_cursor_macrobox
;
; Reset the cursor to the top left of the pattern.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_samplebox:
	call	flush_cursor
;	ld	a,2
;	ld	(cursor_y),a
	ld	a,3
	ld	(cursor_type),a		
	ld	a,24	
	ld	(cursor_x),a
	ld	a,12	
	ld	(cursor_y),a	
	ld	a,0
	ld	(editsubmode),a
	ret



;--------------------------------------------
; sample_get_note
; Determines the base note using the tone value in the sample data
; in [A] sample nr
; out: stores the value at the correct address
;--------------------------------------------
sample_get_note:
	ld	de, $8000
[2]	add	a			; times 4
	add	a,e
	ld 	e,a
	jp	nc,99f
	inc	d
99:
	inc	de
	
	push	de
	call	set_samplepage

	pop	de
	;--- find matching note
	ld	b,2
	ld	hl,TRACK_ToneTable+3
.loop_high:
	ld	a,(de)

	cp	(hl)
	jp	c,.nomatch_high
	jp	nz,.match_end_high

	dec	de
	dec	hl
.loop_low:
	ld	a,(de)
	cp	(hl)
	jp	c,.nomatch_low
	jp	.match_end_low

.nomatch_low:
	inc	b
	inc	hl
	inc	hl
	jp	.loop_low	

.nomatch_high:
	inc	b
	inc	hl
	inc	hl
	jp	.loop_high


.match_end_low:
.match_end_high:
	ld	a,(sample_current)
	add	a
	add	a
	ld	hl,sample_offsets
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	(hl),b

	call	set_songpage

	ret


temp_start:	dw	0
temp_end:		dw	0
temp_len:		dw	0
;--------------------------------------------
; sample_remove :
; Removes the sample from RAM and moves other 
; samples into it's place. Moking room ath the 
; end of RAM
; in: [A] has sample nr
;---------------------------------------------
sample_remove:
	push	af
	call	set_samplepage
	pop	af
	add	a
	add	a	; times 4
	ld	h,$80
	ld	l,a

	;--- Erase the base note
	ld	(hl),0
	inc	hl
	ld	(hl),0
	inc	hl

	;--- Get the start address and erase 
	ld	e,(hl)
	ld	(hl),0
	inc	hl
	ld	d,(hl)
	ld	(hl),0

	;--- check for empty slot
	ld	a,e
	or	d
	ret	z

	ld	(temp_start),de
	;--- get the end of the sample
	ex	de,hl
	ld	a,$FF
	ld	bc,34
.frame_loop:
	cp	(hl)
	jp	nz,.no_end_low
	inc	hl
	cp	(hl)
	jp	z,.end_found
	dec	hl
.no_end_low:
	add	hl,bc
	jr.	.frame_loop


.end_found:
	;--- skip loop bytes + low byte delimiter
	inc	hl
	inc	hl
	inc	hl
	ld	(temp_end),hl	; sample end

	;--- calculate the length
	ld	de,(temp_start)
	xor	a		; reset carry
	sbc	hl,de		; calculate the length of the sample
	ld	(temp_len),hl

	;--- move data up
	ld	de,(temp_start)
	ld	hl,(temp_end)
	ld	bc,(temp_len)
	ldir

	;--- update sample start pointers.
	ld	de,$8002			; start of first pointer


.pointer_loop:
	ld	a,(de)		; get the pointer
	ld	l,a
	inc	de
	ld	a,(de)
	ld	h,a
	inc	de

	ld	bc,(temp_start)					; pointer > sample_start
	cp	b
	jp	c,.before_start
	ld	a,l
	cp	c
	jp	c,.before_start
	;---- update this pointer
	xor	a
	ld	bc,(temp_len)
	sbc	hl,bc
	ex	de,hl
	dec	hl
	dec	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	de
	ex	de,hl
.before_start:
	;-- skip period 
	inc	de
	inc	de
	ld	a,$40			; test is we are done with period/pointer data (16 sampels * 4 bytes)
	cp	l
	jp	c,.pointer_loop


	;--- set new sample_end
	ld	hl,(sample_end)
	ld	bc,(temp_len)
	sbc	hl,bc
	ld	(sample_end),hl

	call	set_songpage

	ret