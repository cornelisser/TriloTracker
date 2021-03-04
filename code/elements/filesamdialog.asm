;===========================================================
; --- draw_sam_filedialog
; Display the sequence area.  Without actual values 
; 
;===========================================================
draw_sam_filedialog:

	;filemessage/input
	ld	hl,(80*2)+0
	ld	de,(58*256) + 2
	call	draw_box	
	ld	hl,0x0002
	ld	de,0x3903
	call	draw_colorbox	
	
	;directory
	ld	hl,(80*4)+0
	ld	de,(58*256) + 1
	call	draw_box	
	ld	hl,0x0004
	ld	de,0x3901
	call	draw_colorbox		
	
	
	;rightside bar
	ld	hl,0x3902
	ld	de,0x1718
	call	draw_colorbox	
	 
	;song area
	ld	hl,(80*2)+57
	ld	de,(23*256) + 5
	call	draw_box	
	ld	hl,0x3a03
	ld	de,0x1504
	call	erase_colorbox	
	ld	hl,(80*3)+0x3b
	;menu 1
	ld	de,_LABEL_DISKSAM
	call	draw_label
	inc	de
	ld	hl,(80*4)+0x3b
	call	draw_label
;	inc	de	
;	ld	hl,(80*5)+0x3b
;	call	draw_label
;	inc	de	
;	ld	hl,(80*6)+0x3b
;	call	draw_label	
	
	
	;menu 2
	ld	hl,(80*7)+57
	ld	de,(23*256) + 5
	call	draw_box	
	ld	hl,0x3a08
	ld	de,0x1504
	call	erase_colorbox		
	ld	hl,(80*8)+0x3b	
	ld	de,_LABEL_DISKPAK
	call	draw_label
	inc	de
	ld	hl,(80*9)+0x3b
	call	draw_label
;	inc	de	
;	ld	hl,(80*10)+0x3b
;	call	draw_label
;	inc	de	
;	ld	hl,(80*11)+0x3b
;	call	draw_label	
	
	;menu 3
	ld	hl,(80*12)+57
	ld	de,(23*256) + 5
	call	draw_box	
	ld	hl,0x3a0d
	ld	de,0x1504
	call	erase_colorbox		

	;drive name
	ld	hl,(80*17)+57
	ld	de,(23*256) + 2
	call	draw_box	
	ld	hl,0x3a12
	ld	de,0x1501
	call	erase_colorbox	
	ld	hl,(80*18)+0x3b	
	ld	de,_LABEL_DISKDRIVE
	call	draw_label

	ret
		
_LABEL_DISKSAM:
	db	"Load Sample",0
	db	"Save Sample",0
_LABEL_DISKPAK:
	db	"Load Sample-Pak",0
	db	"Save Sample-Pak",0
	

;===========================================================
; --- update_sam_filedialog
; Display the sequence area.  Without actual values 
; 
;===========================================================
update_sam_filedialog:
	;--- the current drive
	ld	hl,(80*4)+0
	ld	de,(58*256) + 1
	call	draw_box	
	
	ld	de,disk_workdir
	ld	hl,(80*18)+0x3b+7
	ld	b,1
	call	draw_label_fast

	;--- the current directory
	ld	de,buffer		; buffer has drive+path+wildcard
	ld	hl,(80*4)+2
	call	draw_label	

	;--- Show current menu selection
	ld	a,(menu_selection)
	cp	4
	jr.	c,_usfd_showselection
	inc	a
	cp	9
	jr.	c,_usfd_showselection
	inc	a	
	cp	14
	jr.	c,_usfd_showselection
	inc	a


	
_usfd_showselection:
	add	3
	ld	l,a
	ld	h,59
	ld	de,0x1301
	call	draw_colorbox


	call	update_filedialog_files

	ret
	


;===========================================================
; --- init_sam_filedialog
; Starts the file dialog  Without actual values 
; 
;===========================================================	
init_sam_filedialog:

	ld	a,(editmode)
	cp	7
	ret	z
	
	ld	a,(editsubmode)
	and	a
	jr.	nz,99f

	call	save_cursor	
99:	
	; erase workingdir display.
	xor	a
	ld	(buffer),a
	
	; --- Init values
	ld	a,7
	ld	(editmode),a
	ld	a,0
	ld	(editsubmode),a	
	ld	(file_selection),a
	ld	(menu_selection),a
	ld	(disk_entries),a	
	
	call 	reset_cursor_sam_filedialog
	call	clear_screen
	call	draw_sam_filedialog
	
	; fill buffer with information
	ld	de,_SAM_WILDCARD
	call	set_wildcard
	
