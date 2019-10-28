ERROR_FILE		equ	0xc8	;File allocation error
ERROR_FILEX		equ	0xcb	;File already exists
ERROR_DIRX		equ	0xcc	;Directory name exists
ERROR_SYSX		equ	0xcb	;System
_EOF:         equ     0xC7


; disk vars
disk_workdir	ds 96;64
disk_fib		ds 66;64
disk_wildcard	ds 32;14
disk_entries	ds 1		; number of file entries in buffer
disk_handle		ds 1		; used for reading writing to a file
disk_drives		ds 1		; the available drives (bits are set)
disk_dir_stat	ds 1		; indicates if we want dirs or files

_CHIPSET_SCC	equ	$00	
_CHIPSET_FM		equ	$10
_CHIPSET_SMS	equ	$30



insert_disk_handler:
;	ret
;	ld	a,WIN_INSERTDISK
;	call	window
;	ret





;===========================================================
; --- get_drives
;
; retrieved the availbale drives.
; Only needed on start up
;===========================================================
get_drives:
	ld	c,_LOGIN
	call	DOS	; in l are available drives (00000001=a 00000010=b etc)
	
	ld	a,l
	ld	(disk_drives),a
	
	ret



;	ld	a,1
;	ret


;===========================================================
; --- init_workdir
;
; Stores the working directoy in the 'disk_workdir'
; Only needed on start up
;===========================================================
init_workdir:
	ld	hl,disk_wildcard
	ld	(hl),0

rebuild_workdir:

	ld	c,_CURDRV
	call	DOS		; in a is thecurrent drive (0=a 1=b etc)	
	ld	b,0	
	
	ld	hl,disk_workdir
	add	a,65		; turn into a character
	ld	(hl),a		; paste the char in to the workdir
	inc	hl
	ld	(hl),":"
	inc	hl
	ld	(hl),92
	inc	hl
	push	hl

;	ld	c,$31
;	ld	de,buffer
;	ld	l,0
;	call	DOS



	ld	c,_GETCD	; get the working dir
	ld	b,0		; 0= active drive
	ld	de,disk_fib	; put result in de
	call	DOS	
	and	a
	;jr.	nz,catch_diskerror
	call	nz,catch_diskerror
		
	pop	hl
	ex	de,hl		; switch de,hl	
	
0:
	ld	a,(hl)	; read from path result
	and	a		; end of path string?
	jr.	z,1f
	ldi			; copy from hl to de
	jr.	0b
1:
	ex	de,hl
	dec	hl
	ld	a,(hl)
	inc	hl
	cp	92
	jr.	z,2f
	ld	(hl),92	; \ backslash
	inc	hl
2:
	ld	(hl),0


	ret




;===========================================================
; --- select_drive
;
; sets a new drive
; A contains the drive number
;===========================================================
select_drive:
	ld	(_catch_stackpointer),sp
	ld	e,a
	
	call	reset_hook
	
	ld	c,_SELDSK
	call	DOS

	
	call	rebuild_workdir
	call	set_hook
	
	ret


;===========================================================
; --- get_dir
;
; Stores the contents of the working directoy in the 
; general buffer 
; variable disk_wildcard contains the files to display
;===========================================================
get_dir:
	ld	(_catch_stackpointer),sp
	call	reset_hook
	; clear the buffer
	call	clear_files
	
	ld	c,_FLUSH
	ld	b,$ff
	ld	d,$ff
	call	DOS
	
	
	; ===== first get the directories
	xor	a
	ld	(disk_dir_stat),a

	;--- Always do this to ensure disk swap doesn't get stuck on non existing dir.
	call	rebuild_workdir	
	;--- first concat workdir and wildcard
	ld	hl,disk_workdir
	ld	de,buffer
0:
	ld	a,(hl)
	and	a
	jr.	z,1f		; 0 marks end of workdir
	
	ld	(de),a
	inc	hl
	inc	de
	jr.	0b

1:	
	xor	a
	ld	(de),a

	; -- file counter init
	ld	b,-1		; number of files/dirs found
;	ld	c,-1		; number of dirs found
;	push	bc
;

	call	_get_entries
	
	;==== now only get the files (with the wildcard)
	ld	a,1
	ld	(disk_dir_stat),a
		
	ld	hl,disk_workdir
	ld	de,buffer
0:
	ld	a,(hl)
	and	a
	jr.	z,1f		; 0 marks end of workdir
	
	ld	(de),a
	inc	hl
	inc	de
	jr.	0b

1:	
	xor	a
	ld	(de),a

	ld	hl,disk_wildcard
0:
	ld	a,(hl)
	and	a
	jr.	z,1f		; 0 marks end of wildcard
	
	ld	(de),a
	inc	hl
	inc	de
	jr.	0b	
1:	
	ld	(de),a
	
	; -- file counter init
	ld	a,(disk_entries)
	dec	a
	ld	b,a		; number of files/dirs found
;	ld	c,-1		; number of dirs found
	;push	bc
	
	call	_get_entries
	
	
	;--- after retieval we can be sure about found dir/files
	ld	a,(disk_entries)
;	cp	1
;	jp	c,99f
0:	
	call	set_hook
	ret
;99:	;-- no files or directories found
;	ld	a,(suppress_filenotfound)
;	and	a
;	jp	nz,0b
;	
;	ld	a,$D7
;	jr.	window
;	;ret
	


_get_entries:	
	push	bc
	; get the first entry on the disk
	ld	c,_FFIRST		
	ld	b,16+4+2		; 16 includes also directories
	ld	de,buffer
	ld	ix,disk_fib	; result is in a FIB format
	call	DOS
	and	a
	jr.	z,_dir_loop
	cp	$D7	; file not found supress.
	call	nz,catch_diskerror


_dir_loop:	
	and	a
	jr.	nz,_dir_noentry	; mothing found
	
	;CHECK FOR '.' (Current dir) entry.
	
	
	pop	bc

	;--- increase file count
	inc	b
	ld	a,b

;-- A contains the position
_dir_store_name:	
	; calculate the start of the file names
	ld	hl,buffer+192		; -1 to end at last byte of name
	and	a
	jr.	z,0f
	ld	de,14			; type + name+.+ext+0
1:	
	add	hl,de
	dec	a
	jr.	nz,1b

0:	
	bit	4,(ix+14)
	jr.	z,0f	;-> not a dir but a file
	;--- check if we may store the dir
		ld	a,(disk_dir_stat)
		and	a	; if stat = 0 then only dirs
		jr.	z,99f	
		
		;- don't store the dir
		dec	b
		push	bc
		jr.	4f
99:		
		; do not list '.' dirs
		ld	a,(disk_fib+1)
		cp	'.'
		jp	nz,33f
		ld	a,(disk_fib+2)
		and 	a
		jp	nz,33f
		jr.  	77f
		
		
33:		;-store the dir	
		ld	a,">"
		jr.	10f
0:	; --- check if we may store the filenames
		ld	a,(disk_dir_stat)
		and	a	; if stat = 0 then only dirs
		jr.	nz,99f	
77:		;- don't store the dir
		dec	b
		push	bc
		jr.	4f
99:		;-store the dir	
		ld	a,32
		jr.	10f		


10:	push	bc
	ld	bc,13
;	add	hl,bc
	
	ld	(hl),a		; type of filename
	inc	hl	
		
	ld	de,disk_fib+1	
	ex	de,hl
	ldir

_dir_next:
	;--- get next entry
4:	ld	c,_FNEXT
	call	DOS
;	jr.	nz,catch_diskerror
		
	jr.	_dir_loop

_dir_noentry:	
	pop	af
	inc	a
	ld	(disk_entries),a
	
	ret
	
	



;===========================================================
; --- open_file
;
; Opens a file. HL needs to point to the file
; A contains the open mode!!
; OUTPUT:
; B contains the file handle
; A contains the error
;===========================================================	
open_file:
	push af
	push hl
	

	;--- first concat workdir and wildcard
	ld	hl,disk_workdir
	ld	de,buffer
0:
	ld	a,(hl)
	and	a
	jr.	z,1f		; 0 marks end of workdir
	
	ld	(de),a
	inc	hl
	inc	de
	jr.	0b

