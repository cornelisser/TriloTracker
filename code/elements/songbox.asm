;===========================================================
; --- draw_songbox
;
; Display the song area.  Without actual values 
; 
;===========================================================	
draw_songbox:
	; Song box
	ld	hl,(80*1)+8
	ld	de,(40*256)+5
	call	draw_box
	ld	hl,(80*1)+1+8
	ld	de,_LABEL_SONGBOX
	call	draw_label

	ld	hl,(80*2)+2+8
	ld	b,5;32
	ld	de,_LABEL_SONGNAME
	call	draw_label_fast	
	ld	hl,(80*3)+2+8
	ld	de,_LABEL_SONGBY
	ld	b,5;32
	call	draw_label_fast
	ld	hl,(80*1)+48
	ld	de,_LABEL_VU
	ld	b,8;32
	call	draw_label_fast



	call	update_songbox_volume


	ld	hl,0x0801
	ld	de,0x2805	
	call	draw_colorbox
	;- name and by
	ld	hl,0x0f02
	ld	de,0x2002	
	call	erase_colorbox
	;- volume
	ld	hl,0x0f05
	ld	de,0x2001	
	call	erase_colorbox	
	;-- VU
	ld	hl,0x3001
	ld	de,0x0801	
	call	draw_colorbox


	ret
	
_LABEL_SONGBOX:
	db	"song:",0

_LABEL_SONGNAME:
	db	"Name:"	
_LABEL_SONGBY:
	db	"By  :"
_LABEL_BALANCE:
IFDEF TTSCC
	db	 "Mix: ",160,161,"----+----+--------+----+----",162,163
ELSE
	db	 "Mix: ",160,161,"----+----+--------+----+----",170,171
ENDIF
_LABEL_VU:
	db	"vu",129,129,129,129,129,129

;===========================================================
; --- update_songbox
;
; Display the values of the song area.  
; 
;===========================================================
update_songbox:
	ld	b,32
	ld	hl,(80*2)+7+8
	ld	de,song_name
	call	draw_label_fast
	ld	b,32
	ld	hl,(80*3)+7+8
	ld	de,song_by
	call	draw_label_fast
;	ld	a,(current_song)
;	inc	a
;	ld	de,_LABEL_SONGNRBOX+1
;	call	draw_hex
;	ld	a,(max_songs)
;	ld	de,_LABEL_SONGNRBOX+3
;	call	draw_hex
	
;	ld	hl,(80*1)+33+8	
;	ld	b,5
;	ld	de,_LABEL_SONGNRBOX
;	call	draw_label_fast	
	ret
	
	
;_LABEL_SONGNRBOX:
;	db	"(x/x)"	

_LABEL_BALANCE_IND:
	DB	254,254
;===========================================================
; --- update_songbox_volume
;
; Display the volume balance of the song area.  
; 
;===========================================================
update_songbox_volume:
	call	flush_cursor
	ld	hl,(80*5)+2+8
	ld	de,_LABEL_BALANCE
	ld	b,37;32
	call	draw_label_fast

	ld	a,0XF0
	ld	bc,(mainPSGvol)
	sub	B
	add	C
	jr.	nc,99f
	inc	a
99:
	RLCA	
	RLCA	
	RLCA
	RLCA	
	LD	D,0
	LD	E,A
	ld	hl,(80*5)+2+8+5
	add	HL,DE
	
	ld	de,_LABEL_BALANCE_IND
	ld	b,2;32
	call	draw_label_fast

	ret


;===========================================================
; --- process_key_songbox
;
; Process the song name input
; 
;===========================================================
process_key_songbox:
	;--- Set the start of the name.
	ld	hl,song_by
	ld	a,(cursor_y)
	cp	2
	jr.	nz,1f

	;--- Check if we need to remove the placeholder
	ld	a,(song_name+31)
	and	a
	jp	nz,0f

	;--- erase placeholder
	ld	hl,song_name
	ld	a,32
88:	
	ld	(hl),32
	inc	hl
	dec	a
	jp	nz,88b
	call	update_songbox

0:	
	ld	hl,song_name
1:
	ld	a,(key)
	;--- Check if edit is ended.
	cp	_ESC
	jr.	nz,99f
88:		ld	a,0
		ld	(editsubmode),a
		call	restore_cursor
		;call	reset_cursor_trackbox
		jr.	process_key_songbox_END