;	ld	de,_FILMES_retrieve
;	call	message_filedialog
;	call	get_dir
	ld	de,_FILMES_none
	call	message_filedialog	
	
	; show this information	
	call	update_sam_filedialog

	ret
	
	
	
	
;===========================================================
; --- processkey_sam_filedialog
; input handling
; 
;===========================================================
processkey_sam_filedialog:

	ld	a,(editsubmode)
	;-- special check for filename
	cp	255
	jr.	z,processkey_filedialog_filename
	and	a
	jr.	z,processkey_sam_filedialog_menu	;--- Menu select
	;dec	a
	jr.	processkey_sam_filedialog_selectfile	;--- File select
	
	ret	
	
	

;===========================================================
; --- processkey_sam_filedialog_menu
;
; 
;===========================================================
processkey_sam_filedialog_menu:
	ld	a,(key)
	
	; - ESCAPE
	cp	_ESC
	jr.	nz,0f
	; escape 
		call	restore_sampleeditor
		jr.	processkey_sam_filedialog_fileselect_END
0:
	; - UP
	cp	_KEY_UP
	jr.	nz,0f
	;up
		ld	a,(menu_selection)
		and	a
		jr.	z,processkey_sam_filedialog_menu_END	; no update
		cp	4
		jp	nz,99f
		ld	a,2
99:
		cp	12
		jp	nz,99f
		ld	a,6
99:
		dec	a
		ld	(menu_selection),a
		;--- erase the menu selection	
777:		call	reset_cursor_sam_filedialog
		ld	hl,0x3a03
		ld	de,0x1504
		call	erase_colorbox	
		ld	hl,0x3a08
		ld	de,0x1504
		call	erase_colorbox			
		ld	hl,0x3a0d
		ld	de,0x1504
		call	erase_colorbox	
		ld	hl,0x3a12
		ld	de,0x1501
		call	erase_colorbox				
		jr.	_spfd_m_END	
0:
	; - down
	cp	_KEY_DOWN
	jr.	nz,0f
	;down
		ld	a,(menu_selection)
		cp	12
		jr.	nc,processkey_sam_filedialog_menu_END	; no update
		cp	1
		jp	nz,99f
		ld	a,3
99:
		cp	5
		jp	nz,99f
		ld	a,11
99:
		inc	a
		ld	(menu_selection),a
		jr.	777b
0:
	; - right
	cp	_KEY_RIGHT
	jr.	nz,0f	
	;--- check if we are at drive select
	ld	a,(menu_selection)
;	cp	8
;	jr.	nz,processkey_filedialog_menu_END
	;--- get next drive
	ld	a,(disk_drives)		; contains the available drives.
	ld	b,a
	ld	d,1
	
	ld	a,(disk_workdir)		; the drive name is in the buffer
	sub	65
	ld	c,a
	jr.	_sfd_drive_change

0:
	; - left
	cp	_KEY_LEFT
	jr.	nz,0f	
	;--- check if we are at drive select
;	ld	a,(menu_selection)
;	cp	8
;	jr.	nz,processkey_filedialog_menu_END
	;--- get next drive
	ld	a,(disk_drives)		; contains the available drives.
	ld	b,a
	ld	d,-1
	
	ld	a,(disk_workdir)		; the drive name is in the buffer
	sub	65
	ld	c,a

_sfd_drive_change:	
	;-- translate current drive to bit mask
	and	a
	jr.	z,_sfd_drive_loop
_sfd_drive_l:
	rrc	b
	dec	a
	jr.	nz,_sfd_drive_l

	;-- apply mask and shift till next drive.
	
_sfd_drive_loop: 
	ld	a,d
	cp	-1
	jr.	nz,_sfd_drive_fw

	;--- backward
	rlc	b
	dec	c
	jr.	_sfd_drive_check

_sfd_drive_fw:
	;--- forward
	inc	c
	rrc	b	

_sfd_drive_check:
	ld	a,c
	and	$07
	ld	c,a

	bit	0,b
	jr.	z,_sfd_drive_loop

	xor	a
	ld	(window_shown),a
	;--- set the new drive
	ld	a,c
	call 	select_drive
	
	ld	a,(window_shown)
	and	a
	jp	nz,restore_samfiledialog
	
	;--- no erorr was shown.
	ld	de,_FILMES_none
	call	message_filedialog
	call	reset_cursor_sam_filedialog
	jr.	_spfd_m_END

0:
	; --- ENTER
	cp	_KEY_ENTER
	jr.	z,99f
	cp	_SPACE	
	jr.	nz,processkey_sam_filedialog_menu_END
