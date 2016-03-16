;===========================================================
; --- draw_samplebox
; Display the  area.  Without actual values 
; 
;===========================================================
draw_drumeditbox:
	ret

;===========================================================
; --- update_psgsamplebox
; Display the values
; 
;===========================================================
update_drumeditbox:
	ret

;===========================================================
; --- process_key_psgsamplebox
;
; Process the input for the PSG sample. 
; 
; 
;===========================================================
process_key_drumeditbox:
	
	ld	a,(key)
	and	a
	ret	z


process_key_drumeditbox_END:
	ret



;===========================================================
; --- get_psgsample_location:
;
; returns in hl the start ofthe current sample line.
; Changes: A, HL and BC
;===========================================================
get_drummacro_location:
	ret





;===========================================================
; --- process_key_psgsamplebox_octave
;
;
;===========================================================
process_key_drumeditbox_octave:
	ld	a,(song_octave)
	ld	c,a
	ld	a,(key)

	;--- Check if edit is ended.
	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		call	restore_cursor
		;call	reset_cursor_trackbox
		jr.	process_key_drumeditbox_octave_END
0:		
	;--- Key_up - Pattern down	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
44:		dec	c
		ld	a,c
		jr.	z,process_key_drumeditbox_octave_END
88:		ld	(song_octave),a
		call	update_drumeditbox
		jr.	process_key_drumeditbox_octave_END	
0:
	;--- Key_down - Pattern up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		ld	a,c
		cp	7
		jr.	nc,process_key_drumeditbox_octave_END
		inc	a
		jr.	88b	
0:
	;---- number key
	cp	"1"
	jr.	c,0f
	cp	"8"
	jr.	nc,0f

		sub	48
		ld	(song_octave),a
		call	restore_cursor
		call	update_drumeditbox
		jr.	process_key_drumeditbox_octave_END
0:	
process_key_drumeditbox_octave_END:
	ret


;===========================================================
; --- process_key_psgsamplebox_len
;
;
;===========================================================
process_key_drumeditbox_len:
0:	ret


;===========================================================
; --- process_key_description
;
; Process the song name input
; 
;===========================================================
process_key_drumeditbox_description:
	ret



;===========================================================
; --- reset_cursor_psgsamplebox
;
; Reset the cursor to the top left of the pattern.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_drumeditbox:
	ret

