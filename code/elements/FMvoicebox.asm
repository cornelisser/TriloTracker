
;_SCCWAVE_TEXT:

;_LABEL_VOICE_ON_EDIT:
;	db	_ARROWLEFT,"ON",_ARROWRIGHT
;_LABEL_VOICE_ON:	
;	db	" ON "
;_LABEL_VOICE_OFF:
;	db	_ARROWLEFT,"..",_ARROWRIGHT
;_LABEL_VOICE_OFF_EDIT:	
;	db	" .. "
_LABEL_VOICE_VAL_EDIT:
	db	_ARROWLEFT,"xx",_ARROWRIGHT
_LABEL_VOICE_VAL:
	db	" xx "
;_LABEL_VOICE_VAL2:
;	db	_ARROWLEFT,"xx",_ARROWRIGHT
;	db	" xx "
;_LABEL_VOICE_DEC:
;	db	_ARROWLEFT," D",_ARROWRIGHT
;	db	"  D "
;_LABEL_VOICE_SUS:
;	db	_ARROWLEFT," S",_ARROWRIGHT
;	db	"  S "
_LABEL_VOICE_DEFAULT:
	db	"           "	
;_LABEL_WAVE1:
;	db	_ARROWLEFT,140,142,_ARROWRIGHT
;_LABEL_WAVE2:
;	db	_ARROWLEFT,140,141,_ARROWRIGHT
;		
_labelpointer  db 2		; points to eighter edit/view mode string	
	
_FM_TEMPSTRING:
	db	"XXx."
_sccwave_pnt:
	dw	0
	
_scc_waveform_col: 	db	0	;column we are editing
_scc_waveform_val: 	db  	0	; value at the column
;===========================================================
; --- update_sccsampleavebox
; Display the values
; 
;===========================================================
update_sccwave:
	;--- Voice nr
	ld	a,(instrument_waveform)
	ld	de,_FM_TEMPSTRING
	call	draw_decimal_3
	ld	de,_FM_TEMPSTRING
	ld	hl,(80*10)+30+2+_base
	ld	b,4
	call	draw_label_fast
	
	;-- Voice name
	ld	a,(instrument_waveform)
	call	get_voicename
	ex	de,hl
	ld	hl,(80*10)+36+_base
	ld	b,20
	call	draw_label_fast
	
	
	;-- Voice values
	ld	de,8
	ld	hl,_VOICES
	ld	a,(instrument_waveform)
	cp	16
	jr.	c,_default_voice		; add erase value for ROM instruments
	sub	16
	
	;-- determine if view or edit
	push 	hl
	ld	hl,_LABEL_VOICE_VAL
	cp 	161
	jp	c,99f
	ld	hl,_LABEL_VOICE_VAL_EDIT
99:
	ld 	(_labelpointer),hl
	pop	hl
	
	jr.	z,99f
44:
	add	hl,de
	dec	a
	jr.	nz,44b
	
99:
	;=================
	;--- register 0
	;
	;=================
	;-- Amp modulation

	bit 7,(hl)
	jp	z,_m_amp_off
_m_amp_on:
	ld	a,1
	jp	66f
_m_amp_off:
	ld	a,0
66:
	push	hl
	call	fill_value
	ld	hl,(80*13)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl

	;--Vib modulation
	bit 6,(hl)
	jp	z,_m_vib_off
_m_vib_on:
	ld	a,1
	jp	66f
_m_vib_off:
	ld	a,0
66:
	push	hl
	call	fill_value
	ld	hl,(80*14)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	

	;--Envelope type (decay/sustain)
	bit 5,(hl)
	jp	nz,_m_env_sus
_m_env_dec:
	ld	a,0
	jp	66f
_m_env_sus:
	ld	a,1
66:
	push	hl
	call	fill_value
	ld	hl,(80*15)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	

	;--Rate key Scale
	bit 4,(hl)
	jp	nz,_m_ksr1
_m_ksr0:
	ld	a,0
	jp	66f
_m_ksr1:
	ld	a,1
