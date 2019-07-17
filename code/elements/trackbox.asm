;===========================================================
; --- update_trackbox
;
; Display the pattern area values.
; 
;===========================================================
update_trackbox:
;	ld	a,(current_song)
	call	set_songpage


	;---- Show selection (only if not playing)
	ld	a,(replay_mode)
	and	a
	call	z,selection_show	

	;--- update the sequence order
	; DEBUG !! replace this as on normal MSX2 too slow.
	call	build_order_list
	call	update_orderbox




	;-- Display the current patterndata
	ld	b,0				; display line number
	ld	a,(song_pattern_offset)
	ld	c,a				; offset (line) to start
; -- add check if pat_offset >= patlen  then offset = patlen-1 

	
	;-- init the step indicator
	ld	a,(song_step)
	ld	(_dpe_step),a
	ld	d,a
	
	ld	a,c
	add	b				; add line + offset
	cp	-8
	jr.	c,99f
	xor	a
	jr.	88f
99:	
	ld	e,a
	xor	a
	sub	d

77:	add	d
	cp	e
	jr.	c,77b

	
88:	ld	(_dpe_step_count),a
	
	; -- Init and store the display pos in PNT
	ld	hl,(80*10)-80			; start position
	ld	(_dpe_pntpos),hl
	
	; --- Set the pattern data in bank 2
	push	bc
	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage		
	pop	bc
	
	; --- save the patlen
;	ld	a,(hl)
	ld	a,64
	ld	(_dpe_patlen),a
;	inc	hl				; hl now point to start of line
	
	; --- set HL to point to the pattern_offset line
	ld	de,8*4;	2+(5*8)
	ld	a,c
	and	a				; not if offset == 0
	jr.	z,1f
	cp 	-8				; not if offset < 0
	jr.	nc,1f
0:
	add	hl,de
	dec	a
	jr.	nz,0b	
1:	
_dpe_lineloop:	

	;--- Set step indicator
	ld	a,c
	add	b	
	ld	d,a
	
	ld	a,(_dpe_step_count)
	cp	d
	jr.	nz,88f
	;--- step indicator
	ld	a,(_dpe_step)
	ld	d,a
	ld	a,(_dpe_step_count)
	add	d
	ld	(_dpe_step_count),a
	ld	a,_VERTICAL_STEP
	ld	(_dpe_step_char),a
	jr.	77f	
	;--- no step indicator
88:	
	ld	a,_VERTICAL_SMALL
	ld	(_dpe_step_char),a	
	
77:	
	; each line
	ld	de,_LABEL_PATLINE

	; --- line number
	ld	a,c
	add	b				; add line + offset
	push	bc

	cp	-8
	jr.	nc,_dpe_emptyline		; if the offset is negative (pre-empty lines)


	; --- check if we are at end of pattern	
	ld	c,a
	ld	a,(_dpe_patlen)
	dec	a
	cp	c
	ld	a,c
	jr.	nc,0f
_dpe_emptyline:
	; --- YES draw empty line
		ld	a," "
		ld	b,80
10:		ld	(de),a
		inc	de
		djnz	10b
		
		jr.	77f
	
	;-- YES draw data!!!
0:	call	draw_hex2			; draw hex line number
	;call	draw_decimal
	inc	de
	inc	de	
	
	; --- display the channels
	call	draw_channel
	ld	a,(_dpe_step_char)
	ld	(de),a
	inc	de		; skip the '|'
	call	draw_channel
	ld	a,(_dpe_step_char)
	ld	(de),a
	inc	de		; skip the '|'	
	call	draw_channel
	ld	a,_VERTICAL_DOUBLE
	ld	(de),a
	inc	de		; skip the '|'
	call	draw_channel
	ld	a,(_dpe_step_char)
	ld	(de),a
	inc	de		; skip the '|'
	call	draw_channel
	ld	a,(_dpe_step_char)
	ld	(de),a
	inc	de		; skip the '|'	
	call	draw_channel
	ld	a,(_dpe_step_char)
	ld	(de),a
	inc	de		; skip the '|'
	call	draw_channel
	ld	a,(_dpe_step_char)
	ld	(de),a
	inc	de		; skip the '|'
	call	draw_channel

	; end the line
	pop	bc		; restore the line and offset value
	push	bc
	; --- line number
	inc	de
	inc	de
	inc	de	

	ld	a,c
	add	b				; add line + offset
	;call	draw_hex2			; draw hex line number
	call	draw_decimal
