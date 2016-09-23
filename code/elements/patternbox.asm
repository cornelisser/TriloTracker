;===========================================================
; --- draw_patternbox
;
; Display the pattern area.  Without actual values 
; 
;===========================================================
draw_patternbox:

;	call	get_waveform_val


	; pattern box
	ld	hl,(80*6)+8
	ld	de,(49*256) + 3
	call	draw_box	
	ld	hl,(80*6)+1+8
	ld	de,_LABEL_PATTERNBOX
	call	draw_label
	ld	hl,(80*7)+2+8
	ld	de,_LABEL_PATTERNTEXT
	call	draw_label
	ld	hl,(80*8)+2+8
	ld	de,_LABEL_PATTERNTEXT2
	call	draw_label
	ld	hl,0x0806
	ld	de,0x3103	
	call	draw_colorbox	
	ld	hl,0x0a08
	ld	de,0x0501	
	call	erase_colorbox	
	ld	hl,0x1008
	ld	de,0x0501	
	call	erase_colorbox		
	ld	hl,0x1608
	ld	de,0x0501	
	call	erase_colorbox
	ld	hl,0x1c08
	ld	de,0x0401	
	call	erase_colorbox
	ld	hl,0x2908
	ld	de,0x0401	
	call	erase_colorbox
	ld	hl,0x2e08
	ld	de,0x0401	
	call	erase_colorbox
	ld	hl,0x3308
	ld	de,0x0401	
	call	erase_colorbox
	
	call	draw_pattern_header	
	

	
	ret
	
_LABEL_PATTERNBOX:
	db	"edit:",0
_LABEL_PATTERNTEXT:
	db	"Pat:  Len:  Rst:  Spd:         Oct: sTp: Add:",0
_LABEL_PATTERNTEXT2:	
	db	_ARROWLEFT,"xxx",_ARROWRIGHT,32
	db	_ARROWLEFT,"xxx",_ARROWRIGHT,32
	db	_ARROWLEFT,"xxx",_ARROWRIGHT,32
	db	_ARROWLEFT,"xx",_ARROWRIGHT,32
	db	"        "	
	db	_ARROWLEFT,"xx",_ARROWRIGHT,32
	db	_ARROWLEFT,"xx",_ARROWRIGHT,32
	db	_ARROWLEFT,"xx",_ARROWRIGHT,0	
	
	
			
;===========================================================
; --- update_patternbox
;
; Display the pattern area values.
; 
;===========================================================
update_patternbox:
	ld	a,(song_pattern)
	ld	de,_LABEL_PATTERNTEXT2+1
	call	draw_decimal_3

	ld	de,_LABEL_PATTERNTEXT2+7
	ld	a,(song_order_len)
	call	draw_decimal_3

	ld	de,_LABEL_PATTERNTEXT2+13
	ld	a,(song_order_loop)
	call	draw_decimal_3

	ld	de,_LABEL_PATTERNTEXT2+19
	ld	a,(song_speed)
	call	draw_decimal

	ld	de,_LABEL_PATTERNTEXT2+25+7
	ld	a,(song_octave)
	call	draw_decimal

	ld	de,_LABEL_PATTERNTEXT2+25+7+5
	ld	a,(song_step)
	call	draw_decimal

	ld	de,_LABEL_PATTERNTEXT2+25+7+10
	ld	a,(song_add)
	call	draw_decimal


	ld	hl,(80*8)+2+8+1
	ld	de,_LABEL_PATTERNTEXT2+1
	ld	b,43
	call	draw_label_fast
	
;	ld	hl,song_speed
;	ld	de,(8*80)+3+8+5+5+5+3
;	call	draw_decimal	
;	ld	hl,song_octave
;	ld	de,(8*80)+23+8+11
;	call	draw_decimal
;	ld	hl,song_step
;	ld	de,(8*80)+18+5+5+8+11
;	call	draw_decimal	
;	ld	hl,song_add
;	ld	de,(8*80)+18+5+5+8+11+5
;	call	draw_decimal	
	

	
	ret
	
;===========================================================
; --- process_key_patternbox_pattern
;
; 
; 
;===========================================================
process_key_patternbox_pattern:
	ld	a,(song_pattern)
	ld	c,a
	ld	a,(key)

	;--- Check if edit is ended.
	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		ld	a,0
		ld	(editsubmode),a
		call	restore_cursor
		;call	reset_cursor_trackbox
		jr.	process_key_patternbox_pattern_END
