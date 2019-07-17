TM_X	equ	5
TM_Y	equ	2


;===========================================================
; --- draw_trackmanager
;
; Display the trackmanager window.  Without actual values 
; 
;===========================================================
draw_trackmanager:

	;draw the window
	ld	hl,(80*TM_Y)+TM_X
	ld	de,(70*256) + 16+8
	call	draw_box
	ld	hl,TM_Y+(256*TM_X)
	ld	de,0x4618	
	call	draw_colorbox
	ld	hl,(80*(TM_Y))+TM_X+10+16
	ld	de,_LABEL_TMANAGER
	call	draw_label	
	
	;draw the source/dest bar
	ld	hl,(80*(TM_Y+1))+TM_X+2+16+2
	ld	de,_LABEL_SRCDEST1
	call	draw_label		
	ld	hl,(80*(TM_Y+2))+TM_X+2+16+2
	ld	de,_LABEL_SRCDEST2
	call	draw_label	
	
	ld	hl,(80*(TM_Y+23))+TM_X+1+16
	ld	de,_LABEL_TMWARNING
	call	draw_label		
	
	;draw the pattern area
	ld	hl,(80*(TM_Y+3))+TM_X
	ld	de,(70*256) + 1
	call	draw_box

	
	;draw the channel area
	ld	hl,(80*(TM_Y+12+8))+TM_X
	ld	de,(70*256) + 1
	call	draw_box	
	
	
	call	update_trackmanager	
	ret
	
_LABEL_TMANAGER:
	db	"[ Track  Manager ]",0	
_LABEL_SRCDEST1:
	db	"Source:         Destination:",0	
_LABEL_SRCDEST2:
	db	"P ...-... T .   P ...-... T .",0	
_LABEL_TRACKSELECT:
	db	32,160,161,164
	db	32,160,161,165
	db	32,160,161,166
	db	32,162,163,164
	db	32,162,163,165
	db	32,162,163,166
	db	32,162,163,167
	db	32,162,163,168,0		
_LABEL_TMWARNING:
	db	"WARNING! Will erase all undo logging",0			
		
	
	
;===========================================================
; --- update_trackmanager_chans		
;
; Display the track managers channels selection. 
; 
;===========================================================
update_trackmanager_chans:	
	ld	hl,TM_Y+13+8+(256*(TM_X+1+16))
	ld	de,0x2401		
	call	erase_colorbox	


	;--- draw the text
	ld	hl,(80*(TM_Y+13+8))+TM_X+3+16
	ld	de,_LABEL_TRACKSELECT
	call	draw_label	


	;--- current chan highlight
	ld	a,(tm_status)
	and	2
	jr.	z,1f

	;--- source  channel
	ld	hl,(80*(TM_Y+13+8))+TM_X+3+16
	ld	a,(tm_src_chan)
	add	a
	add	a
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	de,_LABEL_TM_CHAN
	call	draw_label

	;-- highlight dest chan
1:	ld	a,(tm_dst_chan)
	;-- highlight source chan
	ld	hl,TM_Y+13+8+(256*(TM_X+3+16))
	add	a
	add	a
	add	a,h
	ld	h,a
	ld	de,0x0401		
	call	draw_colorbox	


	
	ret	


_LABEL_TM_CHAN:
	db	"x",0
	ret
;===========================================================
; --- update_trackmanager_patterns		
;
; Display the track manager patterns selection. 
; 
;===========================================================
update_trackmanager_patterns:
	;--- erase the colors
	ld	hl,TM_Y+4+(256*(TM_X+1))
	ld	de,0x4410		
	halt	;reduce flickering
	call	erase_colorbox	

	ld	a,(tm_status)
	and	1
	jr.	z,0f
	
	
	;================================
	; show the selection
	;================================
	ld	bc,(tm_dst_start)		; c= start b=end
	ld	a,b
	cp	c
	jr.	nc,99f
	;-- switch b and c
	ld	c,a
	ld	a,(tm_dst_start)
	ld	b,a
99:	
	inc	b
	
	ld	hl,TM_Y+4+(256*(TM_X+3))
	xor	a		; start with pattern 0
_utp_sel_loop:
	;- check if pattern is in selection range?
	cp	c
	jr.	c,99f		; jump if smaller than start
	cp	b
	jr.	nc,99f	; jump if larger than end
	
	;--- show a highlighted pattern nr
	ld	de,0x0401
	push	af
	push	bc
	push	hl
	call	draw_colorbox
	pop	hl
	pop	bc
	pop	af
