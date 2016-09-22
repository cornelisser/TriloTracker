
;_SCCWAVE_TEXT:

_LABEL_VOICE_ON:
;	db	_ARROWLEFT,"ON",_ARROWRIGHT
	db	" ON "
_LABEL_VOICE_OFF:
;	db	_ARROWLEFT,"..",_ARROWRIGHT
	db	" .. "
_LABEL_VOICE_VAL:
;	db	_ARROWLEFT," x",_ARROWRIGHT
	db	"  x "
_LABEL_VOICE_VAL2:
;	db	_ARROWLEFT,"xx",_ARROWRIGHT
	db	" xx "
_LABEL_VOICE_DEC:
;	db	_ARROWLEFT," D",_ARROWRIGHT
	db	"  D "
_LABEL_VOICE_SUS:
;	db	_ARROWLEFT," S",_ARROWRIGHT
	db	"  S "
_LABEL_VOICE_DEFAULT:
	db	"           "	
_LABEL_WAVE1:
	db	" ",140,142," "
_LABEL_WAVE2:
	db	" ",140,141," "
		
	
	
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
	ld	hl,(80*10)+30+2
	ld	b,4
	call	draw_label_fast
	
	;-- Voice name
	ld	a,(instrument_waveform)
	call	get_voicename
	ex	de,hl
	ld	hl,(80*10)+36
	ld	b,20
	call	draw_label_fast
	
	
	;-- Voice values
	ld	de,8
	ld	hl,_VOICES
	ld	a,(instrument_waveform)
	cp	16
	jr.	c,_default_voice		; add erase value for ROM instruments
	sub	16
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
	ld	de,_LABEL_VOICE_ON
	jp	66f
_m_amp_off:
	ld	de,_LABEL_VOICE_OFF
66:
	push	hl
	ld	hl,(80*13)+38+10+3
	ld	b,4
	call	draw_label_fast
	pop	hl

	;--Vib modulation
	bit 6,(hl)
	jp	z,_m_vib_off
_m_vib_on:
	ld	de,_LABEL_VOICE_ON
	jp	66f
_m_vib_off:
	ld	de,_LABEL_VOICE_OFF
66:
	push	hl
	ld	hl,(80*14)+38+10+3
	ld	b,4
	call	draw_label_fast
	pop	hl	

	;--Envelope type (decay/sustain)
	bit 5,(hl)
	jp	nz,_m_env_sus
_m_env_dec:
	ld	de,_LABEL_VOICE_DEC
	jp	66f
_m_env_sus:
	ld	de,_LABEL_VOICE_SUS
66:
	push	hl
	ld	hl,(80*15)+38+10+3
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
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*16)+38+10+3
	ld	b,4
	call	draw_label_fast
	pop	hl	

	;--Modulation level
	ld	a,(hl)
	and	$0f	
	push	hl
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*17)+38+10+3
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
	ld	de,_LABEL_VOICE_ON
	jp	66f
_c_amp_off:
	ld	de,_LABEL_VOICE_OFF
66:
	push	hl
	ld	hl,(80*13)+38+10+3+7
	ld	b,4
	call	draw_label_fast
	pop	hl

	;--Vib modulation
	bit 6,(hl)
	jp	z,_c_vib_off
_c_vib_on:
	ld	de,_LABEL_VOICE_ON
	jp	66f
_c_vib_off:
	ld	de,_LABEL_VOICE_OFF
66:
	push	hl
	ld	hl,(80*14)+38+10+3+7
	ld	b,4
	call	draw_label_fast
	pop	hl	

	;--Envelope type (decay/sustain)
	bit 5,(hl)
	jp	nz,_c_env_sus
_c_env_dec:
	ld	de,_LABEL_VOICE_DEC
	jp	66f
_c_env_sus:
	ld	de,_LABEL_VOICE_SUS
