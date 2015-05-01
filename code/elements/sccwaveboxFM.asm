
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





















	
_FREQ_LINE:
	db	"xx: --- +xx"
_FREQ_VAL:
	db	"..."	
;===========================================================
; --- update_drumfreq
; Display the values
; 
;===========================================================
update_drumfreq:	
	
	ld	hl,(80*10)+64
	exx
	
	;for each line
	ld 	hl,_FM_drumfreqedit
	ld	b,	0
	
_udfloop:
	push	bc
	;line
	ld	de,_FREQ_LINE
	ld	a,b
	call	draw_hex2
	inc	de
	inc	de	
	;--- the note
	ld	a,(hl)
	and	$7f 		; remove deviation bit


	push	hl

	;--- get pointer to the note labels.
	ld	hl,_LABEL_NOTES
	ld	b,0
	ld	c,a
	add	hl,bc
	add	hl,bc
	add	hl,bc
	;--- copy note label to [DE]
	ldi
	ldi
	ldi

	pop	hl	

	inc	de
	
	;--- The deviation 
	bit 7,(hl)
	jp	z,99f
	ld	a,"-"
	ld	(de),a
	jp	88f
99:
	ld	a,"+"
	ld	(de),a
	
88:	inc	hl
	ld	a,(hl)
	inc	hl
	push	hl

	inc	de
	call	draw_hex2
	inc	de
	pop	hl
	
;	;---- the tone value
;	ld	b,(hl)	;-- deviation
;	dec	hl
;	ld	a,(hl)	;-- note
;	inc	hl
;	inc	hl
;	
;	push	hl
;	
;	ld	hl,CHIP_FM_ToneTable
;	add	a
;	add	a,l
;	ld	l,a
;
;	ld	a,(hl)
;	inc	hl
;	ld	h,(hl)
;	ld	l,a
;	
;	ld	a,b
;	bit	7,a
;	jp	z,77f
;	and	$7f
;	neg
;	add	a,l
;	ld	l,a
;	jp	nc,99f
;	dec	h
;99:	jp	44f
;77:
;	add	a,l
;	ld	l,a
;	jp	nc,99f
;	inc	h	
;99:
;44:
;	ld	a,h
;	push	hl
;	call	draw_hex
;	pop	hl
;	ld	a,l
;	call	draw_hex2		
;
;	pop	hl

	exx
	push	hl
	ld	de,_FREQ_LINE
	ld	b,11
	call	draw_label_fast
	pop	hl
	ld	de,80
	add	hl,de
	exx
	
	pop	bc
	
	inc	b
	ld	a,16
	cp	b
	jr.	nz,_udfloop


	;==== The real values:
	ld	hl,(80*10)+64+12
	ld 	bc,_FM_drumfreqtable
	ld	ixh,16
	
_udfv_loop:
	inc	bc
	ld	a,(bc)
	and	1
	ld	de,_FREQ_VAL
	call	draw_hex
	dec	bc
	ld	a,(bc)
	ld	de,_FREQ_VAL+1
	call	draw_hex2
	
	push	bc
	push	hl
	ld	de,_FREQ_VAL
	ld	b,3
	call	draw_label_fast	
	pop	hl
	pop	bc
	inc	bc
	inc	bc
	ld	de,80
	add	hl,de
	dec	ixh
	jp	nz,_udfv_loop
	
		
	ret
	
	
	
	

;===========================================================
; --- process_key_sccwavebox
;
; Process the input for the scc sample. 
; 
; 
;===========================================================
process_key_sccwavebox_edit:
	
	ld	a,(key)
	and	a
	ret	z

	cp	_ESC
	jr.	nz,0f
	
		jr.	restore_cursor

0:
	cp	_SPACE
	jr.	nz,0f
	ld	a,(keyjazz)
	xor 	1
	ld	(keyjazz),a
	jr.	set_textcolor		
0:

	cp	_KEY_LEFT
	jr.	nz,0f
	;---	move 1 column to the left	
		ld	a,(_scc_waveform_col)
		and	a
		jr.	z,process_key_sccwavebox_edit_END
		dec	a
		ld	(_scc_waveform_col),a
;		jp	nz,99f
;		ld	a,3
;		ld	(cursor_type),a
;		ld	a,(cursor_x)
;		sub	2
;		ld	(cursor_x),a
;99:
		call	flush_cursor
		ld	a,(cursor_x)
		jr.	nz,99f			; flags from previous dec a
		;-- to note pos
		sub	5
		ld	(cursor_x),a
		ld	a,3
		ld	(cursor_type),a
		ret
		
99:
		dec	a
		ld	(cursor_x),a
		ret
;		jr.	get_waveform_val
		
0:	
	cp	_KEY_RIGHT
	jr.	nz,0f
	;---	move 1 column to the right	