66:
	push	hl
	call	fill_value
	ld	hl,(80*16)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	

	;--Modulation level
	ld	a,(hl)
	and	$0f	
	push	hl
	call	fill_value
	ld	hl,(80*17)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	


	inc	hl
	;=================
	;--- register 1
	;
	;=================
	;-- Amp modulation
	bit 7,(hl)
	jp	z,_c_amp_off
_c_amp_on:
	ld	a,1
	jp	66f
_c_amp_off:
	ld	a,0
66:
	push	hl
	call	fill_value
	ld	hl,(80*13)+38+10+3+7+_base
	ld	b,4
	call	draw_label_fast
	pop	hl

	;--Vib modulation
	bit 6,(hl)
	jp	z,_c_vib_off
_c_vib_on:
	ld	a,1
	jp	66f
_c_vib_off:
	ld	a,0
66:
	push	hl
	call	fill_value
	ld	hl,(80*14)+38+10+3+7+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	

	;--Envelope type (decay/sustain)
	bit 5,(hl)
	jp	nz,_c_env_sus
_c_env_dec:
	ld	a,0
	jp	66f
_c_env_sus:
	ld	a,1
66:
	push	hl
	call	fill_value
	ld	hl,(80*15)+38+10+3+7+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	

	;--Rate key Scale
	bit 4,(hl)
	jp	nz,_c_ksr1
_c_ksr0:
	ld	a,0
	jp	66f
_c_ksr1:
	ld	a,1
66:
	push	hl
	call	fill_value
	ld	hl,(80*16)+38+10+3+7+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	

	;--Modulation level
	ld	a,(hl)
	and	$0f	
	push	hl
	call	fill_value
	ld	hl,(80*17)+38+10+3+7+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	

	inc	hl
	;=================
	;--- register 2
	;
	;=================
	;-- Key scale level
	ld	a,(hl)
	push	hl
	rlc	a
	rlc	a
	and	$03
	call	fill_value
	ld	hl,(80*18)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl

	;--Modulation total
	ld	a,(hl)
	push	hl
	and	63
	call	fill_value
	ld	hl,(80*19)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	

	inc	hl
	;=================
	;--- register 3
	;
	;=================
	;-- Key scale level (carrier)
	ld	a,(hl)
	push	hl
	rlc	a
	rlc	a
	and	00000011b
	call	fill_value
	ld	hl,(80*18)+38+10+3+7+_base
	ld	b,4
	call	draw_label_fast
	pop	hl

	;--Wave distortion Modulator
	bit 	3,(hl)
	push	hl
	jp	z,_m_dist_off
_m_dist_on:
	ld	a,1
	jp	66f
_m_dist_off:
	ld	a,0
66:
	call	fill_value
	ld	hl,(80*20)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	
	
	;--Wave distortion Carrier
	bit 	4,(hl)
	push	hl
	jp	z,_c_dist_off
_c_dist_on:
	ld	a,1
	jp	66f
_c_dist_off:
	ld	a,0
