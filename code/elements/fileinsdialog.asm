;===========================================================
; --- draw_ins_filedialog
; Display the sequence area.  Without actual values 
; 
;===========================================================
draw_ins_filedialog:

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
	ld	de,_LABEL_DISKINS
	call	draw_label
	inc	de
	ld	hl,(80*4)+0x3b
	call	draw_label
	inc	de	
	ld	hl,(80*5)+0x3b
	call	draw_label
	inc	de	
	ld	hl,(80*6)+0x3b
	call	draw_label	
	
	
	;menu 2
	ld	hl,(80*7)+57
	ld	de,(23*256) + 5
	call	draw_box	
	ld	hl,0x3a08
	ld	de,0x1504
	call	erase_colorbox		
	ld	hl,(80*8)+0x3b	
	ld	de,_LABEL_DISKMAC
	call	draw_label
	inc	de
	ld	hl,(80*9)+0x3b
	call	draw_label
	inc	de	
	ld	hl,(80*10)+0x3b
	call	draw_label
	inc	de	
	ld	hl,(80*11)+0x3b
	call	draw_label	
	
	;menu 3
	ld	hl,(80*12)+57
	ld	de,(23*256) + 5
	call	draw_box	
	ld	hl,0x3a0d
	ld	de,0x1504
	call	erase_colorbox		

IFDEF TTSCC	
	ld	hl,(80*13)+0x3b	
	ld	de,_LABEL_DISKWAVE
	call	draw_label
	inc	de
	ld	hl,(80*14)+0x3b
	call	draw_label
	inc	de	
	ld	hl,(80*15)+0x3b
	call	draw_label
	inc	de	
	ld	hl,(80*16)+0x3b
	call	draw_label		
ELSE
	ld	a,(instrument_waveform)
	cp	192-15
	jp	c,99f
	;-- only draw if current instrument has custom voice
	ld	hl,(80*13)+0x3b		
	ld	de,_LABEL_DISKWAVE
	call	draw_label
	inc	de
	ld	hl,(80*15)+0x3b
	call	draw_label
99:
	ld	de,_LABEL_DISKWAVE_set
	ld	hl,(80*14)+0x3b
	call	draw_label
	inc	de	
	ld	hl,(80*16)+0x3b
	call	draw_label		



ENDIF
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
		
_LABEL_DISKINS:
	db	"Load Instrument",0
	db	"Load Instr. set",0
	db	"Save Instrument",0
	db	"Save Instr. set",0
_LABEL_DISKMAC:
	db	"Load Macro",0
	db	"Load Macro set",0
	db	"Save Macro",0
	db	"Save Macro set",0	
_LABEL_DISKWAVE:
IFDEF TTSCC
	db	"Load Waveform",0
	db	"Load Waveform set",0
	db	"Save Waveform",0
	db	"Save Waveform set",0
ELSE
	db	"Load Voice",0
	db	"Save Voice",0
_LABEL_DISKWAVE_set:
	db	"Load Voice set",0
	db	"Save Voice set",0
ENDIF

;===========================================================
; --- update_ins_filedialog
; Display the sequence area.  Without actual values 
; 
;===========================================================
update_ins_filedialog:
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
	jr.	c,_uifd_showselection
	inc	a
	cp	9
	jr.	c,_uifd_showselection
	inc	a	
	cp	14
	jr.	c,_uifd_showselection
	inc	a


	
_uifd_showselection:
	add	3
	ld	l,a
	ld	h,59
	ld	de,0x1301
	call	draw_colorbox


	call	update_filedialog_files


update_ins_filedialog_END:
	ret
	


;===========================================================
; --- init_filedialog
; Starts the file dialog  Without actual values 
; 
;===========================================================	
init_ins_filedialog:

	ld	a,(editmode)
	cp	6
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
	ld	a,6
	ld	(editmode),a
	ld	a,0
	ld	(editsubmode),a	
	ld	(file_selection),a
	ld	(menu_selection),a
	ld	(disk_entries),a	
	
	call 	reset_cursor_ins_filedialog
	call	clear_screen
	call	draw_ins_filedialog
	
	; fill buffer with information
	ld	de,_INS_WILDCARD
	call	set_wildcard
	