77:	
	
	
	push	hl		; save the pattern data pointer

	ld	hl,(_dpe_pntpos)
	ld	bc,80
	add	hl,bc
	ld	(_dpe_pntpos),hl
		
	ld	de,_LABEL_PATLINE
	ld	b,80	
	call	draw_label_fast

	pop	hl
	pop	bc
	inc	b 
	
	ld	a,16
	cp	b
	jr.	nz,_dpe_lineloop
	
;	ld	a,(current_song)
	call	set_songpage	


;	; output the cmd line
;
;	call	get_chanrecord_location
;	inc	hl
;	inc	hl
;	inc	hl
;	ld	(command_location),hl
;	call	update_editbox_cmd
;/*	ld	a,(hl)
;	ld	b,a
;	and	0x0f
;	ld	(de),a
;	inc	de
;	call	draw_hex
;	inc	de
;	ld	a,b
;	and	0xf0
;	rrca
;	rrca
;	rrca
;	rrca
;	add	48
;	ld	(de),a
;	inc	de
;	inc	de
;	inc	hl
;	ld	a,(hl)
;	call	draw_hex2
;	
;	ld	hl,(80*8)+32
;	ld	de,_LABEL_CMDLINE
;	ld	b,7
;	call	draw_label_fast
;			
;	ld	a,(current_song)
;	call	set_songpage	
;*/
	

0:

	ret
	


	
;===========================================================
; --- update_trackbox
;
; Display the pattern area values.
; 
;===========================================================
draw_channel:
	;--- the note
	ld	a,(hl)
	inc	hl

	;Change empty value to '---' value
;	cp	a,255
;	jr.	nz,1f
;	ld	a,98	
;1:
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

	pop	hl
	
	;--- the macro
	ld	a,(hl)
	inc	hl
	
	;--- plot the macro value (1-V) 31 values
	call	draw_fake_hex_sp_small


	;--- the volume 
	ld	a,(hl)
	and	0xf0
	rrca
	rrca
	rrca
	rrca
	call	draw_hex_sp_small
	
	;--- the command
	ld	a,(hl)
	and	0x0f	
	;--- check for pattern end!!!
	cp	0x0d
	jr.	nz,32f
	exx
	pop	de
	pop	bc
	ld	a,c
	add	b
	push	bc
	push	de
	exx	
	inc	a
	ld	(_dpe_patlen),a
	ld	a,0x0d
		
32:
	;--- skip empty cmd	
	and	a
	jr.	nz,33f
	inc	hl
	ld	a,(hl)
	dec	hl
	and	a
	ld	a,0
	jr.	nz,33f
	
	
	ld	a," "
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de	
	ld	(de),a
	inc	de	
	inc	hl
	jr.	34f
	
	
33:	
	call	draw_hex;_small




	;--- command params
	inc	hl
	ld	a,(hl)
	call	draw_hex2;_cmd
34:
	inc	hl

	ret
	



;===========================================================
; --- process_key_trackbox
;
; Process the input for the pattern. 
; There are 2 version for compact and full view
; 
;===========================================================	
process_key_trackbox:


	;--- Special numkey check for setting octave.
;	call	read_numkeys
	ld	a,(key_value)
	 
	cp	0x4b
	jr.	c,0f
	cp	0x55
	jr.	nc,0f
		
	;--- set octave
	sub	0x4b
	ld	(song_octave),a
	xor	a
	ld	(key),a
	call	update_patterneditor

	jr.	_process_key_trackbox_END



0:
	;--- General trackbox keys
	;--- check [CTRL] combinations
	ld	a,(fkey)
	cp	_KEY_CTRL
	jr.	nz,76f
		
	;--- check 2nd key combo
	ld	a,(key)
	
		;--- NOTE UP
		cp	"."+128
		jr.	nz,0f

		; Note up on selection
		call	selection_note_up
		jr.	update_patterneditor
		
		
0:		
	
	
	
	
	
		;--- DOWN
		cp	_KEY_DOWN
		jr.	nz,0f
		; pattern# down
		ld	a,(song_pattern)
		and	a
		ret	z	; no update
		dec	a