99:	

	push	af			; store the pattern#
	ld	a,4			; hl + 4
	add	a,h
	ld	h,a
	pop	af
	inc	a			; next pattern# 

	ld	d,a
	and	15		
	jr.	nz,99f		; 16th entry -> if not then jump
	inc	l			; next line
	ld	h,TM_X+3		; set hl to left start pos
99:
;	ld	a,d
;	cp	SONG_MAXPAT
	;- check if we reached the last(+1) pattern.
	ld	a,(max_pattern)
;	dec	a
	cp	d
	ld	a,d
	jr.	nc,_utp_sel_loop
	

	;================================
	; show the patter nrs
	;================================
0:
	ld	ixh,0
	ld	hl,(80*(TM_Y+4))+TM_X+3
	ld	bc,(tm_src_start)		; c = start, b= end
	inc	b
	
_utp_loop:
	ld	de,_LABEL_TMPAT

_utp_loop_pat:
	;-- no more patterns?
;	ld	a,ixh
;	cp	SONG_MAXPAT
	ld	a,(max_pattern)
	dec	a
	cp	ixh
	jr.	nc,0f

	;---
	ld	a," "
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	
	jr.	3f

0:
	;-- check if we need to display the source indications.
	ld	a,(tm_status)
	and	2
	jr.	z,1f
	
	ld	a,ixh
	cp	c		; compare with start selection	
	jr.	c,1f
	cp	b		; compare with end of selection
	jr.	nc,1f

0:	
	ld	a,">"
	ld	(de),a
	jr.	2f	
1:
	ld	a," "
	ld	(de),a
	
2:
	inc	de
	ld	a,ixh
	push	bc
	cp	100
	jr.	c,33f
	call	draw_decimal_3
	jr.	44f
33:
	call	draw_decimal
	ld	a," "
	ld	(de),a
	inc	de


44:
	pop	bc
;	inc	de
3:
	inc	ixh
	
	ld	a,ixh
	and	15
	jr.	nz,_utp_loop_pat

	push	bc
	push	hl
	
	ld	de,_LABEL_TMPAT
	ld	b,64
	call	draw_label_fast	

	pop	hl
	ld	bc,80
	add	hl,bc		; hl at next line
	pop	bc

;	ld	a,ixh
;	cp	SONG_MAXPAT+1
	xor	a
	cp	ixh
	ret	z			; failsafe for pattern #256
	ld	a,(max_pattern)
;	inc	a
	cp	ixh
	jr.	nc,_utp_loop

	ret
_LABEL_TMPAT:
	db	".00b.00b.000.000.000.000.000.000.00b.00b.000.000.000.000.000.000",0


;===========================================================
; --- update_trackmanager
;
; Display the track manager values. 
; 
;===========================================================
update_trackmanager:
;	db	"P ...-... T.    P ...-... T.",0
	ld	de,_LABEL_SRCDEST2+2
	ld	a,(tm_src_start)
	call	draw_decimal_3
	inc	de
	ld	a,(tm_src_end)
	call	draw_decimal_3
	inc	de
	inc	de
	inc	de	
	ld	a,(tm_src_chan)
	call	draw_hex

	ld	de,_LABEL_SRCDEST2+18
	ld	a,(tm_dst_start)
	call	draw_decimal_3
	inc	de
	ld	a,(tm_dst_end)
	call	draw_decimal_3
	inc	de
	inc	de
	inc	de
	ld	a,(tm_dst_chan)
	call	draw_hex


	
	ld	hl,(80*(TM_Y+2))+TM_X+2+16+2
	ld	de,_LABEL_SRCDEST2
	call	draw_label	


	call	update_trackmanager_patterns		
	call	update_trackmanager_chans


; --- Vars for track manager
;tm_src_start:	#1	; start pattern of selection
;tm_src_end:		#1
;tm_src_chan:	#1	; source channel
;tm_dst_start:	#1
;tm_dst_end:		#1
;tm_dst_chan:	#1	; dest channel
;tm_pattern:		#1	; current pattern in window
;tm_status:		#1	; status to keep track actions
	ret

;===========================================================
; --- init_trackmanager
;
; initialise the track manager window
; 
;===========================================================	
init_trackmanager:
	ld	a,(editmode)
	cp	4
	ret	z

	call	save_cursor

	; --- init mode
	ld	a,4
	ld	(editmode),a
;	ld	a,0
;	ld	(editsubmode),a	


	; calc the cursor pos
	ld	a,(song_pattern)
	ld	(tm_pattern),a
	call	set_cursor_trackmanager

	;--- set the startvalues
	ld	a,(tm_pattern)
	ld	(tm_src_start),a
	ld	(tm_dst_start),a
	ld	(tm_src_end),a
	ld	(tm_dst_end),a
	xor	a
	ld	(tm_status),a
	ld	(tm_src_chan),a
	ld	(tm_dst_chan),a


	; --- show the screen
	call	draw_trackmanager
	call	update_trackmanager
	
	ret	
	
	