1:	
	pop	hl		; The filename to load
0:
	ld	a,(hl)
	and	a
	jr.	z,1f		; 0 marks end of the filename
	
	ld	(de),a
	inc	hl
	inc	de
	jr.	0b	
1:	
	ld	(de),a

	; Try to open the file for reading
	pop	af		; a contains the open mode byte
	ld	de,buffer
	ld	c,(_OPEN)
	call	DOS
	and	a
		
	ret




;===========================================================
; --- create_file
;
; Creates/saves a file. HL needs to point to the filename
; A contains the open mode!!
; OUTPUT:
; B contains the file handle
; A contains the error
;===========================================================	
create_file:
	push af
	push hl		; store pointer to the filename
	

	;--- first concat workdir and filename
	ld	hl,disk_workdir
	ld	de,buffer
0:
	ld	a,(hl)
	and	a
	jr.	z,1f		; 0 marks end of workdir
	
	ld	(de),a
	inc	hl
	inc	de
	jr.	0b

1:	
	pop	hl		; The filename to create
0:
	ld	a,(hl)
	and	a
	jr.	z,1f		; 0 marks end of the filename
	
	ld	(de),a
	inc	hl
	inc	de
	jr.	0b	
1:	
	ld	(de),a

	; Try to open the file for writing
	pop	af		; a contains the mode byte
	ld	de,buffer
	ld	c,(_CREATE)
	call	DOS
	and	a
		
	ret





;===========================================================
; --- read_file
;
; Read x bytes (in HL) into RAM (DE)
; variable 'disk_handle' needs to contain valid file handle
;===========================================================	
read_file:
	push	de	;dest
	push	hl	; len
	ld	de,buffer+32
	ld	a,(disk_handle)
	ld	b,a
	ld	c,_READ
	call	DOS	
	
	pop	bc	;len
	pop	de	; dest
	push	af	; preserve flags and error code
	
	ld	hl,buffer+32	; copy read data to page. 
	ldir
	
	pop	af
	and	a	

	ret

;===========================================================
; --- write_file
;
; writes x bytes (in HL) to file (DE) contains values
; variable 'disk_handle' needs to contain valid file handle
;===========================================================	
write_file:
 	push	de
	push	hl
	pop	bc
	push	hl
	ex	de,hl
	
	ld	de,buffer+32
	ldir
	
	ld	de,buffer+32
	pop	hl
	push	hl
	ld	a,(disk_handle)
	ld	b,a
	ld	c,_WRITE
	call	DOS		
	
	pop	hl
	pop	de
	add	hl,de
	ex	de,hl
	
	and	a
	ret



	
;===========================================================
; --- close_file
;
; 
; variable 'disk_handle' needs to contain valid file handle
;===========================================================	
close_file:
	ld	a,(disk_handle)
	ld	b,a
	ld	c,_CLOSE
	call	DOS	
	and	a

	ret	
	
;===========================================================
; --- open_directory
;
; Open a directory. HL needs to point to the name
; 
;===========================================================	
open_directory:
	ld	(_catch_stackpointer),sp
	call	reset_hook

	ld	c,_CHDIR
	ex	de,hl
	call	DOS	
	;--- Check for errors
	and	a
	jr.	nz,0f
	call	rebuild_workdir
;	call	set_wildcard
0:
	call	get_dir
	
	ret	
	
_DISK_BACKUPNAME:
	db	0,0,0,0,0,0,0,0,0,0,0,0,0	
;===========================================================
; --- backup_tmufile
;
; Deletes old back-up and renames the current to tm_
; HL points to the filename.
;===========================================================	
backup_tmufile:	
	push	hl	; save the pointer to the file
	
	; put the name without extension in temp buffer
	ld	de,_DISK_BACKUPNAME
99:	ld	a,(hl)
	ld	(de),a
	inc	de
	inc	hl
	cp	"."
	jr.	z,0f

	jr.	99b
0:	
	;--- Add the backup file extension
	ex	de,hl
	ld	(hl),"T"
	inc	hl
	ld	(hl),"M"
	inc	hl
	ld	(hl),"_"
	inc	hl
	ld	(hl),0
	
	ld	hl,_DISK_BACKUPNAME
	call	delete_file
	
	;--- Get the original filename	
	pop	de
	push	de

	
	ld	hl,_DISK_BACKUPNAME
	call	rename_file


	pop	hl	
	ret
	
	
	
;===========================================================
; --- restore_tmufile
;
; deletes current TMU file and renames TM_ to TMU
; 
;===========================================================	
;restore_tmufile:	
;	
;	
;	ret	
	

;===========================================================
; --- delete_file
;
; Deletes a file. HL needs to point to the file
;===========================================================	
delete_file:
	push hl
	
	;--- first concat workdir and wildcard
	ld	hl,disk_workdir
	ld	de,buffer
0:
	ld	a,(hl)
	and	a
	jr.	z,1f		; 0 marks end of workdir
	
	ld	(de),a
	inc	hl
	inc	de
	jr.	0b

1:	
	pop	hl		; The filename to load
0:
	ld	a,(hl)
	and	a
	jr.	z,1f		; 0 marks end of the filename
	
	ld	(de),a
	inc	hl
	inc	de
	jr.	0b	
1:	
	ld	(de),a

	; Try to open the file for reading
	ld	de,buffer
	ld	c,(_DELETE)
	call	DOS
	and	a	
	ret

;===========================================================
; --- rename_file
;
; Renames a file. de point to the original filename. 
; HL to the new filename.
;===========================================================	
rename_file:
	push hl
	push de
	
	;--- first concat workdir and wildcard
	ld	hl,disk_workdir
	ld	de,buffer
0:
	ld	a,(hl)
	and	a
	jr.	z,1f		; 0 marks end of workdir
	
	ld	(de),a
	inc	hl
	inc	de
	jr.	0b

1:	
	pop	hl		; The filename to load
0:
	ld	a,(hl)
	and	a
	jr.	z,1f		; 0 marks end of the filename
	
	ld	(de),a
	inc	hl
	inc	de
	jr.	0b	
1:	
	ld	(de),a

;	ex	de,hl
	ld	de,buffer
	pop	hl
	; rename de into hl
	ld	c,_RENAME
	call	DOS
	and 	a	
	ret

;===========================================================
; --- delete_tmufile
;
; delete a tmufile. HL needs to point to the file
; 
;===========================================================	
delete_tmufile:
	ld	(_catch_stackpointer),sp
	push	hl	

	ld	a,WIN_WARN_DELETE
	call	window

	call	reset_hook
		
	cp	"Y"
	jp	z,1f
	cp	"y"
	jp	nz,0f

1:
	pop	hl
	call	delete_file

	jp	z,1f
	
	;--- general error display
	call	catch_diskerror 		; display the error
0:
1:	call	set_hook
	ret



;===========================================================
; --- create_tmufile
;
; creat a tmufile. HL needs to point to the file
; Original file is backed up if the file existed.
;===========================================================	
create_tmufile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	push	hl			; save hl for overwrite handling
	ld	a,00000000b
	ld	b,10000000b		; create new flag (no overwrite)
	call	create_file
	pop	hl			; restore hl for overwrite retry

	;--- need to catch overwrite? error.
	and	a
	jr.	z,_create_tmu_continue	; continue if there are no errors
	;--- check for "File alread exists ("_FILEX" 0xCB)
	cp	0xCB
	jr.	z,_ctf_overwrite
	
	;--- general error display
	call	catch_diskerror 		; display the error
	call	set_hook
	ret
	
;-- Handles the overwrite option
_ctf_overwrite:
	push	hl				; save the pointer to the filename
	call	window
	cp	"Y"
	jr.	z,0f
	cp	"y"
	jr.	nz,1f		; nope stop
0:	
	;--- start overwriting
	call	reset_hook
;	call	catch_diskerrorYN		; display the error and checks for a Y or N
	pop	hl				; restore the  pointer to the filename
	jr.	save_tmufile		; if result is '0' (YES overwrite the file)
1:
	call	set_hook			; The result is "NO"
	ret
	


