;===========================================================
; --- draw_psggsampleeditor
;
; Display the psg sample editor.  Without actual values 
; 
;===========================================================
draw_drumeditor:

	ld	a,255
	ld	(song_order_update),a
	call	clear_screen
	call	draw_orderbox
	call	draw_songbox
	call	draw_drumeditbox
	call	draw_instrumentbox
;	call update_samplebox
	ret

		
;===========================================================
; --- update_psggsampleeditor
;
; Display the psg sample editor values. 
; 
;===========================================================
update_drumeditor:

	call	update_orderbox
	call	update_songbox
	call	update_drumeditbox
	call	update_instrumentbox
	ret



restore_drumeditor:
	ld	a,(editmode)
	cp	1
	jr.	z,99f
	
	ld	a,1
	ld	(editmode),a	
		
	call	restore_cursor
	
99:	; --- show the screen
	call	draw_drumeditor
	call	update_drumeditor
	
	ret


;===========================================================
; --- init_drumeditor
;
; initialise the FM drum editor screen
; 
;===========================================================	
init_drumeditor:
	ld	a,(editmode)
	cp	3
	ret	z

	call	save_cursor


	; --- File selection pointer to the first entry			
	xor	a
	ld	(menu_selection),a
	inc	a
	ld	(cursor_type),a		; hide cursor


	; --- init mode
	ld	a,3
	ld	(editmode),a
	ld	a,0
	ld	(editsubmode),a	
	call	reset_cursor_drumeditbox

	; --- show the screen
	call	draw_drumeditor
	call	update_drumeditor
	
	ret	
	
	
;===========================================================
; --- processkey_drumeditor
; Specific controls 
; 
;===========================================================	
processkey_drumeditor:
0:
	;--- check [CTRL] combinations
	ld	a,(fkey)
	cp	_KEY_CTRL
	jr.	nz,processkey_drumeditor_normal
		
	;--- check 2nd key combo
	ld	a,(key)
	
		;--- DOWN
		cp	_KEY_DOWN
		jr.	nz,0f
_drum_up:
		; pattern# down
		ld	a,(song_cur_drum)
		cp	1
		ret	z	; no update
		dec	a
		ld	(song_cur_drum),a
		
		call	reset_cursor_drumeditbox
		call	update_drumeditor
;		call	update_sccwave
		jr.	processkey_drumeditor_END
0:
		;--- UP
		cp	_KEY_UP
		jr.	nz,0f
		; pattern# up
_drum_down:		
		ld	a,(song_cur_drum)
		inc	a
		cp	MAX_DRUMS
		ret	nc	; no update
		ld	(song_cur_drum),a
				
		call	reset_cursor_drumeditbox
		call	update_drumeditor
		jr.	processkey_drumeditor_END	

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
			
		call	reset_cursor_drumeditbox
		jr.	processkey_drumeditor_END		
0:
;	;--- CTRL_T - type
;	cp	_CTRL_T
;	jr.	nz,0f
;		ld	a,(editsubmode)
;		and	a
;		jr.	nz,79f
;		call	save_cursor
;79:
;		ld	a,3
;		ld	(editsubmode),a
;		call	reset_cursor_drumeditbox
;		jr.	processkey_drumeditor_END		
;
;0:
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
		call	reset_cursor_drumeditbox
		jr.	processkey_drumeditor_END	
0:
;	;--- CTRL_F - Wave form edit
;	cp	_CTRL_F
;	jr.	nz,0f
;		ld	a,(editsubmode)
;		and	a
;		jr.	nz,79f
;		call	save_cursor
;79:
;		ld	a,5
;		ld	(editsubmode),a
;		call	reset_cursor_psgsamplebox
;		jr.	processkey_psgsampleeditor_END	
0:	
	;--- CTRL_D - Instrument Name
	cp	_CTRL_N
	jr.	nz,0f
		ld	a,(editsubmode)
		and	a
		jr.	nz,79f
		call	save_cursor
79:
		ld	a,6
		ld	(editsubmode),a
		call	reset_cursor_drumeditbox
		jr.	processkey_drumeditor_END	
0:	
	;--- CTRL_C - Drum copy
	cp	_CTRL_C
	jr.	nz,0f
		ld	a,1
		ld	(drum_select_status),a	

		;--- get the location in RAM
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
		;--- copy to buffer
		ld	de,drum_buffer
		ld	bc,DRUMMACRO_SIZE
		ldir

		jr.	processkey_drumeditor_END	
0:	
	;--- CTRL_V - Drum paste
	cp	_CTRL_V
	jr.	nz,0f
		ld	a,(drum_select_status)	
		and	a
		jr.	z,processkey_drumeditor_END

		;--- get the location in RAM
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
		ex	de,hl
		;--- copy to buffer
		ld	hl,drum_buffer
		ld	bc,DRUMMACRO_SIZE
		ldir
		call	update_drumeditbox

		jr.	processkey_drumeditor_END	
	

;===========================================================
; --- process_key_drumeditor_musickb
;
; Process the input for the pattern. 
; There are 2 version for compact and full view
; 
;===========================================================
process_key_drumeditor_musickb:
	ld	a,(music_key)
	and	a
	ret	z				; stop if no key found

	;--- check for keyjazz
	;ex	af,af'	
;	ld	a,(keyjazz)
;	and	a
;	jr.	nz,process_key_drumjazz
	jr. 	process_key_drumjazz
;	ret		
	



processkey_drumeditor_normal:	

	call	process_key_drumeditor_musickb

	;--- Check drum numpad extra
	ld	a,(key_value)
	cp	72
	jr.	c,0f
	cp	89
	jr.	nc,0f

	ld	a,(key)
	;--- Drum up
	cp	"+"
	jr.	nz,1f
	jr.	_drum_down
1:	
	;--- drum down
	cp	"-"
	jr.	nz,1f
	jr.	_drum_up
1:	
	;--- drum reset
	cp "0"
	jr.	nz,1f
	jr.	update_drumeditor
1:
	call	process_key_numpad
	jr. 	c,update_drumeditor


0:
;	;--- insturment editor?
;	ld	a,(editsubmode)
;	cp	11
;	;--- Instruments
;	jr.	z,process_key_instrumentbox	


	ld	a,(key)

	; - ESCAPE
	cp	_ESC
	jr.	nz,0f
	; escape 
	ld	a,(editsubmode)
	and	a
	jr.	nz,0f

		jr.	restore_patterneditor
		;jr.	processkey_drumeditor_END
	
0:
	cp	_SPACE
	jr.	nz,1f
	
	;-- Always reset
	ld	a,(keyjazz)
	and	a
	jr.	nz,2f
	;--- only if we are editing
	ld	a,(editsubmode)
	and	a
	jr.	nz,1f
	ld	a,(keyjazz)
2:	xor 	1
	ld	(keyjazz),a
	jr.	set_textcolor		
1:
	ld	a,(editsubmode)
	and	a
	jr.	nz,0f
	ld	a,(keyjazz)
	and	a
	jr.	nz,process_key_drumjazz
	
0:	
	ld	a,(editsubmode)
	and	a	
	jr.	z,process_key_drumeditbox
	
	dec	a
;	jr.	z,process_key_drumbox_waveform

	dec	a
	jr.	z,process_key_drumeditbox_len		

	dec	a
;	jr.	z,process_key_drumeditbox_type
	
	dec	a
	jr.	z,process_key_drumeditbox_octave			

	dec	a
;	jr.	z,process_key_sccwavebox_edit

	dec	a
	jr.	z,process_key_drumeditbox_description
	
processkey_drumeditor_END:

	ret