;===========================================================
; --- processkey_trackmanager
; Specific controls 
; 
;===========================================================	
processkey_trackmanager:
	;--- check [CTRL] combinations
	ld	a,(fkey)
	cp	_KEY_CTRL
	jr.	z,processkey_trackmanager_ctrl
	
	
	ld	a,(key)

	cp	_ESC
	jr.	nz,0f
	jr.	restore_patterneditor

0:		
	;--- next pattern
	cp	_KEY_LEFT
	jr.	nz,0f
		
	ld	a,(tm_pattern)
	and 	a
	jr.	z,processkey_trackmanager_END
	dec	a
	ld	(tm_pattern),a
	jr.	_pk_tm_shift
	
0:
	;--- next pattern
	cp	_KEY_RIGHT
	jr.	nz,0f
		
;	ld	a,(tm_pattern)
;	cp	SONG_MAXPAT-1
	ld	a,(max_pattern)
	dec	a
	ld	b,a
	ld	a,(tm_pattern)
	cp	b

	jr.	nc,processkey_trackmanager_END
	inc	a
	ld	(tm_pattern),a
	jr.	_pk_tm_shift
	
0:
	;--- next pattern
	cp	_KEY_UP
	jr.	nz,0f
		
	ld	a,(tm_pattern)
	cp	16
	jr.	c,processkey_trackmanager_END
	sub	16
	ld	(tm_pattern),a
	jr.	_pk_tm_shift

0:
	;--- next pattern
	cp	_KEY_DOWN
	jr.	nz,0f
		
;	ld	a,(tm_pattern)
;	cp	SONG_MAXPAT-8
	ld	a,(max_pattern)
	sub	16
	ld	b,a
	ld	a,(tm_pattern)
	cp	b

	jr.	nc,processkey_trackmanager_END
	add	16
	ld	(tm_pattern),a
	jr.	_pk_tm_shift
	
	
0:		
processkey_trackmanager_END:
	ret
	




;===========================================================
; --- processkey_trackmanager_ctrl
; Specific controls 
; 
;===========================================================	
processkey_trackmanager_ctrl:	
	ld	a,(key)


	;-- set clipboard
	cp	_CTRL_C
	jr.	nz,0f

	ld	bc,(tm_dst_start)
	;--- swap if needed
	ld	a,b
	cp	c
	jr.	nc,99f
	push	af
	ld	a,c
	ld	b,a
	pop	af
	ld	c,a
99:	
	
	ld	(tm_src_start),bc	
	ld	a,(tm_dst_chan)
	ld	(tm_src_chan),a
	ld	a,3
	ld	(tm_status),a
	call	update_trackmanager

0:	;-- paste selection
	cp	_CTRL_V
	jr.	nz,0f
	
	;-- check if there is data to paste
	ld	a,(tm_status)
	and	2
	ret	z
	
	call	tm_paste
	

	ret
	
0:	;--- swap selection
	cp	_CTRL_S
	jr.	nz,0f

	;-- check if there is data to swap.
	ld	a,(tm_status)
	and	2
	ret	z

	call	tm_swap
	
	ret

0:
	cp	_KEY_LEFT
	jr.	nz,0f

	ld	a,(tm_dst_chan)
	and	a
	jr.	z,_processkey_trackmanager_chans_end
	dec	a
	ld	(tm_dst_chan),a
	jr.	update_trackmanager

0:	
	cp	_KEY_RIGHT
	jr.	nz,0f

	ld	a,(tm_dst_chan)
	cp	7
	jr.	z,_processkey_trackmanager_chans_end
	inc	a
	ld	(tm_dst_chan),a
	jr.	update_trackmanager

0:	


_processkey_trackmanager_chans_end:
	ret	
	
;===========================================================
; --- set_cursor_trachmanager
; Translate thecurrent pattern to a cursor pos.
; 
;===========================================================	
set_cursor_trackmanager:	
	call	flush_cursor

	ld	a,(tm_pattern)			; cursor at this pattern
	ld	bc,((TM_Y+4)*256)+TM_X+4	; start pos
	
0:	cp	16		; is the cursor on the first line?
	jr.	c,1f
	inc	b		; y++
	sub	16
	jr.	0b	
	
1:
	add	a
	add	a			; x4
	add	c
	ld	(cursor_x),a
	ld	a,b
	ld	(cursor_y),a
	ld	a,3
	ld	(cursor_type),a
	
	ret