;	ld	de,_FILMES_retrieve
;	call	message_filedialog
;	call	get_dir
	ld	de,_FILMES_none
	call	message_filedialog	
	
	; show this information	
	call	update_ins_filedialog

	ret
	
	
	
	
;===========================================================
; --- processkey_ins_filedialog
; input handling
; 
;===========================================================
processkey_ins_filedialog:

	ld	a,(editsubmode)
	;-- special check for filename
	cp	255
	jr.	z,processkey_filedialog_filename
	and	a
	jr.	z,processkey_ins_filedialog_menu	;--- Menu select
	;dec	a
	jr.	processkey_ins_filedialog_selectfile	;--- File select
	
	ret	
	
	

;===========================================================
; --- processkey_ins_filedialog_menu
;
; 
;===========================================================
processkey_ins_filedialog_menu:
	ld	a,(key)
	
	; - ESCAPE
	cp	_ESC
	jr.	nz,0f
	; escape 
		call	restore_psgsampleeditor
		jr.	processkey_ins_filedialog_fileselect_END
0:
	; - UP
	cp	_KEY_UP
	jr.	nz,0f
	;up
		ld	a,(menu_selection)
		and	a
		jr.	z,processkey_ins_filedialog_menu_END	; no update
		dec	a
		ld	(menu_selection),a
		;--- erase the menu selection	
777:		call	reset_cursor_ins_filedialog
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
		jr.	_ipfd_m_END	
0:
	; - down
	cp	_KEY_DOWN
	jr.	nz,0f
	;down
		ld	a,(menu_selection)
		cp	12
		jr.	nc,processkey_ins_filedialog_menu_END	; no update
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
	jr.	_ifd_drive_change

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

_ifd_drive_change:	
	;-- translate current drive to bit mask
	and	a
	jr.	z,_ifd_drive_loop
_ifd_drive_l:
	rrc	b
	dec	a
	jr.	nz,_ifd_drive_l

	;-- apply mask and shift till next drive.
	
_ifd_drive_loop:
	ld	a,d
	cp	-1
	jr.	nz,_ifd_drive_fw

	;--- backward
	rlc	b
	dec	c
	jr.	_ifd_drive_check

_ifd_drive_fw:
	;--- forward
	inc	c
	rrc	b	

_ifd_drive_check:
	ld	a,c
	and	$07
	ld	c,a

	bit	0,b
	jr.	z,_ifd_drive_loop

	xor	a
	ld	(window_shown),a
	;--- set the new drive
	ld	a,c
	call 	select_drive
	
	ld	a,(window_shown)
	and	a
	jp	nz,restore_insfiledialog
	
	;--- no erorr was shown.
	ld	de,_FILMES_none
	call	message_filedialog
	call	reset_cursor_ins_filedialog
	jr.	_ipfd_m_END

0:
	; --- ENTER
	cp	_KEY_ENTER
	jr.	z,99f
	cp	_SPACE	
	jr.	nz,processkey_ins_filedialog_menu_END
99:	
	;-- reset selection cursor position.
	xor	a
	ld	(file_selection),a
	;--- Selection is made
	ld	a,(menu_selection)
	and	a
	jr.	z,0f
	dec	a
	jr.	z,1f
	dec	a
	jr.	z,2f
	dec	a
	jr.	z,3f
	dec	a
	jr.	z,4f	
	dec	a
	jr.	z,5f
	dec	a
	jr.	z,6f
	dec	a
	jr.	z,7f		
	dec	a
	jr.	z,8f
	dec	a
	jr.	z,9f	
	dec	a
	jr.	z,10f
	dec	a
	jr.	z,11f	
		
	ret	
	
0:	;--- 0 = load instrument
	ld	a,1
	ld	(editsubmode),a	
	call	reset_cursor_ins_filedialog
	
	;	; fill buffer with information
	ld	de,_INS_WILDCARD
_ipf_open_cont:
	call	set_wildcard
	ld	de,_FILMES_retrieve
	call	message_filedialog
	xor	a
	ld	(window_shown),a
	call	get_dir
	ld	a,(window_shown)
	and	a
		call	nz,restore_insfiledialog
	ld	de,_FILMES_select_open
	call	message_filedialog
	
	call	update_ins_filedialog	
	jr.	update_filedailog_fileselection