99:
	;--- Check if edit is submitted
	cp	_ENTER
	jr.	z,88b	

	;--- Check for RIGHT
	cp	_KEY_RIGHT
	jr.	nz,99f
		ld	a,(cursor_x)
		cp	7+31+8
		jr.	nc,process_key_songbox_END
		call	flush_cursor
		inc	a
		ld	(cursor_x),a
		jr.	process_key_songbox_END			
99:	
	
	;--- Check for LEFT
	cp	_KEY_LEFT
	jr.	nz,99f
		ld	a,(cursor_x)
		cp	8+8
		jr.	c,process_key_songbox_END
		call	flush_cursor
		dec	a
		ld	(cursor_x),a
		jr.	process_key_songbox_END
99:
	;--- Backspace
	cp	_BACKSPACE
	jr.	nz,99f
		; get location in RAM
		ld	b,a
		ld	a,(cursor_x)
		sub	7+8
		add	a,l
		ld	l,a
		jr.	nc,88f
		inc	h
88:
		; move cursor (if possible)
		ld	a,(cursor_x)
		cp	8+8
		jr.	c,77f		
		dec	a
		ld	(cursor_x),a
77:		
		ld	(hl),32
		call	update_songbox
		jr.	process_key_songbox_END

99:
	;--- Delete
	cp	_DEL
	jr.	nz,99f
		ld	a,(cursor_x)
		sub	7+8
		add	a,l
		ld	l,a
		jr.	nc,88f
		inc	h	
88:	
		ld	(hl)," "
		call	update_songbox
		jr.	process_key_songbox_END	

99:
	;--- All other (normal) keys
	cp	32
	jr.	c,process_key_songbox_END
	cp	128
	jr.	nc,process_key_songbox_END
	
	ld	b,a
	ld	a,(cursor_x)
	sub	7+8
	add	a,l
	ld	l,a
	jr.	nc,88f
	inc	h
88:
		ld	a,(cursor_x)
		cp	7+31+8
		jr.	nc,99f
		call	flush_cursor
		inc	a
		ld	(cursor_x),a
99:	ld	(hl),b
	call	update_songbox
	jr.	process_key_songbox_END
			
process_key_songbox_END:
	ret
	
;===========================================================
; --- process_key_songbox_volume
;
; Change the volume balance
; 
;===========================================================	
process_key_songbox_volume:
	ld	a,(key)
	;--- Check if edit is ended.
	cp	_ESC
	jr.	nz,0f
88:		ld	a,0
		ld	(editsubmode),a
		call	restore_cursor
		;call	reset_cursor_trackbox
		jr.	process_key_songbox_END
0:
	CP	_KEY_LEFT
	jr.	nz,0f

	ld	a,(mainPSGvol)
	and	a
	jr.	z,88f
	;--- change PSG val
	sub	16
	ld	(mainPSGvol),a
	jr.	99f
	
88:	;--- change SCC  val
	ld	a,(mainSCCvol)
	cp	0xf0
	jr.	z,99f
	add	16
	ld	(mainSCCvol),a
	jr.	99f
99:
	;-- show the volume bar
	CALL	update_songbox_volume
	ret	
0:
	CP	_KEY_RIGHT
	jr.	nz,0f

	ld	a,(mainSCCvol)
	and	a
	jr.	z,88f
	;--- change SCCval
	sub	16
	ld	(mainSCCvol),a
	jr.	99f
88:	;---change PSG val	
	ld	a,(mainPSGvol)
	cp	0xF0
	jr.	z,99f
	add	16
	ld	(mainPSGvol),a

99:
	;-- show the volume bar
	CALL	update_songbox_volume
	ret	
0:	
	
	
process_key_songbox_volume_END:
	ret	
	
;===========================================================
; --- reset_cursor_songbox
;
; Reset the cursor to the top left of the songbox.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_songbox:
	call	flush_cursor
	ld	a,7+8
	ld	(cursor_x),a
	ld	a,1
	ld	(cursor_type),a		
	
	ld	a,(editsubmode)
	dec	a
	jr.	nz,1f
	;--- Songname
	ld	a,2	
	jr.	2f	
1:	;--- Songby	
	dec	a
	jr.	nz,3f
	ld	a,3
	jr.	2F
3:	;--- balance
	ld	a,7+7+16
	ld	(cursor_x),a
	ld	a,2
	ld	(cursor_type),a		

	ld	 a,5

2:	ld	(cursor_y),a
	ret
