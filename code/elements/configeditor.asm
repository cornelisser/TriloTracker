;===========================================================
; --- draw_psggsampleeditor
;
; Display the config editor.  Without actual values 
; 
;===========================================================
draw_configeditor:
	call	clear_screen
	call	draw_orderbox
	call	draw_songbox
	call	draw_patternbox	
	call	draw_instrumentbox
	call	draw_configbox

	

	
	
	ret
		
;===========================================================
; --- update_psggsampleeditor
;
; Display the config editor values. 
; 
;===========================================================
update_configeditor:
	call	update_orderbox
	call	update_songbox
	call	update_patternbox	
;	call	update_psgsamplebox
	call	update_instrumentbox
	call	update_configbox
	ret




;===========================================================
; --- init_configeditor
;
; initialise the config editor screen
; 
;===========================================================	
init_configeditor:
	ld	a,(editmode)
	cp	2
	ret	z

	call	set_songpage
	call	save_cursor

	; --- File selection pointer to the first entry			
	xor	a
	ld	(menu_selection),a
	inc	a
	ld	(cursor_type),a		; hide cursor


	; --- init mode
	ld	a,2
	ld	(editmode),a
	ld	a,0
	ld	(editsubmode),a	
;	call	reset_cursor_psgsamplebox

	call	reset_cursor_configbox

	; --- show the screen
	call	draw_configeditor
	call	update_configeditor

	ret	
	
	
;===========================================================
; --- processkey_psgsampleeditor
; Specific controls 
; 
;===========================================================	
processkey_configeditor:

	call	process_key_configbox


processkey_configeditor_END:

	ret