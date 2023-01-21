ERROR_FILE		equ	0xc8	;File allocation error
ERROR_FILEX		equ	0xcb	;File already exists
ERROR_DIRX		equ	0xcc	;Directory name exists
ERROR_SYSX		equ	0xcb	;System
_EOF:         	equ   0xC7


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

get_instrument_address:
	;--- Calculate the position in RAM of current sample	
	ld	hl,instrument_macros
	ld	de,INSTRUMENT_SIZE
	ld	a,(song_cur_instrument)
	and	a
	ret	z
0:
	add	hl,de
	dec	a
	jr.	nz,0b	
	ret


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
;	jr.	c,99f
0:	
	call	set_hook
	ret
;99:	;-- no files or directories found
;	ld	a,(suppress_filenotfound)
;	and	a
;	jr.	nz,0b
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
		jr.	nz,33f
		ld	a,(disk_fib+2)
		and 	a
		jr.	nz,33f
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
	call	get_instrument_address
	push 	hl
	ex	de,hl
	call	write_file
	call	nz,catch_diskerror
	pop	hl

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
	call	nz,catch_diskerror
ELSE
	;--- check if it contains a software voice
	inc	hl
	inc	hl
	ld	a,(hl)
	cp	177
	jr.	c,0f

	;--- Write voice
	;--- calculate the current wave pos in RAM
	ld	hl,_VOICES+((192-31)*8)
	ld	de,8
	sub	177
	jr.	z,3f
1:
	add	hl,de
	dec	a
	jr.	nz,1b

3:	ex	de,hl
	call	write_file	
	call	nz,catch_diskerror
0:

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
	ld	de,_WAVESSCC
	ld	hl,32*MAX_WAVEFORM
	call	write_file	 
	call	nz,catch_diskerror
ELSE
	;--- Write custom voices.
	ld	de,_VOICES+((192-31)*8)
	ld	hl,8*16
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


IFDEF TTSCC
;===========================================================
; --- save_masfile
;
; save a masfile. HL needs to point to the file
; 
;===========================================================	
save_samfile:
	ret
;===========================================================
; --- save_masfile
;
; save a masfile. HL needs to point to the file
; 
;===========================================================	
save_pakfile:
	ret
ENDIF






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
	
;_create_va_continue:
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


;===========================================================
; --- save_vosfile
;
; save a vosfile. HL needs to point to the file
; 
;===========================================================	
save_vosfile:
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
	
;_create_va_continue:
	ld	a,b
	ld	(disk_handle),a

;	ld	a,(current_song)
	call	set_songpage

	
	;--- Write header
	ld	de,disk_wildcard+2
	ld	hl,3
	call	write_file
	call	nz,catch_diskerror


	;--- Write voices
	ld	de,_VOICES+((192-31)*8)
	ld	hl,8*16
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
	ld	de,32*MAX_WAVEFORM
	ex	de,hl
	call	write_file	 
	call	nz,catch_diskerror
	
	call	close_file
;	call	nz,catch_diskerror
	call	set_hook
	ret

ENDIF


open_samplepak:
	call	reset_hook
	ld	(_catch_stackpointer),sp


	ld	a,00000001b		; NO write
	call	open_file	


	
	

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
	call	get_instrument_address
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




ELSE
	call	get_instrument_address
	inc	hl
	inc	hl
	push	hl			; save pointer to update new custom voice nr
	ld	a,(hl)
	cp	177			; Check if this instrument has a custom voice
	jr.	c,0f

	;--- check for an empty voice slot
	ld	hl,_VOICES+((192-31)*8)
	ld	c,0			; voice slot
1:	;--- voice check loop
	ld	b,8			; bytes to check
	xor	a			
2:	;--- data 0 check loop 
	or	(hl)
	inc	hl
	djnz	2b

	and	a			; any value found?
	jr.	z,11f			; Found empty voice slot

	inc	c			; Next voice slot
	ld	a,c
	cp	16			; Nax 16 voices. 
	jr.	c,1b
	
	dec	c			; If none found overwrite last slot
11:
	;--- found slot	
	ld	a,177
	add	c
	pop	de			; pointer custom voicenr
	ld	(de),a		; store voice in instrument
	ld	(instrument_waveform),a

	ld	de,-8
	add	hl,de
	ld	de,8
	ex	de,hl
	call	read_file
	call	nz,catch_diskerror	

0:
ENDIF
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
ELSE
	;--- Write custom voices.
	ld	de,_VOICES+((192-31)*8)
	ld	hl,8*16
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

;===========================================================
; --- open_vosfile
;
; Open a vos file. HL needs to point to the file
; Data is loaded into the current song
;===========================================================	
open_vosfile:
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
			
	;--- Read waveforms
	ld	de,_VOICES+((192-31)*8)
	ld	hl,8*16
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


