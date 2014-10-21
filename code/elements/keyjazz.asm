
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
		
		
;process_key_drumjazz:
;	push	af
;	ld	a,(current_song)
;	call	set_songpage
;	ld	a,(key_value)
;	ld	(replay_key),a
;	
;	pop	af
;;	;--- is it a number?
;;	cp	1
;;	jp	c,_process_key_drumjazz_END
;;	cp	6
;;	jp	nc,_process_key_drumjazz_END
;	
;	;--- erase notes
;	ld	hl,_KJ_SCC
;	ld	(hl),97		
;	ld	hl,_KJ_PSG
;	ld	(hl),97
;
;
;
;	;--- store drum cmd
;	ld	hl,_KJ_DRM1
;	ld	(hl),$0C		; drum effect
;	inc	hl
;	ld	b,a
;	dec	a
;
;	or	$F0
;	ld	(hl),a		; drum entry
;	
;	;--- store drum freq cmd
;	ld	hl,_KJ_DRM2
;	ld	(hl),$0C		; drum freq effect
;	inc	hl
;	ld	a,b
;	cp 	1
;	jp	z,44f
;	cp	2
;	jp	z,33f
;	cp	5
;	jp	z,33f
;
;	add	$10
;33:	add	$10
;44:	add	$60
;	and	$F0
;	ld	b,a
;	
;	ld	a,(cursor_y)
;	sub	10
;	or	b
;	
;	ld	(hl),a
;
;	call	replay_init
;	ld	a,0x00
;	ld	b,3
;	ld	hl,FM_volreg1
;33:	ld	(hl),a
;	inc	hl
;	djnz	33b
;	ld	a,00000111b
;	ld	(FM_DRUM_Flags),a		
;	call	replay_route
;
;	ld	a,(current_song)
;	call	set_songpage	
;;	ld	hl,_KEYJAZZ_LINE
;	ld	(replay_patpointer),hl
;	ld	a,2
;	ld	(replay_mode),a
;
;
;	di
;	call	replay_play
;	call	replay_route	
;	ei
;
;88:
;	ld	a,(replay_mode)
;	and	a
;	jp	nz,88b
;
;	ld	hl,_KJ_DRM1
;	ld	(hl),0
;	inc	hl
;	ld	(hl),0	
;	ld	hl,_KJ_DRM2
;	ld	(hl),0
;	inc	hl
;	ld	(hl),0
;
;	ret
;
;
;_process_key_drumjazz_END:	
;
;	ld	a,(current_song)
;	call	set_songpage
;	ret

		
		
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
	jp	z,99f
	
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