;---- process possible shift controls
_pk_tm_shift:
	ld	a,(skey)
	cp	1
	jr.	nz,_pk_tm_shift_no

	;-- shift already active?
	ld	a,(tm_status)
	bit	0,a
	jr.	z,_pk_tm_shift_start
	
	;-- continue the selection
	ld	a,(tm_pattern)
	ld	(tm_dst_end),a
	jr.	_pk_tm_shift_end
	
_pk_tm_shift_start:
	set	0,a
	ld	(tm_status),a
	ld	a,(tm_pattern)
	ld	(tm_dst_end),a
;	ld	(tm_dst_start),a
	jr.	_pk_tm_shift_end

_pk_tm_shift_no:
	;--- reset shift
	ld	a,(tm_status)
	and	254
	ld	(tm_status),a	

	ld	a,(tm_pattern)
	ld	(tm_dst_start),a
	ld	(tm_dst_end),a

	

_pk_tm_shift_end:
	call	update_trackmanager
	jr.	set_cursor_trackmanager



;=====================================
;
;
;
;=====================================
tm_paste:

	;--- set up the copy buffer
	call	_tm_fill_buffer
	call	_tm_copy_tracks
	
	call	init_undoredo		; Reset the undo/redo log

	ret
	
;=====================================
;
;
;
;=====================================
tm_swap:
	;--- swap always with src selection
	; window
	ld	a,(tm_status)
	and	254
	ld	(tm_status),a


	;--- set up the copy buffer
	call	_tm_fill_buffer
	call	_tm_swap_tracks

	call	init_undoredo		; Reset the undo/redo log
	ret


;=====================================
;
;
;
;=====================================
;--- Fill the buffer with the patterns to process.
_tm_fill_buffer:
	;-- set source start-end
	ld	bc,(tm_src_start)
	ld	a,b
	cp	c
	jr.	nc,99f
	;--- swap start end if needed
	ld	c,a
	ld	a,(tm_src_start)
	ld	b,a
	;-- set start pat and # of pats
99:	ld	a,b
	sub	c
	ld	b,a
	inc	b
	ld	a,b
	ld	(buffer),a

	;-- set destination start-end
	ld	de,(tm_dst_start)
	ld	a,d
	cp	e
	jr.	nc,99f
	;--- swap start end if needed
	ld	e,a
	ld	a,(tm_dst_start)
	ld	d,a
	;-- set start pat and # of pats
99:	ld	a,d
	sub	e
	ld	d,a
	inc	d

	;--- INIT for dest size is not a selection	
	ld	a,(tm_status)
	and	1
	jr.	nz,99f
	ld	a,b
	ld	d,a	;(buffer+3),a	
	
99:	ld	hl,buffer+1		;
	ld	a,d
	ld	(hl),a
	inc	hl
	ld	(hl),255
	inc	hl
_tfb_loop:
	ld	(hl),c
	inc	hl
	ld	(hl),e
	inc	hl

	dec	d
	jr.	z,0f		; jump outside loop if finished
	dec	b
	jr.	nz,99f	; jump if not end of source selection	
	ld	a,(buffer)
	ld	b,a
	ld	a,c
	sub	b
	ld	c,a
99:		
	inc	c
	inc	e
	jr.	_tfb_loop
	
0:
	ld	(hl),255
	ret
	
	
	
;======================================
;
;
;======================================
_tm_copy_tracks:
;	ld	a,(tm_src_start)
;	ld	b,a
;	ld	a,(tm_dst_start)
	ld	a,d
	cp	b
	jr.	nc,_tct_rev
_tct_fwd:
	ld	hl,buffer+3
0:	call	_tm_copy
	ld	a,(hl)
	cp	255
	jr.	nz,0b
	ret
_tct_rev:
	ld	hl,buffer+3

	ld	a,(buffer+1)	;-- contains the # of patterns to process
	dec	a
	add	a
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
0:	call	_tm_copy
	dec	hl
	dec	hl
	dec	hl
	ld	a,(hl)
	cp	255
	ret	z
	
;	dec	hl
	dec	hl
	jr.	0b

	ret
	
;====================================
;
;
;====================================
_tm_copy:
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	
	; avoid writing outside patterns.
;	ld	a,SONG_MAXPAT
	ld	a,(max_pattern)
	dec	a
	cp	c
	ret	c
	

	push	hl
	push	bc
	
	;--- store track in buffer
	call	set_patternpage
	ld	a,(tm_src_chan)
	sla 	a
	sla	a	; X4 to start at correct track
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
;	ld	de,buffer+(SONG_MAXPAT*2)+4
	ld	de,buffer+4
	ld	a,(max_pattern)
	add	a
	jr.	nc,99f
	inc	d
