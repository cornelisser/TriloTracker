suppress_filenotfound:
	db	0			; for suppressing file no found when saving a file and dir is retrieved.

_FILMES_retrieve:	
	db	"Retrieving folders and files...             " 
_FILMES_select_open:	
	db	"Please select a file to open.               "
_FILMES_select_save:
	db	"Please select a file to save or type a name."
_FILMES_select_delete:
	db	"Please select a file to delete."
_FILMES_input_name:
	db	"Save to filename :                          "
_FILMES_loading:
	db	"Opening file. Please wait...                "
_FILMES_saving:
	db	"Saving file. Please wait...                 "	
_FILMES_deleting:
	db	"Deleting file. Please wait...                 "	

_FILMES_importpat:
	db	"Importing pattern xx/yy... please wait.     "
_FILMES_importins:
	db	"Importing instrument xx/yy... please wait.  "
_FILMES_none:
	db	"                                            "        
	
_fd_noentries:	
	; erase the files area
	ld	hl,0x0005
	ld	de,0x3915
	call	erase_colorbox		
	
	ret
	
;===========================================================
; --- message_filedialog
;
; shows a message in the filedialog
; 
; DE contains the message start in RAM
;===========================================================
message_filedialog:
	push	hl
	push	bc
	push	af
	
	ld	hl,(80*3)+2
	ld	b,44
	call	draw_label_fast

	pop	af
	pop	bc
	pop	hl

	ret

;===========================================================
; --- update_filedialog_fileselection
; Display the file select cusor
; 
;===========================================================
update_filedailog_fileselection:
	; draw the file selector
	
	;--- Check if we have found anything
	ld	a,(disk_entries)
	and	a
	ret	z
	
	ld	a,(file_selection)
	ld	c,a
	
	and	0x03
	jr.	z,0f

	ld	b,a
	
99:	add	13
	djnz	99b
	
0:	
	ld	h,a
	ld	a,c
	and	0xfc
	rrca
	rrca

	add	6
	ld	l,a	

	ld	de,0x0e01	
	call	draw_colorbox		

	ret
	
;===========================================================
; --- update_filedialog_files
; Display the files found.
; 
;===========================================================
update_filedialog_files:
	;--- show the found files.
	
	ld	hl,(80*6)+0
	ld	de,buffer+192
	
	ld	a,(disk_entries)
	and	a
	jr.	z,_fd_noentries
	
	ld	c,a
	xor	a
	ld	b,a
	push	bc	
1:		

	push	de
	push	hl
	
	ld	b,14
	call	draw_label_fast
	
	pop	hl
	pop	de
	pop	bc
	
	inc	b
	ld	a,b
	cp	c
	jr.	z,_fd_noentries
	
	push	bc
	and	3
	jr.	nz,3f
	ld	bc,38	
	jr.	4f
3:
	ld	bc,14
4:
	add	hl,bc
	
	ld	a,14
	add	a,e
	ld	e,a
	jr.	nc,0f
	inc	d
0:	
	
	jr.	1b	
	