66:
	push	hl
	ld	hl,(80*15)+38+10+3+7
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
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*16)+38+10+3+7
	ld	b,4
	call	draw_label_fast
	pop	hl	

	;--Modulation level
	ld	a,(hl)
	and	$0f	
	push	hl
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*17)+38+10+3+7
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
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*18)+38+10+3
	ld	b,4
	call	draw_label_fast
	pop	hl

	;--Modulation total
	ld	a,(hl)
	push	hl
	and	63
	ld	de,_LABEL_VOICE_VAL2+1
	call	draw_hex2
	ld	de,_LABEL_VOICE_VAL2
	ld	hl,(80*19)+38+10+3
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
	and	$03
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*18)+38+10+3+7
	ld	b,4
	call	draw_label_fast
	pop	hl

	;--Wave distortion Modulator
	bit 	4,(hl)
	push	hl
	jp	z,_m_dist_off
_m_dist_on:
	ld	de,_LABEL_WAVE1
	jp	66f
_m_dist_off:
	ld	de,_LABEL_WAVE2
66:
	ld	hl,(80*20)+38+10+3
	ld	b,4
	call	draw_label_fast
	pop	hl	
	
	;--Wave distortion Carrier
	bit 	3,(hl)
	push	hl
	jp	z,_c_dist_off
_c_dist_on:
	ld	de,_LABEL_WAVE1
	jp	66f
_c_dist_off:
	ld	de,_LABEL_WAVE2
66:
	ld	hl,(80*20)+38+10+3+7
	ld	b,4
	call	draw_label_fast
	pop	hl

	;--- Feedback (modulator)
	ld	a,(hl)
	push	hl
	and	$07
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*21)+38+10+3
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
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*22)+38+10+3
	ld	b,4
	call	draw_label_fast
	pop	hl
	
	;-- decay (mod)
	ld	a,(hl)
	push	hl
	and	$0f
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*23)+38+10+3
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
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*22)+38+10+3+7
	ld	b,4
	call	draw_label_fast
	pop	hl
	
	;-- decay (car)
	ld	a,(hl)
	push	hl
	and	$0f
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*23)+38+10+3+7
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
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*24)+38+10+3
	ld	b,4
	call	draw_label_fast
	pop	hl
	
	;-- release (mod)
	ld	a,(hl)
	push	hl
	and	$0f
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*25)+38+10+3
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
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*24)+38+10+3+7
	ld	b,4
	call	draw_label_fast
	pop	hl
	
	;-- release (car)
	ld	a,(hl)
	push	hl
	and	$0f
	ld	de,_LABEL_VOICE_VAL+2
	call	draw_hex
	ld	de,_LABEL_VOICE_VAL
	ld	hl,(80*25)+38+10+3+7
	ld	b,4
	call	draw_label_fast
	pop	hl	
	ret


	
;===========================================================
; --- process_key_voicebox
;
; Process the input for the custom voices. 
; 
; 
;===========================================================
process_key_voicebox_edit:
	
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
		ld	a,(_scc_waveform_col)
		and	a
		jr.	z,process_key_voicebox_edit_END
		dec	a
		ld	(_scc_waveform_col),a
		call	flush_cursor
		jp	_set_voice_cursor
		
0:	
	cp	_KEY_RIGHT
	jr.	nz,0f
	;---	move 1 column to the right	
		ld	a,(_scc_waveform_col)
		cp	25
		jr.	nc,process_key_voicebox_edit_END
		inc	a
		ld	(_scc_waveform_col),a
		call	flush_cursor
		jp	_set_voice_cursor
0:	
	cp	_KEY_UP
	jr.	nz,0f
	;---	increase value by 2
		ld	a,(_scc_waveform_col)
		cp	2
		jr.	c,process_key_voicebox_edit_END
		dec	a
		dec	a
		ld	(_scc_waveform_col),a
		call	flush_cursor
		jp	_set_voice_cursor
	
0:	
	cp	_KEY_DOWN
	jr.	nz,0f
	;---	decrease value by 2
		ld	a,(_scc_waveform_col)
		cp	24
		jr.	nc,process_key_voicebox_edit_END
		inc	a
		inc	a
		ld	(_scc_waveform_col),a
		call	flush_cursor
		jp	_set_voice_cursor
	