66:
	call	fill_value
	ld	hl,(80*20)+38+10+3+7+_base
	ld	b,4
	call	draw_label_fast
	pop	hl

	;--- Feedback (modulator)
	ld	a,(hl)
	push	hl
	and	00000111b
	call	fill_value
	ld	hl,(80*21)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	

	inc	hl
	;=================
	;--- register 4
	;
	;=================
	;-- attack (mod)
	ld	a,(hl)
	push	hl
	rlc	a
	rlc	a
	rlc	a
	rlc	a
	and	$0f
	call	fill_value
	ld	hl,(80*22)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl
	
	;-- decay (mod)
	ld	a,(hl)
	push	hl
	and	$0f
	call	fill_value
	ld	hl,(80*23)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl
	
	inc	hl
	;=================
	;--- register 5
	;
	;=================
	;-- attack (car)
	ld	a,(hl)
	push	hl
	rlc	a
	rlc	a
	rlc	a
	rlc	a
	and	$0f
	call	fill_value
	ld	hl,(80*22)+38+10+3+7+_base
	ld	b,4
	call	draw_label_fast
	pop	hl
	
	;-- decay (car)
	ld	a,(hl)
	push	hl
	and	$0f
	call	fill_value
	ld	hl,(80*23)+38+10+3+7+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	


	inc	hl
	;=================
	;--- register 6
	;
	;=================
	;-- sustain (mod)
	ld	a,(hl)
	push	hl
	rlc	a
	rlc	a
	rlc	a
	rlc	a
	and	$0f
	call	fill_value
	ld	hl,(80*24)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl
	
	;-- release (mod)
	ld	a,(hl)
	push	hl
	and	$0f
	call	fill_value
	ld	hl,(80*25)+38+10+3+_base
	ld	b,4
	call	draw_label_fast
	pop	hl
	
	inc	hl
	;=================
	;--- register 7
	;
	;=================
	;-- sustain (car)
	ld	a,(hl)
	push	hl
	rlc	a
	rlc	a
	rlc	a
	rlc	a
	and	$0f
	call	fill_value
	ld	hl,(80*24)+38+10+3+7+_base
	ld	b,4
	call	draw_label_fast
	pop	hl
	
	;-- release (car)
	ld	a,(hl)
	push	hl
	and	$0f
	call	fill_value
	ld	hl,(80*25)+38+10+3+7+_base
	ld	b,4
	call	draw_label_fast
	pop	hl	
	ret

fill_value:
	ld 	de,(_labelpointer)
	inc	de
	call	draw_hex2
	ld 	de,(_labelpointer)
	ret



	
;===========================================================
; --- process_key_voicebox
;
; Process the input for the custom voices. 
; 
; 
;===========================================================
process_key_voicebox_edit:
	
	;--- disable edit when not in a custom voice
	ld	a,(instrument_waveform)
	cp	177
	jr.	c,restore_cursor

	
	ld	a,(key)
	and	a
	ret	z
 
	cp	_ESC
	jr.	nz,0f
	
		jr.	restore_cursor

0:
	cp	_SPACE
	jp	nz,0f
	ld	a,(keyjazz)
	xor	1
	ld	(keyjazz),a
	jr.	set_textcolor


0:
	cp	_KEY_LEFT
	jr.	nz,0f
	;---	move 1 column to the left
		call 	.handleleftright
;		ld	a,(_scc_waveform_col)
;		and	a
;		jr.	z,process_key_voicebox_edit_END
;		dec	a
;		ld	(_scc_waveform_col),a
;		call	flush_cursor
;		jp	_set_voice_cursor
		
0:	
	cp	_KEY_RIGHT
	jr.	nz,0f
	;---	move 1 column to the right	
		call 	.handleleftright
;		ld	a,(_scc_waveform_col)
;		cp	25
;		jr.	nc,process_key_voicebox_edit_END
;		inc	a
;		ld	(_scc_waveform_col),a
;		call	flush_cursor
;		jp	_set_voice_cursor
0:	
	cp	_KEY_UP
	jr.	nz,0f
	;---	increase value by 2
		ld	a,(_scc_waveform_col)
		cp	1
		jr.	c,process_key_voicebox_edit_END
		cp 	14
		jp	nz,99f
		dec	a
99:	
		cp 	18
		jp	nz,99f
		dec	a
99:
		dec	a
		;dec	a
		ld	(_scc_waveform_col),a
		call	flush_cursor
		jp	_set_voice_cursor
	
0:	
	cp	_KEY_DOWN
	jr.	nz,0f
	;---	decrease value by 2
		ld	a,(_scc_waveform_col)
		cp	25
		jr.	nc,process_key_voicebox_edit_END
		cp 	12
		jp	nz,99f
		inc	a
99:	
		cp 	16
		jp	nz,99f
		inc	a
99:
		;inc	a
		inc	a
		ld	(_scc_waveform_col),a
		call	flush_cursor
		jp	_set_voice_cursor
	
0:

	;--- check for keyjazz
;	ld	b,a
	ld	a,(keyjazz)
	and	a
	jr.	nz,process_key_keyjazz	