3:		ld	(song_pattern),a
		call	reset_selection
		call	check_cursor_patternbox
		call	update_patterneditor
		jr.	_process_key_trackbox_END
0:
		;--- UP
		cp	_KEY_UP
		jr.	nz,0f
		; pattern# up
		ld	a,(song_pattern)
		inc	a
		ld	c,a
		ld	a,(max_pattern)
		dec	a
		cp	c
		ret	c	; no update
		ld	a,c
		ld	(song_pattern),a		
		jr.	3b
		
0:
		;--- LEFT
		cp	_KEY_LEFT
		jr.	nz,0f
		; orderpos down
		ld	a,(song_order_pos)
		and	a
		ret	z	; no update
		dec	a
3:		ld	(song_order_pos),a
		ld	hl,song_order
		add	a,l
		ld	l,a
		jr.	nc,4f
		inc	h
4:				
		ld	a,(hl)
		ld	(song_pattern),a	
		call	reset_selection		
		call	build_order_list
		call	check_cursor_patternbox	
		call	update_patterneditor
		jr.	_process_key_trackbox_END		
0:

		;--- RIGHT
		cp	_KEY_RIGHT
		jr.	nz,0f
		; orderpos up
		ld	a,(song_order_len)
		ld	c,a
		ld	a,(song_order_pos)
		inc	a
		cp	c
		jr.	nc,_process_key_trackbox_END
		
		jr.	3b
		
0:	

		;--- OCTAVE UP
		cp	">"+128
		jr.	nz,0f

		; Octave up on selection
		call	selection_octave_up
		jr.	update_patterneditor
		
		
0:	
		;--- OCTAVE DOWN
		cp	"<"+128
		jr.	nz,0f

		; Octave down on selection
		call	selection_octave_down
		jr.	update_patterneditor
		
			
0:	

		;--- NOTE DOWN
		cp	","+128
		jr.	nz,0f

		; Note down on selection
		call	selection_note_down
		jr.	update_patterneditor		
		
		
		



0:
76:
	;--- Need to add different views
	call	process_key_trackbox_compact
	
_process_key_trackbox_END:
	ret

		
;===========================================================
; --- process_key_trackbox_compact
;
; Process the input for the pattern. 
; There are 2 version for compact and full view
; 
;===========================================================
process_key_trackbox_compact:
	
	ld	a,(key)
	and	a
	ret	z


	;--- ESC return to start of pattern
	cp	_ESC
	jr.	nz,0f
	call	flush_cursor
	call	reset_cursor_trackbox
	jr.	update_trackbox

0:
	cp	_ENTER
	jr.	nz,0f
	call	start_playback_looped
	ret


0:
	;--- copy current pattern into the next empty pattern
	cp	_CTRL_G
	jr.	nz,0f

	;--- copy current pattern onto the buffer
	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage
	ld	de,buffer
	ld	bc,SONG_PATSIZE
	ldir
	
	;--- search for the next available free pattern
	ld	b,0
_pkt_gloop:
	push	bc
	call	set_patternpage
	pop	bc
	
	ld	de,SONG_PATSIZE
_pkt_gloop1:
	ld	a,(hl)
	cp	0
	jr.	nz,_pkt_gloop_not_empty
	inc	hl
	dec	de
	ld	a,d
	cp	e
	jr.	nz,_pkt_gloop1
	and	a
	jr.	nz,_pkt_gloop1
		
	;--- found an empty pattern!
	push	bc
;	ld	a,(current_song)
	call	set_songpage
	pop	bc
	ld	a,b
	ld	(song_pattern),a

	call	set_patternpage
	push	hl
	ld	de,buffer
	ex	de,hl

	ld 	bc,SONG_PATSIZE
	ldir

	;-- clear buffer for edit log dif check
	ld	hl,buffer
	ld	de,buffer+1
	ld	(hl),0
	ld	bc,SONG_PATSIZE-1
	ldir
	
	pop	hl
	call	store_log_block


	call	reset_cursor_trackbox
	jr.	update_patternbox
	
_pkt_gloop_not_empty:
	inc	b
;	ld	a,b
	;-- did we process all patterns
;	cp	SONG_MAXPAT
	ld	a,(max_pattern)
	cp	b
	ld	a,b
	jr.	nc,_pkt_gloop
;	ld	a,(current_song)
	jr.	set_songpage	
	



