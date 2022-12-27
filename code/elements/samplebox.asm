
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

	;box around waveform
	ld	hl,(80*9)+32+14
	ld	de,(34*256) + 17
	call	draw_box	
	;box around waveform data
	ld	hl,(80*17)+32
	ld	de,(15*256) + 9
	call	draw_box	

	ld	hl,(80*6)+1+8
	ld	de,_LABEL_SAPMPLEBOX
	call	draw_label
	
	ld	hl,(80*7)+2+8
	ld	de,_LABEL_SAPMPLETEXT
	call	draw_label

	ld	hl,(80*25)+1
	ld	de,_LABEL_SAMPLE_KB
	call	draw_label


	ld	hl,(80*9)+1
	ld	de,_LABEL_SAPMPLEMACRO
	call	draw_label


;	ld	hl,(80*9)+1+28+4
;	ld	de,_LABEL_SAMPLEFORM
;	call	draw_label


	ld	hl,0x0806
	ld	de,0x3103	
	call	draw_colorbox	
	; length
	ld	hl,0x0f08
	ld	de,0x0401	
	call	erase_colorbox
	; restart	
	ld	hl,0x1408
	ld	de,0x0401	
	call	erase_colorbox

	;base note
	ld	hl,0x1908
	ld	de,0x0401	
	call	erase_colorbox

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

	;--- waveform small * 6
	ld	hl,0x020b
	ld	de,0x2404	
	call	erase_colorbox	

	; sample frame data
;	ld	hl,0x040a
;	ld	de,0x0e0e	
;	call	erase_colorbox	

      ;-- memory row
	ld	hl,0x1012
	ld	de,0x1008	
	call	erase_colorbox	

;	; sample edit values	
;	ld	hl,0x170c
;	ld	de,0x0504	
;	call	erase_colorbox

;	; sample edit values	
;	ld	hl,0x330a
;	ld	de,0x1010	
;	call	erase_colorbox


	; hex wave values
	ld	hl,0x2312
	ld	de,0x0b08	
	call	erase_colorbox
	
;	ld	hl,(80*17)+1+28+4
;	ld	de,_LABEL_SAMPLEEDIT
;	call	draw_label
	
	;wavearea 
	ld	hl,0x2f0a
	ld	de,0x2010	
	call	erase_colorbox

		
	ret
	
_LABEL_SAPMPLEBOX:
	db	"Sample edit:",0
_LABEL_SAPMPLEMACRO:
	db	"Sample:",0

_LABEL_SAPMPLETEXT:
	db	"Sam: Len: Rst: Bse: Description:     Oct:",0
_LABEL_SAMPLE_NR:	
	db	_ARROWLEFT,"0x",_ARROWRIGHT,0
_LABEL_SAMPLE_LEN:
	db	_ARROWLEFT,"xx",_ARROWRIGHT,0
_LABEL_SAMPLE_RST:
	db	_ARROWLEFT,"xx",_ARROWRIGHT,0
_LABEL_SAMPLE_BASE:
	db	_ARROWLEFT,"xx",_ARROWRIGHT,0
_LABEL_SAMPLE_OCT:
	db	_ARROWLEFT,"xx",_ARROWRIGHT,0
_LABEL_SAMPLE_KB:
	db	"0 - - - 4 - - - 8 - - -12 - - -16",0
_LABEL_SAMPLE_MEMORY:
	db	"                "
	db	"                "
	db	"                "
	db	"                "
	db	0
_LABEL_SAMPLE_NOTE: 
	db	"Base:  x-x",0
_LABEL_SAMPLE_START: 
	db	"Start: $0000",0
_LABEL_SAMPLE_END: 
	db	"End:   $0000",0
_LABEL_SAMPLE_LOOP: 
	db	"Loop:  $0000",0
_sample_SAMPLESTRING:
	db	"   _____|---   .|--- . .|--- . ."

_LABEL_SAMPLE_TOP:
	db	182,184,186,188,190,192, 194,196,198,200,202,204, 206,208,210,212,214,216, 218,220,222,224,226,228, 230,232,234,236,238,240, 242,244,246,248,250,252,0
_LABEL_SAMPLE_BOTTOM:
	db	183,185,187,189,191,193, 195,197,199,201,203,205, 207,209,211,213,215,217, 219,221,223,225,227,229, 231,233,235,237,239,241, 243,245,247,249,251,253,0