;	ld	a,b
	ret

.handleleftright:	
	ld 	b,a
	;--- handle input
	ld	a,(_scc_waveform_col)
	add	a
	ld	hl,_pkv_jumplist
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	(hl)

_pkv_jumplist:	
	dw	_pkv_mod_amp
	dw	_pkv_car_amp
	dw	_pkv_mod_freq
	dw	_pkv_car_freq
	dw	_pkv_mod_env
	dw	_pkv_car_env
	dw	_pkv_mod_rate
	dw	_pkv_car_rate
	dw	_pkv_mod_mlev
	dw	_pkv_car_mlev
	dw	_pkv_mod_klev
	dw	_pkv_car_klev
	dw	_pkv_mod_total
	dw	_pkv_none
	dw	_pkv_mod_wav
	dw	_pkv_car_wav
	dw	_pkv_mod_feed
	dw	_pkv_none
	dw	_pkv_mod_attack
	dw	_pkv_car_attack
	dw	_pkv_mod_decay
	dw	_pkv_car_decay
	dw	_pkv_mod_sustain
	dw	_pkv_car_sustain
	dw	_pkv_mod_release
	dw	_pkv_car_release

	
_pkv_mod_amp:
	ld	a,(key)
;	cp	_ENTER
;	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	ld	a,(hl)
	xor	10000000b
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_amp:
	ld	a,(key)
;	cp	_ENTER
;	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	ld	a,(hl)
	xor	10000000b
	ld	(hl),a
	jp	update_sccwave

	

_pkv_mod_freq:
	ld	a,(key)
;	cp	_ENTER
;	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	ld	a,(hl)
	xor	01000000b
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_freq:
	ld	a,(key)
;	cp	_ENTER
;	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	ld	a,(hl)
	xor	01000000b
	ld	(hl),a
	jp	update_sccwave

_pkv_mod_env:
;	ld	a,(key)
;	cp	_ENTER
;	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	ld	a,(hl)
	xor	00100000b
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_env:
	ld	a,(key)
;	cp	_ENTER
;	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	ld	a,(hl)
	xor	00100000b
	ld	(hl),a
	jp	update_sccwave

_pkv_mod_rate:
	ld	a,(key)
;	cp	_ENTER
;	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	ld	a,(hl)
	xor	00010000b
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_rate:
	ld	a,(key)
;	cp	_ENTER
;	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	ld	a,(hl)
	xor	00010000b
	ld	(hl),a
	jp	update_sccwave

_pkv_mod_wav:
;	ld	a,(key)
;	cp	_ENTER
;	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	
	xor	00001000b
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_wav:
;	ld	a,(key)
;	cp	_ENTER
;	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	xor	00010000b
	ld	(hl),a
	jp	update_sccwave
	
_pkv_mod_mlev:
;	call	_pkv_input_4bitvalue
;	ld	d,a

	ld	a,(instrument_waveform)	
	call	get_voice_location
	ld	a,(hl)
	and	$0f
	call	_4bit_leftright	
	
	ld	a,(hl)	
	and	$f0
	or	d
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_mlev:
;	call	_pkv_input_4bitvalue
;	ld	d,a
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	ld	a,(hl)
	and	$0f
	call	_4bit_leftright
	
	ld	a,(hl)
	and	$f0
	or	d
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_mod_klev:
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	inc	hl
	ld	a,(hl)
	and	11000000b
	call	_2bits_high_leftright
	ld	a,(hl)
	and	00111111b
	or	d
	ld	(hl),a
	jp	update_sccwave
	
_pkv_car_klev:
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	11000000b	
	call	_2bits_high_leftright	
	ld	a,(hl)
	and	00111111b
	or	d
	ld	(hl),a
	jp	update_sccwave
	
	

_pkv_mod_total:

	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	inc	hl
	ld	a,(hl)
	and	00111111b
	call	_6bit_leftright
	ld	a,(hl)
	and	11000000b
	or	d
	ld	(hl),a
		
	ld	a,1
	ld	(_pkv_mod_total_COL),a
	jp	update_sccwave	