_right:	ld	a,(_scc_waveform_col)
		cp	2
		jr.	nc,update_drumfreq
		inc	a
		ld	(_scc_waveform_col),a

		call	flush_cursor
		cp	1
		ld	a,(cursor_x)
		jr.	nz,99f
		add	4
99:
		inc	a
		ld	(cursor_x),a
		ld	a,1
		ld	(cursor_type),a
		jr.	update_drumfreq
		;jr.	get_waveform_val
0:	
	cp	_KEY_UP
	jr.	nz,0f
	;---	increase value by 1
		ld	a,(cursor_y)
		cp	11
		jr.	c,process_key_sccwavebox_edit_END
		dec	a
		call	flush_cursor
		ld	(cursor_y),a
		ret		
	
0:	
	cp	_KEY_DOWN
	jr.	nz,0f
	;---	decrease value by 1
		ld	a,(cursor_y)
		cp	9+16
		jr.	nc,process_key_sccwavebox_edit_END
		inc	a
		call	flush_cursor
		ld	(cursor_y),a
		ret		

	
0:	
	ld	a,(keyjazz)
	and	a
	ld	a,(key)
	jp	z,0f
	
	;--- drumjazz
	cp	"1"
	jr.	c,4f
	cp	"9"+1
	jp	nc,4f
	sub	"1"-1

	jr.	process_key_drumjazz
4:
	ret

0:
	ld	a,(_scc_waveform_col)
	and	a
	jp	z,process_key_drumfreq_note
	jp	process_key_drumfreq_dev
	
process_key_sccwavebox_edit_END:
	ret
	
process_key_drumfreq_note:
	ld	a,(key)
	;---- Test for DEL
	cp	_DEL
	jr.	nz,99f
	xor	a
	jr.	77f

99:	
	ld	a,(key_value)
	;---- now get the note
	ld	(replay_key),a
	ld	b,0
	;valid key?
	cp	88   ; SHIFT?
	jr.	c,99f
	inc	b
	sub	88
99:	
	;- Note under this keys?
	cp	48			
	ret	nc	
	
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
	;--- Only process values != 255
	cp	255
	ret	z
	
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
	ret	nc
	
77:
	ld	b,a
	;--- offset (2bytes)
	ld	a,(cursor_y)
	sub	10
	add	a
	ld	hl,_FM_drumfreqedit
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(hl)
	and	$80
	or	b
	ld	(hl),a
	call	update_waveform_val
	jp	update_drumfreq


		 
;-------
; Drum frequency deviation 
;-------
process_key_drumfreq_dev:	
	;--- offset (2bytes)
	ld	a,(cursor_y)
	sub	10
	add	a
	ld	c,a
	ld	b,0

	ld	a,(key)
	;-- check deviation types input
	cp	"+"
	jp	nz,0f
	ld	hl,_FM_drumfreqedit
	add	hl,bc
	ld	a,(hl)
	and	$7f
	ld	(hl),a	
	call	update_waveform_val
	jp	update_drumfreq	
	
0:		
	cp	"-"
	jp	nz,0f
	ld	hl,_FM_drumfreqedit
	add	hl,bc
	ld	a,(hl)
	or 	$80
	ld	(hl),a	
	call	update_waveform_val
	jp	update_drumfreq			

0:
	;--- nummeric input
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
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
22:	
	ld	d,a	

	;--- offset (2bytes)
	ld 	hl,_FM_drumfreqedit
	inc	bc
	add	hl,bc
	ld	a,(_scc_waveform_col)
	cp	1
	jp	nz,55f
	;-- high 4 bits
	sla	d
	sla	d	
	sla	d
	sla	d	
	ld	a,(hl)
	and	$0f
	or	d
	ld	(hl),a
	jp	99f	
55:
	ld	a,(hl)
	and	$F0
	or 	d
	ld	(hl),a
99:
0:	
	call	update_waveform_val
	jp	update_drumfreq	


_drumfreq_update:	
	ret


update_waveform_val:
	;-- make sure replayer data (tone table) is loaded
	xor	a
	call	swap_loadblock

	ld	a,(cursor_y)
	sub	10
	add	a
	
	ld 	bc,_FM_drumfreqedit
	add	a,c
	ld	c,a
	jp	nc,99f
	inc	b
99:
	ld	a,(bc)
	and	$7f
	
	;-- get the tone related to the note
	add	a
	ld	hl,CHIP_FM_ToneTable
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	e,(hl)
	inc	hl
	ld	d,(hl)

	;-- add the deviation
	ld	a,(bc)
	inc	bc
	and	$80
	ld	a,(bc)
	ld	h,0
	ld	l,a	
	ex	de,hl
	jp	z,_uwv_add
_uwv_sub:
	xor	a
	sbc	hl,de
	jp	88f
_uwv_add:	
	add	hl,de
	
88:
	ex	de,hl
	ld	a,(cursor_y)
	sub	10
	add	a
	
	ld 	hl,_FM_drumfreqtable
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	(hl),e
	inc	hl
	ld	(hl),d
	
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