0:		
	;--- Key_up - Pattern down	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
44:		ld	a,c
		and	a
		jr.	z,process_key_patternbox_pattern_END
		dec	a
88:		ld	(song_pattern),a
		call	update_patterneditor
		jr.	process_key_patternbox_pattern_END	
0:
	;--- Key_down - Pattern up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		
;		ld	a,c
;		cp	SONG_MAXPAT-1
;		jr.	nc,process_key_patternbox_pattern_END
		ld	a,(max_pattern)
		cp	c
		jr.	c,process_key_patternbox_pattern_END
		ld	a,c

		inc	a
		jr.	88b	
0:	
process_key_patternbox_pattern_END:
	ret


;===========================================================
; --- process_key_patternbox_restart
;
; 
; 
;===========================================================
process_key_patternbox_restart:
	ld	a,(key)

	;--- Check if edit is ended.
	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		ld	a,0
		ld	(editsubmode),a
		call	restore_cursor
		jr.	process_key_patternbox_restart_END
0:		
	;--- Key_up - restart down	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
44:		ld	a,(song_order_loop)
		and	a
		jr.	z,process_key_patternbox_restart_END
		dec	a
88:		ld	(song_order_loop),a
		call	update_patterneditor
		jr.	process_key_patternbox_restart_END	
0:
	;--- Key_down - length up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		ld	a,(song_order_len)
		ld	b,a
		ld	a,(song_order_loop)
		cp	b
		jr.	nc,process_key_patternbox_restart_END
		inc	a
		jr.	88b	
0:	
process_key_patternbox_restart_END:
	ret



;===========================================================
; --- process_key_patternbox_Length
;
; 
; 
;===========================================================
process_key_patternbox_length:

	ld	a,(key)

	;--- Check if edit is ended.
	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		ld	a,0
		ld	(editsubmode),a
		call	restore_cursor
		jr.	process_key_patternbox_length_END
0:		
	;--- Key_up - length down	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
44:		ld	a,(song_order_len)
		dec	a
		jr.	z,process_key_patternbox_length_END
88:		ld	(song_order_len),a
		;--- make sure restart is nog bigger than length
		ld	bc,(song_order_loop)
		cp	c
		jr.	nc,77f
		ld	(song_order_loop ),a

77:
		call	build_order_list
		call	update_patterneditor
		jr.	process_key_patternbox_length_END	
0:
	;--- Key_down - length up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		ld	a,(song_order_len)
		cp	SONG_SEQSIZE
		jr.	nc,process_key_patternbox_length_END
		inc	a
		jr.	88b	
0:	
process_key_patternbox_length_END:
	ret


;===========================================================
; --- process_key_patternbox_speed
;
; 
; 
;===========================================================
process_key_patternbox_speed:
	ld	a,(song_speed)
	ld	c,a
	ld	a,(key)

	;--- Check if edit is ended.
	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		ld	a,0
		ld	(editsubmode),a
		call	restore_cursor
		;call	reset_cursor_trackbox
		jr.	process_key_patternbox_speed_END
0:		
	;--- Key_up - Pattern down
	cp	_KEY_DOWN
	jr.	z,44f	
	cp	_KEY_LEFT
	jr.	nz,0f
44:		dec	c
		ld	a,c
		cp	2
		jr.	c,process_key_patternbox_speed_END
88:		ld	(song_speed),a
		call	update_patterneditor
		jr.	process_key_patternbox_speed_END	
0:
	;--- Key_down - Pattern up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		ld	a,c
		cp	63
		jr.	nc,process_key_patternbox_speed_END
		inc	a
		jr.	88b	
0:	
process_key_patternbox_speed_END:
	ret


;===========================================================
; --- process_key_patternbox_octave
;
; 
; 
;===========================================================
process_key_patternbox_octave:
	ld	a,(song_octave)
	ld	c,a
	ld	a,(key)

	;--- Check if edit is ended.
	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		ld	a,0
		ld	(editsubmode),a
		call	restore_cursor
		;call	reset_cursor_trackbox
		jr.	process_key_patternbox_octave_END
0:		
	;--- Key_up - Pattern down	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
44:		dec	c
		ld	a,c
		jr.	z,process_key_patternbox_octave_END
88:		ld	(song_octave),a
		call	update_patterneditor
		jr.	process_key_patternbox_octave_END	