_pkv_mod_feed:
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	00000111b
	call	_3bit_leftright
	
	ld	a,(hl)
	and	11111000b
	or	d
	ld	(hl),a
	jp	update_sccwave
	
_pkv_mod_attack:
;	call	_pkv_input_4bitvalue
;	rrc	a
;	rrc	a
;	rrc	a
;	rrc	a
;	ld	d,a

	ld	a,(instrument_waveform)	
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	inc	hl 
	ld	a,(hl)
	and	$f0
	call	_4bit_high_leftright
	
	ld	a,(hl)
	and	$0f
	or	d
	ld	(hl),a
	jp	update_sccwave	



_pkv_car_attack:

	ld	a,(instrument_waveform)	
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	inc	hl 
	inc	hl
	ld	a,(hl)
	and	$f0
	call	_4bit_high_leftright	
		
	ld	a,(hl)
	and	$0f
	or	d
	ld	(hl),a
	jp	update_sccwave
	
_pkv_mod_decay:
	ld	a,(instrument_waveform)	
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	inc	hl 
	ld	a,(hl)
	and	$0f
	call	_4bit_leftright	
	
	ld	a,(hl)
	and	$f0
	or	d
	ld	(hl),a
	jp	update_sccwave
	
_pkv_car_decay:
	ld	a,(instrument_waveform)	
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	inc	hl 
	inc	hl
	ld	a,(hl)
	and	$0f
	call	_4bit_leftright	
	
	ld	a,(hl)
	and	$f0
	or	d
	ld	(hl),a
	jp	update_sccwave
	
_pkv_mod_sustain:
	ld	a,(instrument_waveform)	
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	inc	hl 
	inc	hl
	inc	hl
	ld	a,(hl)
	and	$f0
	call	_4bit_high_leftright	
	
	ld	a,(hl)
	and	$0f
	or	d
	ld	(hl),a
	jp	update_sccwave
	
_pkv_car_sustain:
	ld	a,(instrument_waveform)	
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	inc	hl 
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	$f0
	call	_4bit_high_leftright	
	
	ld	a,(hl)
	and	$0f
	or	d
	ld	(hl),a
	jp	update_sccwave
	
_pkv_mod_release:
	ld	a,(instrument_waveform)	
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	inc	hl 
	inc	hl
	inc	hl
	ld	a,(hl)
	and	$0f
	call	_4bit_leftright	
		
	ld	a,(hl)
	and	$f0
	or	d
	ld	(hl),a
	jp	update_sccwave
	
_pkv_car_release:
	ld	a,(instrument_waveform)	
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	inc	hl 
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	$0f
	call	_4bit_leftright
	ld	a,(hl)
	and	$f0
	or	d
	ld	(hl),a
	jp	update_sccwave
	
_pkv_none:
	ret
	
	
_3bit_leftright:
	; in B the key (LEFT or RIGHT)
	; in A the value to change
	;
	; out the new value in D
	ex	af,af'
	ld	a,b
	;-- left
	cp 	_KEY_LEFT
	jp	nz,99f
	ex	af,af'
	and	a
	jp	z,88f
	dec	a
	jp	88f
99:
	;-- right
	cp	_KEY_RIGHT
	jp	nz,99f
	ex	af,af'
	cp	00000111b
	jp	z,88f
	inc	a
88:
	ld	d,a
	ret


_4bit_leftright:
	; in B the key (LEFT or RIGHT)
	; in A the value to change
	;
	; out the new value in D
	ex	af,af'
	ld	a,b
	;-- left
	cp 	_KEY_LEFT
	jp	nz,99f
	ex	af,af'
	and	a
	jp	z,88f
	dec	a
	jp	88f
99:
	;-- right
	cp	_KEY_RIGHT
	jp	nz,99f
	ex	af,af'
	cp	15
	jp	z,88f
	inc	a
88:
	ld	d,a
	ret
	
	