1:	;--- 1 = load instrument set
	ld	a,1
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_INSSET_WILDCARD
	jr.	_ipf_open_cont
		
2:	;--- 2 = save instrument	
	ld	a,2
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_INS_WILDCARD
_ipf_save_cont:
	call	set_wildcard
	ld	de,_FILMES_retrieve
	call	message_filedialog
	xor	a
	ld	(window_shown),a
	call	get_dir
	ld	a,(window_shown)
	and	a
	call	nz,restore_insfiledialog
	ld	de,_FILMES_select_save
	call	message_filedialog
	
	call	update_ins_filedialog	
	jr.	update_filedailog_fileselection
3:	;--- 3 = save instrument set
	ld	a,2
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_INSSET_WILDCARD
	jr.	_ipf_save_cont

	
4:	;--- 4 = load macro
	ld	a,1
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_MAC_WILDCARD
	jr.	_ipf_open_cont

5:	;--- 5 = load macro set
	ld	a,1
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_MACSET_WILDCARD
	jr.	_ipf_open_cont

		
6:	;--- 6 = save macro	
	ld	a,2
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_MAC_WILDCARD
	jr.	_ipf_save_cont

7:	;--- 7 = save macroset
	ld	a,2
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_MACSET_WILDCARD
	jr.	_ipf_save_cont


IFDEF TTSCC	
8:	;--- 8 = load waveform
	ld	a,1
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_WAV_WILDCARD
	jr.	_ipf_open_cont

9:	;--- 9 = load waveform set
	ld	a,1
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_WAVSET_WILDCARD
	jr.	_ipf_open_cont

10:	;--- 11 = save waveform	
	ld	a,2
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_WAV_WILDCARD
	jr.	_ipf_save_cont

11:	;--- 12 = save waveformset
	ld	a,2
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_WAVSET_WILDCARD
	jr.	_ipf_save_cont
ELSE
8:	;--- 8 = load voice
	ld	a,1
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_VOI_WILDCARD
	jr.	_ipf_open_cont

9:	;--- 9 = load voice set
	ld	a,1
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_VOISET_WILDCARD
	jr.	_ipf_open_cont

10:	;--- 11 = save voice	
	ld	a,2
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_VOI_WILDCARD
	jr.	_ipf_save_cont

11:	;--- 12 = save voice set
	ld	a,2
	ld	(editsubmode),a
	call	reset_cursor_ins_filedialog
	
	; fill buffer with information
	ld	de,_VOISET_WILDCARD
	jr.	_ipf_save_cont
ENDIF


0:
_ipfd_m_END:
	jr.	update_ins_filedialog
	
processkey_ins_filedialog_menu_END:
	ret


;===========================================================
; --- processkey_ins_filedialog_selectfile
;
; 
;===========================================================
processkey_ins_filedialog_selectfile:
	ld	a,(key)
	
	; - ESCAPE
	cp	_ESC
	jr.	nz,0f
	; escape 
		xor	a
		ld	(editsubmode),a
		ld	(disk_entries),a
		call	_fd_noentries
		call	reset_cursor_ins_filedialog
		ld	de,_FILMES_none
		call	message_filedialog
		jr.	update_ins_filedialog
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
	jr.	_ipfd_sf_END
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
	jr.	_ipfd_sf_END	
0:
	; - UP
	cp	_KEY_UP
	jr.	nz,0f
	;up
		ld	a,(file_selection)
		cp	4
		jr.	c,processkey_ins_filedialog_fileselect_END	; no update
		sub	4
		ld	(file_selection),a
		jr.	_ipfd_sf_END	
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
		jr.	nc,processkey_ins_filedialog_fileselect_END	; no update
		ld	(file_selection),a
		jr.	_ipfd_sf_END	
0:
	;--- Type filename check
	cp	"!"
	jr.	z,_ipfs_foundvalidchar
	cp	"#"
	jr.	c,0f
	cp	"'"+1
	jr.	c,_ipfs_foundvalidchar
	cp	"-"
	jr.	z,_ipfs_foundvalidchar
	cp	"0"
	jr.	c,0f
	cp	":"
	jr.	c,_ipfs_foundvalidchar	
	cp	"?"
	jr.	c,0f
	cp	"Z"+1
	jr.	c,_ipfs_foundvalidchar
	cp	"^"
	jr.	c,0f
	cp	"~"+1
	jr.	nc,0f