99:	
	;-- reset selection cursor position.
	xor	a
	ld	(file_selection),a
	;--- Selection is made
	ld	a,(menu_selection)
	and	a
	jr.	z,_spf_load_sam
	dec	a
	jr.	z,_spf_save_sam
	dec	a
	dec	a
	dec	a
	jr.	z,_spf_load_pak	
	dec	a
	jr.	z,_spf_save_pak
		
	ret	
	
_spf_load_sam:	;--- 0 = load sample
	ld	a,1
	ld	(editsubmode),a	
	call	reset_cursor_sam_filedialog
	
	;	; fill buffer with information
	ld	de,_SAM_WILDCARD
_spf_open_cont:
	call	set_wildcard
	ld	de,_FILMES_retrieve
	call	message_filedialog
	xor	a
	ld	(window_shown),a
	call	get_dir
	ld	a,(window_shown)
	and	a
	call	nz,restore_samfiledialog
	ld	de,_FILMES_select_open
	call	message_filedialog
	
	call	update_sam_filedialog	
	jr.	update_filedailog_fileselection



_spf_save_sam:	;--- 1 = save sample
	ld	a,2
	ld	(editsubmode),a
	call	reset_cursor_sam_filedialog
	
	; fill buffer with information
	ld	de,_SAM_WILDCARD
_spf_save_cont:
	call	set_wildcard
	ld	de,_FILMES_retrieve
	call	message_filedialog
	xor	a
	ld	(window_shown),a
	call	get_dir
	ld	a,(window_shown)
	and	a
	call	nz,restore_samfiledialog
	ld	de,_FILMES_select_save
	call	message_filedialog
	
	call	update_sam_filedialog	
	jr.	update_filedailog_fileselection


_spf_load_pak:	;--- 4 = load pak
	ld	a,1
	ld	(editsubmode),a
	call	reset_cursor_sam_filedialog
	
	; fill buffer with information
	ld	de,_PAK_WILDCARD
	jr.	_spf_open_cont



_spf_save_pak:	;--- 7 = save macroset
	ld	a,2
	ld	(editsubmode),a
	call	reset_cursor_sam_filedialog
	
	; fill buffer with information
	ld	de,_PAK_WILDCARD
	jr.	_spf_save_cont


_spfd_m_END:
	jr.	update_sam_filedialog
	
processkey_sam_filedialog_menu_END:
	ret


;===========================================================
; --- processkey_sam_filedialog_selectfile
;
; 
;===========================================================
processkey_sam_filedialog_selectfile:
	ld	a,(key)
	
	; - ESCAPE
	cp	_ESC
	jr.	nz,0f
	; escape 
		xor	a
		ld	(editsubmode),a
		ld	(disk_entries),a
		call	_fd_noentries
		call	reset_cursor_sam_filedialog
		ld	de,_FILMES_none
		call	message_filedialog
		jr.	update_sam_filedialog
0:	
	
	; - Left
	cp	_KEY_LEFT
	jr.	nz,0f
	; left key
	ld	a,(file_selection)
	and	a
	ret	z	; no update
	dec	a
	ld	(file_selection),a
	jr.	_spfd_sf_END
0:
	; - Right
	cp	_KEY_RIGHT
	jr.	nz,0f
	; left right
	ld	a,(disk_entries)
	dec	a
	ld	b,a
	ld	a,(file_selection)
	cp	b
	ret	nc	; no update
	inc	a
	ld	(file_selection),a
	jr.	_spfd_sf_END	
0:
	; - UP
	cp	_KEY_UP
	jr.	nz,0f
	;up
		ld	a,(file_selection)
		cp	4
		jr.	c,processkey_sam_filedialog_fileselect_END	; no update
		sub	4
		ld	(file_selection),a
		jr.	_spfd_sf_END	
0:
	; - down
	cp	_KEY_DOWN
	jr.	nz,0f
	;down
		ld	a,(disk_entries)
		ld	b,a
		ld	a,(file_selection)
		add	4
		cp	b
		jr.	nc,processkey_sam_filedialog_fileselect_END	; no update
		ld	(file_selection),a
		jr.	_spfd_sf_END	
0:
	;--- Type filename check
	cp	"!"
	jr.	z,_spfs_foundvalidchar
	cp	"#"
	jr.	c,0f
	cp	"'"+1
	jr.	c,_spfs_foundvalidchar
	cp	"-"
	jr.	z,_spfs_foundvalidchar
	cp	"0"
	jr.	c,0f
	cp	":"
	jr.	c,_spfs_foundvalidchar	
	cp	"?"
	jr.	c,0f
	cp	"Z"+1
	jr.	c,_spfs_foundvalidchar
	cp	"^"
	jr.	c,0f
	cp	"~"+1
	jr.	nc,0f