0:
	;--- copy selection into copy buffer 
	cp	_CTRL_C
	jr.	nz,0f
	; copy to buffer
	call	copy_to_buffer
	jr.	_process_key_trackbox_compact_END
	
0:
	;--- copy selection into copy buffer 
	cp	_CTRL_V
	jr.	nz,0f
	; copy to buffer
	call	copy_to_pattern
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END
0:
	;--- copy selection into copy buffer and clear selection 
	cp	_CTRL_X
	jr.	nz,0f
	; copy to buffer
	call	copy_to_buffer
	call	erase_selection
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END
0:
	;--- erase the selection from pattern
	cp	_DEL
	jr.	nz,0f
	;--- is there a selection?
	ld	b,a
	ld	a,(selection_status)
	and	a
	ld	a,b
	jr.	z,0f		; jump if we have no selection		
	
	call	erase_selection
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END
0:
	;--- remove the row of current channel.
	cp	_BACKSPACE
	jr.	nz,0f
	
	;--- logging
	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage
	call	init_log_block
;	ld	a,(current_song)	; song page is expected 
	call	set_songpage	
	
	ld	a,(song_pattern_line)		; current editline	
;	cp	63
;	jr.	z,_process_key_trackbox_compact_END
	push	af
	call	get_chanrecord_location		; get the start pos in HL
	ld	a,h					; het the next row in DE	
	ld	d,a
	ld	a,32
	add	a,l
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ex	de,hl
	pop	af
	ld	b,a
	ld	a,63					
	sub	b					; a = rows till end
	jr.	z,33f
_pktc_bckspc_loop:
	; copy the 4 bytes
	ldi	
	ldi	
	ldi	
	ldi	
	; new pointers (next row)
	ld	bc,32-4
	add	hl,bc
	ex	de,hl
	add	hl,bc
	ex	de,hl
	
	dec	a
	jr.	nz,_pktc_bckspc_loop
33:	
	;--- clear the last row
	ld b,4
	xor	a
_pktc_bckspc_loop2:
	ld	(de),a
	inc	de
	djnz	_pktc_bckspc_loop2
	
	;--- logging
	call	store_log_block
		
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END
0:
	;--- insert a row in current channel.
	cp	_INS
	jr.	nz,0f
	
	;--- logging
	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage
	call	init_log_block
;	ld	a,(current_song)	; song page is expected 
	call	set_songpage
	
	ld	a,(song_pattern_line)		; current editline	
	call	get_chanrecord_location		; get the start pos in HL

	ld	b,a
	ld	a,63					
	sub	b					; a = rows till end
	; calculate address of last row.
	ld	b,a
	dec	b
	ld	de,32
_pktc_ins_loop3:
	add	hl,de
	djnz	_pktc_ins_loop3

	ex	de,hl
	add	hl,de
	ex	de,hl
	
_pktc_ins_loop:
	; copy the 4 bytes
	ldi	
	ldi	
	ldi	
	ldi	
	; new pointers (next row)
	ld	bc,-36
	add	hl,bc
	ex	de,hl
	add	hl,bc
	ex	de,hl
	
	dec	a
	jr.	nz,_pktc_ins_loop
	
	;--- clear the first row
	ld b,4
	xor	a
_pktc_ins_loop2:
	ld	(de),a
	inc	de
	djnz	_pktc_ins_loop2
	
	;--- logging
	call	store_log_block
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END

0:
	;--- key left
	cp	_KEY_LEFT
	jr.	nz,0f
	ld	c,1
	
	;--- check if we need to get to prev track
	ld	a,(fkey)
	cp	7
	jr.	nz,44f
	ld	c,6		; 6 colomns to move
44:
_pktc_kleft_loop:	
	; column left
	ld	hl,_COLTAB_COMPACT
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
	jr.	z,55f;_process_key_trackbox_compact_END
	
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
	and	a
	ld	a,1
	jr.	nz,99f
	ld	a,3	
99:	
	ld	(cursor_type),a
	ld	hl,cursor_column
	dec	(hl)
	
	dec	c
	jr.	nz,_pktc_kleft_loop
	
	
55:	call	selection_process
	call	flush_cursor
	call	update_trackbox
	call	show_cursor
	jr.	_process_key_trackbox_compact_END			



