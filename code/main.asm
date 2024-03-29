_TRACK1ONOFF	equ 32
_TRACK2ONOFF	equ 64
_TRACK3ONOFF	equ 128
_TRACK4ONOFF	equ 1
_TRACK5ONOFF	equ 2
_TRACK6ONOFF	equ 4
_TRACK7ONOFF	equ 8
_TRACK8ONOFF	equ 16

; --- Main loop

MAIN_LOOP:
	halt
	call	show_cursor
	call	read_key
	call	musickb_readkey

	; --- Dispatch input checks	
	ld	a,(editmode)
	and	a	
	jr.	nz,0f	
	;--- 0:Pattern screen
		call	processkey_patterneditor
		jr.	_main_dispatch_END
0:	dec	a
	jr.	nz,0f		
	;--- 1:PSG sampleeditor
		call	processkey_macroeditor
		jr.	_main_dispatch_END
0:	dec	a
	jr.	nz,0f
;	;--- 2: Config menu
		call	processkey_configeditor
		jr.	_main_dispatch_END

IFDEF TTSCC
0:	dec	a
	;--- 3: Sample editor
	jr.	nz,0f
		call	processkey_sampleeditor
		jr.	_main_dispatch_END
ELSE
0:	dec	a
	;--- 3: Drum macro editor
	jr.	nz,0f
		call	processkey_drumeditor
		jr.	_main_dispatch_END
ENDIF
	
0:	dec	a
	;--- 4: Track manager
	jr.	nz,0f
;		call	processkey_trackmanager
		jr.	_main_dispatch_END
	;--- 5: File dialog
0:	dec	a
	jr.	nz,0f
		call	processkey_filedialog
		jr.	_main_dispatch_END
0:	dec	a
	;--- 6: Instrument File dialog
	jr.	nz,0f
		call	processkey_ins_filedialog
		jr.	_main_dispatch_END

IFDEF TTSCC
0:	dec	a
	;--- 7: Sample file dialog
	jr.	nz,0f
		call	processkey_sam_filedialog
		jr.	_main_dispatch_END


ELSE 
0:	dec	a
	;--- 7: Instrument Voice manager
	jr.	nz,0f
		call	processkey_voicemanager
		jr.	_main_dispatch_END
ENDIF

0:


_main_dispatch_END:
	jr. MAIN_LOOP	;- to disable the key debug display
	;--- Display key for debug purposes.

;	ld	a,(key_value)
;	ld	(_dd+4),a
;	
;	ld	de,_dd+6
;	call	draw_hex2
;
;	ld	hl,(80*2)+44+4
;	ld	de,_dd
;	call	draw_label
;
;	ld	hl,(80*3)+44+4
;	ld	de,KH_buffer
;	ld	b,16
;	call	draw_label_fast
;	ld	hl,(80*4)+44+4
;	ld	de,KH_buffer+16
;	ld	b,16
;	call	draw_label_fast
;
;1:
;	jr. MAIN_LOOP
;;
;_dd:
;	db	"Key: (  )",0
	
	
_tmp_pattern:		db	0
_tmp_pattern_offset:	db	0
;_tmp_speed:		db	0
_tmp_orderpos:		db	0
_tmp_patline:		db	0

;===========================================================
; --- start_playback_stepped
;
; Start playing from current pos/line but only this pattern
;===========================================================
start_playback_stepped:
	ld	a,(song_pattern)	; store current pattern
	ld	(_tmp_pattern),a

	ld	a,(song_pattern_line)
	ld	(_tmp_patline),a
	
	ld	a,(song_order_pos)		
	ld	(_tmp_orderpos),a
	
	ld	a,(song_pattern_offset)
	ld	(_tmp_pattern_offset),a
		
	call	replay_init		; setup all registers
	di
	ld	a,5			; replay mode 5 = play stepped
	jr.	_start_playback_continue
	
;===========================================================
; --- start_playback_looped
;
; Start playing from current pos/line but only this pattern
;===========================================================
start_playback_looped:
	ld	a,(song_pattern)	; store current pattern
	ld	(_tmp_pattern),a

	ld	a,(song_pattern_line)
	ld	(_tmp_patline),a
	
	ld	a,(song_order_pos)		
	ld	(_tmp_orderpos),a
	
	ld	a,(song_pattern_offset)
	ld	(_tmp_pattern_offset),a
		
	call	replay_init		; setup all registers
	di
	ld	a,4			; replay mode 1 = play song
	jr.	_start_playback_continue

