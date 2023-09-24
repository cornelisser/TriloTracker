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

	jr.	nz,4b
	

	call	set_songpage

	ld	a,255
	ld	(song_order_loop),a
	; set '0' defaults
	xor	a
	ld	(song_pattern),a
	ld	(song_pattern_offset),a
	ld	(song_pattern_line),a
	ld	(song_add),a
	ld	(song_order_pos),a
	ld	(editmode),a
	ld	(editsubmode),a
	ld	(song_order),a
	ld	(song_order_offset),a
	ld	(song_instrument_offset),a
	ld	(song_active_instrument),a
	ld	(tmp_cur_instrument),a

	inc	a
	ld	(song_cur_instrument),a
IFDEF TTSCC
ELSE
	ld	(drum_type),a
	ld	(song_cur_drum),a
ENDIF
	ld	(song_order_len),a
	ld	(song_order_pos_old),a

IFDEF TTSCC
	;--- sample init
	xor	a
	ld	(sample_current),a
	ld	(sample_enabled),a

	ld	hl,sample_names
	ld	(hl),0
	ld	de,sample_names+1
	ld	bc, 8*16-1
	ldir
	ld	hl,sample_offsets
	ld	(hl),0
	ld	de,sample_offsets+1
	ld	bc, 4*16-1
	ldir

	ld	hl,$8040		; (16 times 8 bytes; base tone, start address, loop addres, note, ??)
	ld	(sample_end),hl
ENDIF	






	;--- Cursor init
	call	reset_cursor_patternbox
	
	;--- Undo Redo init
	call	init_undoredo
	
	;--- Clear clipboard
	call	clear_clipboard



	; custom defaults
	ld	a,4
	ld	(song_octave),a
	ld	a,(_CONFIG_STEP)
	ld	(song_step),a
	ld	a,(_CONFIG_SPEED)
	ld	(song_speed),a
	ld	a,(_CONFIG_ADD)
	ld	(song_add),a
	ld	a,(_CONFIG_PERIOD)
	ld	(replay_period),a


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
	
	;--- Clear the instrument types
	ld	hl,instrument_types
	ld	b,32
0:
	ld	(hl),3	; All 
	inc	hl
	djnz	0b
	
	
	;--- Clear the samples
	ld	b,32
	ld	de,instrument_macros
	
0:
	ld	c,(32*4)+1
	ld	a,1
	ld	(de),a
	inc	de
	ld	a,0
	ld	(de),a
	inc	de	
	xor	a
1:	ld	(de),a
	inc	de
	dec	c
	jr.	nz,1b
	djnz	0b

IFDEF TTSCC	
clear_waveforms:
	ld	hl,_WAVESSCC
	ld	de,_WAVESSCC+1
	ld	bc,32*32 -1
	ld	(hl),0
	ldir
ELSE
clear_customvoices:
	ld	hl,_VOICES+((192-31)*8)
	ld	de,_VOICES+((192-31)*8)+1
	ld	bc,(8*16)-1
	ld	(hl),0
	ldir
ENDIF
	
	;clear audition line
	ld hl,_KEYJAZZ_LINE
	ld	b,32
0:
	ld 	(hl),0
	inc	hl
	djnz 	0b

IFDEF TTSCC
	ret
ELSE

clear_drummacros:
	; Clear Drum macro values
	ld	b,MAX_DRUMS
	ld	hl,drum_macros
	
_cdm_loop:
	ld	(hl),1			; Default size
	ld	c,(7*16)			; DRUM macro size.
	inc	hl
_cdm_loop2:
	ld	(hl),0
	inc	hl
	dec	c
	jr. nz,_cdm_loop2
	djnz	_cdm_loop

	; Clear Drum macro names.
	ld	de,song_drum_list+1
	ld	hl,song_drum_list
	ld	(hl)," "
	ld	bc,(MAX_DRUMS*16)-1	
	ldir


	;--- Set default drums
	ld 	hl,drum_macros+1+(1+(16*7))	; first macro is empty macro.
	ld	de,_cdm_DRUMDEFAULT
	ld	b,15
_cdm_loop3:
	ld	a,(de)		;- set the default drum  bits
	ld	(hl),a
	inc	de
	ld	a,(16*7)+1
	add	a,l
	ld	l,a
	jr.	nc,88f
	inc	h
88:	
	djnz	_cdm_loop3
	ret
	

_cdm_DRUMDEFAULT:
	db	16, 8,24,1,2,18,10,26,4,20,17,9,25,22,3	

ENDIF

	
	; TODO Always set correct version
_ns_TEMP:
	db	"v0.13.7                         ",0	; 0 marker indicates placeholder 
	db	"                                "
;	db	"Richard Cornelisse      (c) ",YEAR
_empty_ins_label:
	db	"<no instrument> "