0:
	;--- Key_down - Pattern up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		ld	a,c
		cp	7
		jr.	nc,process_key_patternbox_octave_END
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
		call	update_patterneditor
		jr.	process_key_patternbox_octave_END
		
	

0:	
process_key_patternbox_octave_END:
	ret


;===========================================================
; --- process_key_patternbox_step
;
; 
; 
;===========================================================
process_key_patternbox_step:
	ld	a,(song_step)
	ld	c,a
	ld	a,(key)

	;--- Check if edit is ended.
	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		ld	a,0
		ld	(editsubmode),a
		call	restore_cursor
		;call	reset_cursor_trackbox
		jr.	process_key_patternbox_step_END
0:		
	;--- Key_up - Pattern down	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
44:		dec	c
		ld	a,c
		cp	1
		jr.	z,process_key_patternbox_step_END
88:		ld	(song_step),a
		call	update_patterneditor
		jr.	process_key_patternbox_step_END	
0:
	;--- Key_down - Pattern up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		ld	a,c
		cp	32
		jr.	nc,process_key_patternbox_step_END
		inc	a
		jr.	88b	
0:	
process_key_patternbox_step_END:
	ret


process_key_patternbox_add:
	ld	a,(song_add)
	ld	c,a
	ld	a,(key)

	;--- Check if edit is ended.
	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		ld	a,0
		ld	(editsubmode),a
		call	restore_cursor
		;call	reset_cursor_patternbox
		jr.	process_key_patternbox_add_END
0:	
	;--- Key_up - Pattern down	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
44:		ld	a,c
		cp	0
		jr.	z,process_key_patternbox_add_END
		dec	a
88:		ld	(song_add),a
		call	update_patternbox
		jr.	process_key_patternbox_add_END	
0:
	;--- Key_down - Pattern up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		ld	a,c
		cp	16
		jr.	nc,process_key_patternbox_add_END
		inc	a
		jr.	88b	
0:	
process_key_patternbox_add_END:
	ret

;===========================================================
; --- check_cursor_patternbox
;
; Checks if the cursor is still in boundaries of current pattern
; If not the cursor is placed on the last valid line of the pattern
; BE SURE TO USE THIS FUNCTION AFTER update_trackbox when switching
; pattern
;===========================================================
check_cursor_patternbox:
	call	GET_P2
	push	af
	;--- Calculate the pattern length
	
	ld	a,(song_pattern)	; set the pattern data
	ld	b,a
	call	set_patternpage

	inc	hl			; set pointer to vol/cmd byte
	inc	hl
	
	ld	bc,0x4008			; check 64 rows 8 channels
	ld	d,1				; default patternlength
	
_ccp_loop:	
	ld	a,(hl)
	and	0xf			; get low 4 bits
	cp	0xd			; D command?
	jr.	z,_ccp_end_loop

	ld	a,l			; go to next vol/cmd byte
	add	4
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	dec	c
	jr.	nz,_ccp_loop

	ld	c,8
	inc	d			; increase line nr	
	dec	b
	jr.	nz,_ccp_loop
	
_ccp_end_loop:	
	;--- no offset
;	ld	a,(current_song)
	call	set_songpage_safe

	ld	a,(cursor_y)
	sub	10
	ld	b,a
	ld	a,(song_pattern_offset)
	ld	c,a
	add	b
	cp	d
	
	jr.	c,_cpp_END

	;--- cursor is outside pattern. 
	ld 	a,15
	cp	d		; do we need to set pattern offset?
	
	jr.	c,88f	; jump if we need to set offset
	

	ld	a,d
	dec	a
	ld	(song_pattern_line),a
	add	10
	ld	(cursor_y),a
	xor	a
	ld	(song_pattern_offset),a
	jr.	_cpp_END
	
	;--- offset needed
88:
	ld	a,10+15 
	ld	(cursor_y),a
	ld	a,d
	dec	a
	ld	(song_pattern_line),a
	sub	15
	ld	(song_pattern_offset),a

_cpp_END:
	pop	af
	call	PUT_P2
	ret


;===========================================================
; --- reset_cursor_patternbox
;
; Reset the cursor to the top left of the patternbox.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_patternbox:
	call	flush_cursor
	ld	a,8
	ld	(cursor_y),a
	
	ld	a,(editsubmode)
	sub	3
	jr.	nz,1f
	;--- Pattern number
		ld	a,3
		ld	(cursor_type),a		
		ld	a,3+8
		jr.	reset_cursor_patternbox_END