99:	
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	ixh,64
1:	ldi
	ldi
	ldi
	ldi
	ld	a,32-4	; next row of track	
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	dec	ixh
	jr.	nz,1b
	

	;--- place buffer in track
	pop	bc
	ld	b,c
	
	call	set_patternpage
	ld	a,(tm_dst_chan)
	sla 	a
	sla	a	; X4 to start at correct track
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
;	ld	de,buffer+(SONG_MAXPAT*2)+4
	ld	de,buffer+4
	ld	a,(max_pattern)
	add	a
	jr.	nc,99f
	inc	d
99:	
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	ixh,64
	ex	de,hl
1:	ldi
	ldi
	ldi
	ldi
	ld	a,32-4	; next row of track	
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	dec	ixh
	jr.	nz,1b	
	

	;--- restore pages
;	ld	a,(current_song)
	call	set_songpage
	; restore pointer of pats to copy.	
	pop	hl
	ret
	
	
;======================================
;
;
;======================================
_tm_swap_tracks:
;	ld	a,(tm_src_start)
;	ld	b,a
;	ld	a,(tm_dst_start)
	ld	a,d
	cp	b
	jr.	nc,_tst_rev
_tst_fwd:
	ld	hl,buffer+3
0:	call	_tm_swap
	ld	a,(hl)
	cp	255
	jr.	nz,0b
	ret
_tst_rev:
	ld	hl,buffer+3

	ld	a,(buffer+1)	;-- contains the # of patterns to process
	dec	a
	add	a
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
0:	call	_tm_swap
	dec	hl
	dec	hl
	dec	hl
	ld	a,(hl)
	cp	255
	ret	z
	
;	dec	hl
	dec	hl
	jr.	0b

	ret
	
	
;====================================
;
;
;====================================
_tm_swap:
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	
	; avoid writing outside patterns.
;	ld	a,SONG_MAXPAT
	ld	a,(max_pattern)
	cp	c
	ret	c
	

	push	hl
	push	bc
	
	;--- store track in buffer
	call	set_patternpage
	ld	a,(tm_src_chan)
	sla 	a
	sla	a	; X4 to start at correct track
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
;	ld	de,buffer+(SONG_MAXPAT*2)+4
	ld	de,buffer+4
	ld	a,(max_pattern)
	add	a
	jr.	nc,99f
	inc	d
99:	
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	ixh,64
1:	ldi
	ldi
	ldi
	ldi
	ld	a,32-4	; next row of track	
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	dec	ixh
	jr.	nz,1b
	

	;--- place buffer in track
	pop	bc
	push	bc
	ld	b,c
	
	call	set_patternpage
	ld	a,(tm_dst_chan)
	sla 	a
	sla	a	; X4 to start at correct track
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	push	hl
	;--- save the old values
;	ld	de,buffer+(SONG_MAXPAT*2)+4+(4*64)
	ld	de,buffer+4+(4*64)
	ld	a,(max_pattern)
	add	a
	jr.	nc,99f
	inc	d
99:	
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:	

	ld	ixh,64

1:	ldi
	ldi
	ldi
	ldi
	ld	a,32-4	; next row of track	
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	dec	ixh
	jr.	nz,1b	
	
	;--- set the new values
	pop	hl
;	ld	de,buffer+(SONG_MAXPAT*2)+4
	ld	de,buffer+4
	ld	a,(max_pattern)
	add	a
	jr.	nc,99f
	inc	d
99:	
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:

	ld	ixh,64
	ex	de,hl
1:	ldi
	ldi
	ldi
	ldi
	ld	a,32-4	; next row of track	
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	dec	ixh
	jr.	nz,1b	
	
	;--- set value at src track
	pop	bc
	call	set_patternpage
	ld	a,(tm_src_chan)
	sla 	a
	sla	a	; X4 to start at correct track
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:

;	ld	de,buffer+(SONG_MAXPAT*2)+4+(4*64)
	ld	de,buffer+4+(4*64)
	ld	a,(max_pattern)
	add	a
	jr.	nc,99f
	inc	d
99:	
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:	
	
	ld	ixh,64
	ex	de,hl
1:	ldi
	ldi
	ldi
	ldi
	ld	a,32-4	; next row of track	
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	dec	ixh
	jr.	nz,1b	
	
	;--- restore pages
;	ld	a,(current_song)
	call	set_songpage
	; restore pointer of pats to copy.	
	pop	hl
	ret
	
	