0:		
	;--- key TAB
	cp	_KEY_TAB
	jr.	nz,0f
	ld	c,6
	ld	a,(skey)
	cp	1	;graph
	jr.	nz,44f
	xor	a				;--- cancel any selection on SHIFT+TAB
	ld	(skey),a
	jr.	44b	

0:

	;--- key right
	cp	_KEY_RIGHT
	jr.	nz,0f
	ld	c,1

	;--- check if we need to get to prev track
	ld	a,(fkey)
	cp	7
	jr.	nz,44f
	ld	c,6		; 6 colomns to move
44:
_pktc_kright_loop:	

	call	flush_cursor
	; column right
	ld	hl,_COLTAB_COMPACT
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
	jr.	z,55f
	
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

	dec	c
	jr.	nz,_pktc_kright_loop

55:	call	selection_process
	call	flush_cursor
	call	update_trackbox
	call	show_cursor
	jr.	_process_key_trackbox_compact_END			
0:		

	;--- key down
	cp	_KEY_DOWN
	jr.	nz,0f
	ld	c,1
	;--- get lines to move
	ld	a,(fkey)
	cp	7
	jr.	nz,44f
	ld	a,(song_step)
	ld	c,a
44:
	
	; rows down
	ld	a,(_dpe_patlen)
	ld	b,a
	ld	a,(song_pattern_line)
	add	c
	cp	b
	jr.	c,11f
	;jr.	nc,_process_key_trackbox_compact_END
	sub	c
	ld	c,a
	ld	a,b
	sub	c
	dec	a
	ld	c,a
	ld	a,b
	dec	a
11:
	
	ld	(song_pattern_line),a
	push	bc
	call	flush_cursor
	pop	bc
	ld	a,(cursor_y)
	add	c
	cp	26
	jr.	nc,99f
	ld	(cursor_y),a
	call	selection_process
	call	update_trackbox
	call	show_cursor
	jr.	_process_key_trackbox_compact_END				
99:	ld	a,(song_pattern_offset)
	add	c
	ld	(song_pattern_offset),a	
	
	call	selection_process	
	call	update_trackbox
	
	call	show_cursor
	
	jr.	_process_key_trackbox_compact_END		
0:		
	;--- key up
	cp	_KEY_UP
	jr.	nz,0f
	
	ld	c,1
	;--- get lines to move
	ld	a,(fkey)
	cp	7
	jr.	nz,44f
	ld	a,(song_step)
	ld	c,a
44:	

	; row up
	ld	a,(song_pattern_line)
	cp	c
	jr.	nc,11f
	
	ld	c,a
	
	
11:
	sub	c
	
	ld	(song_pattern_line),a
	push	bc
	call	flush_cursor
	pop	bc
	ld	a,(cursor_y)
	sub	c
	cp	10
	jr.	c,99f
	cp	128
	jr.	nc,99f
	ld	(cursor_y),a
	call	selection_process
	call	update_trackbox
	call	show_cursor
	jr.	_process_key_trackbox_compact_END				
99:	ld	a,(song_pattern_offset)
	sub	c	
	ld	(song_pattern_offset),a
	call	selection_process
	call	update_trackbox
	call	show_cursor
	jr.	_process_key_trackbox_compact_END		
0:	
	;--- UNDO
	cp	_CTRL_Z
	jr.	nz,0f
	; undo
	call	undo
	jr.	_process_key_trackbox_compact_END	

0:
	;--- REDO
	cp	_CTRL_Y
	jr.	nz,0f
	; redo
	call	redo
	jr.	_process_key_trackbox_compact_END	

0:
	;--- check for keyjazz
	ld	b,a
	ld	a,(keyjazz)
	and	a
	jr.	nz,process_key_keyjazz
	

	;===================
	; INPUT is NOTES
	;
	; NOTES!!
	;
	;===================
	;--- Check if we are in a note column
	;ld	b,a
	ld	a,(cursor_input)
	and	a
	ld	a,b
	jr.	nz,0f

	;---- Test for DEL
	cp	_DEL
	jr.	nz,99f
	xor	a
	jr.	77f

99:	
	ld	a,(key_value)
	;---- now get the note
	ld	(replay_key),a
	ld	b,0
	;valid key?
;	cp	128	; CTRL combination?
;	jr.	nc,_process_key_trackbox_compact_END
	;get the note octave addittion	
	cp	88   ; SHIFT?
	jr.	c,99f
	inc	b
	sub	88