;===========================================================
; --- start_playback
;
; Start playing from current pos/line
;===========================================================
start_playback:
	ld	a,(song_pattern)	; store current pattern
	ld	(_tmp_pattern),a

	ld	a,(song_pattern_line)
	ld	(_tmp_patline),a
	
	ld	a,(song_order_pos)		
	ld	(_tmp_orderpos),a
	
	ld	a,(song_pattern_offset)
	ld	(_tmp_pattern_offset),a

	; set the correct pattern for display
		ld	a,(song_order_pos)
		ld	hl,song_order
		add	a,l
		ld	l,a
		jr.	nc,4f
		inc	h
4:				
		ld	a,(hl)
		ld	(song_pattern),a	


		
	call	replay_init		; setup all registers

;	di		
	ld	a,1			; replay mode 1 = play song
_start_playback_continue:
	ld	(replay_mode),a
	call	replay_init_pre
	;--- now reset any speed changes by the pre scan.
	ld	a,1
	ld	(replay_speed_timer),a
	
;	ld	a,(current_song)
	call	set_songpage
	ld	a,-8;	-7		; set offset to center screen
	ld	(song_pattern_offset),a	
	
	;--- erase possible selection
	call	reset_selection
	call	selection_show
	
	
	ld	hl,0x0011		; draw the line for the current played line.
	ld	de,0x5001	

	call	draw_colorbox		
	


	

	
	
	
_playback_loop:
	halt
	
	ld	a,(_CONFIG_DEBUG)
	and	a
	jr.	z,99f
	call	draw_register_debug

99:
	call	draw_vu

	;-- Center the song to the center of the screen
	ld	a,(replay_line)
	dec	a
	ld	(song_pattern_line),a
	sub	7
	ld	(song_pattern_offset),a
	; update only the minimal needed info.
	; ADD special faster here for non tR machines.?
	call 	update_trackbox
	call	update_patternbox
	call	update_orderbox


;	ld	a,(key)
;	cp	1
;	jr.	nz,0f
;	
;	ld	a,1
;;	ld	(replay_mode),a
;
;0:	
	;--- Trigger an ESC when replayer stoped (no loop)
	ld	a,(replay_mode)
	and	a
	jr.	nz,4f

	ld	a,_ESC	; trick  key into ESC to stop.	
	ld	(key),a
	jr.	5f

4:
	call	read_key

	ld	a,(key)
	and	a
	jr.	z,_playback_loop
5:
	; check key for muting channels
	call	check_channel_mute
	call	check_channel_soloplay


	ld	a,(key)
	cp	_SPACE
	jr.	nz,0f
	
;	call 	replay_init
	call	replay_stop
;	ld	a,(current_song)
	call	set_songpage	
	halt
	
	xor	a
	ld	(replay_mode),a

	ld	a,(editsubmode)
	and	a
	jr.	z,99f
	
	ld	a,0
	ld	(editsubmode),a
	call	restore_cursor	
		
99:	ld	a,(_tmp_pattern)
	ld	(song_pattern),a	

	ld	a,(_tmp_orderpos)
	ld	(song_order_pos),a		

	ld	a,(_tmp_pattern_offset)
	ld	(song_pattern_offset),a
	ld	b,a

	ld	a,(_tmp_patline)
	ld	(song_pattern_line),a
	
	sub	b
	add	10
	ld	(cursor_y),a
	jr.	33f
		
		
0;
	cp	_ENTER
	jr.	nz,0f
	ld	a,_ESC	; trick  key into ESC to stop.		
	
0:	
	cp	_ESC
	jr.	nz,_playback_loop
	
;	call replay_init
	call	replay_stop
;	ld	a,(current_song)
	call	set_songpage	
	halt
	
	xor	a
	ld	(replay_mode),a
	
	ld	a,(editsubmode)
	and	a
	jr.	z,99f
	
	ld	a,0
	ld	(editsubmode),a
	call	restore_cursor
99:	
	ld	a,17
	ld	(cursor_y),a

	;--- this is a workaround. to avoid ending outside the pattern.
	call	 check_cursor_patternbox
33:	call	reset_selection
	ld	hl,0x0211		; draw the line for the current played line.
	ld	de,0x4c01	
	call	erase_colorbox
	
	;call	draw_patterneditor
	call 	update_patterneditor	
	call	draw_vu_empty
	ret
