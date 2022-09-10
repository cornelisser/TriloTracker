;===========================================================
; --- draw_psggsampleeditor
;
; Display the psg sample editor.  Without actual values 
; 
;===========================================================
draw_macroeditor:

	ld	a,255
	ld	(song_order_update),a
	call	clear_screen
	call	draw_orderbox
	call	draw_songbox
	call	draw_macrobox
	call	draw_instrumentbox
	

	
	
	ret
		
;===========================================================
; --- update_psggsampleeditor
;
; Display the psg sample editor values. 
; 
;===========================================================
update_macroeditor:

	call	update_orderbox
	call	update_songbox
	call	update_macrobox
	call	update_instrumentbox
	call	update_sccwave
	ret

restore_macroeditor:

IFDEF TTSCC
ELSE
	; restore voicemanager and Wave/Voice code.
;	ld	a,7
;	call	swap_loadelementblock
ENDIF


	ld	a,(editmode)
	cp	1
	jr.	z,99f
	
	ld	a,1
	ld	(editmode),a	
		
	call	restore_cursor
	
99:	; --- show the screen
	call	draw_macroeditor
	call	update_macroeditor
	
	ret


;===========================================================
; --- init_macroeditor
;
; initialise the psg sample editor screen
; 
;===========================================================	
init_macroeditor:
	ld	a,(editmode)
	cp	1
	ret	z

	call	save_cursor


	; --- File selection pointer to the first entry			
	xor	a
	ld	(menu_selection),a
	inc	a
	ld	(cursor_type),a		; hide cursor


	; --- init mode
	ld	a,1
	ld	(editmode),a
	ld	a,0
	ld	(editsubmode),a	
	call	reset_cursor_macrobox

	; --- show the screen
	call	draw_macroeditor
	call	update_macroeditor
	
	ret	
	
	
;===========================================================
; --- processkey_macroeditor
; Specific controls 
; 
;===========================================================	
processkey_macroeditor:
	;--- check for filedialog
	ld	a,(key)
	cp	5
	jr.	nz,0f
	;--- start instrument filedialog
	ld	a,5
	call	swap_loadblock
	;--- load generic filedialog
;	ld    a,6
;	call  swap_loadelementblock	
	
	jr.	init_ins_filedialog

0:
	;--- check [CTRL] combinations
	ld	a,(fkey)
	cp	_KEY_CTRL
	jr.	nz,processkey_macroeditor_normal
		
	;--- check 2nd key combo
	ld	a,(key)
	
		;--- DOWN
		cp	_KEY_DOWN
		jr.	nz,0f
		; pattern# down
		ld	a,(song_cur_instrument)
		cp	1
		ret	z	; no update
		dec	a
		ld	(song_cur_instrument),a
;		ld	(tmp_cur_instrument),a
		
		call	reset_cursor_macrobox
		call	update_macroeditor
		call	update_sccwave
		jr.	processkey_macroeditor_END
0:
		;--- UP
		cp	_KEY_UP
		jr.	nz,0f
		; pattern# up
		ld	a,(song_cur_instrument)
		inc	a
		cp	32
		ret	nc	; no update
		ld	(song_cur_instrument),a
;		ld	(tmp_cur_instrument),a
				
		call	reset_cursor_macrobox
		call	update_macroeditor
		call	update_sccwave
		jr.	processkey_macroeditor_END	
0:
		;--- get the location in RAM
		ld	d,a	; store key
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
		inc	hl
		inc	hl

		ld	a,d
		;--- LEFT
		cp	_KEY_LEFT
		jr.	nz,0f
		;--- sample nr down
			ld	a,(hl)
			and	a
IFDEF TTSCC
			ret	z
			dec	a
ELSE
			jr.	nz,99f
			ld	a,MAX_WAVEFORM
99:
			dec	a
ENDIF
			ld	(instrument_waveform),a
			ld	(hl),a
			call	update_sccwave
			jr.	update_macrobox		

0:
		;--- Right
		cp	_KEY_RIGHT
		jr.	nz,0f
		;--- sample nr up
			ld	a,(hl)