99:	
	;- Note under this keys?
	cp	48			
	jr.	nc,_process_key_trackbox_compact_END	
	
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
	jr.	z,_process_key_trackbox_compact_END
	
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
	jr.	nc,_process_key_trackbox_compact_END
	
77:

;	;!!!! add not setting instrument 0 on delete or 'k'
;	
;	
;	cp	_DEL
;	jr.	nz,99f
;	ld	a,'k'
;99:	
;	;--- Check if the key pressed is in the note range
;	cp	0x21	; first key mapped to a note
;	jr.	c,0f	
;	cp	0x7f	; last key mapped to a note
;	jr.	nc,0f
;
;	;--- Get the note value of the key pressed
;	ld	hl,_KEY_NOTE_TABLE-0x21
;	add	a,l
;	ld	l,a
;	jr.	nc,99f
;	inc	h
;99:
;
;	;--- Get the octave
;	ld	a,(song_octave)
;	ld	b,a
;	
;	ld	a,(hl)
;	;inc	a
;	;--- Only process values != 255
;	cp	255
;	jr.	z,_process_key_trackbox_compact_END
;	
;	;--- Add the octave
;	; but not for these;
;	cp	97
;	jr.	nc,77f
;	and	a
;	jr.	z,77f
;	sub	12
;88:
;	add	12
;	djnz	88b
;	;--- Check if we are not outside the 8th ocatave
;	cp	97
;	jr.	nc,_process_key_trackbox_compact_END
;	
;77:	
	call	get_chanrecord_location
	;ld	(hl),a
	ex	af,af'			;'
	ld	a,(tmp_cur_instrument)
	and	a
	jr.	z,3f	;-store without instrument
	ex	af,af'			;'
	call	store_log_note
	jr.	4f
3:	
	ex	af,af'			;'
	call	store_log_byte
	
4:

;	ld	a,(current_song)
	call	set_songpage
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END_sound

0:	
	;===================
	; INPUT is Command nr
	;
	; C O M M A N D
	;
	;===================
	;--- Check if we are in an command column
	ld	a,(cursor_input)
	cp	3			; 3 = command type
	ld	a,b
	jr.	nz,0f
	cp	_DEL
	jr.	nz,99f
_pktc_delcmd:
	call	get_chanrecord_location	
	inc	hl
	inc	hl
	ld	a,(hl)
	and	0xf0
	ld	(hl),a
	inc	hl
	ld	(hl),0
;	ld	a,(current_song)
	call	set_songpage
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END_sound
	
99:	
	;--- Check if the key pressed is in the command range
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	_commandvalfound
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	_commandvalfound
99:	
	cp	'A'
	jr.	c,91f
	cp	'F'+1
	jr.	nc,91f
	sub	'A'-10
		
_commandvalfound:	
	call	get_chanrecord_location
;	inc	hl
	inc	hl
	inc	hl		; cmd is int the 3rd byte		
	ld	b,a
	ld	a,(hl)		; get the existing value
	and	0xf0		; erase current ornament
	or	b		; add ornament
;	ld	(hl),a
	call	store_log_byte
	
;	ld	a,(current_song)
	call	set_songpage
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END_sound

91:	;nothing found
	jr.	_process_key_trackbox_compact_END


0:		
	;===================
	; INPUT is Instrument
	;
	; I N S T R U M E N T
	;
	;===================
	;--- Check if we are in a instrument column
	ld	a,(cursor_input)
	cp	1			; 1 = sample type
	ld	a,b
	jr.	nz,0f
	cp	_DEL
	jr.	nz,99f
	ld	a,'0'	
	
99:	
	;--- Check if the key pressed is in the range
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	_samplevalfound
99:	
	cp	'a'
	jr.	c,99f
	cp	'v'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	_samplevalfound
99:	
	cp	'A'
	jr.	c,91f
	cp	'V'+1
	jr.	nc,91f
	sub	'A'-10

		
_samplevalfound:	
	call	get_chanrecord_location
	inc	hl		; sample is int the 2nd byte
	call	store_log_byte
	
;	ld	a,(current_song)
	call	set_songpage
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END_sound

91:	;nothing found
	jr.	_process_key_trackbox_compact_END