_LABEL_SAMPLE_STEP:
	db	"| ... | ... | ... | ... | ... | ... |",0


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
	jr.	nc,99f
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
	ld	hl,_LABEL_SAMPLE_MEMORY
	ld	a,(sample_end+1)  			; high byte
	sub	$80
;	srl	a	
	ld	b,63
	ld	c,'*'
.memory_loop:
	and	a
	jr.	nz,99f
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
	jr.	nc,99f
	inc	h
99:
	inc	ixh
	ld	a,ixh
	cp	16
	jr.	nz,.name_loop


	;---- Draw sample base notes
	ld	ixh,16
	ld	bc,sample_offsets
	ld	hl,(80*10)+60

.note_loop:
	ld	a,(bc)
	push	bc
	push	hl
	ld	de,_LABEL_SAMPLE_NOTE+11
	ld	hl,_LABEL_NOTES
	ld	b,0
	ld	c,a
	add	hl,bc
	add	hl,bc
	add	hl,bc
	;--- copy note label to [DE]
[3]	ldi

	ld	de,_LABEL_SAMPLE_NOTE+11
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
	jr.	nc,99f
	inc	h
99:
	;--- next tone value
	inc	bc
	inc	bc
	inc	bc
	inc	bc


	dec	ixh
	jr.	nz,.note_loop



	;draw memory usage
	ld	hl,(80*18)+16
	ld	de,_LABEL_SAMPLE_MEMORY
	ld	b,16
	call	draw_label_fast
	ld	hl,(80*19)+16
	ld	b,16
	call	draw_label_fast
	ld	hl,(80*20)+16
	ld	b,16
	call	draw_label_fast
	ld	hl,(80*21)+16
	ld	b,16
	call	draw_label_fast

	;--- tone - note
	ld	de,sample_offsets
	ld	a,(sample_current)
[2]	add	a			; times 4
	add	a,e
	ld 	e,a
	jr.	nc,99f
	inc	d
99:
	ld	a,(de)
	ld	de,_LABEL_SAMPLE_NOTE+11
	ld	hl,_LABEL_NOTES
	ld	b,0
	ld	c,a
	add	hl,bc
	add	hl,bc
	add	hl,bc

	;--- copy note label to [DE]
[3]	ldi

	ld	de,_LABEL_SAMPLE_NOTE
	ld	hl,(80*16)+1	
	call	draw_label
	ld	de,_LABEL_SAMPLE_START
	ld	hl,(80*17)+1	
	call	draw_label
	ld	de,_LABEL_SAMPLE_END
	ld	hl,(80*18)+1	
	call	draw_label
	ld	de,_LABEL_SAMPLE_LOOP
	ld	hl,(80*19)+1	
	call	draw_label

	;----- New code for wavform gfx display
	;
	ld	de,_LABEL_SAMPLE_TOP
	ld	hl,(80*12)+2	
	call	draw_label
	ld	de,_LABEL_SAMPLE_BOTTOM
	ld	hl,(80*11)+2	
	call	draw_label


	ld	de,_LABEL_SAMPLE_STEP+1
	ld	a,(sample_step)
	call	draw_hex2

	ld	de,_LABEL_SAMPLE_STEP
	ld	hl,(80*10)+1	
	call	draw_label
	;
	;
	;
	;
DEBUG:
	;--- Clear gfx data
	ld	hl,sample_frames
	ld	de,sample_frames+1
	ld	bc,575
	ld	(hl),0
	ldir

	;---- create wave form gfx
	call	set_samplepage
	ld	de,sample_frames

	ld	a,(sample_current)
	call	get_sample

	inc	hl		; skip base tone value
	inc	hl

	ld	a,(hl)	; get pointer to start sample frame
	inc	hl
	ld	h,(hl)
	ld	l,a

	ld	a,(sample_step)
	and	a
	jp	z,.loop_step_skip
	ld	bc,34
.loop_step:
	add	hl,bc
	dec	a
	jp	nz,.loop_step
.loop_step_skip:



	;---- loop 6 frames
	call	sample_draw_frame
	call	sample_draw_frame
	call	sample_draw_frame
	call	sample_draw_frame
	call	sample_draw_frame
	call	sample_draw_frame

	ld	hl,$95B0+$800 
	call	set_vdpwrite

	ld	hl,sample_frames
	ld	d,3
	ld	bc,0xC098
1:	;--- sub loop
	ld	a,(hl)
	inc	hl
	out	(c),a
	djnz 	1b
	ld	b,$c0
	dec	d
	jp	nz,1b


	call	set_songpage
	ret