1:	dec	a	
	jr.	nz,1f
	;--- Pattern Length
		ld	a,3
		ld	(cursor_type),a		
		ld	a,3+5+8+1	
		jr.	reset_cursor_patternbox_END	
1:	dec	a	
	jr.	nz,1f
	;--- Song Speed
		ld	a,2
		ld	(cursor_type),a		
		ld	a,3+5+5+8+5+3	
		jr.	reset_cursor_patternbox_END	
1:	dec	a	
	jr.	nz,1f
	;--- Octave
		ld	a,2
		ld	(cursor_type),a		
		ld	a,3+5+5+5+8+11+5	
		jr.	reset_cursor_patternbox_END	
1:	dec	a	
	jr.	nz,1f
		jr.	reset_cursor_patternbox_END	
1:	dec	a
	jr.	nz,1f
	;--- Patternorder Restart
		ld	a,3
		ld	(cursor_type),a		
		ld	a,3+5+8+5+2	
		jr.	reset_cursor_patternbox_END		
1:	dec	a
	jr.	nz,1f	
	;--- Add
		ld	a,2
		ld	(cursor_type),a		
		ld	a,3+5+5+5+5+8+11+5+5
		jr.	reset_cursor_patternbox_END
1:	dec	a
	jr.	nz,1f	
	;--- Step
		ld	a,2
		ld	(cursor_type),a		
		ld	a,3+5+5+5+5+8+11+5	
		jr.	reset_cursor_patternbox_END
1:		
			
				
reset_cursor_patternbox_END:	
	ld	(cursor_x),a
	ret
	

_LABEL_DISABLED:
	db	"        "	
;===========================================================
; --- draw pattern header
;
; Show the enables channels in the header
;===========================================================
draw_pattern_header:
IFDEF	TTSCC
ELSE
	ld	a,(replay_chan_setup)
	and 	a
	jp	z,99f
	ld	de,_LABEL_PATTERNHEADER2	
	jp	88f
99:
ENDIF
	ld	de,_LABEL_PATTERNHEADER
88:
	ld	hl,(80*9)+0
	call	draw_label	

	ld	a,(MainMixer)
	bit	5,a
	jr.	nz,0f
		ex	af,af'	;'
		ld	hl,(80*9)+4
		ld	de,_LABEL_DISABLED
		ld	b,8
		call	draw_label_fast
		ex	af,af'	;'	
0:
	bit	6,a
	jr.	nz,0f
		ex	af,af'	;'
		ld	hl,(80*9)+4+9
		ld	de,_LABEL_DISABLED
		ld	b,8
		call	draw_label_fast
		ex	af,af'	;'	
0:	
	bit	7,a
	jr.	nz,0f
		ex	af,af'	;'
		ld	hl,(80*9)+4+18
		ld	de,_LABEL_DISABLED
		ld	b,8
		call	draw_label_fast
		ex	af,af'	;'	
0:		
	bit	0,a
	jr.	nz,0f
		ex	af,af'	;'
		ld	hl,(80*9)+4+27
		ld	de,_LABEL_DISABLED
		ld	b,8
		call	draw_label_fast
		ex	af,af'	;'	
0:
	bit	1,a
	jr.	nz,0f
		ex	af,af'	;'
		ld	hl,(80*9)+4+36
		ld	de,_LABEL_DISABLED
		ld	b,8
		call	draw_label_fast
		ex	af,af'	;'	
0:
	bit	2,a
	jr.	nz,0f
		ex	af,af'	;'
		ld	hl,(80*9)+4+45
		ld	de,_LABEL_DISABLED
		ld	b,8
		call	draw_label_fast
		ex	af,af'	;'	
0:
	bit	3,a
	jr.	nz,0f
		ex	af,af'	;'
		ld	hl,(80*9)+4+54
		ld	de,_LABEL_DISABLED
		ld	b,8
		call	draw_label_fast
		ex	af,af'	;'	
0:
	bit	4,a
	jr.	nz,0f
		ex	af,af'	;'
		ld	hl,(80*9)+4+63
		ld	de,_LABEL_DISABLED
		ld	b,8
		call	draw_label_fast
		ex	af,af'	;'	
0:
	

	ret