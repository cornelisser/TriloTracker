;===========================================================
; --- new_song
; Initializes a new empty song. 
; All defaults are set.
; 
; input: a = song# in RAM
;===========================================================
new_song:
clear_patterns:
	; --- Clear the patterndata
	
	;xor	a
	ld	a,(max_pattern)
4:
	push	af
	ld	b,a		; patternnumber to set
	dec	b
	call	set_patternpage


	push	bc
	
	ld	bc,2048-1
	xor	a
	
	ld	(hl),a
	push	hl
	pop	de
	inc	de
	
	ldir	
	
	

	pop	bc
	
	pop	af
	dec	a
	
;	cp	(SONG_SEGSIZE-1)*SONG_PATINSEG
	jr.	nz,4b
	

	call	set_songpage
	
	; set '0' defaults
	xor	a
	ld	(song_pattern),a
	ld	(song_pattern_offset),a
	ld	(song_pattern_line),a
	ld	(song_add),a
	ld	(song_order_pos),a
	ld	(song_order_loop),a
	ld	(editmode),a
	ld	(editsubmode),a
	ld	(song_order),a
	ld	(song_order_offset),a
	ld	(song_instrument_offset),a
	ld	(song_active_instrument),a
	ld	(tmp_cur_instrument),a
	inc	a
	ld	(song_cur_instrument),a
	ld	(song_order_update),a
	ld	(song_order_len),a
	ld	(song_order_pos_old),a

		
	;--- Cursor init
	call	reset_cursor_patternbox
	
	;--- Undo Redo init
	call	init_undoredo
	
	
	; custom defaults
	ld	a,2
	ld	(song_octave),a
	ld	a,(_CONFIG_STEP)
	ld	(song_step),a
	ld	a,(_CONFIG_SPEED)
	ld	(song_speed),a
	ld	a,(_CONFIG_ADD)
	ld	(song_add),a

	ld	a,0
	ld	b,SONG_SEQSIZE-1
	ld	hl,song_order+1
0:
	ld	(hl),a
	inc	hl
	djnz 	0b
	
	ld	b,65
	ld	hl,_ns_TEMP
	ld	de,song_name
1:
	ldi
	djnz	1b
	
	
	;--- Clear the songnames
	ld	hl,song_instrument_list
	ld	de,song_instrument_list+1
	ld	a," "
	ld	(hl),a
	ld	bc,(31*16)-1
	ldir
	ld	de,song_empty_string
	ld	hl,_empty_ins_label
	ld	bc,16
	ldir
	
	
	
	
	;--- Clear the samples
	ld	b,32
	ld	de,instrument_macros
	
0:
	ld	c,(32*4)+2
	ld	a,1
	ld	(de),a
	inc	de
	xor	a
1:	ld	(de),a
	inc	de
	dec	c
	jr.	nz,1b
	djnz	0b

clear_waveforms:
	ld	hl,_WAVESSCC
	ld	de,_WAVESSCC+1
	ld	bc,32*32 -1
	ld	(hl),0
	ldir
	

	ret
	
_ns_TEMP:
	db	"TriloTracker ",VERSION
	db	"Richard Cornelisse      (c) ",YEAR
_empty_ins_label:
	db	"<no instrument> "