_6bit_leftright:
	; in B the key (LEFT or RIGHT)
	; in A the value to change
	;
	; out the new value in D
	ex	af,af'
	ld	a,b
	;-- left
	cp 	_KEY_LEFT
	jp	nz,99f
	ex	af,af'
	and	a
	jp	z,88f
	dec	a
	jp	88f
99:
	;-- right
	cp	_KEY_RIGHT
	jp	nz,99f
	ex	af,af'
	cp	00111111b
	jp	z,88f
	inc	a
88:
	ld	d,a
	ret
_4bit_high_leftright:
	; in B the key (LEFT or RIGHT)
	; in A the value to change
	;
	; out the new value in D
	ex	af,af'
	ld	a,b
	;-- left
	cp 	_KEY_LEFT
	jp	nz,99f
	ex	af,af'
	and	a
	jp	z,88f
	sub	16
	jp	88f
99:
	;-- right
	cp	_KEY_RIGHT
	jp	nz,99f
	ex	af,af'
	cp	$f0
	jp	z,88f
	add	16
88:
	ld	d,a
	ret


_2bits_high_leftright:
	; in B the key (LEFT or RIGHT)
	; in A the value to change
	;
	; out the new value in D
	ex	af,af'
	ld	a,b
	;-- left
	cp	_KEY_LEFT
	jp	nz,99f
	ex	af,af'
	cp	0
	jp	z,88f
	sub	01000000b
	jp	88f
	;-- right
99:	
	cp	_KEY_RIGHT
	jp	nz,88f
	ex	af,af'
	cp	11000000b
	jp	z,88f
	add	01000000b
88:	
	ld	d,a
	ret


; sub routine to get a 0-f hex value
;_pkv_input_4bitvalue:
;	ld	a,(key)
;	; is it a number?
;	cp	'0'	; bigger than 0 
;	jr.	c,99f	
;	cp	'9'+1	; smaller than 9?
;	jr.	nc,99f
;	sub 	'0'
;	jr.	22f
;99:	
;	cp	'a'
;	jr.	c,99f
;	cp	'f'+1
;	jr.	nc,99f
;	sub	'a'-10
;	jr.	22f
;99:	
;	cp	'A'
;	ret	c
;	cp	'F'+1
;	jp	44f
;	sub	'A'-10
;22:
;	ret
;
;44:	; Retur trick to stop processing in calling code
;	pop	af
;	ret


get_voice_location:
	push	de
	;-- Voice values
	ld	de,8
	ld	hl,_VOICES
	cp	16
	ret	c			; return for HW voices
	sub	16
	jr.	z,99f
44:
	add	hl,de
	dec	a
	jr.	nz,44b
99:	
	pop	de
	ret	
	
	

process_key_voicebox_edit_END:
	ret	
	
	
	
_set_voice_cursor:
	; in a the column
	sra	a
	ld	b,a
	jp	c,_svc_car

	;--- modulator column
_svc_mod:
	ld	a,52+_base
	jp	0f
	;--- carrier column
_svc_car:	
	ld	a,59+_base
0:	
	ld	(cursor_x),a	
	ld	a,13
	add	b
	ld	(cursor_y),a
	
	xor 	a			; just a hack to set cusro to first digit on Total level value
	ld	(_pkv_mod_total_COL),a	
	
	ret
	
	
	
	
	
	
	
	
	
	
	
	
_default_voice:
	ld	ixh,13
	ld	hl,(80*13)+38+10+3+_base
_dv_loop:
	push	hl
	ld	de,_LABEL_VOICE_DEFAULT
	ld	b,11
	call	draw_label_fast
	pop	hl
	ld	de,80
	add	hl,de
	dec	ixh
	jp	nz,_dv_loop
	ret




; in [A] the voice number
get_voicename:
	ld	h,0
	ld	l,a
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl	
	ld	bc,_VOICE_VRAM_START
	add	hl,bc
	call	set_vdpread
	
	di
	ld	hl,_LABEL_VOICENAME+2
	ld	bc,$1098
	inir
	
	ei
	ld	hl,_LABEL_VOICENAME
	ret
	
_LABEL_VOICENAME:
	db	"[ namenamenamename ]"