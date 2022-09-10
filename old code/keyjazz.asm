
_KEYJAZZ_LINE:
		db	0,0,0,0
		db	0,0,0,0
_KJ_PSG:	db	0,0,0,0
_KJ_SCC:	db	0,0
_KJ_DRM1:	db	0,0
		db	0,0
_KJ_DRM2:	db	0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		
		
process_key_keyjazz:
;	ld	a,(current_song)
	call	set_songpage
	ld	a,(key_value)
	ld	(replay_key),a
	ld	b,0
	;valid key?
	cp	128	; CTRL combination?
	jr.	nc,_keyjazz_END
	;get the note octave addittion	
	cp	88   ; SHIFT?
	jr.	c,99f
	inc	b
	sub	88
99:	
	;- Note under this keys?
	cp	48			
	jr.	nc,_keyjazz_END	
	
	;--- Get the note value of the key pressed
	ld	hl,_KEY_NOTE_TABLE
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	;--- Get the octave
	ld	a,(song_octave)
	add	b
	ld	b,a
	
	ld	a,(hl)
;	inc	a
	;--- Only process values != 255
	cp	255
	jr.	z,_keyjazz_END
	
	;--- Add the octave
	; but not for these;
	cp	97
	jr.	nc,77f
	and	a
	jr.	z,77f
	sub	12
88:
	add	12
	djnz	88b
	;--- Check if we are not outside the 8th ocatave
	cp	97
	jr.	nc,_keyjazz_END
	
77:		
	push	af
	call	replay_init
;	ld	a,(current_song)
	call	set_songpage	
	ld	hl,_KEYJAZZ_LINE
	ld	(replay_patpointer),hl
	ld	a,2
	ld	(replay_mode),a

;	;- determine the chip for location to set values	
;	ld	a,(editmode)
;	and	a
;	jr.	nz, 8f
;	ld	a,(cursor_x)
;	cp	31
;	ld	a,1
;	jr.	c,9f
;	inc	a
;9:	ld	(keyjazz_chip),a	
;
;8:	
	ld	hl,_KJ_SCC
	ld	(hl),97		
	ld	hl,_KJ_PSG
	ld	(hl),97

	ld	a,(keyjazz_chip)
	and	1
	jr.	z,_ky_noPSG
; set PSG playback values
	pop	af
	push	af
	ld	(hl),a
	inc	hl
	ld	a,(song_cur_instrument)
	ld	(hl),a
	inc	hl
	ld	a,0xf0	;	volume F, CMD 0	
	ld	(hl),a

_ky_noPSG:
	ld	a,(keyjazz_chip)
	and	2
	jr.	z,99f
	ld	hl,_KJ_SCC
	
	pop	af
	push	af
	ld	(hl),a
	inc	hl
	ld	a,(song_cur_instrument)
	ld	(hl),a
	inc	hl
	ld	a,0xf0	;	volume F, CMD 0	
	ld	(hl),a

99:
	pop	af
	di
	call	replay_play
	call	replay_route	
	ei
	
88:	;halt
;	--- wait till key is released	
	ld	a,(replay_mode)
	and	a
	jr.	z,_keyjazz_END

	ld	a,(_CONFIG_DEBUG)
	and	a
	jr.	z,99f
	
	call	draw_PSGdebug
	call	draw_SCCdebug
99:

	halt 
	jr.	88b


_keyjazz_END:	

;	ld	a,(current_song)
	call	set_songpage
	ret	


	
	
	; no key ? -> counter -1
	
	; key? -> set kj_line + pointer + timer > 0 + replay_mode=2


	ret