_spfs_foundvalidchar:
	ld	b,a
	ld	a,(menu_selection)
	and	2			; saving only possible for even menu items ;)
	ld	a,b
	jr.	nz,processkey_filedialog_filename	


0:

	;- Enter
	cp	_KEY_ENTER
	jr.	z,99f
	cp	_SPACE
	jr.	nz,processkey_sam_filedialog_fileselect_END
	
99:	ld	hl,buffer+192		; calculate filename pos in the buffer
	ld	a,(file_selection)	; selected file
	and	a
	jr.	z,1f
	ld	b,a
	ld	de,14			; length in buffer of a name
_spfd_eloop:
		add	hl,de		
		djnz	_spfd_eloop
	
1:	ld	a,(hl)			; check first char of filename (type)
	inc	hl
	cp	">"			; it the start contains a "\" then it is a dir	
	jr.	z,_spfd_sf_DIR
	
	;==================================
	;--- Determin the action to execute
	;
	;==================================
	ld	a,(menu_selection)
	and	a
	jr.	z,_spfd_LOAD_SAM
	dec	a
	jr.	z,_spfd_SAVE_SAM
	dec	a
	dec	a
	dec	a
	jr.	z,_spfd_LOAD_PAK
	dec	a
	jr.	z,_spfd_SAVE_PAK

	;--- Add more actions here	
	


	
_spfd_LOAD_SAM:	
	xor	a
	ld	(window_shown),a
	;--- LOAD An instrument (macro+waveform)
	ld	de,_FILMES_loading
	call	message_filedialog
	call	open_samfile		; hl needs to point to the filename 

	ld	a,(sample_current)
	call	sample_get_note

	ld	a,(window_shown)
	and	a
	jr.	z,restore_macroeditor
	jr.	restore_samfiledialog

_spfd_LOAD_PAK:
	xor	a
	ld	(window_shown),a	
	;--- LOAD An instrument (macro+waveform)
	ld	de,_FILMES_loading
	call	message_filedialog
	call	open_pakfile		; hl needs to point to the filename 
	ld	a,(window_shown)
	and	a
	jr.	z,restore_macroeditor
	jr.	restore_samfiledialog


_spfd_SAVE_SAM:
	;--- Save instrument
	ld	de,_FILMES_saving
	call	message_filedialog
	call	save_samfile		; hl needs to point to the filename 
	jr.	restore_samfiledialog

_spfd_SAVE_PAK:
	;--- SAVE instrument set
	ld	de,_FILMES_saving
	call	message_filedialog
	call	save_pakfile		; hl needs to point to the filename 
	jr.	restore_samfiledialog
	

	
_spfd_sf_DIR:
	call	open_directory
	xor	a
	ld	(file_selection),a
	call	update_sam_filedialog	
	call 	update_filedailog_fileselection

	jr.	_spfd_sf_END


0:
_spfd_sf_END:
	call	_fd_noentries
	call	update_filedailog_fileselection
processkey_sam_filedialog_fileselect_END:
	ret
	
	
	
	
	
	
	
;===========================================================
; --- reset_cursor_sam_filedialog
;
; Reset the cursor 
; 
;===========================================================
reset_cursor_sam_filedialog:
	call	flush_cursor
	
	ld	a,(editsubmode)
	and	a
	jr.	nz,0f	
	;--- Menu slection
		ld	a,2
		ld	(cursor_type),a
		ld	a,76
		ld	(cursor_x),a
		ld	a,(menu_selection)
		cp	4
		jr.	c,99f
		inc	a
		cp	9
		jr.	c,99f
		inc	a	
		cp	14
		jr.	c,99f
		inc	a			
		cp	19
		jr.	c,99f
		inc	a			
		
				
99:		add	3
		ld	(cursor_y),a
	ret
	
0:

	;--- File selection	
		xor	a
		ld	(cursor_type),a
	ret
	
0:	
	
;--- this restores after error, saving, delete etc.
restore_samfiledialog:
		call	clear_screen
		xor	a
		ld	(editsubmode),a
		ld	(disk_entries),a
		call	_fd_noentries
		call	reset_cursor_sam_filedialog
		ld	de,_FILMES_none
		call	message_filedialog
		call	draw_sam_filedialog
		jr.	update_sam_filedialog	




	