;--- Get the start of the sample info 
get_sample:
	add	a
	add	a
	add	a
	ld	h,$80	; start op sample list
	ld	l,a
	ret
;-----------------------------------------
; process a sample frame (34 bytes)
; HL = sample frame start
; DE = sample gfx data
sample_draw_frame:

	push	de		; store for filling in

	inc	hl		; skip frame tone value
	inc	hl

	ld	c,0100000b		; mask
	ld	b,32
	;--- Translate the values into gfx data
.waveloop:
	ld	a,(hl)
	neg
	rrca			; divide 16
	rrca
	rrca
	rrca
	and	00001111b

	push	de
	add	a,e
	ld	e,a
	jp	nc,99f
	inc	d
99:
	ld	a,(de)		
	or	c
	ld	(de),a
	
	pop	de
	inc	hl
	rrc	c
	bit	1,c
	jp	z,.nocarry
	;--- next pattern collumn
	ld	c,10000000b
	ld	a,16
	add	a,e
	ld	e,a
	jp	nc,99f
	inc	d
99:
.nocarry:
	djnz	.waveloop

	ex	de,hl
	pop	hl	; get start of gfx data
	push	hl	; store

	;---- Fill in the waveform
	ld	a,8
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	bc,$0806	; 8 lines of 6 tiles
	xor	a
.fillloop_pos:
	or	(hl)
	ld	(hl),a
	inc	hl
	djnz	.fillloop_pos
	ld	a,8
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	b,8
	xor	a
	dec	c
	jp	nz,.fillloop_pos

	pop	hl	; get start of gfx data
	;--- add 7
	ld	a,7
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	bc,$0806	; 8 lines of 6 tiles
	xor	a
.fillloop_neg:
	or	(hl)
	ld	(hl),a
	dec	hl
	djnz	.fillloop_neg
	ld	a,24
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	b,8
	xor	a
	dec	c
	jp	nz,.fillloop_neg

	ex	de,hl
	ld	a,e
	sub	7
	ld	e,a
	jp	nc,99f
	dec	d
99:
	ret


sample_frames:
[576]	db	0



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
	jr.	nz,0f

	ld	a,(editsubmode)
	cp	3
	jr.	z,process_key_samplebox_END
	inc	a
	ld	(editsubmode),a
	call	flush_cursor
	ld	a,(cursor_y)
	inc	a
	ld	(cursor_y),a

	jr.	process_key_samplebox_END
0:
	cp	_KEY_UP
	jr.	nz,0f

	ld	a,(editsubmode)
	and	a
	jr.	z,process_key_samplebox_END
	dec	a
	ld	(editsubmode),a
	call	flush_cursor
	ld	a,(cursor_y)
	dec	a
	ld	(cursor_y),a
	jr.	process_key_samplebox_END

0:
	cp	_KEY_RIGHT
	jr.	nz,0f

	ld	a,(sample_step)
	inc	a
;	and	a
	jp	z,process_key_samplebox_END	
	ld	(sample_step),a
	call	update_sampleeditor
	jr.	process_key_samplebox_END
0:
	cp	_KEY_LEFT
	jr.	nz,0f

	ld	a,(sample_step)
	and	a
	jp	z,process_key_samplebox_END
	dec	a
	
	ld	(sample_step),a
	call	update_sampleeditor
	jr.	process_key_samplebox_END
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
	jr.	nc,99f
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
	jr.	c,.nomatch_high
	jr.	nz,.match_end_high

	dec	de
	dec	hl
.loop_low:
	ld	a,(de)
	cp	(hl)
	jr.	c,.nomatch_low
	jr.	.match_end_low

.nomatch_low:
	inc	b
	inc	hl
	inc	hl
	jr.	.loop_low	

.nomatch_high:
	inc	b
	inc	hl
	inc	hl
	jr.	.loop_high


.match_end_low:
.match_end_high:
	ld	a,(sample_current)
	add	a
	add	a
	ld	hl,sample_offsets
	add	a,l
	ld	l,a
	jr.	nc,99f
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
	jr.	nz,.no_end_low
	inc	hl
	cp	(hl)
	jr.	z,.end_found
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
	jr.	c,.before_start
	ld	a,l
	cp	c
	jr.	c,.before_start
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
	jr.	c,.pointer_loop


	;--- set new sample_end
	ld	hl,(sample_end)
	ld	bc,(temp_len)
	sbc	hl,bc
	ld	(sample_end),hl

	call	set_songpage

	ret