IFDEF TTSCC
;===========================================================
; --- open_pakfile
;
; Open a pak file. In hihgest segment
; Data is loaded into the current song
;===========================================================
open_samfile:
	call	reset_hook
	ld	(_catch_stackpointer),sp

	;--- store the name of the sample_current
	push	hl
	ld	a,(sample_current)
[3]	add	a	; times 8
	ld	de,sample_names
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	b,8
.nameloop:
	ld	a,(hl)
	cp	'.'		; stop if extension starts
	jr.	z,0f
	ldi				; p is reset if  bc = 0
	jp	p,.nameloop

0:
	pop	hl
	ld	a,00000001b		; NO write
	call	open_file
	
	;--- Check for errors
	and	a
	call	nz,catch_diskerror
	
	ld	a,b
	ld	(disk_handle),a
	
	;--- Set the highest segment
	call	set_samplepage


	;--- Read header + version (skipped for now)
	ld	de,buffer
	ld	hl,4
	call	read_file
	call	nz,catch_diskerror

	;--- Get loop pos
	ld	h,$80
	ld	a,(sample_current)
[3]	add	a
	add	6
	ld	l,a

	ld	de,buffer+2
	ld	a,(de)
	cp	$4D	; "M"
	jp	nc,.noloopval
.loopval:
	ld	(hl),a
	inc	de
	inc	hl
	ld	a,(de)
	ld	(hl),a
	jp	99f
.noloopval:
	ld	(hl),255
	inc	hl
	ld	(hl),255	
99:
	;--- Read base tone
	ld	de,$8000		
	ld	a,(sample_current)
[3]	add	a		; times 8
	add	a,e
	ld	e,a

	ld	hl,2
	call	read_file
	call	nz,catch_diskerror


	;--- Get/Set start address of the data
	ld	a,(sample_end)		; Get start of free sample RAM
	ld	(de),a
	inc	de
	ld	a,(sample_end+1)
	ld	(de),a

	ld	ix,0				; number of frames = len
	ld	de,(sample_end)
.read_frame:
	;--- read period/end delimiter
	ld	hl,2	
	call	read_file
	call	nz,catch_diskerror	

	;--- Check for end delimitor
	dec	de
	ld	a,(de)
	cp	$ff
	jr.	nz,.read_wav
	ld	b,a
	dec	de
	ld	a,(de)
	inc	de	
	cp	b
	jr.	z,.read_end

	;--- read wave data
.read_wav:
	inc	de
	;--- Check if memory limit is reached ($bfff - frame (34) - loop offset (2)) -> $BFDB
	ld	a,$be
	cp	a,d
	jr.	nc,.no_end
	ld	a,$da
	cp	a,e
	jr.	nc,.no_end

	;--- manual end to the sample
	dec	de
	dec	de
	ld	a,$ff
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	xor	a
	ld	(de),a
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de

	jr.	.end
	

.no_end:
	inc	ix				; a frame is next
	ld	hl,32	
	call	read_file
	call	nz,catch_diskerror	
	jr.	.read_frame


	;--- read the loop offset
.read_end:
	;--- Get pointer loop addres
	ld	b,$80		
	ld	a,(sample_current)
[3]	add	a		; times 8
	add	4		; move pointer to len  (skip base tone, start address)
	ld	c,a
	;--- store the length
	ld	a,ixl
	ld	(bc),a
	inc	bc
	ld	a,ixh
	ld	(bc),a

	;-- work around ????
	inc	de
.end:
	;-- Store the new pointer to free RAM
	ld	(sample_end),de


	call	close_file
	;--- restore set_patternpage
	call	set_songpage_safe
	call	set_hook
	ret


;===========================================================
; --- open_pakfile
;
; Open a pak file. In hihgest segment
; Data is loaded into the current song
;===========================================================
open_pakfile:
	call	reset_hook
	ld	(_catch_stackpointer),sp
	ld	a,00000001b		; NO write
	call	open_file
	
	;--- Check for errors
	and	a
	call	nz,catch_diskerror
	
	ld	a,b
	ld	(disk_handle),a
	
	;--- Set the highest segment
	call	set_samplepage
;
;
;	;--- Read type
	ld	de,$8000
1:	ld	hl,1*1024
	call	read_file
	call	nz,catch_diskerror
	jr.	1b	
	;catch error here

	call	close_file
	
	call	set_hook
	ret
ENDIF
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

IFDEF TTSCC
_SAM_WILDCARD:
	db	"*.SAM",0
_PAK_WILDCARD:
	db	"*.PAK",0
ENDIF

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

;	ld	c,_CLOSE
;	ld	a,(disk_handle)
;	ld	b,a
;	call	DOS


	ld	sp,(_catch_stackpointer)
	
	;--- restore set_patternpage
	call	set_songpage_safe

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