0:	
	;===================
	; INPUT is X
	;
	; X
	;
	;===================
	;--- Check if we are in an X column
	ld	a,(cursor_input)
	cp	4			; 4 = x type
	ld	a,b
	jr.	nz,0f
	cp	_DEL
	jr.	z,_pktc_delcmd	
	
	
	;--- Check if the key pressed is in the envelope range
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	_xvalfound
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	_xvalfound
99:	
	cp	'A'
	jr.	c,91f
	cp	'F'+1
	jr.	nc,91f
	sub	'A'-10

		
_xvalfound:	
	call	get_chanrecord_location
	inc	hl		; sample is int the 3rd byte
	inc	hl
	inc	hl
	rlca			; low three bytes are for ornament
	rlca	
	rlca		
	rlca		
	ld	b,a
	ld	a,(hl)		; get the existing value
	and	0x0f		; erase current envelope
	or	b		; add envelope
;	ld	(hl),a
	call	store_log_byte
	
;	ld	a,(current_song)
	call	set_songpage
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END_sound

91:	;nothing found
	jr.	_process_key_trackbox_compact_END

0:	
	;===================
	; INPUT is Y
	;
	; Y
	;
	;===================
	;--- Check if we are in an Y column
	ld	a,(cursor_input)
	cp	5			; 5 = y type
	ld	a,b
	jr.	nz,0f
	cp	_DEL
	jr.	z,_pktc_delcmd
	
99:	
	;--- Check if the key pressed is in the envelope range
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	_yvalfound
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	_yvalfound
99:	
	cp	'A'
	jr.	c,91f
	cp	'F'+1
	jr.	nc,91f
	sub	'A'-10

		
_yvalfound:	
	call	get_chanrecord_location
	inc	hl		; sample is int the 3rd byte
	inc	hl
	inc	hl
	ld	b,a
	ld	a,(hl)		; get the existing value
	and	0xf0		; erase current envelope
	or	b		; add envelope
;	ld	(hl),a
	call	store_log_byte
	
;	ld	a,(current_song)
	call	set_songpage
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END_sound

91:	;nothing found
	jr.	_process_key_trackbox_compact_END

;0:	
;	;===================
;	; INPUT is Ornament
;	;
;	; O R N A M E N T
;	;
;	;===================
;	;--- Check if we are in an ornament column
;	ld	a,(cursor_input)
;	cp	3			; 3 = ornament type
;	ld	a,b
;	jr.	nz,0f
;	cp	_DEL
;	jr.	nz,99f
;	ld	a,'0'	
;	
;99:	
;	;--- Check if the key pressed is in the ornament range
;	; is it a number?
;	cp	'0'	; bigger than 0 
;	jr.	c,91f	
;	cp	'8'+1	; smaller than 8?
;	jr.	nc,91f
;	sub 	'0'
;		
;	
;	call	get_chanrecord_location
;	inc	hl		; ornament is int the 2nd byte		
;	ld	b,a
;	ld	a,(hl)		; get the existing value;
;	and	0xf8		; erase current ornament
;	or	b		; add ornament
;;	ld	(hl),a
;	call	store_log_byte
;	
;	ld	a,(current_song)
;	call	set_songpage
;	call	update_trackbox
;	jr.	_process_key_trackbox_compact_END_sound
;
;91:	;nothing found
;	jr.	_process_key_trackbox_compact_END
;

0:	
	;===================
	; INPUT is Volume
	;
	; V O L U M E
	;
	;===================
	;--- Check if we are in an volume column
	ld	a,(cursor_input)
	cp	2			; 2 = volume type
	ld	a,b
	jr.	nz,0f
	cp	_DEL
	jr.	nz,99f
	ld	a,'0'	
	
99:	
	;--- Check if the key pressed is in the range
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	_volumevalfound
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	_volumevalfound
99:	
	cp	'A'
	jr.	c,91f
	cp	'F'+1
	jr.	nc,91f
	sub	'A'-10

		
_volumevalfound:	
	call	get_chanrecord_location
	inc	hl		; volume is int the 3rd byte
	inc	hl
	
	rlca
	rlca
	rlca
	rlca
	ld	b,a
	ld	a,(hl)		; get the existing value
	and	0x0f		; erase current volume
	or	b		; add volume
;	ld	(hl),a
	call	store_log_byte
	