0:

	;--- check for keyjazz
	ld	b,a
	ld	a,(keyjazz)
	and	a
	jr.	nz,process_key_keyjazz	
	ld	a,b
	
	
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
	cp	_ENTER
	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	ld	a,(hl)
	xor	10000000b
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_amp:
	ld	a,(key)
	cp	_ENTER
	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	ld	a,(hl)
	xor	10000000b
	ld	(hl),a
	jp	update_sccwave

	

_pkv_mod_freq:
	ld	a,(key)
	cp	_ENTER
	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	ld	a,(hl)
	xor	01000000b
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_freq:
	ld	a,(key)
	cp	_ENTER
	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	ld	a,(hl)
	xor	01000000b
	ld	(hl),a
	jp	update_sccwave

_pkv_mod_env:
	ld	a,(key)
	cp	_ENTER
	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	ld	a,(hl)
	xor	00100000b
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_env:
	ld	a,(key)
	cp	_ENTER
	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	ld	a,(hl)
	xor	00100000b
	ld	(hl),a
	jp	update_sccwave

_pkv_mod_rate:
	ld	a,(key)
	cp	_ENTER
	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	ld	a,(hl)
	xor	00010000b
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_rate:
	ld	a,(key)
	cp	_ENTER
	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	ld	a,(hl)
	xor	00010000b
	ld	(hl),a
	jp	update_sccwave

_pkv_mod_wav:
	ld	a,(key)
	cp	_ENTER
	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	
	xor	00010000b
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_wav:
	ld	a,(key)
	cp	_ENTER
	ret	nz
	
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	xor	00001000b
	ld	(hl),a
	jp	update_sccwave
	
_pkv_mod_mlev:
	ld	a,(key)
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	22f
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	22f
99:	
	cp	'A'
	ret	c
	cp	'F'+1
	ret	nc
	sub	'A'-10
22:
	ld	d,a

	ld	a,(instrument_waveform)	
	call	get_voice_location
	ld	a,(hl)
	and	$f0
	or	d
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_car_mlev:
	ld	a,(key)
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	22f
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	22f
99:	
	cp	'A'
	ret	c
	cp	'F'+1
	ret	nc
	sub	'A'-10
22:
	ld	d,a
	ld	a,(instrument_waveform)
	call	get_voice_location
	inc	hl
	ld	a,(hl)
	and	$f0
	or	d
	ld	(hl),a
	jp	update_sccwave	
	
_pkv_mod_klev:
	ld	a,(key)
	; is it a number?
	cp	'0'	; bigger than 0 
	ret	c	
	cp	'3'+1	; smaller than 3?
	ret	nc
	sub 	'0'

	rrc	a
	rrc	a
	ld	d,a
	ld	a,(instrument_waveform)
	call	get_voice_location
	ld	a,(hl)
	inc	hl
	inc	hl
	and	00111111b
	or	d
	ld	(hl),a
	jp	update_sccwave
	
_pkv_car_klev:
	ld	a,(key)
	; is it a number?
	cp	'0'	; bigger than 0 
	ret	c	
	cp	'3'+1	; smaller than 3?
	ret	nc
	sub 	'0'

	rrc	a
	rrc	a
	ld	d,a
	ld	a,(instrument_waveform)
	call	get_voice_location
	ld	a,(hl)
	inc	hl
	inc	hl
	inc	hl
	and	00111111b
	or	d
	ld	(hl),a
	jp	update_sccwave
	
_pkv_mod_total;
_pkv_mod_feed:
_pkv_mod_attack:
_pkv_car_attack:
_pkv_mod_decay:
_pkv_car_decay:
_pkv_mod_sustain:
_pkv_car_sustain:
_pkv_mod_release:
_pkv_car_release:
_pkv_none:
	ret



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
	ld	a,52
	jp	0f
	;--- carrier column
_svc_car:	
	ld	a,59
0:	
	ld	(cursor_x),a	
	ld	a,13
	add	b
	ld	(cursor_y),a
	ret
	
	
	
	
	
	
	
	
	
	
	
	
_default_voice:
	ld	ixh,13
	ld	hl,(80*13)+38+10+3
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