;===========================================================
; --- save_tmufile
;
; save a tmufile. HL needs to point to the file
; Original file is backed up
;===========================================================	
save_tmufile:
	ld	(_catch_stackpointer),sp
	call	reset_hook

	call	backup_tmufile

	ld	a,00000000b
	ld	b,00000000b		; required attributes. 0=overwrite
	call	create_file

	;--- Check for errors
	; if error then restore backup
	and	a
;	jr.	nz,catch_diskerror ;<- replace with restore
	call	nz,catch_diskerror
	
_create_tmu_continue:
	ld	a,b
	ld	(disk_handle),a

;	ld	a,(current_song)
	call	set_songpage

	
	;--- Write header
	ld	a,8				; Increased to 8 for new FM drum macro version 
	or	CHIPSET_CODE
	ld	(song_version),a
	
	ld	de,song_version
	ld	hl,1
	call	write_file
	call	nz,catch_diskerror
	
	;--- Write song name
	ld	de,song_name
	ld	hl,32
	call	write_file
	call	nz,catch_diskerror
	
	;--- Write song by
	ld	de,song_by
	ld	hl,32
	call	write_file	
	call	nz,catch_diskerror
			
	;--- Write speed
	ld	de,song_speed
	ld	hl,1
	call	write_file
	call	nz,catch_diskerror

	;--- Write order loop
	ld	de,song_order_loop
	ld	hl,1
	call	write_file
	call	nz,catch_diskerror
	
	;--- Write order length
	ld	de,song_order_len
	ld	hl,1
	call	write_file
	call	nz,catch_diskerror
		
	;--- Write order data
	ld	de,song_order
	ld	a,(song_order_len)
	ld	h,0
	ld	l,a	
	call	write_file	
	call	nz,catch_diskerror

 	;--- write instrument names.
	ld	de,song_instrument_list
	ld	hl,31*16
	call	write_file
	call	nz,catch_diskerror

	;--- Write the sample data
	ld	de,instrument_macros+((4*32)+3)	; sample 0 is always empty.	
	ld	b,31			; 32 samples to write.	
_stmu_samploop:
	push	bc
	push	de
	ld	hl,1
	call	write_file
	call	nz,catch_diskerror
	
	dec	de
	ld	a,(de)			; get the sample length	
	inc	de
	ld	b,a
	xor	a


_stmu_samplsub:				; calculate the number of bytes
	add	a,4			; 4 bytes per line
	djnz	_stmu_samplsub
		
	inc	a			; 1 byte extra for loop position
	inc	a			; 1 byte extra for wave form
	ld	h,0
	ld	l,a
	call	write_file
	call	nz,catch_diskerror
	
	pop	hl
	ld	de,(32*4)+3
	add	hl,de
	ex	de,hl	
	pop	bc
	djnz	_stmu_samploop
	
IFDEF	TTSCC			
	;--- Write the SCC waveform data;
	ld	de,_WAVESSCC
	ld	hl,1024
	call	write_file
	call	nz,catch_diskerror
ELSE

_save_tmufile_customvoices:	
	ld	de,_VOICES+((192-16)*8)
	ld	hl,8*16
	call	write_file
	jr.	nz,catch_diskerror

		
_save_tmufile_drumnames:
	;--- write drum names.	
	ld	de,song_drum_list
	ld	hl,MAX_DRUMS*16
	call	write_file
	call	nz,catch_diskerror

	;--- Write the drum data
	ld	de,drum_macros+(DRUMMACRO_SIZE)	; sample 0 is always empty.	
	ld	b,MAX_DRUMS	-1				; 20-1 samples to write.	
_stmu_drumloop:
	push	bc
	push	de
	ld  	hl,1
	call	write_file
	call	nz,catch_diskerror
	
	dec	de
	ld	a,(de)				; get the sample length	
	inc	de
	ld	b,a
	xor	a


_stmu_drumsub:					; calculate the number of bytes
	add	a,7					; 7 bytes per line
	djnz	_stmu_drumsub
		
	ld	h,0
	ld	l,a
	call	write_file
	call	nz,catch_diskerror
	
	pop	hl
	ld	de,DRUMMACRO_SIZE
	add	hl,de
;	ex	de,hl	 
	pop	bc
	djnz	_stmu_drumloop
ENDIF
	
	xor	a
_save_tmufile_patloop:	
	;--- compress the pattern
	push	af
	ld	(_tmp_pat),a
	ld	b,a
	call	compress_pattern
	;catch error here
	
	ld	a,l
	cp	20
	jr.	nz,99f
	ld	a,h
	and	a
	jr.	nz,99f
	
	; length == 0 so pattern was empty	
	jr.	_save_tmufile_patskip	
99:
;	ex	de,hl
	ld	(_tmp_len),hl		;--- Store the packed len
	push	hl
	
	;--- write packed header
	ld	de,_tmp_pat		;--- _tmp_pat + _tmp_len = bytes
	ld	hl,3
	call	write_file
	;catch error here
	
	;--- Write packed data
	pop	hl
	ld	de,pat_buffer
	call	write_file
	;catch error here
	
_save_tmufile_patskip:
	ld	a,(max_pattern)
	ld	b,a
	pop	af
	inc	a
;	cp	SONG_MAXPAT
	cp	b
	jr.	nz,_save_tmufile_patloop	

	;--- end of file
	ld	a,255
	ld	(_tmp_pat),a
	
	ld	de,_tmp_pat
	ld	hl,1
	call	write_file
	;catch error here
	
	call	close_file
	;catch error here

	call	set_hook
	ret

_tmp_pat:	db	0
_tmp_len:	dw	0



;===========================================================
; --- create_infile
;
; creat a in file. HL needs to point to the file
; Original file is backed up if the file existed.
;===========================================================	
create_infile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	push	hl			; save hl for overwrite handling
	ld	a,00000000b
	ld	b,10000000b		; create new flag (no overwrite)
	call	create_file
	pop	hl			; restore hl for overwrite retry

	;--- need to catch overwrite? error.
	and	a
	jr.	z,_create_in_continue	; continue if there are no errors
	;--- check for "File alread exists ("_FILEX" 0xCB)
	cp	0xCB
	jr.	z,_cif_overwrite
	
	;--- general error display
	call	catch_diskerror 		; display the error
	call	set_hook
	ret
	
;-- Handles the overwrite option
_cif_overwrite:
	push	hl				; save the pointer to the filename
	call	window
	cp	"Y"
	jr.	z,0f
	cp	"y"
	jr.	nz,1f		; nope stop
0:	
	;--- start overwriting
	call	reset_hook
	pop	hl				; restore the  pointer to the filename
	jr.	save_infile		; if result is '0' (YES overwrite the file)

1:	call	set_hook			; The result is "NO"
	ret
	
;===========================================================
; --- save_infile
;
; save a infile. HL needs to point to the file
; Original file is backed up
;===========================================================	
save_infile:
	ld	(_catch_stackpointer),sp
	call	reset_hook

;	call	backup_file

	ld	a,00000000b
	ld	b,00000000b		; required attributes. 0=overwrite
	call	create_file

	;--- Check for errors
	; if error then restore backup
	and	a
;	jr.	nz,catch_diskerror ;<- replace with restore
	call	nz,catch_diskerror
	
_create_in_continue:
	ld	a,b
	ld	(disk_handle),a

;	ld	a,(current_song)
	call	set_songpage

	
	;--- Write header
	ld	de,disk_wildcard+2
	ld	hl,3
	call	write_file
	;catch error here
	
	;--- Write the instrument name
	ld	hl,song_instrument_list-16
	ld	de,16
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,1f
0:
	add	hl,de
	dec	a
	jr.	nz,0b
1:
	ex	de,hl
	call	write_file	
	
	;--- Write macro
	;--- Calculate the position in RAM of current sample	
	ld	hl,instrument_macros
	ld	de,INSTRUMENT_SIZE
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,1f
0:
	add	hl,de
	dec	a
	jr.	nz,0b	
1:	
	ex	de,hl
	call	write_file
	;catch error here