IFDEF TTSCC
			cp	MAX_WAVEFORM-1
			ret	nc
			inc	a
ELSE
			cp	MAX_WAVEFORM-1
			jr.	c,99f
			ld	a,-1
99:
			inc	a
ENDIF
			ld	(hl),a
			ld	(instrument_waveform),a
			call	update_sccwave
			jr.	update_macrobox

0:
	;--- CTRL_T- keyjazz chip type
	cp	_CTRL_T
	jr.	nz,0f
		;--- Set pointer to type
		ld	a,(song_cur_instrument)
		ld	hl,instrument_types
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:

		ld	a,(keyjazz_chip)
		add	1
		and	$03
		jr.	nz,33f
		inc	a	

33:
		ld	(hl),a
		ld	(keyjazz_chip),a
		
		call	build_instrument_list
		jr.	update_macrobox	
			

0:
	;--- CTRL_W- waveform number
	cp	_CTRL_W
	jr.	nz,0f
		ld	a,(editsubmode)
		and	a
		jr.	nz,79f
		call	save_cursor
79:
IFDEF TTFM
		jr.	init_voicemanager
ELSEIFDEF TTSMS
		jr.	init_voicemanager
ELSE
		ld	a,1
		ld	(editsubmode),a
		call	reset_cursor_macrobox
ENDIF
		jr.	processkey_macroeditor_END			

0:
	;--- CTRL_L - sample length
	cp	_CTRL_L
	jr.	nz,0f
		ld	a,(editsubmode)
		and	a
		jr.	nz,79f
		call	save_cursor
79:
		ld	a,2
		ld	(editsubmode),a
			
		call	reset_cursor_macrobox
		jr.	processkey_macroeditor_END		
0:
	;--- CTRL_R - Sample restart
	cp	_CTRL_R
	jr.	nz,0f
		ld	a,(editsubmode)
		and	a
		jr.	nz,79f
		call	save_cursor
79:
		ld	a,3
		ld	(editsubmode),a
		call	reset_cursor_macrobox
		jr.	processkey_macroeditor_END		

0:
	;--- CTRL_O - Octave
	cp	_CTRL_O
	jr.	nz,0f
		ld	a,(editsubmode)
		and	a
		jr.	nz,79f
		call	save_cursor
79:
		ld	a,4
		ld	(editsubmode),a
		call	reset_cursor_macrobox
		jr.	processkey_macroeditor_END	
0:
	;--- CTRL_F - Wave form edit
	cp	_CTRL_F
	jr.	nz,0f
IFDEF TTSCC
ELSE
		ld	a,(instrument_waveform)
		cp	177
		jr	c,0f
ENDIF	
		ld	a,(editsubmode)
		and	a
		jr.	nz,79f
		call	save_cursor
79:
		ld	a,5
		ld	(editsubmode),a
		call	reset_cursor_macrobox
		jr.	processkey_macroeditor_END	
IFDEF TTSCC
0:
	;--- CTRL_E - Waveform edit in hex
	cp	_CTRL_E
	jr. 	nz,0f
		ld	a,(editsubmode)
		and	a
		jr.	nz,79f
		call	save_cursor
79:		
		ld	a,7
		ld	(editsubmode),a
		call	reset_cursor_macrobox
		jr.	processkey_macroeditor_END
ENDIF
0:	
	;--- CTRL_N - Instrument name
	cp	_CTRL_N
	jr.	nz,0f
		ld	a,(editsubmode)
		and	a
		jr.	nz,79f
		call	save_cursor
79:
		ld	a,6
		ld	(editsubmode),a
		call	reset_cursor_macrobox
		jr.	processkey_macroeditor_END	
0:	
	;--- CTRL_C - Instrument copy
	cp	_CTRL_C
	jr.	nz,0f
		; instrument or waveform?
		ld	a,(editsubmode)
		cp	5
		jr.	nz,_pkps_instr

IFDEF TTSCC		
		;--- copy a waveform
		ld	a,1
		ld	(waveform_select_status),a	

		;--- calculate the current wave pos in RAM
		ld	a,(instrument_waveform)	; get the current waveform
		ld	hl,_WAVESSCC
		and	a
		jr.	z,99f
		
		ld	de,32
