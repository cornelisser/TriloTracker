;---- This file contains the disk code that is only used for tmu related code. Not for macro's/drums/waveforms etc.

;_DISK_BACKUPNAME:
;	db	0,0,0,0,0,0,0,0,0,0,0,0,0	
;===========================================================
; --- backup_tmufile
;
; Deletes old back-up and renames the current to tm_
; HL points to the filename.
;===========================================================	
;backup_tmufile:	
;
;	
;	;--- Disabled as it gave strange errors where old data is in the new file.???
;	push	hl	; save the pointer to the file
;	
;	; put the name without extension in temp buffer
;	ld	de,_DISK_BACKUPNAME
;99:	ld	a,(hl)
;	ld	(de),a
;	inc	de
;	inc	hl
;	cp	"."
;	jr.	z,0f
;
;	jr.	99b
;0:	
;	;--- Add the backup file extension
;	ex	de,hl
;	ld	(hl),"T"
;	inc	hl
;	ld	(hl),"M"
;	inc	hl
;	ld	(hl),"_"
;	inc	hl
;	ld	(hl),0
;	
;	ld	hl,_DISK_BACKUPNAME
;	call	delete_file
;	
;	;--- Get the original filename	
;	pop	de
;	push	de
;
;	
;	ld	hl,_DISK_BACKUPNAME
;	call	rename_file
;
;	pop	hl	
;	ret
;
;	
	
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
; --- rename_file
;
; Renames a file. de point to the original filename. 
; HL to the new filename.
;===========================================================	
;rename_file:
;	push hl
;	push de
;	
;	;--- first concat workdir and wildcard
;	ld	hl,disk_workdir
;	ld	de,buffer
;0:
;	ld	a,(hl)
;	and	a
;	jr.	z,1f		; 0 marks end of workdir
;	
;	ld	(de),a
;	inc	hl
;	inc	de
;	jr.	0b
;
;1:	
;	pop	hl		; The filename to load
;0:
;	ld	a,(hl)
;	and	a
;	jr.	z,1f		; 0 marks end of the filename
;	
;	ld	(de),a
;	inc	hl
;	inc	de
;	jr.	0b	
;1:	
;	ld	(de),a
;
;;	ex	de,hl
;	ld	de,buffer
;	pop	hl
;	; rename de into hl
;	ld	c,_RENAME
;	call	DOS
;	and 	a	
;	ret

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
	jr.	z,1f
	cp	"y"
	jr.	nz,0f

1:
	pop	hl
	call	delete_file

	jr.	z,1f
	
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

;	call	backup_tmufile
;	and	a
;	call	nz,catch_diskerror	

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
	ld	a,11				; Increased to 11 for extra bytes 
	or	CHIPSET_CODE
IFDEF TTSCC
ELSE
	;--- TTFM and TTSMS has chan_setup 
	ld	c,a
	ld	a,(replay_chan_setup)
	and	$01
	jr.	z,99f
	ld	a,$80			; Set highest bit to indicate 2/6 setup.
99:
	or	c
ENDIF
	ld	(song_version),a
	
	ld	de,song_version
	ld	hl,1
	call	write_file
	call	nz,catch_diskerror
	
	;==============================
	;---- Extra info bytes
	;
	ld	de,buffer
	ld	a,1+32+1		; # of bytes data next
	ld	(de),a
	ld	hl,1
	call	write_file
	call	nz,catch_diskerror	

	;--- Pitchtable
	ld	de,replay_period	
	ld	hl,1
	call	write_file
	call	nz,catch_diskerror

	;--- Instrument types
	ld	de,instrument_types
	ld	hl,32
	call	write_file
	call	nz,catch_diskerror

	;--- Drum style (FM)
IFDEF TTFM
	ld	a,(drum_type)
ELSE
	ld	a,0
ENDIF	
	ld	de,buffer
	ld	(de),a
	ld	hl,1
	call	write_file	
	call	nz,catch_diskerror

	;===============================

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
	ld	hl,32*MAX_WAVEFORM
	call	write_file
	call	nz,catch_diskerror
ELSE

_save_tmufile_customvoices:	
	ld	de,_VOICES+((192-31)*8)
	ld	hl,8*16
	call	write_file
	call	nz,catch_diskerror

		
_save_tmufile_drumnames:
	;--- write drum names.	
	ld	de,song_drum_list
	ld	hl,(MAX_DRUMS-1)*16
	call	write_file
	call	nz,catch_diskerror

	;--- Write the drum data
	ld	de,drum_macros+(DRUMMACRO_SIZE)	; sample 0 is always empty.	
	ld	b,MAX_DRUMS	-1				; 20-1 samples to write.	