IFDEF TTSCC	
	;--- Write waveform
	;--- calculate the current wave pos in RAM
	ld	a,(instrument_waveform)	; get the current waveform
	ld	hl,_WAVESSCC
	ld	de,32
	and	a
	jr.	z,99f
	

0:
	add	hl,de
	dec	a
	jr.	nz,0b

99:
	ex	de,hl
	call	write_file	
	;catch error here
ENDIF
	
	call	close_file
	;catch error here

	call	set_hook
	ret


;===========================================================
; --- create_insfile
;
; creat a ins file. HL needs to point to the file
; Original file is backed up if the file existed.
;===========================================================	
create_insfile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	push	hl			; save hl for overwrite handling
	ld	a,00000000b
	ld	b,10000000b		; create new flag (no overwrite)
	call	create_file
	pop	hl			; restore hl for overwrite retry

	;--- need to catch overwrite? error.
	and	a
	jr.	z,_create_ins_continue	; continue if there are no errors
	;--- check for "File alread exists ("_FILEX" 0xCB)
	cp	0xCB
	jr.	z,_cisf_overwrite
	
	;--- general error display
	call	catch_diskerror 		; display the error
	call	set_hook
	ret
	
;-- Handles the overwrite option
_cisf_overwrite:
	push	hl				; save the pointer to the filename
	call	window
	cp	"Y"
	jr.	z,0f
	cp	"y"
	jr.	nz,1f		; nope stop
0:	
	;--- start overwriting
	call	reset_hook
	pop	hl				; restore the  pointer to the filename
	jr.	save_insfile		; if result is '0' (YES overwrite the file)
1:
	call	set_hook			; The result is "NO"
	ret
	
;===========================================================
; --- save_insfile
;
; save a insfile. HL needs to point to the file
; 
;===========================================================	
save_insfile:
	ld	(_catch_stackpointer),sp
	call	reset_hook

;	call	backup_file

	ld	a,00000000b
	ld	b,00000000b		; required attributes. 0=overwrite
	call	create_file

	;--- Check for errors
	; if error then restore backup
	and	a
;	jr.	nz,catch_diskerror ;<- replace with restore
	call	nz,catch_diskerror
	
_create_ins_continue:
	ld	a,b
	ld	(disk_handle),a

;	ld	a,(current_song)
	call	set_songpage

	
	;--- Write header
	ld	de,disk_wildcard+2
	ld	hl,3
	call	write_file
	call	nz,catch_diskerror
	
	;--- Write the instrument name
	ld	hl,song_instrument_list
	ld	de,16*31
	ex	de,hl
	call	write_file	
	call	nz,catch_diskerror
	
	;--- Write macro
	;--- Calculate the position in RAM of current sample	
	ld	hl,instrument_macros+INSTRUMENT_SIZE
	ld	de,INSTRUMENT_SIZE*15
	ex	de,hl
	call	write_file
	call	nz,catch_diskerror
	
	ld	hl,instrument_macros+INSTRUMENT_SIZE*15
	ld	de,INSTRUMENT_SIZE*16
	ex	de,hl
	call	write_file
	call	nz,catch_diskerror

IFDEF	TTSCC	
	;--- Write waveform
	;--- calculate the current wave pos in RAM
	ld	hl,_WAVESSCC
	ld	de,32*32
	ex	de,hl
	call	write_file	 
	call	nz,catch_diskerror
ENDIF
	
	call	close_file
	call	nz,catch_diskerror
	
	call	set_hook
	ret





;===========================================================
; --- create_mafile
;
; creat a ma file. HL needs to point to the file
; Original file is backed up if the file existed.
;===========================================================	
create_mafile:
	;push	hl			; save hl for overwrite handling
	call	reset_hook
	ld	(_catch_stackpointer),sp
	push	hl
	ld	a,00000000b
	ld	b,10000000b		; create new flag (no overwrite)
	call	create_file
	pop	hl			; restore hl for overwrite retry

	;--- need to catch overwrite? error.
	and	a
	jr.	z,_create_ma_continue	; continue if there are no errors
	;--- check for "File alread exists ("_FILEX" 0xCB)
	cp	0xCB
	jr.	z,_cmaf_overwrite
	
	;--- general error display
	call	catch_diskerror 		; display the error
	call	set_hook
	ret
	
;-- Handles the overwrite option
_cmaf_overwrite:
	push	hl				; save the pointer to the filename
	call	window
	cp	"Y"
	jr.	z,0f
	cp	"y"
	jr.	nz,1f		; nope stop
0:	
	;--- start overwriting
	call	reset_hook
	pop	hl				; restore the  pointer to the filename
	jr.	save_mafile		; if result is '0' (YES overwrite the file)
1:
	call	set_hook			; The result is "NO"
	ret


;===========================================================
; --- save_mafile
;
; save a mafile. HL needs to point to the file
; Original file is backed up
;===========================================================	
save_mafile:
	ld	(_catch_stackpointer),sp
	call	reset_hook

;	call	backup_file

	ld	a,00000000b
	ld	b,00000000b		; required attributes. 0=overwrite
	call	create_file

	;--- Check for errors
	; if error then restore backup
	and	a
;	jr.	nz,catch_diskerror ;<- replace with restore
	call	nz,catch_diskerror

_create_ma_continue:
	ld	a,b
	ld	(disk_handle),a

;	ld	a,(current_song)
	call	set_songpage

	
	;--- Write header
	ld	de,disk_wildcard+2
	ld	hl,3
	call	write_file
	call	nz,catch_diskerror
	
	;--- Write the instrument name
	ld	hl,song_instrument_list-16
	ld	de,16
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,1f
0:
	add	hl,de
	dec	a
	jr.	nz,0b
1:
	ex	de,hl
	call	write_file	
	call	nz,catch_diskerror
		
	;--- Write macro
	;--- Calculate the position in RAM of current sample	
	ld	hl,instrument_macros
	ld	de,INSTRUMENT_SIZE
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,1f
0:
	add	hl,de
	dec	a
	jr.	nz,0b	
1:	
	ex	de,hl
	call	write_file
	call	nz,catch_diskerror
		
	call	close_file
	call	nz,catch_diskerror

	call	set_hook
	ret




;===========================================================
; --- create_masfile
;
; creat a mas file. HL needs to point to the file
; Original file is backed up if the file existed.
;===========================================================	
create_masfile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	push	hl			; save hl for overwrite handling
	ld	a,00000000b
	ld	b,10000000b		; create new flag (no overwrite)
	call	create_file
	pop	hl			; restore hl for overwrite retry

	;--- need to catch overwrite? error.
	and	a
	jr.	z,_create_mas_continue	; continue if there are no errors
	;--- check for "File alread exists ("_FILEX" 0xCB)
	cp	0xCB
	jr.	z,_cmasf_overwrite
	
	;--- general error display
	call	catch_diskerror 		; display the error
	call	set_hook
	ret
	
;-- Handles the overwrite option
_cmasf_overwrite:
	push	hl				; save the pointer to the filename
	call	window
	cp	"Y"
	jr.	z,0f
	cp	"y"
	jr.	nz,1f		; nope stop
0:	
	;--- start overwriting
	call	reset_hook
	pop	hl				; restore the  pointer to the filename
	jr.	save_masfile		; if result is '0' (YES overwrite the file)
1:
	call	set_hook			; The result is "NO"
	ret
	
;===========================================================
; --- save_masfile
;
; save a masfile. HL needs to point to the file
; 
;===========================================================	
save_masfile:
	ld	(_catch_stackpointer),sp
	call	reset_hook

;	call	backup_file

	ld	a,00000000b
	ld	b,00000000b		; required attributes. 0=overwrite
	call	create_file

	;--- Check for errors
	; if error then restore backup
	and	a
	;jr.	nz,catch_diskerror ;<- replace with restore
	call	nz,catch_diskerror
_create_mas_continue:
	ld	a,b
	ld	(disk_handle),a

