;===========================================================
; --- reset_cursor_trackbox
;
; Reset the cursor to the top left of the pattern.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_trackbox:
	call	flush_cursor
	call	cursorstack_init		; cancel any previous sub edit modes.
	
	ld	a,10
	ld	(cursor_y),a
	ld	a,4
	ld	(cursor_x),a
	ld	a,3
	ld	(cursor_type),a	
	ld	a,(_COLTAB_COMPACT)		; get first value
	ld	(cursor_input),a
	xor	a
	ld	(song_pattern_line),a
	ld	(cursor_column),a
	ld	(song_pattern_offset),a

	ret


	db	255	;end
_COLTAB_COMPACT:
	;chan 1
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 2
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 3
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 4
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 5
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 6
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 7
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 8
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5	; 5= y
	db	255
	




;==================================================
;--- Copies the pattern in a into an empty pattern. 
;    in [A] the pattern to copy.
;==================================================
copy_to_empty_pattern:
	;--- copy pattern onto the buffer
	ld	b,a
	call	set_patternpage
	ld	de,buffer
	ld	bc,SONG_PATSIZE
	ldir
	
	;--- search for the next available free pattern
	ld	b,0
_pkt_gloop:
	push	bc
	call	set_patternpage
	pop	bc
	
	ld	de,SONG_PATSIZE
_pkt_gloop1:
	ld	a,(hl)
	cp	0
	jr.	nz,_pkt_gloop_not_empty
	inc	hl
	dec	de
	ld	a,d
	cp	e
	jr.	nz,_pkt_gloop1
	and	a
	jr.	nz,_pkt_gloop1
		
	;--- found an empty pattern!
	push	bc
;	ld	a,(current_song)
	call	set_songpage
	pop	bc
	ld	a,b
	ld	(song_pattern),a

	call	set_patternpage
	push	hl
	ld	de,buffer
	ex	de,hl

	ld 	bc,SONG_PATSIZE
	ldir

	;-- clear buffer for edit log dif check
	ld	hl,buffer
	ld	de,buffer+1
	ld	(hl),0
	ld	bc,SONG_PATSIZE-1
	ldir
	
	pop	hl
	call	store_log_block
	ret
	
_pkt_gloop_not_empty:
	inc	b
;	ld	a,b
	;-- did we process all patterns
;	cp	SONG_MAXPAT
	ld	a,(max_pattern)
	cp	b
	ld	a,b
	jr.	nc,_pkt_gloop
;	ld	a,(current_song)
	jr.	set_songpage	
	
	