_ipfs_foundvalidchar:
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
	jr.	nz,processkey_ins_filedialog_fileselect_END
	
99:	ld	hl,buffer+192		; calculate filename pos in the buffer
	ld	a,(file_selection)	; selected file
	and	a
	jr.	z,1f
	ld	b,a
	ld	de,14			; length in buffer of a name
_ipfd_eloop:
		add	hl,de		
		djnz	_ipfd_eloop
	
1:	ld	a,(hl)			; check first char of filename (type)
	inc	hl
	cp	">"			; it the start contains a "\" then it is a dir	
	jr.	z,_ipfd_sf_DIR
	
	;==================================
	;--- Determin the action to execute
	;
	;==================================
	ld	a,(menu_selection)
	and	a
	jr.	z,_ipfd_LOAD_INS
	dec	a
	jr.	z,_ipfd_LOAD_INSSET
	dec	a
	jr.	z,_ipfd_SAVE_INS
	dec	a
	jr.	z,_ipfd_SAVE_INSSET
	dec	a
	jr.	z,_ipfd_LOAD_MAC
	dec	a
	jr.	z,_ipfd_LOAD_MACSET
	dec	a
	jr.	z,_ipfd_SAVE_MAC
	dec	a
	jr.	z,_ipfd_SAVE_MACSET
	dec	a
IFDEF TTSCC
	jr.	z,_ipfd_LOAD_WAV
	dec	a
	jr.	z,_ipfd_LOAD_WAVSET
	dec	a
	jr.	z,_ipfd_SAVE_WAV
	dec	a
	jr.	z,_ipfd_SAVE_WAVSET

ELSE
	jr.	z,_ipfd_LOAD_VOI
	dec	a
	jr.	z,_ipfd_LOAD_VOISET
	dec	a
	jr.	z,_ipfd_SAVE_VOI
	dec	a
	jr.	z,_ipfd_SAVE_VOISET
ENDIF	
	;--- Add more actions here	
	

IFDEF TTSCC
ELSE

_ipfd_LOAD_VOI:
	;-- Only if current voice is custom
	ld	a,(instrument_waveform)
	cp	192-15
	jp	c,restore_insfiledialog
	
	;--- LOAD software voice
	ld	de,_FILMES_loading
	call	message_filedialog
	call	open_vofile		; hl needs to point to the filename 
	ld	a,(window_shown)
	and	a
	jr.	z,restore_psgsampleeditor
	jr.	restore_insfiledialog	
	
	
_ipfd_LOAD_VOISET:
	ld	de,_FILMES_loading
	call	message_filedialog
	call	open_vosfile		; hl needs to point to the filename 
	jr.	restore_insfiledialog

_ipfd_SAVE_VOISET:
	;--- SAVE a voice set
	ld	de,_FILMES_saving
	call	message_filedialog
	call	save_vosfile		; hl needs to point to the filename 
	jr.	restore_insfiledialog



_ipfd_SAVE_VOI:
	;-- Only if current voice is custom
	ld	a,(instrument_waveform)
	cp	192-15
	jp	c,restore_insfiledialog

	;--- Save A voice
	ld	de,_FILMES_saving
	call	message_filedialog
	call	save_vofile		; hl needs to point to the filename 
	jr.	restore_insfiledialog
ENDIF


	
_ipfd_LOAD_INS:	
	xor	a
	ld	(window_shown),a
	;--- LOAD An instrument (macro+waveform)
	ld	de,_FILMES_loading
	call	message_filedialog
	call	open_infile		; hl needs to point to the filename 
	ld	a,(window_shown)
	and	a
	jr.	z,restore_psgsampleeditor
	jr.	restore_insfiledialog

_ipfd_LOAD_INSSET:
	xor	a
	ld	(window_shown),a	
	;--- LOAD An instrument (macro+waveform)
	ld	de,_FILMES_loading
	call	message_filedialog
	call	open_insfile		; hl needs to point to the filename 
	ld	a,(window_shown)
	and	a
	jr.	z,restore_psgsampleeditor
	jr.	restore_insfiledialog