;	ld	a,(current_song)
	call	set_songpage

	
	;--- Write header
	ld	de,disk_wildcard+2
	ld	hl,3
	call	write_file
	call	nz,catch_diskerror
	
	;--- Write the instrument name
	ld	hl,song_instrument_list
	ld	de,16*31
	ex	de,hl
	call	write_file	
	call	nz,catch_diskerror
		
	;--- Write macro
	;--- Calculate the position in RAM of current sample	
	ld	hl,instrument_macros+INSTRUMENT_SIZE
	ld	de,INSTRUMENT_SIZE*15
	ex	de,hl
	call	write_file
	call	nz,catch_diskerror
	
	ld	hl,instrument_macros+INSTRUMENT_SIZE*15
	ld	de,INSTRUMENT_SIZE*16
	ex	de,hl
	call	write_file
	call	nz,catch_diskerror
	
		
	call	close_file
	call	nz,catch_diskerror

	call	set_hook
	ret


;===========================================================
; --- create_wafile
;
; creat a wa file. HL needs to point to the file
; Original file is backed up if the file existed.
;===========================================================	
create_wafile:
IFDEF TTSCC
	call	reset_hook
	ld	(_catch_stackpointer),sp
	push	hl			; save hl for overwrite handling
	ld	a,00000000b
	ld	b,10000000b		; create new flag (no overwrite)
	call	create_file
	pop	hl			; restore hl for overwrite retry

	;--- need to catch overwrite? error.
	and	a
	jr.	z,_create_wa_continue	; continue if there are no errors
	;--- check for "File alread exists ("_FILEX" 0xCB)
	cp	0xCB
	jr.	z,_cwaf_overwrite
	
	;--- general error display
	call	catch_diskerror 		; display the error
	call	set_hook
	ret
	
;-- Handles the overwrite option
_cwaf_overwrite:
	push	hl				; save the pointer to the filename
	call	window
	cp	"Y"
	jr.	z,0f
	cp	"y"
	jr.	nz,1f		; nope stop
0:	
	;--- start overwriting
	call	reset_hook
	pop	hl				; restore the  pointer to the filename
	jr.	save_wafile		; if result is '0' (YES overwrite the file)
1:
	call	set_hook			; The result is "NO"
ENDIF
	ret




IFDEF TTSCC
;===========================================================
; --- save_wafile
;
; save a wafile. HL needs to point to the file
; Original file is backed up
;===========================================================	
save_wafile:
	ld	(_catch_stackpointer),sp
	call	reset_hook

;	call	backup_file

	ld	a,00000000b
	ld	b,00000000b		; required attributes. 0=overwrite
	call	create_file

	;--- Check for errors
	; if error then restore backup
	and	a
;	jr.	nz,catch_diskerror ;<- replace with restore
	call	nz,catch_diskerror
	
_create_wa_continue:
	ld	a,b
	ld	(disk_handle),a

;	ld	a,(current_song)
	call	set_songpage

	
	;--- Write header
	ld	de,disk_wildcard+2
	ld	hl,3
	call	write_file
	call	nz,catch_diskerror


	;--- Write waveform
	;--- calculate the current wave pos in RAM
	ld	a,(instrument_waveform)	; get the current waveform
	ld	hl,_WAVESSCC
	ld	de,32
	and	a
	jr.	z,99f
	

0:
	add	hl,de
	dec	a
	jr.	nz,0b

99:
	ex	de,hl
	call	write_file	
	call	nz,catch_diskerror
 

	
	call	close_file
	call	nz,catch_diskerror

	call	set_hook
	ret
ELSE
;===========================================================
; --- save_vofile
;
; save a vofile. HL needs to point to the file
; 
;===========================================================	
save_vofile:
	ld	(_catch_stackpointer),sp
	call	reset_hook

;	call	backup_file

	ld	a,00000000b
	ld	b,00000000b		; required attributes. 0=overwrite
	call	create_file

	;--- Check for errors
	; if error then restore backup
	and	a
;	jr.	nz,catch_diskerror ;<- replace with restore
	call	nz,catch_diskerror
	
_create_va_continue:
	ld	a,b
	ld	(disk_handle),a

;	ld	a,(current_song)
	call	set_songpage

	
	;--- Write header
	ld	de,disk_wildcard+2
	ld	hl,3
	call	write_file
	call	nz,catch_diskerror


	;--- Write voice
	;--- calculate the current wave pos in RAM
	ld	a,(instrument_waveform)	; get the current waveform
	sub	16				; first 16 are hw voices.
	ld	hl,_VOICES
	ld	de,8
	and	a
	jr.	z,99f
	

0:
	add	hl,de
	dec	a
	jr.	nz,0b

99:
	ex	de,hl
	call	write_file	
	call	nz,catch_diskerror
 

	
	call	close_file
	call	nz,catch_diskerror

	call	set_hook
	ret

ENDIF



;===========================================================
; --- create_wasfile
;
; creat a was file. HL needs to point to the file
; Original file is backed up if the file existed.
;===========================================================	
create_wasfile:
IFDEF TTSCC
	call	reset_hook
	ld	(_catch_stackpointer),sp
	push	hl			; save hl for overwrite handling
	ld	a,00000000b
	ld	b,10000000b		; create new flag (no overwrite)
	call	create_file
	pop	hl			; restore hl for overwrite retry

	;--- need to catch overwrite? error.
	and	a
	jr.	z,_create_was_continue	; continue if there are no errors
	;--- check for "File alread exists ("_FILEX" 0xCB)
	cp	0xCB
	jr.	z,_cwasf_overwrite
	
	;--- general error display
	call	catch_diskerror 		; display the error
	call	set_hook
	ret
	
;-- Handles the overwrite option
_cwasf_overwrite:
	push	hl				; save the pointer to the filename
	call	window
	cp	"Y"
	jr.	z,0f
	cp	"y"
	jr.	nz,1f		; nope stop
0:	
	;--- start overwriting
	call	reset_hook
	pop	hl				; restore the  pointer to the filename
	jr.	save_wasfile		; if result is '0' (YES overwrite the file)
1:
	call	set_hook			; The result is "NO"
ENDIF
	ret


IFDEF TTSCC	
;===========================================================
; --- save_wasfile
;
; save a wasfile. HL needs to point to the file
; 
;===========================================================	
save_wasfile:
	ld	(_catch_stackpointer),sp
	call	reset_hook

;	call	backup_file

	ld	a,00000000b
	ld	b,00000000b		; required attributes. 0=overwrite
	call	create_file

	;--- Check for errors
	; if error then restore backup
	and	a
;	jr.	nz,catch_diskerror ;<- replace with restore
	call	nz,catch_diskerror

_create_was_continue:
	ld	a,b
	ld	(disk_handle),a

;	ld	a,(current_song)
	call	set_songpage

	
	;--- Write header
	ld	de,disk_wildcard+2
	ld	hl,3
	call	write_file
	call	nz,catch_diskerror


	;--- Write waveform
	;--- calculate the current wave pos in RAM
	ld	hl,_WAVESSCC
	ld	de,32*32
	ex	de,hl
	call	write_file	 
	call	nz,catch_diskerror
	
	call	close_file
;	call	nz,catch_diskerror
	call	set_hook
	ret

ENDIF

;===========================================================
; --- open_tmufile
;
; Open a tmufile. HL needs to point to the file
; Data is loaded into the current song
;===========================================================	
open_tmufile:
	call	reset_hook
	ld	(_catch_stackpointer),sp


	ld	a,00000001b		; NO write
	call	open_file
	
	;--- Check for errors
	and	a
;	jr.	nz,catch_diskerror
	call	nz,catch_diskerror	

	ld	a,b
	ld	(disk_handle),a
	
	;--- Read version
	ld	de,song_version
	ld	hl,1
	call	read_file
;	jr.	nz,catch_diskerror
	call	nz,catch_diskerror
			
	;--- Read song name
	ld	de,song_name
	ld	hl,32
	call	read_file
	jr.	nz,catch_diskerror
				
	;--- Read song by
	ld	de,song_by
	ld	hl,32
	call	read_file	
	jr.	nz,catch_diskerror
			
	;--- Read speed
	ld	de,song_speed
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror
		
	;--- Clear the order.	
	ld	a,SONG_SEQSIZE-1
	ld	hl,song_order