;	ld	a,(current_song)
	call	set_songpage
	call	update_trackbox
	jr.	_process_key_trackbox_compact_END_sound

91:	;nothing found
	jr.	_process_key_trackbox_compact_END


0:

_process_key_trackbox_compact_END:
	ret

_process_key_trackbox_compact_END_sound:
	ld	a,(_CONFIG_AUDIT)
	and	a
	ret	z
	;--- sound the pattern line
	call	replay_init
;	ld	a,(song_pattern)
;	ld	b,a
;	call	set_patternpage	
;;	inc	hl
;	ld	a,(current_song)
	call	set_songpage_safe
;	ld	a,(song_pattern_line)
;	and	a
;	jr.	z,9f
;	ld	de,SONG_PATLNSIZE
;
;	;--- Set patternline offset
;99:
;	add	hl,de
;	dec	a	
;	jr.	nz,99b
;9:
;	ld	(replay_patpointer),hl
	ld	a,(key_value)
	ld	(replay_key),a	
	ld	a,3
	ld	(replay_mode),a

	;--- Auto increment after audition start to audit correct patline.
	call	auto_increment
	
88:	halt
;	--- wait till key is released	
	ld	a,(replay_mode)
	and	a
	jr.	z,99f
	
	ld	a,(_CONFIG_DEBUG)
	and	a
	jr.	z,88b
	
	call	draw_PSGdebug
	call	draw_SCCdebug
		
	jr.	88b
99:	
;	ld	a,(current_song)
	call	set_songpage
	ret	
	

;===========================================================
; --- get_chanrecord_location
;
; Returns the location of the start of the current chanrecord
; in RAM (hl). It is needed to add the offset in the record after
; this function.
; The function expects songdata to be swapped in and it
; swaps pattern data in.
;===========================================================
get_chanrecord_location:

	push	af
	push	bc
	push	de

	ld	hl,0	
	ld	a,(song_pattern_line)
	and	a
	jr.	z,0f
	ld	de,SONG_PATLNSIZE

	;--- Set patternline offset
_gcll_loop:
	add	hl,de
	dec	a	
	jr.	nz,_gcll_loop
0:
	;--- Get channel number
	ld	a,(cursor_x)
	sub	4 		; first chan starts at 4

	dec	hl
	dec	hl
	dec	hl
	dec	hl
	dec	hl		; only go 3 pos back as first 2 are not chan record.
	ld	bc,4




	
99:	;--- Calculate the channel
	add	hl,bc
	sub	9		; each channel is 9 chars wide
	jp	p,99b

	;--- Set HL to the patten data
	ex	de,hl
	ld	a,(song_pattern)
	ld	b,a
	push	de
	call	set_patternpage
	pop	de
	inc	hl		;dirst pos is the pat length
	add	hl,de
	
	pop	de
	pop	bc
	pop	af
		
	ret


;===========================================================
; --- auto_increment
;
; Auto increments the line if set 
;===========================================================
auto_increment:
	push	af
	push	bc
		
	;--- Auto increment 
	ld	a,(song_add)
	ld	b,a
	ld	a,(_dpe_patlen)
	ld	c,a
	ld	a,(song_pattern_line)
	add	b
	cp	c
	jr.	nc,_auto_increment_END
	
	;--- new line < pattern length
	ld	(song_pattern_line),a
	
	ld	a,(cursor_y)
	add	b
	cp	26
	jr.	c,99f
	;-- new cursor is off screen.
		ld	a,(song_pattern_offset)
		add	b
		ld	(song_pattern_offset),a
		call	update_trackbox
		jr.	_auto_increment_END
	
99:	;--- new cursor is on screen.
	ld	(cursor_y),a
	


_auto_increment_END:	
	pop	bc
	pop	af
	ret

;===========================================================
; --- reset_cursor_trackbox
;
; Reset the cursor to the top left of the pattern.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_trackbox:
	call	flush_cursor
	
	
	
	ld	a,10
	ld	(cursor_y),a
	ld	a,4
	ld	(cursor_x),a
	ld	a,3
	ld	(cursor_type),a	
	ld	a,(_COLTAB_COMPACT)		; get first value
	ld	(cursor_input),a
	xor	a
	ld	(song_pattern_line),a
	ld	(cursor_column),a
	ld	(song_pattern_offset),a

	ret