_ipfd_SAVE_INS:
	;--- Save instrument
	ld	de,_FILMES_saving
	call	message_filedialog
	call	save_infile		; hl needs to point to the filename 
	jr.	restore_insfiledialog

_ipfd_SAVE_INSSET:
	;--- SAVE instrument set
	ld	de,_FILMES_saving
	call	message_filedialog
	call	save_insfile		; hl needs to point to the filename 
	jr.	restore_insfiledialog
	
_ipfd_LOAD_MAC:	
	xor	a
	ld	(window_shown),a
	;--- LOAD Macro
	ld	de,_FILMES_loading
	call	message_filedialog
	call	open_mafile		; hl needs to point to the filename 
;	call	restore_cursor
	ld	a,(window_shown)
	and	a
	jr.	z,restore_psgsampleeditor
	jr.	restore_insfiledialog

_ipfd_LOAD_MACSET:
	xor	a
	ld	(window_shown),a	
	;--- LOAD macro set
	ld	de,_FILMES_loading
	call	message_filedialog
	call	open_masfile		; hl needs to point to the filename 
;	call	restore_cursor
	ld	a,(window_shown)
	and	a
	jr.	z,restore_psgsampleeditor
	jr.	restore_insfiledialog


_ipfd_SAVE_MAC:
	;--- Save A macro
	ld	de,_FILMES_saving
	call	message_filedialog
	call	save_mafile		; hl needs to point to the filename 
	jr.	restore_insfiledialog

_ipfd_SAVE_MACSET:
	;--- SAVE a macro set
	ld	de,_FILMES_saving
	call	message_filedialog
	call	save_masfile		; hl needs to point to the filename 
	jr.	restore_insfiledialog

IFDEF TTSCC
_ipfd_LOAD_WAV:
	xor	a
	ld	(window_shown),a	
	;--- LOAD Waveform
	ld	de,_FILMES_loading
	call	message_filedialog
	call	open_wafile		; hl needs to point to the filename 
	ld	a,(window_shown)
	and	a
	jr.	z,restore_psgsampleeditor
	jr.	restore_insfiledialog
ENDIF

IFDEF TTSCC
_ipfd_LOAD_WAVSET:
	xor	a
	ld	(window_shown),a	
	;--- LOAD waveform set
	ld	de,_FILMES_loading
	call	message_filedialog
	call	open_wasfile		; hl needs to point to the filename 
	ld	a,(window_shown)
	and	a
	jr.	z,restore_psgsampleeditor
	jr.	restore_insfiledialog
ENDIF

IFDEF TTSCC
_ipfd_SAVE_WAV:
	;--- Save A waveform
	ld	de,_FILMES_saving
	call	message_filedialog
	call	save_wafile		; hl needs to point to the filename 
	jr.	restore_insfiledialog
ENDIF

IFDEF TTSCC
_ipfd_SAVE_WAVSET:
	;--- SAVE a waveform set
	ld	de,_FILMES_saving
	call	message_filedialog
	call	save_wasfile		; hl needs to point to the filename 
	jr.	restore_insfiledialog
ENDIF	
	
_ipfd_sf_DIR:
	call	open_directory
	xor	a
	ld	(file_selection),a
	call	update_ins_filedialog	
	call 	update_filedailog_fileselection

	jr.	_ipfd_sf_END


0:
_ipfd_sf_END:
	call	_fd_noentries
	call	update_filedailog_fileselection
processkey_ins_filedialog_fileselect_END:
	ret
	
	
	
	
	
	
	
;===========================================================
; --- reset_cursor_ins_filedialog
;
; Reset the cursor 
; 
;===========================================================
reset_cursor_ins_filedialog:
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
restore_insfiledialog:
		call	clear_screen
		xor	a
		ld	(editsubmode),a
		ld	(disk_entries),a
		call	_fd_noentries
		call	reset_cursor_ins_filedialog
		ld	de,_FILMES_none
		call	message_filedialog
		call	draw_ins_filedialog
		jr.	update_ins_filedialog	




	