0:
	ld	(hl),0
	inc	hl
	dec	a
	jr.	nz,0b			
			
	;--- Read order loop
	ld	de,song_order_loop
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror

	;--- Read order length
	ld	de,song_order_len
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror

	ld	a,(song_version)
	and	$0f
	cp	4
	jr.	nc,1f

	;--- Read order data VERSION 3-
	; remove this after some time. 
	; it this is only for handling a bug
	; in the previous versions (3 and before).	
	ld	de,song_order
_otf_oloop:
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror
	; check for last pos (255)
	dec	de
	ld	a,(de)
	inc	de
	cp	255
	jr.	nz,_otf_oloop	
	jr.	2f
1:			
	;--- Read order data VERSION 4+
	ld	de,song_order	
	ld	a,(song_order_len)
	ld	h,0
	ld	l,a
	call	read_file	
	jr.	nz,catch_diskerror

2: 	;--- load instrument names.
	ld	de,song_instrument_list
	ld	hl,31*16
	
	call	read_file	
	jr.	nz,catch_diskerror
			
	;--- Read the sample data
	ld	de,instrument_macros+((4*32)+3)	; sample 0 is always empty.	
	ld	b,31			; 32 samples to read.	
_otmu_samploop:
	push	bc
	push	de
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror			
	
	dec	de
	ld	a,(de)			; get the sample length	
	inc	de
	ld	b,a
	xor	a


_otmu_samplsub:				; calculate the number of bytes
	add	a,4			; 4 bytes per line
	djnz	_otmu_samplsub
		
	inc	a			; 1 byte extra for loop position
	inc	a			; 1 byte extra for waveform#
	ld	h,0
	ld	l,a
	call	read_file
	jr.	nz,catch_diskerror	
	
	pop	hl
	ld	de,(32*4)+3
	add	hl,de
	ex	de,hl	
	pop	bc
	djnz	_otmu_samploop

IFDEF	TTSCC	
	;--- Handle loading of FM and SMS tmu files
	ld	a,(song_version)
	and	$f0
	cp	_CHIPSET_SCC
	jp	z,0f			; jump if SCC TMU file
; Skip FM/SMS data
	; skip the custom voice data
	ld	de,buffer		
	ld	hl,8*16
	call	read_file
	jr.	nz,catch_diskerror	
	; skip the drum macro names
	ld	hl,MAX_DRUMS*16
	call	read_file	
	jr.	nz,catch_diskerror
	; skip the drum data
	ld	b,MAX_DRUMS-1				; 20-1 samples to read.	
2:	push	bc
	ld	de,buffer	
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror			
	
	ld	a,(buffer)				; get the sample length	
	ld	b,a
	xor	a
1:							; calculate the number of bytes
	add	a,7					; 7 bytes per line
	djnz	1b

	ld	h,0
	ld	l,a
	call	read_file
	jr.	nz,catch_diskerror	
	
	pop	bc
	djnz	2b
	
	jr	_otmu_patterns		; continue to pattern loading

	;--- normal TMU SSC loading
0:
	;--- Read the SCC waveform data;
	ld	de,_WAVESSCC
	;--- check how many scc waveforms we need to load.
	ld	a,(song_version)
	and	$0f
	cp	3
	jr.	c,99f
	ld	hl,1024
	jr.	88f
99:	
	ld	hl,512
88:	call	read_file
	jr.	nz,catch_diskerror
ELSE
	ld	a,(song_version)
	and	$0f
	cp	6
	jp	nc,_open_tmufile_customvoices
	
	;--- Read AND IGNORE the SCC waveform data;
	ld	de,buffer
	;--- check how many scc waveforms we need to load.
	ld	a,(song_version)
	and	$0f
	cp	3
	jr.	c,99f
	ld	hl,1024
	jr.	88f
99:	
	ld	hl,512
88:	call	read_file
	jr.	nz,catch_diskerror	
	jr.	_otmu_patterns
	
_open_tmufile_customvoices:
	ld	de,_VOICES+((192-16)*8)
	ld	hl,8*16
	call	read_file
	jr.	nz,catch_diskerror

	ld	a,(song_version)
	and 	0x0f
	cp 	8
	jp	nc,_open_tmufile_drumnames_NEW

; Old Drummacro version.
; Brute conversions to new format  
_open_tmufile_drumnames:	
 	;--- load <MAX_DRUM> drum names.
	ld	de,song_drum_list
	ld	hl,MAX_DRUMS*16
	call	read_file	
	jr.	nz,catch_diskerror
	
 	;--- Skip remaining drum names.
	ld	de,drum_buffer
	ld	hl,(31-MAX_DRUMS)*16
	call	read_file	
	jr.	nz,catch_diskerror	
	

_open_tmufile_drummacros:	
	;--- Read the sample data
	ld	de,drum_macros+(DRUMMACRO_SIZE)	; sample 0 is always empty.	
	ld	b,MAX_DRUMS-1				; 20-1 samples to read.	
_otmu_drumloop:
	push	bc
	push	de
	ld	hl,2
	call	read_file
	jr.	nz,catch_diskerror			
	
	dec	de
	dec	de
	ld	a,(de)			; get the sample length	
	inc	de				; skip to the type (not needed anymore)
	ld	b,a
	xor	a

_otmu_drumsub:				; calculate the number of bytes
	add	a,4				; 4 bytes per line
	djnz	_otmu_drumsub

	ld	h,0
	ld	l,a
	call	read_file
	jr.	nz,catch_diskerror	
	
	pop	hl
	ld	de,DRUMMACRO_SIZE
	add	hl,de
	ex	de,hl	
	pop	bc
	djnz	_otmu_drumloop

; Skip all remaining drum macro's		
	ld	b,31-(MAX_DRUMS-1)	; 31-19 samples to read.
	ld	de,drum_buffer		; write to temp buffer
_otmu_drumloop_SKIP:
	push	bc
	push	de
	ld	hl,2
	call	read_file
	jr.	nz,catch_diskerror			
	
	dec	de
	dec	de
	ld	a,(de)			; get the sample length	
	inc	de				; skip to the type (not needed anymore)
	ld	b,a
	xor	a

_otmu_drumsub_SKIP:				; calculate the number of bytes
	add	a,4				; 4 bytes per line
	djnz	_otmu_drumsub_SKIP

	ld	h,0
	ld	l,a
	call	read_file
	jr.	nz,catch_diskerror	
	
	pop	hl
	ld	de,drum_buffer
	ex	de,hl	
	pop	bc
	djnz	_otmu_drumloop_SKIP
		
	
	
	
	jr.	_otmu_drum_END
	
; NEW Drum macro format loading.
_open_tmufile_drumnames_NEW:	
 	;--- load drum names.
	ld	de,song_drum_list
	ld	hl,MAX_DRUMS*16
	
	call	read_file	
	jr.	nz,catch_diskerror

_open_tmufile_drummacros_NEW:	
	;--- Read the sample data
	ld	de,drum_macros+(DRUMMACRO_SIZE)	; sample 0 is always empty.	
	ld	b,MAX_DRUMS-1				; 20-1 samples to read.	
_otmu_drumloop_NEW:
	push	bc
	push	de
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror			
	
	dec	de
	ld	a,(de)				; get the sample length	
	inc	de
	ld	b,a
	xor	a

_otmu_drumsub_NEW:				; calculate the number of bytes
	add	a,7					; 7 bytes per line
	djnz	_otmu_drumsub_NEW

	ld	h,0
	ld	l,a
	call	read_file
	jr.	nz,catch_diskerror	
	
	pop	hl
	ld	de,DRUMMACRO_SIZE
	add	hl,de
	ex	de,hl	
	pop	bc
	djnz	_otmu_drumloop_NEW
	
_otmu_drum_END:
ENDIF	



_otmu_patterns:
	;--- Test which way the patterns are stored
	; 1 = uncompressed (converter tool)
	; 2 = compressed
	ld	a,(song_version)
	and	$0f
	cp	1
	jr.	nz,_open_tmufile_compressed


_open_tmufile_patloop:	
	;--- Read the patterns
	ld	de,song_pattern
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror
		
	ld	a,(max_pattern)
	ld	b,a	
	ld	a,(song_pattern)