_stmu_drumloop:
	push	bc
	push	de

	;--- Savegueard for lengths above 16
	ld	a,(de)
	cp	17
	jr.	c,99f
	ld	a,16
	ld	(de),a
99:
	;--- end Saveguard

	ld  	hl,1					; Write the sample length
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
	ex	de,hl	 
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
	call	nz,catch_diskerror
	
	;--- Write packed data
	pop	hl
	ld	de,pat_buffer
	call	write_file
	call	nz,catch_diskerror
	
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
	call	nz,catch_diskerror
	
	call	close_file
	call	nz,catch_diskerror

	call	set_hook
	ret

_tmp_pat:	db	0
_tmp_len:	dw	0

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
			
IFDEF TTSCC
	ld	a,(song_version)
ELSE
	;--- Set channel setup
	ld	a,(song_version)
	rlc	a
	and	$01
	ld	(replay_chan_setup),a
	ld	a,(song_version)
	and	01111111b
	ld	(song_version),a
ENDIF
	
	;--- song version 11 and up have extra bytes info
	and	$0f
	cp	11
	jr.	nz,0f

	;----- START OF EXTRA INFO
	;--- Get number of extra items
	ld	de,buffer
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror	

	;--- Read all extra item in buffer.
	ld	de,buffer+1
	ld	a,(buffer)
	ld	h,0
	ld	l,a
	call	read_file
	jr.	nz,catch_diskerror

	;--- Period table
	ld	a,(buffer+1)
	ld	(replay_period),a

	;--- Instrument types
	ld	a,(buffer)
	cp	32
	jr.	c,0f	;--- skip if not loaded from file
	ld	de,instrument_types
	ld	hl,buffer+2
	ld	bc,32
	ldir
0:
	;--- Drum type (FM)
	ld	a,(buffer)
	cp	33
	jr.	c,0f
IFDEF TTFM
	ld	a,(buffer+34)
	ld	(drum_type),a	
ENDIF
	;----- END OF EXTRA INFO

0:
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
	jr.	z,0f			; jump if SCC TMU file
; Skip FM/SMS data
	; skip the custom voice data
	ld	de,buffer		
	ld	hl,8*16
	call	read_file
	jr.	nz,catch_diskerror	

	;---- NOTE previous version then version 8 of TTFM are not loaded correct in TTSCC
	;	as the data is 2 byte (header) + 4 byte (data n-times)


	; skip the drum macro names
	ld	hl,MAX_DRUMS*16
	ld	a,(song_version)
	cp	9
	jr.	c,99f
	ld	hl,(MAX_DRUMS-1)*16
99:
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
	;--- FM 
	ld	a,(song_version)
	and	$f0
	cp	_CHIPSET_SCC
	jr.	nz,0f			; jump if not SCC file -> FM TMU file

	;--- SKip the waveform data
	ld	hl,32*32
	ld	de,buffer
	call	read_file
	jr.	nz,catch_diskerror
	jr. 	_otmu_patterns

0:
	ld	a,(song_version)
	and	$0f
	cp	6
	jr.	nc,_open_tmufile_customvoices
	
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
	ld	de,_VOICES+((192-31)*8)
	ld	hl,8*16
	call	read_file
	jr.	nz,catch_diskerror

	ld	a,(song_version)
	and 	0x0f
	cp 	8
	jr.	nc,_open_tmufile_drumnames_NEW

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
	ld	hl,MAX_DRUMS*16
	cp	9
	jr.	c,99f
	ld	hl,(MAX_DRUMS-1)*16
99:
 	;--- load drum names.
	ld	de,song_drum_list
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
	jr.	c,99f	
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

IFDEF TTSMS
ELSE
	ld	a,(song_version)
	and	$0f
	cp	10
	jr.	c,_translate_macros_correct_basevol
ENDIF
	ret




_translate_macros_correct_basevol:

	ld	b,32
	ld	de,instrument_macros
	
.insloop:
	ld	c,32
	inc	de	; skip len
	inc	de	; skip restart
	inc	de	; skip waveform

.rowloop:	
	inc	de	; skip noise

	ld	a,(de)
	bit	5,a		; check if base vol (bit5 == 0)
	jr.	nz,99f
	and	11001111b	; reset also bit 4 for base. Bit4 is for envelope.
	ld	(de),a
99:
	inc	de
	inc	de	; skip tone value
	inc	de	; skip tine value
	dec	c
	jr.	nz,.rowloop
	djnz	.insloop	

	ret


