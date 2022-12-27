; SAM file format
;--- File header
; 00 - 3 : SAM
; 03 - 1 : Version
; 04 - 2 ; base note
;--- Frames
; +0 - 2 : period
; +2 - 32: waveform
;   <repeat>
;--- footer
; +0 - 2 : $FFFF
; +2 - 2 : loop offset (negative)








;===========================================================
; --- draw_sampleeditor
;
; Display the sample editor.  Without actual values 
; 
;===========================================================
draw_sampleeditor:

	ld	a,255
	ld	(song_order_update),a
	call	clear_screen
	call	draw_orderbox
	call	draw_songbox
	call	draw_samplebox
	call	draw_instrumentbox
	ret

		
;===========================================================
; --- update_sampleeditor
;
; Display the psg sample editor values. 
; 
;===========================================================
update_sampleeditor:

	call	update_orderbox
	call	update_songbox
	call	update_samplebox
	call	update_instrumentbox
	ret



restore_sampleeditor:
	ld	a,(editmode)
	cp	3
	jr.	z,99f
	
	ld	a,3
	ld	(editmode),a	
		
	call	restore_cursor
99:	; --- show the screen
	call	draw_sampleeditor
	call	update_sampleeditor
	
	ret


;===========================================================
; --- init_sampleeditor
;
; initialise the sample editor screen
; 
;===========================================================	
init_sampleeditor:
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
	call	reset_cursor_samplebox

	; --- show the screen
	call	draw_sampleeditor
	call	update_sampleeditor
	
	ret	
	
	
;===========================================================
; --- processkey_sampleeditor
; Specific controls 
; 
;===========================================================	
processkey_sampleeditor:
	;--- check for sample file dialog
	ld	a,(key)
	cp	5
	jr.	nz,.noFunctionkey

	;--- start filedialog
	ld	a,2
	call	swap_loadblock
	
	jr.	init_sam_filedialog

0:	




.noFunctionkey:
	;--- check [CTRL] combinations
	ld	a,(fkey)
	cp	_KEY_CTRL
	jr.	nz,processkey_sampleeditor_normal
		
	;--- check 2nd key combo
	ld	a,(key)
		;--- DOWN
		cp	_KEY_DOWN
		jr.	nz,0f
		; pattern# down
		ld	a,(sample_current)
		cp	0
		ret	z	; no update
		dec	a
		ld	(sample_current),a
		
		call	reset_cursor_samplebox
		call	update_sampleeditor
;		call	update_sccwave
		jr.	processkey_sampleeditor_END
0:
		;--- UP
		cp	_KEY_UP
		jr.	nz,0f
		; pattern# up
		ld	a,(sample_current)
		inc	a
		cp	MAX_SAMPLES
		ret	nc	; no update
		ld	(sample_current),a
				
		call	reset_cursor_samplebox
		call	update_sampleeditor
		jr.	processkey_sampleeditor_END	

0:

		



		jr.	processkey_sampleeditor_END	
	

;===========================================================
; --- process_key_sampleeditor_musickb
;
; Process the input for the pattern. 
; There are 2 version for compact and full view
; 
;===========================================================
process_key_sampleeditor_musickb:
	ld	a,(music_key)
	and	a
	ret	z				; stop if no key found

	;--- check for keyjazz
	;ex	af,af'	
;	ld	a,(keyjazz)
;	and	a
;	jr.	nz,process_key_samplejazz
;	jr. 	process_key_samplejazz
	ret		
	
processkey_sampleeditor_normal:	

	call	process_key_sampleeditor_musickb

	call	process_key_numpad
	jr.	c,update_sampleeditor

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

		call	set_font_org
		jr.	restore_patterneditor
		;jr.	processkey_sampleeditor_END
	
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
;	ld	a,(editsubmode)
;	and	a
;	jr.	z,0f
	ld	a,(keyjazz)
	and	a
;	ld	a,(key)
	jr.	nz,process_key_samplejazz
	
0:	
;	ld	a,(editsubmode)
;	and	a	
	jr.	z,process_key_samplebox
	
	dec	a
;	jr.	z,process_key_samplebox_waveform

	dec	a
;	jr.	z,process_key_samplebox_len		

	dec	a
;	jr.	z,process_key_samplebox_type
	
	dec	a
;	jr.	z,process_key_samplebox_octave			

	dec	a
;	jr.	z,process_key_sccwavebox_edit

	dec	a
;	jr.	z,process_key_samplebox_description
	
processkey_sampleeditor_END:

	ret