;	cp	SONG_MAXPAT			; read byte until we have 255
	cp	b
	jr.	nc,_open_tmufile_end
	ld	b,a				; set pattern# in b
	call	set_patternpage			; set the memory page of the pattern
	ex	de,hl				; hl contains the start of the patterndata
	ld	hl,SONG_PATSIZE			; read a complete 
	call	read_file
	jr.	nz,catch_diskerror
	
;	ld	a,(current_song)
	call	set_songpage			; restore the page to the general song data
	jr.	_open_tmufile_patloop	

_open_tmufile_compressed:
	;--- read the pattern number
	ld	de,song_pattern
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror

	;--- Check if pattern fits in RAM
	ld	a,(max_pattern)
	ld	b,a
	ld	a,(song_pattern)
	
	;--- Check if this is the file end	
	cp	255
	jr.	z,_open_tmufile_end	
	

	;--- Check if pattern fits in RAM
	cp	b
	jp	c,99f	
	ld	a,WIN_WARN_LESS_RAM
	call	window
	jr.	_open_tmufile_end
	
99:	
	
	;--- Load data length
	ld	de,_tmp_len
	ld	hl,2
	call	read_file
	jr.	nz,catch_diskerror




	
	;--- load the data into the buffer
	ld	hl,(_tmp_len)
	ld	de,SONG_PATSIZE+2	; max size we can read in RAM
	;-- test high bytes
	ld	a,h
	cp	d
	jr.	c,99f		; jump if tmplen < patbuffer
	jr.	z,88f		; jump if H=D -> check if L<E)
	
	;--- error read block is too large
77:

	ld	a,WIN_FILE_CORRUPT
	call	window
	ret

	;--- test low bytes if high bytes are equal
88:	ld	a,e
	cp	l
	jr.	c,77b		; jump if e<l
99:	
	ld	de,pat_buffer
	call	read_file

	;--- decompress the data
	ld	a,(song_pattern)
	ld	b,a
	call	decompress_pattern	; decompress the data into the pattern RAM	

;	ld	a,(current_song)
	call	set_songpage			; restore the page to the general song data
	jr.	_open_tmufile_compressed
	
	
	
_open_tmufile_end:
	; --- Set the first pattern in the order after loading	
	ld	a,(song_order)
	ld	(song_pattern),a
	
	call	close_file
	call	set_hook

	ld	a,(song_version)
	and	$0f
	cp	5
	call	c,_translate_macros

	ret
	
_translate_macros:
	ld	b,32
	ld	de,instrument_macros
	
0:
	ld	c,(32)
	inc	de	; skip len
	inc	de	; skip restart
	inc	de	; skip waveform

1:	
	inc	de	; skip noise
	ld	a,(de)
	ld	h,a
	
	;-- translate tone deviation
	bit	5,h
	jr.	z,10f
	set	6,a
	jr.	20f
10:	res	6,a
20:	
	;-- translate volume deviation
	bit	4,h
	jr.	nz,10f
	res	5,a	; base	
	res	4,a	; pos
	jr.	20f
10:	set	5,a	; relative
	res	3,a	; only -7..7
	;--posneg?
	bit	3,h
	jr.	nz,30f
	res	4,a	; pos
	jr.	20f
30:
	set	4,a	; neg

20:	
	ld	(de),a	
	
	inc	de
	inc	de	; skip tone value
	inc	de	; skip tine value
	dec	c
	jr.	nz,1b
	djnz	0b
	
	ret
	
	

;===========================================================
; --- open_infile
;
; Open a in file. HL needs to point to the file
; Data is loaded into the current song
;===========================================================	
open_infile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	ld	a,00000001b		; NO write
	call	open_file
	
	;--- Check for errors
	and	a
	call	nz,catch_diskerror
	

	ld	a,b
	ld	(disk_handle),a
	
	;--- Read type
	ld	de,buffer
	ld	hl,3
	call	read_file
	call	nz,catch_diskerror
			
	;--- Read song name
	ld	hl,song_instrument_list-16
	ld	de,16
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,1f
0:
	add	hl,de
	dec	a
	jr.	nz,0b
1:
	ex	de,hl
	call	read_file
	call	nz,catch_diskerror


	;--- read macro
	;--- Calculate the position in RAM of current sample	
	ld	hl,instrument_macros
	ld	de,INSTRUMENT_SIZE
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,1f
0:
	add	hl,de
	dec	a
	jr.	nz,0b	
1:	
	ex	de,hl
	call	read_file
	call	nz,catch_diskerror

IFDEF	TTSCC	
	;--- Read waveform
	;--- calculate the current wave pos in RAM
	ld	a,(instrument_waveform)	; get the current waveform
	ld	hl,_WAVESSCC
	ld	de,32
	and	a
	jr.	z,99f
	
0:
	add	hl,de
	dec	a
	jr.	nz,0b

99:
	ex	de,hl
	call	read_file	
	call	nz,catch_diskerror
ENDIF

	; restore the correct waveform
	ld	hl,instrument_macros
	ld	de,INSTRUMENT_SIZE
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,1f
0:
	add	hl,de
	dec	a
	jr.	nz,0b	
1:	
	inc	hl
	inc	hl
	ld	a,(instrument_waveform)
	ld	(hl),a


	call	close_file
	
	call	set_hook
	ret
	


;===========================================================
; --- open_insfile
;
; Open a ins file. HL needs to point to the file
; Data is loaded into the current song
;===========================================================	
open_insfile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	ld	a,00000001b		; NO write
	call	open_file
	
	;--- Check for errors
	and	a
	call	nz,catch_diskerror

open_insfile_direct:		;- used for loading default set	
	ld	a,b
	ld	(disk_handle),a
	
	;--- Read type
	ld	de,buffer
	ld	hl,3
	call	read_file
	call	nz,catch_diskerror
			
	;--- Read song name
	ld	de,song_instrument_list
	ld	hl,16*31
	call	read_file
	call	nz,catch_diskerror


	;--- read macro
	;--- Calculate the position in RAM of current sample	
	ld	de,instrument_macros+INSTRUMENT_SIZE
	ld	hl,INSTRUMENT_SIZE*15
	call	read_file
	call	nz,catch_diskerror
	
	ld	de,instrument_macros+INSTRUMENT_SIZE*16
	ld	hl,INSTRUMENT_SIZE*16
	call	read_file
	call	nz,catch_diskerror

IFDEF	TTSCC	
	;--- Read waveform
	;--- calculate the current wave pos in RAM
	ld	de,_WAVESSCC
	ld	hl,32*32
	call	read_file	
	call	nz,catch_diskerror
ENDIF
	
	call	close_file
	
	call	set_hook
	ret


IFDEF TTSCC
;===========================================================
; --- open_wavfile
;
; Open a wa file. HL needs to point to the file
; Data is loaded into the current song
;===========================================================	
open_wafile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	ld	a,00000001b		; NO write
	call	open_file
	
	;--- Check for errors
	and	a
	call	nz,catch_diskerror
	

	ld	a,b
	ld	(disk_handle),a
	
	;--- Read type
	ld	de,buffer
	ld	hl,3
	call	read_file
	call	nz,catch_diskerror
			

	;--- Read waveform
	;--- calculate the current wave pos in RAM
	ld	a,(instrument_waveform)	; get the current waveform
	ld	hl,_WAVESSCC
	ld	de,32
	and	a
	jr.	z,99f
	

0:
	add	hl,de
	dec	a
	jr.	nz,0b

99:
	ex	de,hl
	call	read_file	
	call	nz,catch_diskerror
	
	
	call	close_file
	
	call	set_hook
	ret
ELSE
;===========================================================
; --- open_vofile
;
; Open a vo file. HL needs to point to the file
; Data is loaded into the current song
;===========================================================	
open_vofile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	ld	a,00000001b		; NO write
	call	open_file
	
	;--- Check for errors
	and	a
	call	nz,catch_diskerror
	

	ld	a,b
	ld	(disk_handle),a
	
	;--- Read type
	ld	de,buffer
	ld	hl,3
	call	read_file
	call	nz,catch_diskerror
			

	;--- Read waveform
	;--- calculate the current wave pos in RAM
	ld	a,(instrument_waveform)	; get the current waveform
	sub	16
	ld	hl,_VOICES
	ld	de,8
	and	a
	jr.	z,99f
	

