;===========================================================
; --- draw_psggsampleeditor
;
; Display the psg sample editor.  Without actual values 
; 
;===========================================================
draw_psgsampleeditor:
	call	clear_screen
	call	draw_orderbox
	call	draw_songbox
	call	draw_psgsamplebox
	call	draw_instrumentbox
	

	
	
	ret
		
;===========================================================
; --- update_psggsampleeditor
;
; Display the psg sample editor values. 
; 
;===========================================================
update_psgsampleeditor:

	call	update_orderbox
	call	update_songbox
	call	update_psgsamplebox
	call	update_instrumentbox
	ret



restore_psgsampleeditor:
	ld	a,(editmode)
	cp	1
	jr.	z,99f
	
	ld	a,1
	ld	(editmode),a	
		
	call	restore_cursor
	
99:	; --- show the screen
	call	draw_psgsampleeditor
	call	update_psgsampleeditor
	
	ret


;===========================================================
; --- init_psgsampleeditor
;
; initialise the psg sample editor screen
; 
;===========================================================	
init_psgsampleeditor:
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
	call	reset_cursor_psgsamplebox

	; --- show the screen
	call	draw_psgsampleeditor
	call	update_psgsampleeditor
	
	ret	
	
	
;===========================================================
; --- processkey_psgsampleeditor
; Specific controls 
; 
;===========================================================	
processkey_psgsampleeditor:
	;--- check for filedialog
	ld	a,(key)
	cp	5
	jr.	nz,0f
	;--- start filedialog
	ld	a,5
	call	swap_loadblock
	jr.	init_ins_filedialog

0:
	;--- check [CTRL] combinations
	ld	a,(fkey)
	cp	_KEY_CTRL
	jr.	nz,processkey_psgsampleeditor_normal
		
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
		
		call	reset_cursor_psgsamplebox
		call	update_psgsampleeditor
		call	update_sccwave
		jr.	processkey_psgsampleeditor_END
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
				
		call	reset_cursor_psgsamplebox
		call	update_psgsampleeditor
		call	update_sccwave
		jr.	processkey_psgsampleeditor_END	
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
			ret	z
			dec	a
			ld	(instrument_waveform),a
			ld	(hl),a
			call	update_sccwave
			jr.	update_psgsamplebox		

0:
		;--- Right
		cp	_KEY_RIGHT
		jr.	nz,0f
		;--- sample nr up
			ld	a,(hl)
			cp	MAX_WAVEFORM-1
			ret	nc
			inc	a
			ld	(hl),a
			ld	(instrument_waveform),a
			call	update_sccwave
			jr.	update_psgsamplebox

0:
	;--- CTRL_T- keyjazz chip type
	cp	_CTRL_T
	jr.	nz,0f
		ld	a,(keyjazz_chip)
		add	1
		and	$03
		jr.	nz,33f
		inc	a	
33:
		ld	(keyjazz_chip),a
		ld	hl,_LABEL_keyjazz
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
		jr.	update_psgsamplebox		

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
		call	reset_cursor_psgsamplebox
ENDIF
		jr.	processkey_psgsampleeditor_END			

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
			
		call	reset_cursor_psgsamplebox
		jr.	processkey_psgsampleeditor_END		
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
		call	reset_cursor_psgsamplebox
		jr.	processkey_psgsampleeditor_END		

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
		call	reset_cursor_psgsamplebox
		jr.	processkey_psgsampleeditor_END	
0:
	;--- CTRL_F - Wave form edit
	cp	_CTRL_F
	jr.	nz,0f
		ld	a,(editsubmode)
		and	a
		jr.	nz,79f
		call	save_cursor
79:
		ld	a,5
		ld	(editsubmode),a
		call	reset_cursor_psgsamplebox
		jr.	processkey_psgsampleeditor_END	
0:	
	;--- CTRL_D - Instrument description
	cp	_CTRL_D
	jr.	nz,0f
		ld	a,(editsubmode)
		and	a
		jr.	nz,79f
		call	save_cursor
79:
		ld	a,6
		ld	(editsubmode),a
		call	reset_cursor_psgsamplebox
		jr.	processkey_psgsampleeditor_END	
0:	
	;--- CTRL_C - Instrument copy
	cp	_CTRL_C
	jr.	nz,0f
		; instrument or waveform?
		ld	a,(editsubmode)
		cp	5
		jr.	nz,_pkps_instr

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
		jr.	processkey_psgsampleeditor_END	



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

		jr.	processkey_psgsampleeditor_END	
0:	
	;--- CTRL_V - Instrument paste
	cp	_CTRL_V
	jr.	nz,0f

		; instrument or waveform?
		ld	a,(editsubmode)
		cp	5
		jr.	nz,_pkpse_instr

		;--- paste a waveform
		ld	a,(waveform_select_status)
		and	a	
		jr.	z,processkey_psgsampleeditor_END

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
		call	update_psgsamplebox

		jr.	processkey_psgsampleeditor_END	

_pkpse_instr:		
		;-- we are copying an instrument
		ld	a,(instrument_select_status)	
		and	a
		jr.	z,processkey_psgsampleeditor_END

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
		call	update_psgsamplebox

		jr.	processkey_psgsampleeditor_END	
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
		
	
processkey_psgsampleeditor_normal:	

	;--- set octave using numpad
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
	call	update_psgsampleeditor

	jr.	processkey_psgsampleeditor_END

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

		call	restore_patterneditor
		jr.	processkey_psgsampleeditor_END
	

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
	jr.	z,process_key_psgsamplebox
	
	dec	a
	jr.	z,process_key_psgsamplebox_waveform

	dec	a
	jr.	z,process_key_psgsamplebox_len		

	dec	a
	jr.	z,process_key_psgsamplebox_loop
	
	dec	a
	jr.	z,process_key_psgsamplebox_octave			

	dec	a
	jr.	z,process_key_sccwavebox_edit

	dec	a
	jr.	z,process_key_psgsamplebox_description
	
processkey_psgsampleeditor_END:

	ret