10:
		add	hl,de
		dec	a
		jr.	nz,10b
99:
		ld	de,waveform_buffer
		ld	bc,32
		ldir
		jr.	processkey_macroeditor_END	
ENDIF


_pkps_instr:		;-- we are copying an instrument
		ld	a,1
		ld	(instrument_select_status),a	

		;--- get the location in RAM
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
		;--- copy to buffer
		ld	de,instrument_buffer
		ld	bc,INSTRUMENT_SIZE
		ldir

		jr.	processkey_macroeditor_END	
0:	
	;--- CTRL_V - Instrument paste
	cp	_CTRL_V
	jr.	nz,0f

		; instrument or waveform?
		ld	a,(editsubmode)
		cp	5
		jr.	nz,_pkpse_instr

IFDEF TTSCC		
		;--- paste a waveform
		ld	a,(waveform_select_status)
		and	a	
		jr.	z,processkey_macroeditor_END

		;--- calculate the current wave pos in RAM
		ld	a,(instrument_waveform)	; get the current waveform
		ld	hl,_WAVESSCC
		and	a
		jr.	z,99f
		
		ld	de,32
10:
		add	hl,de
		dec	a
		jr.	nz,10b
99:
		ld	de,waveform_buffer
		ex	de,hl
		ld	bc,32
		ldir
		call	update_macrobox

		jr.	processkey_macroeditor_END	
ENDIF
		
_pkpse_instr:		
		;-- we are copying an instrument
		ld	a,(instrument_select_status)	
		and	a
		jr.	z,processkey_macroeditor_END

		;--- get the location in RAM
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
		ex	de,hl
		;--- copy to buffer
		ld	hl,instrument_buffer
		ld	bc,INSTRUMENT_SIZE
		ldir
		call	update_macrobox

		jr.	processkey_macroeditor_END	
0:	
	;--- CTRL + I - Instruments
	cp	_CTRL_I
	jr.	nz,0f
_pppp_instruments:	
		ld	a,(editsubmode)
		and	a
		jr.	nz,79f
		call	save_cursor
79:
		ld	a,11
		ld	(editsubmode),a
		call	reset_cursor_instrumentbox
		jr.	processkey_patterneditor_END

0:
		
	
processkey_macroeditor_normal:	

	call	process_key_numpad
	jr.	c,update_macroeditor


0:
	;--- insturment editor?
	ld	a,(editsubmode)
	cp	11
	;--- Instruments
	jr.	z,process_key_instrumentbox	



	ld	a,(key)
	
	;--- Instrument select
	cp	_KEY_TAB
	jr.	nz,1f
	ld	a,(editmode)
	cp	11
	ld	a,(key)
	jr.	nz,_pppp_instruments

1:	
	; - ESCAPE
	cp	_ESC
	jr.	nz,0f
	; escape 
	ld	a,(editsubmode)
	and	a
	jr.	nz,0f

		jr.	restore_patterneditor
		;jr.	processkey_macroeditor_END
	

0:
	cp	_SPACE
	jr.	nz,1f
	;--- only if we are editing
	ld	a,(editsubmode)
	and	a
	jr.	nz,1f
	ld	a,(keyjazz)
	xor 	1
	ld	(keyjazz),a
	jr.	set_textcolor		
1:
	
	ld	a,(editsubmode)
	and	a	
	jr.	z,process_key_macrobox
	
	dec	a
	jr.	z,process_key_macrobox_waveform

	dec	a
	jr.	z,process_key_macrobox_len		

	dec	a
	jr.	z,process_key_macrobox_loop
	
	dec	a
	jr.	z,process_key_macrobox_octave			

	dec	a
IFDEF	TTSCC	
	jr.	z,process_key_sccwavebox_edit
ELSE
	jr.	z,process_key_voicebox_edit
ENDIF
	dec	a
	jr.	z,process_key_macrobox_description
IFDEF TTSCC
	dec	a
	jr.	z,process_key_sccwavebox_hex	
ENDIF

	
processkey_macroeditor_END:

	ret