0:
	add	hl,de
	dec	a
	jr.	nz,0b

99:
	ex	de,hl
	call	read_file	
	call	nz,catch_diskerror
	
	
	call	close_file
	
	call	set_hook
	ret	
ENDIF
	

IFDEF TTSCC
;===========================================================
; --- open_wasfile
;
; Open a was file. HL needs to point to the file
; Data is loaded into the current song
;===========================================================	
open_wasfile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	ld	a,00000001b		; NO write
	call	open_file
	
	;--- Check for errors
	and	a
	call	nz,catch_diskerror
	
	ld	a,b
	ld	(disk_handle),a
	
	;--- Read type
	ld	de,buffer
	ld	hl,3
	call	read_file
	call	nz,catch_diskerror


	;--- Read waveform
	;--- calculate the current wave pos in RAM
	ld	hl,_WAVESSCC
	ld	de,32*32
	ex	de,hl
	call	read_file	
	call	nz,catch_diskerror

	call	close_file
	
	call	set_hook
	ret
ENDIF

;===========================================================
; --- open_mafile
;
; Open a ma file. HL needs to point to the file
; Data is loaded into the current song
;===========================================================	
open_mafile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	ld	a,00000001b		; NO write
	call	open_file
	
	;--- Check for errors
	and	a
	call	nz,catch_diskerror
	

	ld	a,b
	ld	(disk_handle),a
	
	;--- Read type
	ld	de,buffer
	ld	hl,3
	call	read_file
	call	nz,catch_diskerror
			
	;--- Read instrument name
	ld	hl,song_instrument_list-16
	ld	de,16
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,1f
0:
	add	hl,de
	dec	a
	jr.	nz,0b
1:
	ex	de,hl
	call	read_file
	call	nz,catch_diskerror


	;--- read macro
	;--- Calculate the position in RAM of current sample	
	ld	hl,instrument_macros
	ld	de,INSTRUMENT_SIZE
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,1f
0:
	add	hl,de
	dec	a
	jr.	nz,0b	
1:	
	ex	de,hl
	call	read_file
	call	nz,catch_diskerror
	
	; restore the correct waveform
	ld	hl,instrument_macros
	ld	de,INSTRUMENT_SIZE
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,1f
0:
	add	hl,de
	dec	a
	jr.	nz,0b	
1:	
	inc	hl
	inc	hl
	ld	a,(instrument_waveform)
	ld	(hl),a


	call	close_file
	
	call	set_hook
	ret
	

;===========================================================
; --- open_masfile
;
; Open a ins file. HL needs to point to the file
; Data is loaded into the current song
;===========================================================	
open_masfile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	ld	a,00000001b		; NO write
	call	open_file
	
	;--- Check for errors
	and	a
	call	nz,catch_diskerror
	
	ld	a,b
	ld	(disk_handle),a
	
	;--- Read type
	ld	de,buffer
	ld	hl,3
	call	read_file
	call	nz,catch_diskerror
			
	;--- Read song name
	ld	de,song_instrument_list
	ld	hl,16*31

	call	read_file
	call	nz,catch_diskerror


	;--- read macro
	;--- Calculate the position in RAM of current sample	
	ld	de,instrument_macros+INSTRUMENT_SIZE
	ld	hl,INSTRUMENT_SIZE*15
	call	read_file
	call	nz,catch_diskerror
	
	ld	de,instrument_macros+INSTRUMENT_SIZE*16
	ld	hl,INSTRUMENT_SIZE*16
	call	read_file
	call	nz,catch_diskerror


	;catch error here
	call	close_file
	
	call	set_hook
	ret
	



;===========================================================
; --- check_extension
;
; returns a value that represents current file extension
; 
; A is changed.
;	0 = TMU
;	1 = IN		; instrument macro
;	2 = IS
;	3 = MA		; macro
;	4 = MS
;	5 = WA		; waveform
;	6 = WS
;	7 = VO		; FM voice
;	8 = VS
;	9 = DR		; Drum macro
;	10= DS
;===========================================================
check_extension:
	push	hl
	
	ld	hl,disk_wildcard+2 	 ; skip "*."
	ld	a,"T"
	cp	(hl)
	jr.	nz,0f
	;---- This is a music file (TMU)
		XOR	a
		jr.	_ce_END	
0:
	ld	a,"I"
	cp	(hl)
	jr.	nz,0f
	;---- Instrument file
		inc	hl
		ld	a,"S"
		cp	(hl)
		jr.	z,1f
		;--- a single instrument
		ld	a,1
		jr.	_ce_END
1:		
		ld	a,2
		jr.	_ce_END
0:
	ld	a,"M"
	cp	(hl)
	jr.	nz,0f
	;---- macro file
		inc	hl
		ld	a,"S"
		cp	(hl)
		jr.	z,1f
		;--- a single macro
		ld	a,3
		jr.	_ce_END
1:		
		ld	a,4
		jr.	_ce_END
0:
	ld	a,"W"
	cp	(hl)
	jr.	nz,0f
	;---- Wave file
		inc	hl
		ld	a,"S"
		cp	(hl)
		jr.	z,1f
		;--- a single Wave
		ld	a,5
		jr.	_ce_END
1:		
		ld	a,6
		jr.	_ce_END

0:
	ld	a,"V"
	cp	(hl)
	jr.	nz,0f
	;---- FM voice file
		inc	hl
		ld	a,"S"
		cp	(hl)
		jr.	z,1f
		;--- a single voice
		ld	a,7
		jr.	_ce_END
1:		
		ld	a,8
		jr.	_ce_END

0:
	ld	a,"D"
	cp	(hl)
	jr.	nz,0f
	;---- Drum macro file
		inc	hl
		ld	a,"S"
		cp	(hl)
		jr.	z,1f
		;--- a single drum maro
		ld	a,9
		jr.	_ce_END
1:		
		ld	a,10
		jr.	_ce_END





0:
	ld	a,255			;- error value


				
_ce_END:
	pop	hl
	ret	



;===========================================================
; --- set_wilcard
;
; Puts the string at DE in the wilcard variable
;===========================================================		
set_wildcard:
	ld	hl,disk_wildcard
0:	
	ld	a,(de)
	ld	(hl),a
	inc	hl
	inc	de

	cp	0
	ret	z
	jr.	0b	

_TMU_WILDCARD:
	db	"*.TMU",0
_TM_WILDCARD:
	db	"*.TM_",0
_DEL_WILDCARD:
	db	"*.TM*",0


_INS_WILDCARD:
	db	"*.IN",0
_INSSET_WILDCARD:
	db	"*.IS",0	
_MAC_WILDCARD:
	db	"*.MA",0
_MACSET_WILDCARD:
	db	"*.MS",0	
_WAV_WILDCARD:
	db	"*.WA",0
_WAVSET_WILDCARD:
	db	"*.WS",0	
_VOI_WILDCARD:
	db	"*.VO",0
_VOISET_WILDCARD:
	db	"*.VS",0
_DRM_WILDCARD:
	db	"*.DR",0
_DRMSET_WILDCARD:
	db	"*.DS",0
	

_catch_stackpointer:			; value needs to be set on disk access to be able to
						; return keeping the program functional.
	dw	0
;===========================================================
; --- catch_diskerror
;
; Displays the error value of a
; waits for a key press to continue (at your own risk)
;===========================================================		
catch_diskerror:
;	push	hl
;	push	de
;	push	bc
;	push	af
	
	ei
	
;	push	af
	
	call	window	

	ld	c,_CLOSE
	ld	a,(disk_handle)
	ld	b,a
	call	DOS


	ld	sp,(_catch_stackpointer)
	
	ret
;_LABEL_ERROR:
;	db	"ERROR:  -",0
;_LABEL_ERROR_EXPLAIN:
;	ds	64	
	
	
	
disk_error_handler:
	ld	a,1

	ret	
	
disk_abort_handler:
	pop	hl
	ret