;================================
; The new replayer.
;
; Swappable part
;
;================================
REPLAY_START:

_TEMPAY:	db "aAAA bBBB cCCC nNN mMM aVbVcV e eeee"
_TEMPSCC:	db "aAAA bBBB cCCC dDDD eEEE aVbVcVdVeV mMM"

; Sine table used for tremolo and vibrato
CHIP_Vibrato_sine:
      db 	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00		      ; depth 	1
      db 	$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00		      ; depth 	2
      db 	$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$02,$02,$02,$02,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00		      ; depth 	3
      db 	$00,$00,$00,$00,$00,$01,$01,$01,$01,$02,$02,$02,$03,$03,$04,$04,$04,$04,$03,$03,$02,$02,$02,$01,$01,$01,$01,$00,$00,$00,$00,$00		      ; depth 	4
      db 	$00,$00,$00,$00,$01,$01,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$05,$05,$04,$04,$03,$03,$02,$02,$01,$01,$01,$01,$00,$00,$00,$00		      ; depth 	5
      db 	$00,$00,$00,$00,$01,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$05,$05,$04,$04,$03,$03,$02,$02,$01,$01,$01,$00,$00,$00,$00		      ; depth 	6
      db 	$00,$00,$00,$01,$01,$01,$02,$02,$03,$04,$04,$05,$06,$06,$07,$08,$08,$07,$06,$06,$05,$04,$04,$03,$02,$02,$01,$01,$01,$00,$00,$00		      ; depth 	7
      db 	$00,$00,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0C,$0D,$0D,$0C,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$01,$01,$00,$00		      ; depth 	8
      db 	$00,$00,$01,$02,$02,$04,$05,$06,$08,$09,$0B,$0D,$0F,$11,$13,$15,$15,$13,$11,$0F,$0D,$0B,$09,$08,$06,$05,$04,$02,$02,$01,$00,$00		      ; depth 	9
      db 	$00,$01,$01,$02,$04,$05,$07,$09,$0B,$0E,$10,$13,$16,$19,$1C,$1F,$1F,$1C,$19,$16,$13,$10,$0E,$0B,$09,$07,$05,$04,$02,$01,$01,$00		      ; depth 	A
      db 	$00,$01,$02,$03,$05,$08,$0B,$0E,$11,$15,$19,$1D,$21,$26,$2B,$2F,$2F,$2B,$26,$21,$1D,$19,$15,$11,$0E,$0B,$08,$05,$03,$02,$01,$00		      ; depth 	B
      db 	$01,$01,$03,$05,$07,$0B,$0E,$12,$17,$1C,$21,$27,$2D,$33,$39,$3F,$3F,$39,$33,$2D,$27,$21,$1C,$17,$12,$0E,$0B,$07,$05,$03,$01,$01		      ; depth 	C

			
;--- Replay	music stepped
replay_mode5:
	;--- The speed timer
	ld	hl,replay_speed_timer
	dec	(hl)

	jr.	nz,replay_decodedata_NO	; jmp	if timer > 0

	ld	a,(key)
	and	a
	jr.	nz,.key
.nokey:
	inc	(hl)
	jr. 	replay_decodedata_NO
.key:
	jr.	_rplmd_cont

;--- Replay	music
replay_mode1:
	;--- The speed timer
	ld	hl,replay_speed_timer
	dec	(hl)
	
	jr.	nz,replay_decodedata_NO	; jmp	if timer > 0
_rplmd_cont:	
	;--- Reset Timer == 0
	xor	a
	ld	bc,(replay_speed)		; [b]	subtimer [c] speed
	srl	c				; bit	0 is halve speedstep
	adc	a,a
	xor	b				; alternate	speed	to have halve speed.
	ld	(replay_speed_subtimer),a
	add	c
	ld	(replay_speed_timer),a
	
	;--- Only for visualisation of the playback.
	ld	a,(replay_line)
	inc	a
	ld	(replay_line),a
	;--- to prevent missing	Dxx command
	cp	65
	call	nc,replay_setnextpattern
	jr.	replay_decodedata	
	
;--- Keyjazz
replay_mode2:
	;--- mode 2	- Replay the line	in 'replay_patpointer'
	ld	a,(replay_speed_timer)
	and	a
	jr.	z,_rpm2_3
	
	;-- decode data only once. Timer is never updated again.
	xor	a
	ld	(replay_speed_timer),a
	jr.	replay_decodedata	
	
	;--- test if key is still pressed.
_rpm2_3:
	ld	a,0x0f
	ld	(KH_timer),a		; F3F7 REPCNT  Delay until the auto-repeat of the key	begins	
	
	;-- test if musickb is pressed
	ld	a,(music_key_on)
	and	a
	jr.	z,.testkb
	ld	a,(music_key)
	ld	c,a
	ld	a,(music_buf_key)
	cp	c
	;--- just keep playing empty lines.
	jr.	z,replay_decodedata_NO
	
.testkb:
	;--- test if key is still pressed.
	ld	a,(replay_key)
	ld	c,a		; calculate the row
	srl	c
	srl	c
	srl	c
	and	0x07		; calculate the bit
	ld	b,a
	ld	a,1
	jr.	z,99f
88:
	sla	a
	djnz	88b
99:
	ld	hl,KH_matrix	; get matrix byte
	add	hl,bc
	and	(hl)			; bit is unset?
	;--- just keep playing empty lines.
	jr.	z,replay_decodedata_NO
	
	;--- stop playing.
	call	replay_stop
	ret
;-- end

replay_mode3:
	;--- mode 3	- Replay the line	in 'replay_patpointer'
	ld	a,(replay_speed_timer)
	and	a
	jr.	nz,1f	
	jr.	_rpm2_3		; mode 2 and 3 work alike.
	
1:	
;	call	replay_init_pre
	jr.	replay_mode2


;-- end
;--- Replay	music	looped pattern
replay_mode4:
	;--- The speed timer
	ld	hl,replay_speed_timer
	dec	(hl)
	
	jr.	nz,replay_decodedata_NO	; jmp	if timer > 0
	
	;--- Reset Timer == 0
	xor	a
	ld	bc,(replay_speed)		; [b]	subtimer [c] speed
	srl	c				; bit	0 is halve speedstep
	adc	a,a
	xor	b				; alternate	speed	to have halve speed.
	ld	(replay_speed_subtimer),a
	add	c
	ld	(replay_speed_timer),a
	
	;--- Only for visualisation of the playback.
	ld	a,(replay_line)
	inc	a
	ld	(replay_line),a
	
	;--- to prevent missing	Dxx command
	cp	65
	;call	nc,replay_setnextpattern
	jr.	c,replay_decodedata
	
;	ld	a,(current_song)
	call	set_songpage
	ld	a,(song_pattern)
	;-- Get the	new pattern	data pointer
	ld	b,a
	call	set_patternpage
	ld	(replay_patpointer),hl
	
	;--- Set the line	to the first line
	ld	a,1;xor	a		;ld	a,255
	ld	(replay_line),a
	jr.	replay_decodedata
	




	
	
;===========================================================
; ---	replay_decodedata
; Process the patterndata 
; 
; 
;===========================================================
replay_decodedata:
	ld	a,(replay_patpage)	;--- set correct pattern page
	call	PUT_P2
	ld	bc,(replay_patpointer)	;--- Get the pointer to	the data

	;--- Set the tone table base
;	ld	hl,TRACK_ToneTable
;	ld	(replay_Tonetable),hl
	
	ld	iyh,$00
	ld	ix,TRACK_Chan1
	call	replay_decode_chan
	ld	ix,TRACK_Chan2
	call	replay_decode_chan
	ld	ix,TRACK_Chan3
	call	replay_decode_chan
	ld	ix,TRACK_Chan4
	call	replay_decode_chan
	ld	iyh,$20
	ld	ix,TRACK_Chan5
	call	replay_decode_chan
	ld	iyh,$40
	ld	ix,TRACK_Chan6
	call	replay_decode_chan
	ld	iyh,$60
	ld	ix,TRACK_Chan7
	call	replay_decode_chan
	ld	ix,TRACK_Chan8
	call	replay_decode_chan

	;--- store the pointer
	ld	(replay_patpointer),bc
	

		
;===========================================================
; ---	replay_decodedata_NO
; Process changes.
; 
; 
;===========================================================
replay_decodedata_NO:
	; do what is needed when there is no new data

	;---- morph routine here
	ld	a,(replay_morph_active)
	and	a
	call	nz,replay_process_morph

	xor	a
	ld	(SCC_regMIXER),a
	ld	a,(mainPSGvol)
	ld	(replay_mainvol),a

	ld	ix,TRACK_Chan1
	ld	hl,AY_regToneA
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLE)
	ld	(AY_regVOLA),a	

	ld	ix,TRACK_Chan2
	ld	hl,AY_regToneB	
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLE)
	ld	(AY_regVOLB),a
	
	ld	ix,TRACK_Chan3
	ld	hl,AY_regToneC	
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLE)
	ld	(AY_regVOLC),a


	ld	a,(SCC_regMIXER)
	srl	a
	srl	a
	xor	0x3f
	ld	(AY_regMIXER),a
	xor	a
	ld	(SCC_regMIXER),a
	ld	a,(mainSCCvol)
	ld	(replay_mainvol),a
	
	ld	iyh,0			;iyh stores	the SCC chan#
					; used for waveform updates
	ld	ix,TRACK_Chan4
	ld	hl,SCC_regToneA	
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLE)
	ld	(SCC_regVOLA),a	

	inc	iyh
	
	ld	ix,TRACK_Chan5
	ld	hl,SCC_regToneB
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLE)
	ld	(SCC_regVOLB),a

	inc	iyh
		
	ld	ix,TRACK_Chan6
	ld	hl,SCC_regToneC	
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLE)
	ld	(SCC_regVOLC),a	

	inc	iyh
		
	ld	ix,TRACK_Chan7
	ld	hl,SCC_regToneD	
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLE)
	ld	(SCC_regVOLD),a	

;	inc	iyh
		
	ld	ix,TRACK_Chan8
	ld	hl,SCC_regToneE	
	call	replay_process_chan_AY

	ret


;===========================================================
; ---	replay_setpattern
; Process changes.
; 
; 
;===========================================================
replay_setnextpattern:
	;-- get new	page
	call	set_songpage
	
	;--- Get the loop	position
	ld	a,(song_order_len)
	ld	b,a
	
	;--- Get the next	pattern number in	the order
	ld	hl,song_order
	ld	a,(song_order_pos)
	inc	a
	cp	b
	jr.	nc,_snp_loop
	jr.	_snp_continue		
	
_snp_loop:
	ld	a,(song_order_loop)
	cp	255		;--- no loop?

	jr.	nz,_snp_continue
	call	z,replay_stop

	;--- set to last played line
	ld	a,(replay_line)
	dec	a
	ld	(replay_line),a
	;--- Stop playback (should be implemented in a cleaner way I think)
	xor	a
	ld	(replay_mode),a
	pop	af			; remove RET address from stack
	ret
		
_snp_continue:
	ld	(song_order_pos),a
	ld	e,a
	ld	d,0
	add	hl,de

	ld	a,(hl)
	ld	(song_pattern),a

	;-- Get the	new pattern	data pointer
	ld	b,a
	call	set_patternpage
	ld	(replay_patpointer),hl
	
	;--- Set the line	to the first line
	ld	a,1;xor	a		;ld	a,255
	ld	(replay_line),a
	
	;--- Store the new page	of the pattern
	call	GET_P2
	ld	(replay_patpage),a

	ret	
	
	
;===========================================================
; ---	replay_init
; Initialize all data for playback
; 
; 
;===========================================================
replay_init_cont:
	di
;	call	draw_vu_empty
	;--- Get the start speed.
	ld	a,(song_speed)
	ld	(replay_speed),a
	ld	a,1
	ld	(replay_morph_type),a			; default continue last written waveform
	ld	(replay_speed_timer),a
	ld	(replay_morph_timer),a
	ld	(replay_morph_speed),a
	dec	a

	ld	(replay_speed_subtimer),a
	ld	(replay_mode),a	
	ld	(replay_morph_active),a
	ld	(replay_morph_waveform),a
	
	;--- Erase channel data	in RAM
;	xor	a
	ld	bc,(TRACK_REC_SIZE*8)-1
	ld	hl,TRACK_Chan1
	ld	de,TRACK_Chan1+1
	ld	(hl),a
	ldir
	
;	;--- Set vibrato table
;	ld	hl,TRACK_Vibrato_sine
;	ld	(replay_vib_table),hl
	
	;--- Set the tone table base
	ld	hl,TRACK_ToneTable
	ld	(replay_Tonetable),hl
	
	
	;--- Silence the chips
	ld	a,0x3f
	ld	(AY_regMIXER),a
	xor	a
	ld	(SCC_regMIXER),a
	ld	(AY_regVOLA),a
	ld	(AY_regVOLB),a	
	ld	(AY_regVOLC),a
		
	;--- Init the SCC	(waveforms too)
	ld	a,(SCC_slot)
	ld	h,0x80
	call enaslt
	
	ld	a,255
	ld	(TRACK_Chan4+TRACK_Waveform),a
	ld	(TRACK_Chan5+TRACK_Waveform),a
	ld	(TRACK_Chan6+TRACK_Waveform),a	
	ld	(TRACK_Chan7+TRACK_Waveform),a	
	ld	(TRACK_Chan8+TRACK_Waveform),a	
	ld	a,128
	ld	(TRACK_Chan4+TRACK_Flags),a
	ld	(TRACK_Chan5+TRACK_Flags),a
	ld	(TRACK_Chan6+TRACK_Flags),a	
	ld	(TRACK_Chan7+TRACK_Flags),a	
	ld	(TRACK_Chan8+TRACK_Flags),a	
	
	call 	scc_reg_update
	
	ld	a,(mapper_slot)				; Recuperamos el slot
	ld	h,0x80
	call 	enaslt
	

	call	replay_route
;	ei
	
;	ld	hl,song_order
	ld	a,(song_pattern)	
	ld	b,a;(hl)
	ld	a,(song_pattern_line)
	ld	(replay_line),a
	call	set_patternpage
	ld	a,(replay_line)
	and	a
	jr.	z,6f
	ld	b,a
	ld	de,SONG_PATLNSIZE
5:
	add	hl,de
	djnz	5b
6:	
	ld	(replay_patpointer),hl	
	
	call	GET_P2
	ld	(replay_patpage),a


;	ld	a,(current_song)
;	call	set_songpage
;
	
	; end	is here
	ei
	ret



;--- Very basic pre-scan. Old	one was WAY	too slow.
replay_init_pre:
	di

    ;--- set up the PRE_INIT_LINE
      ld    hl,_PRE_INIT_LINE
      ld    (hl),0      ; No note
      inc   hl
      ld    (hl),1      ; Instrument 1
      inc   hl
      ld    (hl),$f0    ; Max volume/no effect
      inc   hl
      ld    (hl),0      ; No params
      inc   hl

      ;--- Now copy same to other channel data
      ld    de,_PRE_INIT_LINE  
      ex    de,hl
      ld    bc,4*7
      ldir

	;--- Get the instruments from	the first line of	the song
	call	set_songpage
	ld	hl,song_order
	ld	a,(hl)
	ld	b,a
	call	set_patternpage
      ;--- Copy pattern line to pre init line
      call  replay_init_pre_lineupdate 

	;--- Get the data from the first line of the current pattern
	call	set_songpage
      ld    a,(song_pattern_line) 
      inc   a
      push  af                            ; Store for later
	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage
      pop   bc                            ; get the save line
.lineloop:
      push  bc
      call  replay_init_pre_lineupdate 
      pop   bc
      djnz  .lineloop


;--- Process the instuments and volumes in the audition line.
      ld    bc,(replay_patpointer)
      push  bc
      ld	bc,_PRE_INIT_LINE  

	ld	ix,TRACK_Chan1
	call	replay_decode_chan
	ld	ix,TRACK_Chan2
	call	replay_decode_chan
	ld	ix,TRACK_Chan3
      call	replay_decode_chan
	ld	ix,TRACK_Chan4
	call	replay_decode_chan
	ld	ix,TRACK_Chan5
	call	replay_decode_chan
	ld	ix,TRACK_Chan6
	call	replay_decode_chan
	ld	ix,TRACK_Chan7
	call	replay_decode_chan
	ld	ix,TRACK_Chan8
	call	replay_decode_chan


      pop   bc
      ld    (replay_patpointer),bc   
      ei
      ret
	
;---------------------------
; IN: [HL] contains address of a pattern line to update in to audition line
;     Make sure the pattern data is active in page
replay_init_pre_lineupdate:
      ld    de,_PRE_INIT_LINE  
      ld    b,8
	;--- process current line chan data
_pe_chanloop:
      inc   hl                ; Skip note
      inc   de
	ld	a,(hl)		; Copy instrument
	and	a			; only overwrite if instr > 0
	jr.	z,99f
	ld	(de),a
99:
	inc	de
	inc	hl
	ld	a,(hl)		; Copy volume
      and   $f0		      ; only overwrite if there a volume
	jr.	z,99f		; if there is a volume 
      ld    (de),a
99:
	inc	hl
	inc	de
	inc	hl                ; Skip effect param
	inc	de
	djnz	_pe_chanloop
	ret
	

;===========================================================
; ---	replay_decode_chan
; Process the channel data
; 
; in BC is the pointer to the	data
;===========================================================
replay_decode_chan:
	;--- initialize data
	ld	a,(ix+TRACK_Note)
	ld	(replay_previous_note),a
	res	2,(IX+TRACK_Flags)		; Reset envelope

	;=============
	; Note 
	;=============
	ld	a,(bc)
	and	a
	jr.	z,_dc_noNote
	cp	97
	jr.	z,_dc_restNote	; 97 is a rest
	jr.	nc,_dc_noNote	; anything higher	than 97 are	no notes
	
	ld	(ix+TRACK_Note),a
	
	set	0,(ix+TRACK_Flags)	; set note trigger
;	res	4,(ix+TRACK_Flags)	; reset morph slave mode

_dc_noNote:	
	inc	bc
	;=============
	; Instrument
	;=============	
	ld	a,(bc)
	and	a
	jr.	z,_dc_noInstr
	;--- check current instrument
;	res	4,(ix+TRACK_Flags)	; reset morph slave mode
	
	cp	(ix+TRACK_Instrument)
	jr.	z,_dc_noInstr
	
	;--- instrument found
	set	5,(ix+TRACK_Flags)
	
	ld	(ix+TRACK_Instrument),a
	
	;--- set instrument pointer
	;!! This must get	faster	
	call	set_songpage_safe
	ld	de,INSTRUMENT_SIZE
	ld	hl,instrument_macros
0:
	add	hl,de
	dec	a
	jr.	nz,0b
	
	;--- Store the macro start
	ld	(ix+TRACK_MacroPointer),l
	ld	(ix+TRACK_MacroPointer+1),h
	
	;--- Set the waveform  (if needed)
	inc	hl
	inc	hl
	ld	a,(hl)
	cp	(ix+TRACK_Waveform)
	jr.	z,_dc_noNewWaveform
	
	;--- this is a new waveform
	ld	(ix+TRACK_Waveform),a
	set	_TRG_WAV,(ix+TRACK_Flags)
	res	4,(ix+TRACK_Flags)	; reset morph slave mode if waveform changes
	
_dc_noNewWaveform:	
	call	set_patternpage_safe
	
_dc_noInstr:
	inc	bc
	
	;=============
	; Volume
	;=============	
	ld	a,(bc)
	and	0xf0
	jr.	z,_dc_noVolume
	;--- Set new base	volume (high byte) but keep relative offset (low byte)
	ld	d,a
	ld	a,(ix+TRACK_Volume)
	and	0xf
	or	d
	ld	(ix+TRACK_Volume),a
	
_dc_noVolume:
	;=============
	; Command
	;=============
	ld	a,(bc)
	and	0x0f
	jr.	nz,99f
	;-- arpeggio of parameters is 0
	inc	bc
	ld	a,(bc)
	dec	bc
	and	a
	jr.	z,noCMDchange
	xor 	a
99:	    
;	ld	(ix+TRACK_Command),a
	ld	d,a			; Store command in d for later
	
	;--- Hack to disable commands > $f Otherwise it could crash
	cp	$10
	jr.	c,99f
	xor	a
99:									
	;--- calculate cmd address
	add	a
	ld	hl,_CHIPcmdlist
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	inc	bc
	ld	a,(bc)		; get	parameter(s)
	inc	bc
	jp	hl			; jump to the command
	; END

noCMDchange:
	; check for command 3 to continue
	ld	d,(IX+TRACK_Flags)
	bit 	0,d			; note trigger?
	jr.	z,99f
	bit 	3,d			; effect active
	jr.	z,99f
	
	ld	a,(ix+TRACK_Command)	; active effect is 3?
	cp	3				; tone portamento?
	jr.	z,.trigger
	cp 	5
	jr.	z,.trigger		; tone portamento + fade?
99:
	inc	bc
	inc	bc
	ret


.trigger:	
	;--- start new note but keep sliding to this new note
	res	0,d	; reset note trigger
	set	1,d   ; set note active
;	set   4,d   ; FM link active
	ld 	(IX+TRACK_Flags),d
	ld	a,(ix+TRACK_cmd_3)
	inc	bc
	inc	bc
	jr.	_CHPcmd3_newNote
	
	


;-------------------
; Rest the note
;===================
_dc_restNote:	
	res	1,(ix+TRACK_Flags)	; set	note bit to	0
	res	4,(ix+TRACK_Flags)	; reset morph slave mode

	ld	a,(replay_previous_note)
	ld	(ix+TRACK_Note),a
	jr.	_dc_noNote

AA_COMMANDS_decode:
_CHIPcmdlist:
	dw	_CHIPcmd0_arpeggio
	dw	_CHIPcmd1_portUp
	dw	_CHIPcmd2_portDown
	dw	_CHIPcmd3_portTone
	dw	_CHIPcmd4_vibrato
	dw	_CHIPcmd5
	dw	_CHIPcmd6_vibrato_vol
	dw	_CHIPcmd7_tremolo
	dw	_CHIPcmd8_env_low
	dw	_CHIPcmd9_env_high
	dw	_CHIPcmdA_volSlide
	dw	_CHIPcmdB_scc_commands
	dw	_CHIPcmdC_scc_morph
	dw	_CHIPcmdD_patBreak
	dw	_CHIPcmdE_extended
	dw	_CHIPcmdF_speed

_CHIPcmd0_arpeggio:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; Cycles between note, note+x	halftones, note+y
	; halftones. 
	; Ex:	(MOD/XM: C-4 01 .. 037)	This will play 
	; C-4, C-4+3 semitones andC-4+7 semitones. 
	; Note: if both x	and y	are zero, this command
	; is ignored. 


	;--- check for empty params (000 = no cmd	code)
	and	a
	ret	z
	;--- Init values
	ld	(ix+TRACK_Command),d
	ld	(ix+TRACK_cmd_0),a
	set	3,(ix+TRACK_Flags)
	ld	(ix+TRACK_Step),2
	ld	(ix+TRACK_Timer),0

	ret


_CHIPcmd1_portUp:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This will	slide	up the pitch of the current note
	; being played by	the given speed. 
	
	;--- test for retrigger	(do not update values)
	and	a
	jr.	z,_CHIPcmd_end
	ld	(ix+TRACK_Command),d
	ld	(ix+TRACK_cmd_1),a
	set	3,(ix+TRACK_Flags)
	ret
	
	 
_CHIPcmd2_portDown:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This will	slide	down the pitch of	the current	note
	; being played by	the given speed.	


	;--- test for retrigger	(do not update values)
	and	a
	jr.	z,_CHIPcmd_end
	ld	(ix+TRACK_Command),d
	ld	(ix+TRACK_cmd_2),a	
	set	3,(ix+TRACK_Flags)

	ret	
	
	
_CHIPcmd3_portTone:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This command is	used together with a note, and 
	; will bend	the current	pitch	at the given speed
	; towards the specified	note.	Example:
	;	C-4 1....
	;	F-4 ..305 (bend the note up towards	F-4)
	;	... ..300 (continue to slide up, until F-4
	;						  is reached

	;--- Init values
	set	3,(ix+TRACK_Flags)
	set	1,(ix+TRACK_Flags)
	and	a
	jr.	z,_CHIPcmd_end
	ld	(ix+TRACK_Command),d
	ld	(ix+TRACK_cmd_3),a
	ld	(ix+TRACK_Timer),2
		
;_CHIPcmd3_retrig:
	;--- Check if we have a	note on the	same event
	bit	0,(ix+TRACK_Flags)
	ret	z
	
	res	0,(ix+TRACK_Flags)
_CHPcmd3_newNote:
;	ld	a,(ix+TRACK_cmd_3)
	and	$7f				; reset deviation
	ex	af,af'			;'
	
	;-- get the	previous note freq
	ld	a,(replay_previous_note)
	add	a
	ld	hl,(replay_Tonetable);TRACK_ToneTable
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	e,(hl)
	inc	hl
	ld	d,(hl)

	; add	the toneadd
	ld	l,(ix+TRACK_cmd_ToneSlideAdd)
	ld	h,(ix+TRACK_cmd_ToneSlideAdd+1)

	add	hl,de	
	ex	de,hl				; store current freq in	[de]

	;--- get the current note freq
	ld	a,(ix+TRACK_Note)
	add	a
	ld	hl,(replay_Tonetable);TRACK_ToneTable
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a				; destination freq in [hl]
	
	;--- Calculate the delta
	xor	a
	ex	de,hl
	sbc	hl,de				; results in pos/neg delta
	
	ld	(ix+TRACK_cmd_ToneSlideAdd),l
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),h	

	ex	af,af'			;'
	bit	7,h
	jr.	nz,99f
	or 	128
99:
	ld 	(ix+TRACK_cmd_3),a
	ret


_CHIPcmd_end:
	res	3,(ix+TRACK_Flags)
	ret	

_CHIPcmd7_tremolo:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; Tremelo with speed x and depth y.	This command 
	; will oscillate the volume of the current note
	; with a sine wave.
	cp	$11
	jr.	c,_CHIPcmd_end
	
_CHIPcmd4_vibrato:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; Vibrato with speed x and depth y.	This command 
	; will oscillate the frequency of the current note
	; with a sine wave.
	;--- Init values
	and	a
	jr.	z,_CHIPcmd_end  ; <--- make this end effect
	ld	(ix+TRACK_Command),d
	rrca
	rrca
	rrca
	rrca
	ld	e,a
	
	;--- Set the speed
	and	$0f
	jr.	z,.depth 	; 0 -> no speed update
;	inc	a
	ld	(ix+TRACK_cmd_4_step),a	
	neg	
	ld	(ix+TRACK_Step),a	
	
.depth
	;-- set the depth
	ld	a,e
	and	$f0
	jr.	z,.end	; set depth when 0 only when command was not active.
;	bit 	3,(ix+TRACK_Flags)	
;	ld	a,16

99:	cp	$D0		; max 1-12
	jr.	c,99f
	ld	a,$C0
99:
	sub	16
	ld	hl,CHIP_Vibrato_sine
	add	a,a
	jr.	nc,99f
	inc	h
99:	
	add	a,l
	ld 	l,a
	jr.	nc,99f
	inc	h
99:
	ld	(ix+TRACK_cmd_4_depth),l
	ld	(ix+TRACK_cmd_4_depth+1),h
.end	set	3,(ix+TRACK_Flags)	
	
	ret
	
	

	
	

	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This command set the envelope frequency using a
	; multiplier value (00-ff)
_CHIPcmd8_env_low:
	ld	(AY_regEnvL),a
	ld	(envelope_period),a 
	ret	

	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This command set the envelope frequency using a
	; multiplier value (00-ff)
_CHIPcmd9_env_high:
	ld	(AY_regEnvH),a
	ld	(envelope_period+1),a 
	ret	

	
	 
;_CHIPcmd9_macro_offset:
;	; in:	[A] contains the paramvalue
;	; 
;	; ! do not change	[BC] this is the data pointer
;	;--------------------------------------------------
;	; This command, when used together with a	note,	
;	; will start playing the sample at the position	xx 
;	; (instead of position 0). If	xx is	00 (900), the 
;	; previous value will be used.
;
;	;--- Init values
;	and	a
;	jr.	z,_CHIPcmd_end
;	ld	(ix+TRACK_cmd_9),a
;;_CHIPcmd9_retrig:	
;	set	3,(ix+TRACK_Flags)
;	ld	(ix+TRACK_Timer),2		; timer is set as	we process cmd
;						; before new notes.
;	
;	ret
	


_CHIPcmd5:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; portTone	+ volumeslide
	;--- Init values
	;--- Check if we have a	note on the	same event
	and	a
	jr.	z,_CHIPcmd_end
	
	ld	(ix+TRACK_Command),d
	bit 	0,(ix+TRACK_Flags)
	jr.	z,_CHIPcmdA_volSlide_cont
	
	res	0,(ix+TRACK_Flags)

	ld	iyh,a
	ld	a,(ix+TRACK_cmd_3)
	call	_CHPcmd3_newNote

	ld	a,iyh
	jr. 	_CHIPcmdA_volSlide_cont
 
_CHIPcmd6_vibrato_vol:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
_CHIPcmdA_volSlide:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; slide the	volume up or down	1 step.
	; The	x or y param  set	the delay	(x=up,y=down)
	; With A00 the previous	value	is used.
	
	;--- test for retrigger	(do not update values)
	and	a
	jr.	z,_CHIPcmd_end
	ld	(ix+TRACK_Command),d
;	ld	(ix+CHIP_cmd_1),a

_CHIPcmdA_volSlide_cont:

	;--- neg or	pos
	cp	16
	jr.	c,.neg
	
.pos:
	;-- pos
	rra		; only use high 4	bits
	rra
	rra
	rra
	and	$0f
	ld	d,a
	ld	a,16
	sub	d
	jr.	99f

	
.neg:
	;-- neg
	ld	d,a
	ld	a,16
	sub	d	
	or	128
 
99:	ld	(ix+TRACK_cmd_A),a
	and	$0f
	ld	(ix+TRACK_Timer),a
;	
;_CHIPcmdA_retrig:
	;--- Init values
	set	3,(ix+TRACK_Flags)
	ret

;; Taken from http://www.massmind.org/techref/zilog/z80/part4.htm
;Divide:                          ; this routine performs the operation BC=HL/A
;  ld e,a                         ; checking the divisor; returning if it is zero
;  or a                           ; from this time on the carry is cleared
;  ret z
;  ld bc,-1                       ; BC is used to accumulate the result
;  ld d,0                         ; clearing D, so DE holds the divisor
;DivLoop:                         ; subtracting DE from HL until the first overflow
;  sbc hl,de                      ; since the carry is zero, SBC works as if it was a SUB
;  inc bc                         ; note that this instruction does not alter the flags
;  jr nc,DivLoop                  ; no carry means that there was no overflow
;  ret

_CHIPcmdB_auto_envelope:
	cp	$e0
	jr.	c,.correction
	cp	$f0
	jr.	c,.ratiotype
.ratio:
	and	$07
	ld	(envelope_ratio),a
	ret	

.ratiotype:
	and	$0f
	ld	(envelope_ratiotype),a
	ret	nz
	ld	de,(envelope_period)
	ld	(AY_regEnvL),de
	ret

.correction:
	cp	$20
	jr.	c,.cor_up
.cor_down:
	cp	$30
	ret 	nc
	and	$f
0:	
	ld	(envelope_correction),a
	xor	a
	ld	(envelope_correction+1),a	
	ret

.cor_up:
	cp	$11
	jr.	nc,99f
	xor	a
	jr.	0b
99:	
	and 	$f
	neg	
	ld	(envelope_correction),a
	ld	a,255
	ld	(envelope_correction+1),a
	ret

;	and	a
;	jr.	z,.skip_parameter
;
;	ld	d,a
;	;-- set new parameters
;	and	0x0f
;	ld	(auto_env_divide),a
;	ld	a,d
;[4]	srl	a	
;	ld	(auto_env_times),a
;
;.skip_parameter:
;	ld	hl,CHIP_ToneTable+96	;-- set base to C-5
;	ld	a,(IX+CHIP_Note)
;	add	a
;	add	a,l
;	ld	l,a
;	jr.	nc,99f
;	inc	h
;99:
;	push	bc
;	ld	e,(hl)
;	inc	hl
;	ld	d,(hl)
;	ld	hl,0
;	ld	a,(auto_env_times)
;	and	0x0f		; make sure it is at leas 1 or higher
;	jr.	nz,99f
;	inc	a
;99:
;	;--- now we add the base tone value x times 
;.timesloop:
;	add	hl,de
;	dec	a
;	jr.	nz,.timesloop
;
;	;--- now we do a divide over the result
;	ld	a,(auto_env_divide)
;	cp	2		; make sure divider is 1 minimal
;	jr.	nc,99f
;	;-- 0 and 1 then no devide needed
;	ld	(AY_regEnvL),hl
;	pop	bc
;	ret
;99:
;	call	Divide
;
;	;-- correct rounding
;	xor	a
;	adc	hl,de
;	ld	a,e
;	srl	a
;	cp	l
;	jr.	nc,99f
;	inc	bc
;99:
;	ld	(AY_regEnvL),bc
;	pop	bc
;	ret




_CHIPcmdB_scc_commands:
	;=== Check if this is a PSG channel.....
	bit 	_PSG_SCC,(ix+TRACK_Flags)
	jr.	z,_CHIPcmdB_auto_envelope
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; 
	ld	d,a	
	and	0xf0	; get	the extended comand

	cp	0x20
	jr.	c,_CHIPcmdB_setwave			; B0y - B1y is waveform set
;	jr.	z,_CHIPcmdB_cut				; waveform cut
	cp	0x30
	jr.	z,_CHIPcmdB_pwm				; Duty cycle waveform
;	cp	0x40
;	jr.	z,_CHIPcmdB_compress			; Compress waveform
	cp	0x50	
	jr.	z,_CHIPcmdB_soften			; soften waveform
	cp	0xe0
	jr.	z,_CHIPcmdB_reset				; reset to instrument waveform
	ret


_CHIPcmdB_soften:
	;=================
	; Waveform Soften
	;=================
	res	_TRG_WAV,(ix+TRACK_Flags)			; Waveform update
	res	_ACT_MOR,(ix+TRACK_Flags)			; Morph copy off

	;get the waveform	start	in [hl]
	ld	a,(ix+TRACK_Waveform)
	add	a,a
	add	a,a
	add	a,a	

	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	ld	de,_WAVESSCC
	add	hl,de	

	;get the waveform destination address in [DE]
	ld	de,_0x9800
	ld	a,iyh		;ixh contains chan#
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	iyl,32
.softloop:	
	ld	a,(hl)
	sra	a
	ld	(de),a
	dec	iyl
	ret	z
	inc	hl
	inc	de
	jr.	.softloop


	
_CHIPcmdB_reset:
	;--- retrigger the original waveform
	set	_TRG_WAV,(ix+TRACK_Flags)			; Waveform update
	res	_ACT_MOR,(ix+TRACK_Flags)			; Morph copy off

	;--- Look up the waveform form the instrument.
	ld	l,(ix+TRACK_MacroPointer)
	ld	h,(ix+TRACK_MacroPointer+1)
	inc	hl
	inc	hl
	ld	a,(hl)
	ld	(ix+TRACK_Waveform),a
	ret
	
_CHIPcmdB_pwm:	
	;=================
	; Waveform PWM / Duty Cycle
	;=================
	res	_TRG_WAV,(ix+TRACK_Flags)	; reset normal wave update
	res	_ACT_MOR,(ix+TRACK_Flags)
	;get the waveform	start	in [DE]
	ld	hl,_0x9800
	ld	a,iyh		;ixh contains chan#
;	rrca			; a mac value is 4 so
;	rrca			; 3 times rrca is	X32
;	rrca			; max	result is 128.
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:

	ld	e,$77	
	ld	a,d
	and	0x0f
	inc	a
	ld	d,a
	ld	a,32
	sub	d
_wspw_loop_h:
	ld	(hl),e
	inc	hl
	dec	d
	jr.	nz,_wspw_loop_h
	
;	and	a
;	ret	z
	
	ld	e,$87
	ld	d,a
_wspw_loop_l:
	ld	(hl),e
	inc	hl
	dec	d
	jr.	nz,_wspw_loop_l
	ret





_CHIPcmdB_cut:	
	ret



_CHIPcmdB_setwave:
	;--- Set a new waveform
	ld	a,d
	and	0x1f
4:	ld	(ix+TRACK_Waveform),a
	set	_TRG_WAV,(ix+TRACK_Flags)
	res	_ACT_MOR,(ix+TRACK_Flags)
	ret	


	
_CHIPcmdC_scc_morph:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;-----------/---------------------------------------
	ld	d,a
	and	0xf0
	cp	0x20
	jr.	c,.morph_init
	
	cp	0xC0
	jr.	z,.morph_slave

	cp	0xa0
	jr.	z,.sample

	cp	0xE0
	jr.	z,.morph_type

	cp	0xF0
	jr.	nc,.morph_speed
	ret

.sample:
	; Store sample number * 4
	ld	a,d
	and	0x0f
[2]	add	a						; Times 4 as sample pointer table record is 8 bytes


	;--- store this data as it is changed by set_patternpage
	push	bc
	ex	af,af'

	;--- Select sample data
	call	set_samplepage

	;--- pointer to the sample data init
	ex	af,af'
	ld	h,$80
	ld	l,a

	;--- store base tone
	ld	a,(hl)
	ld	(ix+TRACK_cmd_4_depth),a
	inc	hl
	ld	a,(hl)
	ld	(ix+TRACK_cmd_4_depth+1),a
	inc	hl

	;--- store waveform pointer
	ld	a,(hl)
	ld	(ix+TRACK_cmd_2),a
	inc	hl
	ld	a,(hl)
	ld	(ix+TRACK_cmd_3),a
;	inc	hl

	;--- reset tone offset
	xor	a
	ld	(ix+TRACK_cmd_ToneAdd),a
	ld	(ix+TRACK_cmd_ToneAdd+1),a

	;--- restore set_patternpage
	call	set_patternpage_safe
	pop	bc					; restore pointer

	; Reset Morph/note trig/active
;	res	_TRG_NOT,(ix+TRACK_Flags)
	res	_ACT_MOR,(ix+TRACK_Flags)
	set	_ACT_NOT,(ix+TRACK_Flags)
	set   _TRG_CMD,(ix+TRACK_Flags)

	ld	(ix+TRACK_Command),$1e
	ld	a,iyh
	ld	(ix+TRACK_Timer),a		; SCC waveform offset
	
	ret	

.morph_type:
	ld	a,d
	and	1
	ld	(replay_morph_type),a
	ret


.morph_slave:
	set	4,(ix+TRACK_Flags)
	ret

.morph_speed:
	ld	a,d
	and 	0x0f
	inc	a
	ld	(replay_morph_speed),a
	ret

.morph_init:
	;---- init new morph
	ld	a,d
	add	a
	add	a
	add	a
	ld	(replay_morph_waveform),a	; store dest form offset
	xor	a
	ld	(replay_morph_counter),a
	inc	a
	ld	(replay_morph_timer),a
	
	ld	a,(replay_morph_type)
	and	a
	jr.	z,.morph_continue
.morph_start
	ld	hl,_0x9800
	ld	a,iyh
	add	a,l
	ld	l,a
	jr.	nc,.morph_copy
	inc	h
	jr.	.morph_copy

.morph_continue:
	;--- Get the  the waveform address
	ld	a,(ix+TRACK_Waveform)
	add	a,a
	add	a,a
	add	a,a	

	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
		
	ld	de,_WAVESSCC
	add	hl,de
;	push	hl

.morph_copy:
	ld	de,replay_morph_buffer
	ld	a,32
44:
	ex	af,af'	;'
	ld	a,(hl)
;	ld	(de),a
	inc	de		; copy to value (skip delta value byte)
	ld	(de),a	
	inc	hl
	inc	de
	ex	af,af'	;'
	dec	a
	jr.	nz,44b

	;--- calculate the delta's	
	ld	a,255				; 255 triggers calc init
	ld	(replay_morph_active),a		
	set	4,(ix+TRACK_Flags)
	ret
	
_CHIPcmdD_patBreak:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This command will stop playing the current 
	; pattern and will jump	to the next	one in the 
	; order list (pattern sequence). 
	ld	a,64
	ld	(replay_line),a
	ret	
	
	
_CHIPcmdE_extended:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; Extended commands
	; Following	are supported:
	; 
	ld	d,a	
	;and	0xf0	; get	the extended comand
	rrca
	rrca
	rrca	
	and $1E
	
	ld	hl,_CHIPcmdExtended_List
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	hl
99:	
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	hl

_CHIPcmdExtended_List:
	dw	_CHIPcmdE_arpspeed		;0
	dw	_CHIPcmdE_fineup		;1
	dw	_CHIPcmdE_finedown	;2
	dw	_CHIPcmdE_none		;3
	dw	_CHIPcmdE_none		;4
	dw	_CHIPcmdE_notelink	;5
	dw	_CHIPcmdE_trackdetune	;6
	dw	_CHIPcmdE_none		;7
	dw	_CHIPcmdE_transpose	;8
	dw	_CHIPcmdE_none		;9
    
	dw	_CHIPcmdE_none		;A
	dw	_CHIPcmdE_none		;B
	dw	_CHIPcmdE_notecut		;C	
	dw	_CHIPcmdE_notedelay	;D	
	dw	_CHIPcmdE_none		;E
	dw	_CHIPcmdE_none		;F
	

_CHIPcmdE_none:
	ret
	
	
_CHIPcmdE_arpspeed:
	ld	a,d
	and	$0f
	ld	(replay_arp_speed),a
	ret	
	
	
;_CHIPE_noiseOR:
;	ld	a,d
;	ld	(AY_NoiseOR),a
;	ret
;_CHIPcmdE_noiseAND:
;	ld	a,d
;	ld	(AY_NoiseAND),a
;	ret
;
;_CHIPE_noiseAND:
;
;
;_CHIPcmdE_psgmode:
;	ld	a,d
;	and	1
;	ld	(psgmode),a
;	ret
;
;_CHIPcmdE_duty1:
;	ld	a,d
;	and	15
;	ld	(AY_duty1),a
;	ret
;_CHIPcmdE_duty2:
;	ld	a,d
;	and	15
;	ld	(AY_duty2),a
;	ret
;_CHIPcmdE_duty3:
;	ld	a,d
;	and	15
;	ld	(AY_duty3),a
;	ret





;_CHIPcmdE_shortarp:
;	ld	a,d			;- Get the parameter
;	and	0x0f
;;	jr.	z,_CHIPcmdE_shortarp_retrig	;-- Jump if value is 0
;
;	ld	(ix+TRACK_cmd_E),a		; store the halve not to add
;	ld	(ix+TRACK_Timer),0
;_CHIPcmdE_shortarp_retrig:
;	set	3,(ix+TRACK_Flags)		; command active		
;	ld	(ix+TRACK_Command),0x10
;	ret

_CHIPcmdE_notecut:
	set	3,(ix+TRACK_Flags)
	ld	(ix+TRACK_Command),0x1C		; set	the command#
	ld	a,d
	and	0x0f
	inc	a
	ld	(ix+TRACK_Timer),a		; set	the timer to param y
	ret
	
	
_CHIPcmdE_notedelay:
	bit	0,(ix+TRACK_Flags)		; is there a note	in this eventstep?
	ret	z				; return if	no note
	
	set	3,(ix+TRACK_Flags)		; command active
	ld	(ix+TRACK_Command),0x1D	; set	the command#
	ld	a,d
	and	0x0f
	inc	a
	ld	(ix+TRACK_Timer),a		; set	the timer to param y
	ld	a,(ix+TRACK_Note)
	ld	(ix+TRACK_cmd_E),a		; store the	new note
	ld	a,(replay_previous_note)
	ld	(ix+TRACK_Note),a		; restore the old	note
	res	0,(ix+TRACK_Flags)		; reset any	triggernote
	ret


_CHIPcmdE_fineup:
	ld	a,d
	and	0x0f
	ld	(ix+TRACK_cmd_E),a
	ld	(ix+TRACK_Timer),2
	set	3,(ix+TRACK_Flags)		; command active
	ld	(ix+TRACK_Command),0x11	; set	the command#
	ret

_CHIPcmdE_finedown:
	ld	a,d
	and	0x0f
	ld	(ix+TRACK_cmd_E),a
	ld	(ix+TRACK_Timer),2
	set	3,(ix+TRACK_Flags)		; command active
	ld	(ix+TRACK_Command),0x12	; set	the command#
	ret
	
_CHIPcmdE_notelink:
	res	0,(ix+TRACK_Flags)

	ret

_CHIPcmdE_trackdetune:
	ld	a,d
	; This comment sets the	detune of the track.
	and	0x07		; low	4 bits is value
	bit	3,d		; Center around 8
	jr.	z,99f
	inc	a
	neg			; make correct value
	ld	(ix+TRACK_cmd_detune),a
	ld	(ix+TRACK_cmd_detune+1),0xff
	ret
99:
	ld	(ix+TRACK_cmd_detune),a
	ld	(ix+TRACK_cmd_detune+1),0x00	
	ret
	
_CHIPcmdE_transpose:
	ld	a,d
	add	a
	ld	hl,TRACK_ToneTable;(replay_Tonetable)
	; This comment sets the	detune of the track.
	and	15		; low	4 bits is value
	bit	3,d		; Center around 8
	ld	d,0
	ld	e,a

	jr.	z,99f

;neg	
	xor	a
	sbc	hl,de
	ld	(replay_Tonetable),hl
	ret
; pos
99:	
	add	hl,de
	ld	(replay_Tonetable),hl
	ret




;_CHIPcmdE_envelopeauto:
;	ld	hl,TRACK_ToneTable
;
;	ld	a,d
;	and	0x07
;	jr.	z,0f
;
;	;--- parameter *12*2 (12 notes of 2 bytes)
;	add	a	
;	add	a 		; *4
;	ld	d,a
;	add	a 		; *8
;	add	d		; *8+*4 = *12
;	add	a		;  *24
;
;	add	a,l
;	ld	l,a
;	jr.	nc,99f
;	inc	h
;99:
;0:
;	;--- Add current note
;	ld	a,(ix+TRACK_Note)
;	;inc	a
;	add	a,a
;	add	a,l
;	ld	l,a
;	jr.	nc,99f
;	inc	h
;99:
;	ld	a,(hl)
;	ld	(AY_regEnvL),a
;	inc	hl
;	ld	a,(hl)
;	ld	(AY_regEnvH),a
;	ret






_CHIPcmdF_speed:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This command will set	the speed of the current 
	; song (Hex). Avoid using values bigger than 20,
	; for	better MOD/XM compatibility.
	;  
	
	;--- only for trakcer not replayer
	ld	d,a
	ld	a,(replay_mode)			; don't process speed for note autition
	cp	3
	ret	z
	ld	a,d
	call	set_songpage_safe			;<- only for tracker not replayer
	ld	(replay_speed),a
	call	set_patternpage_safe
	
	;--- Reset Timer == 0
	srl	a				; divide speed with 2
	ld	d,a
	ld	a,0				
	adc	a				; store carry of shift as subtimer
	ld	(replay_speed_subtimer),a
	add	a,d
	ld	(replay_speed_timer),a


	ret



;===========================================================
; ---replay_route
; Output the data	to the CHIP	registers
; 
; in HL is the current tone freq
;===========================================================
replay_process_chan_AY:
	push	hl

	;-- set the	mixer	right
	ld	hl,SCC_regMIXER
	srl	(hl)
	
	
;	ld	a,(current_song)
	call	set_songpage

	;===== 
	; Speed equalization check
	;=====
;	ld	a,(equalization_flag)			; check for speed equalization
;	and	a
;	jr.	nz,_pcAY_noNoteTrigger			; Only process instruments

	;=====
	; COMMAND
	;=====
	ld	(ix+TRACK_cmd_NoteAdd),0			; reset ARP. Make sure to do this outside the
								; equalization skip	
	bit	3,(ix+TRACK_Flags)
	jr.	z,_pcAY_noCommand
	

	ld	a,(ix+TRACK_Command)

	;--- Hack to disable commands > $24 Otherwise it might crash
	cp	$25
	jr.	c,99f
	xor	a
99:	
	add	a
	ld	e,a
	ld	d,0
	ld	hl,_pcAY_cmdlist			  
	add	hl,de
	
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a	
	jp	(hl)
	
_pcAY_noCommand:	
_pcAY_commandEND:

	;=====
	; Note
	;=====
	;--- Check if we need to trigger a new note
	bit	0,(ix+TRACK_Flags)
	jr.	z,_pcAY_noNoteTrigger
	
;	;--- Check for CMD Edx
;	bit	3,(ix+TRACK_Flags)
;	jr.	z,_pcAY_triggerNote
;	ld	a,0x1D		; Ed.
;	cp	(ix+TRACK_Command)
;	jr.	z,_pcAY_noNoteTrigger

_pcAY_triggerNote:	
	;--- get new Note
	res	0,(ix+TRACK_Flags)		; reset trigger note flag
	set	1,(ix+TRACK_Flags)		; set	note active	flag

	; init macrostep but check for cmd9
	xor	a
	ld	b,a
	bit	3,(ix+TRACK_Flags)
	jr.	z,99f
	ld	a,0x09		; Macro offset
	cp	(ix+TRACK_Command)
	jr.	nz,99f
	ld	b,(ix+TRACK_cmd_9)
99:	ld	(ix+TRACK_MacroStep),b

	ld	(ix+TRACK_ToneAdd),0
	ld	(ix+TRACK_ToneAdd+1),0
	ld	(ix+TRACK_VolumeAdd),0	
	ld	(ix+TRACK_cmd_ToneAdd),0
	ld	(ix+TRACK_cmd_ToneAdd+1),0
	ld	(ix+TRACK_cmd_VolumeAdd),0
	ld	(ix+TRACK_Noise),0
	ld	(ix+TRACK_cmd_ToneSlideAdd),0
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),0

_pcAY_noNoteTrigger:
	;Get note freq
	ld	a,(ix+TRACK_Note)
	add	a,(ix+TRACK_cmd_NoteAdd)
	add	a
	ex	af,af'			;'store the	note offset	
	

	;==============
	; Macro instrument
	;==============
	bit	1,(ix+TRACK_Flags)
	jr.	z,_pcAY_noNoteActive
	
;	;-- enable tone output
;	ld	a,(SCC_regMIXER)
;	or	16
;	ld	(SCC_regMIXER),a
 
	ld	(_SP_Storage),SP
	
	;--- Get the macro len and loop
	ld	l,(ix+TRACK_MacroPointer)
	ld	h,(ix+TRACK_MacroPointer+1)
	ld	sp,hl
	pop	de	;	set [E] = len
			;	set [D] = loop
			
	;--- Get the macro step	data		
	ld	a,(ix+TRACK_MacroStep)
	ld	b,a		; store the	step
	add	a,a
	add	a,a
	inc	a		; skip the waveform ;)
	ld	l,a
	ld	h,0
	add	hl,sp
	ld	sp,hl
	
	;--- Check for loop pos
	ld	a,b
	inc	a
	cp	e
	jr.	c,_pcAY_noMacroEnd
	ld	a,d		; loop the macro.

	;--- loop or not?
	cp	255
	jr.	nz,_pcAY_noMacroEnd
	res 	1,(ix+TRACK_Flags)	; disable note active
_pcAY_noMacroEnd:
	; tone deviation.
	ld	(ix+TRACK_MacroStep),a

	pop	bc		
	pop	hl		; tone deviation


	ld	e,(ix+TRACK_ToneAdd)	; get	the current	deviation	
	ld	d,(ix+TRACK_ToneAdd+1)


;--- Is tone active this step?
	bit	7,b		; do we have tone?
	jr.	z,_pcAY_noTone

	;-- enable tone output
	ld	a,(SCC_regMIXER)
	or	16
	ld	(SCC_regMIXER),a
	
	;--- base or add/minus
	bit	6,b		; deviation	type
	jr.	nz,_pcAY_Tminus
_pcAY_Tplus:
	add	hl,de		
	jr.	88f

_pcAY_Tminus:
	ex	de,hl
	xor	a
	sbc	hl,de
;	ex	de,hl
	
	
;_pcAY_noTbase:	
;	;-- minus the deviation	of the macro
;	ex	de,hl
;	xor	a
;	sbc	hl,de
;;	ex	de,hl
88:	
;_pcAY_tbase:	

	;--- Store new deviation
	ld	(ix+TRACK_ToneAdd),l
	ld	(ix+TRACK_ToneAdd+1),h
	
	ex	de,hl				; store macro deviation	in [DE]
_pcAY_noTone:
	ex	af,af'			;' get note	offset
	ld	sp,(replay_Tonetable)	;TRACK_ToneTable-2	; -2 as note 0 is	no note
	ld	l,a
	ld	h,0
	add	hl,sp
	ld	sp,hl
	pop	hl				; in HL note value
	add	hl,de				; add	deviation

	; set	the detune.
	ld	e,(ix+TRACK_cmd_detune)
	ld	d,(ix+TRACK_cmd_detune+1)
	add	hl,de

	ld	e,(ix+TRACK_cmd_ToneAdd)
	ld	d,(ix+TRACK_cmd_ToneAdd+1)
	add	hl,de
	ld	e,(ix+TRACK_cmd_ToneSlideAdd)
	ld	d,(ix+TRACK_cmd_ToneSlideAdd+1)
	add	hl,de
	
	
_pcAY_noCMDToneAdd:	
;_pcAY_noTone:	
	ld	sp,(_SP_Storage)
;	ex	(sp),hl		; replace the last pushed value on stack
	pop	de
	ex	de,hl

	bit	_PSG_SCC,(ix+TRACK_Flags)
	jr.	z,_pcAY_tonePSG
_pcAY_toneSCC:
	dec	de		; SCC tone is -1 of PSG tone
	ld	(hl),e
	inc	hl
	ld	(hl),d

_pcAY_Waveform:
	ld	a,01100000b
	and	c
	cp	00100000b
	jr.	nz,_pcAY_noNoise
	ld	a,0x1f
	and	c
	ld	(ix+TRACK_Waveform),a
	set	_TRG_WAV,(ix+TRACK_Flags)
	jr.	_pcAY_noNoise

	;--- PSG only code
_pcAY_tonePSG:
	ld	(hl),e
	inc	hl
	ld	(hl),d

;NOTE - DE register pair is used later on if there is an envelope active. Do not change DE from here till envelope code

_pcAY_Noise:
	;-- Test for noise
	bit	7,c
	jr.	z,_pcAY_noNoise
	; noise

	;--- Set the mixer for noise
	ld	a,(SCC_regMIXER)
	or	128
	ld	(SCC_regMIXER),a

	ld	l,(ix+TRACK_Noise)	; get	the current	deviation	
	ld	a,c
	and	0x1f
	ld	h,a

	;--- base or add/min
	bit	6,c
	jr.	nz,99f
	;--- base
	ld	l,0
99:
	bit	5,c
	jr.	z,99f
	;-- minus the deviation	of the macro
	ld	a,l
	sub	c	
	jr.	88f
99:	;--- Add the deviation
	ld	a,h
	add	l
88:	
	ld	(ix+TRACK_Noise),a
	ld	(AY_regNOISE),a
	
	

_pcAY_noNoise:
	;volume
	ld	a,b
	and	00110000b
	jr.	z,_pcay_volbase
	cp	00110000b
	jr.	z,_pcay_volsub
	cp	00100000b
	jr.	z,_pcay_voladd

_pcay_evelope:
	ld	a,16					; set volume to 16 == envelope
	ld	(SCC_regVOLE),a
	ld	a,b
	and	0x0f
	ld	(AY_regEnvShape),a		; set the new envelope shape

	;--- Envelope sync type
	ld	a,(envelope_ratiotype)
	cp	1
	ret	c
	jr.	z,_ratio_chan_env

_ratio_env_chan:
	ld	a,(envelope_ratio)
	and	a
	jr.	z,_ratio_chan_env_skip

	ex	de,hl
_ratio_env_chan_loop:
	add	hl,hl
	dec	a
	jr.	nz,_ratio_env_chan_loop	

	ex	de,hl

	ld	b,(hl)
	ld	(hl),d
	dec	hl
	ld	c,(hl)
	ld	(hl),e
	;--- Correction
	ld	hl,(envelope_correction)
	add	hl,bc
	ld	(AY_regEnvL),hl
	ret

_ratio_chan_env:
	ld	a,(envelope_ratio)
	and	a
	jr.	z,_ratio_chan_env_skip

_ratio_chan_env_loop:
	SRL 	D
	RR 	E
	dec	a
	jr.	nz,_ratio_chan_env_loop	

	;--- correction
	ld	hl,(envelope_correction)
	add	hl,de

_ratio_chan_env_skip:
	ld	(AY_regEnvL),hl
	ret


_pcay_volbase:
	ld	a,b
	and	0x0f
	jr.	_pcay_volend

_pcay_voladd:
	ld	a,b
	and	$0f
	ld	b,a
	ld	a,(ix+TRACK_VolumeAdd)
	add	b
	cp	16
	jr.	c,_pcay_volend
	ld	a,15
	jr.	_pcay_volend

_pcay_volsub:
	ld	a,b
	and	$0f
	ld	b,a
	ld	a,(ix+TRACK_VolumeAdd)
	sub	b
	cp	16
	jr.	c,_pcay_volend
	xor	a
_pcay_volend:
	ld	(ix+TRACK_VolumeAdd),a
	or	(ix+TRACK_Volume)
	ld	c,a
	
	; This part is only for tremolo
	
	ld	b,(IX+TRACK_cmd_VolumeAdd)	
;	rla						; C flag contains devitation bit (C flag was reset in the previous OR)
;	jr.	c,_sub_Vadd
;_add_Vadd:
;	add	a,c
;	jr.	nc,_Vadd
;	ld	a,c
;	or	0xf0
;	jr.	_Vadd
;_sub_Vadd:
;	ld	b,a
;	xor	a
;	sub	b
;	ld	b,a
;	ld	a,c
	sub	a,b
	jr.	nc,_Vadd
	ld	a,c
	and	0x0f	
	;-- next is _Vadd
_Vadd:
	;--- apply main volume balance
	ld	hl,replay_mainvol
	CP	(HL)
	jr.	C,88F
	sub	(hl)
	jr.	99f
88:	xor	a
99:	
	ld	l,a
	ld	h,0
	; Test which CHIP.
	bit	7,(ix+TRACK_Flags)
	jr.	nz,99f
	ld	de,AY_VOLUME_TABLE
	jr.	88f
99:
	ld	de,SCC_VOLUME_TABLE
88:
	add	hl,de
	ld	a,(hl)	
	ld	(SCC_regVOLE),a
	
	ret
	

_pcAY_noNoteActive:
	pop	hl
	xor	a
	ld	(SCC_regVOLE),a
	
	ret
	
	
AA_COMMANDS_process:	
_pcAY_cmdlist:
	dw	_pcAY_cmd0		; arpeggio
	dw	_pcAY_cmd1
	dw	_pcAY_cmd2
	dw	_pcAY_cmd3
	dw	_pcAY_cmd4		; vibrato
	dw	_pcAY_cmd5
	dw	_pcAY_cmd6
	dw	_pcAY_cmd7
	dw	_pcAY_cmd8
	dw	_pcAY_cmd9
	dw	_pcAY_cmda
	dw	_pcAY_cmdb
	dw	_pcAY_cmdc
	dw	_pcAY_cmdd
	dw	_pcAY_cmde		; should never trig. but >0x10 values
	dw	_pcAY_cmdf
	dw	_pcAY_cmd10 
	dw	_pcAY_cmd11	; fineup	
	dw	_pcAY_cmd12 ; finedown
	dw	_pcAY_cmd13	
	dw	_pcAY_cmd14		
	dw	_pcAY_cmd15
	dw	_pcAY_cmd16	
	dw	_pcAY_cmd17		
	dw	_pcAY_cmd18
	dw	_pcAY_cmd19	; none
	dw	_pcAY_cmd1a		
	dw	_pcAY_cmd1b
	dw	_pcAY_cmd1c	
	dw	_pcAY_cmd1d_delay		
	dw	_pcAY_cmd1e_sample
;	dw	_pcAY_cmd1f	
;	dw	_pcAY_cmd20
;	dw	0			;_pcAY_cmd21
;	dw	_pcAY_cmd22
;	dw	_pcAY_cmd23
;	dw	_pcAY_cmd24
;	dw	_pcAY_cmd25
			
_pcAY_cmd0:
	ld	a,(IX+TRACK_Timer)
	and	a
	jr.	z,.nextNote

	dec	a
	ld	(IX+TRACK_Timer),a
	ld	a,(ix+TRACK_Step)
	and	a
	jr.	z,99f
	ld	a,(IX+TRACK_cmd_0)
	and	$0f
	ld	(ix+TRACK_cmd_NoteAdd),a	
	jr.	_pcAY_commandEND
99:
	ld	(ix+TRACK_cmd_NoteAdd),0	
	jr.	_pcAY_commandEND


.nextNote:
	; re-init the speed.
	ld	a,(replay_arp_speed)
	ld	(IX+TRACK_Timer),a
	
	ld	a,(ix+TRACK_Step)
	and	a
	jr.	nz,99f

	;--- set x
		ld	(ix+TRACK_Step),1
		ld	a,(ix+TRACK_cmd_0)
		rlca
		rlca
		rlca
		rlca		
		ld	(ix+TRACK_cmd_0),a	
		and	$0f
		ld	(ix+TRACK_cmd_NoteAdd),a
		jr.	_pcAY_commandEND
	
99:
	dec	a
	jr.	nz,99f

	;--- set y
		ld	(ix+TRACK_Step),2
		ld	a,(ix+TRACK_cmd_0)
		rlca
		rlca
		rlca
		rlca		
		ld	(ix+TRACK_cmd_0),a			
		and	0x0f
		jr.	nz,0f
		;--- if zero then skip this note and set step to start
		ld	(ix+TRACK_Step),0
0:		
		ld	(ix+TRACK_cmd_NoteAdd),a	
		jr.	_pcAY_commandEND
	
99:
	;--- set none
	ld	(ix+TRACK_Step),0
	ld	(ix+TRACK_cmd_NoteAdd),0		
	jr.	_pcAY_commandEND
	
	
	
_pcAY_cmd1:
	ld	a,(ix+TRACK_cmd_1)
	ld	b,a
	ld	a,(ix+TRACK_cmd_ToneSlideAdd)
	sub	b
	ld	(ix+TRACK_cmd_ToneSlideAdd),a
	jr.	nc,_pcAY_commandEND
	dec	(ix+TRACK_cmd_ToneSlideAdd+1)
	jr.	_pcAY_commandEND
	
_pcAY_cmd2:
	ld	a,(ix+TRACK_cmd_2)
	ld	b,a
	ld	a,(ix+TRACK_cmd_ToneSlideAdd)
	add	b
	ld	(ix+TRACK_cmd_ToneSlideAdd),a
	jr.	nc,_pcAY_commandEND
	inc	(ix+TRACK_cmd_ToneSlideAdd+1)
	jr.	_pcAY_commandEND


_pcAY_cmd3:
	ld	a,(ix+TRACK_cmd_3)
	ld	l,(ix+TRACK_cmd_ToneSlideAdd)
	ld	h,(ix+TRACK_cmd_ToneSlideAdd+1)
	bit	7,a
	jr.	nz,_pcAY_cmd3_sub
_pcAY_cmd3_add:
	;pos slide
	add	a,l
	ld	(ix+TRACK_cmd_ToneSlideAdd),a
	jr.	nc,99f
	inc	h	
99:	bit	7,h
	jr.	z,_pcAY_cmd3_stop			; delta turned pos ?
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),h
	jr.	_pcAY_commandEND
_pcAY_cmd3_sub:
	;negative slide	
	and	$7f	  
	ld	c,a
	xor	a
	ld	b,a
	sbc	hl,bc
	bit	7,h
	jr.	nz,_pcAY_cmd3_stop			; delta turned neg ?
	ld	(ix+TRACK_cmd_ToneSlideAdd),l
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),h
	jr.	_pcAY_commandEND
_pcAY_cmd3_stop:	
	res	3,(ix+TRACK_Flags)
	ld	(ix+TRACK_cmd_ToneSlideAdd),0
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),0	
	jr.	_pcAY_commandEND


	;-- vibrato	
_pcAY_cmd4:
	ld	l,(ix+TRACK_cmd_4_depth)
	ld	h,(ix+TRACK_cmd_4_depth+1)	
	
	;--- Get next step
	ld	a,(IX+TRACK_Step)
	add	(ix+TRACK_cmd_4_step)
	and	$3F			; max	64
	ld	(ix+TRACK_Step),a
	
	bit	5,a			; step 32-63 the neg	
	jr.	z,.pos	
	
.neg:
	and	$1f	; make it 32 steps again
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	neg
	jr.	z,.zero			; $ff00 gives strange result ;)	
	ld	(ix+TRACK_cmd_ToneAdd),a
	ld	(ix+TRACK_cmd_ToneAdd+1),0xff
	jr.	_pcAY_commandEND	

.pos:
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
.zero:	
	ld	(ix+TRACK_cmd_ToneAdd),a
	ld	(ix+TRACK_cmd_ToneAdd+1),0
	jr.	_pcAY_commandEND	

_pcAY_cmd5:
	call	_pcAY_cmdasub
	jr.	_pcAY_cmd3
	



_pcAY_cmd6:
	call	_pcAY_cmdasub
	jr.	_pcAY_cmd4		



	;-- Tremelo
_pcAY_cmd7:
	ld	l,(ix+TRACK_cmd_4_depth)
	ld	h,(ix+TRACK_cmd_4_depth+1)	
	
	;--- Get next step
	ld	a,(IX+TRACK_Step)
	add	(ix+TRACK_cmd_4_step)
	and	$3F			; max	64
	ld	(ix+TRACK_Step),a
	sra 	a	; divide the step with 2
	
;	bit	5,a			; step 32-63 the neg	
;	jr.	z,.pos	
	
.neg:
	and	$1f	; make it 32 steps again
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	sla	a
	sla	a	
	sla	a
	sla	a
;	jr.	z,.zero			; $ff00 gives strange result ;)
;	or 	128				; set the neg bit
;.zero:
	ld	(ix+TRACK_cmd_VolumeAdd),a
	jr.	_pcAY_commandEND		
;.pos:
;	add	a,l
;	ld	l,a
;	jr.	nc,99f
;	inc	h
;99:
;	ld	a,(hl)
;	sla	a
;	sla	a	
;	sla	a
;	or 128
;;.zero:	
;	ld	(ix+CHIP_cmd_VolumeAdd),a
;	jr.	_pcAY_commandEND	





_pcAY_cmd8:
;	res	3,(ix+TRACK_Flags)
	jr.	_pcAY_commandEND
_pcAY_cmd9:
	dec	(ix+TRACK_Timer)
	jr.	nz,_pcAY_commandEND
	res	3,(ix+TRACK_Flags)
	jr.	_pcAY_commandEND



_pcAY_cmda:
	;retrig
	call	_pcAY_cmdasub
	jr.	_pcAY_commandEND

_pcAY_cmdasub
	dec	(ix+TRACK_Timer)
;	jr.	nz,_pcAY_cmd3
	ret	nz
		
	; vol	slide
	ld	a,(ix+TRACK_cmd_A)
	ld	d,a
	and	0x7f
	ld	(ix+TRACK_Timer),a
	ld	a,(ix+TRACK_Volume)
	bit	7,d
	jr.	z,.inc
.dec:
	and	a
	ret	z
	sub	$10
	ld	(ix+TRACK_Volume),a
	ret
.inc:
	cp	$F0
	ret	nc
	add	$10
	ld	(ix+TRACK_Volume),a
	ret
	
	


_pcAY_cmdb:
	
;	jr.	_pcAY_commandEND
_pcAY_cmdc:
;	res	3,(ix+TRACK_Flags)
;	jr.	_pcAY_commandEND
_pcAY_cmdd:
;	;call	replay_setnextpattern
;	ld	a,64
;	ld	(replay_line),a
;	res	3,(ix+TRACK_Flags)
	jr.	_pcAY_commandEND
	
_pcAY_cmde:
;	res	3,(ix+TRACK_Flags)
	jr.	_pcAY_commandEND
_pcAY_cmdf:
;	res	3,(ix+TRACK_Flags)
	jr.	_pcAY_commandEND
;--- SHORT ARP
_pcAY_cmd10:
	dec	(ix+TRACK_Timer)
	bit	0,(ix+TRACK_Timer)
	jr.	z,_pcAY_commandEND
	ld	a,(ix+TRACK_cmd_E)
	ld	(ix+TRACK_cmd_NoteAdd),a		
	jr.	_pcAY_commandEND
	
	
_pcAY_cmd11:
	ld	a,(ix+TRACK_cmd_E)
	ld	(ix+TRACK_cmd_ToneSlideAdd),a
	xor	a
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),a
	jr.	_pcAY_commandEND	

_pcAY_cmd12:
	ld	a,(ix+TRACK_cmd_E)
	ld	(ix+TRACK_cmd_ToneSlideAdd),a
	ld	a,$ff
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),a
	jr.	_pcAY_commandEND	

_pcAY_cmd13:
;	res	3,(ix+TRACK_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd14:
;	res	3,(ix+TRACK_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd15:
_pcAY_cmd16:
_pcAY_cmd17:
_pcAY_cmd18:
	jr.	_pcAY_commandEND	
_pcAY_cmd19:
	;retrig
	dec	(ix+TRACK_Timer)
	jr.	nz,_pcAY_commandEND
	
	; retrig note
	ld	a,(ix+TRACK_cmd_E)
	ld	(ix+TRACK_Timer),a
	set	0,(ix+TRACK_Flags)
	
	jr.	_pcAY_commandEND	
_pcAY_cmd1a:
	jr.	_pcAY_commandEND	
_pcAY_cmd1b:
	jr.	_pcAY_commandEND	
_pcAY_cmd1c:
	dec	(ix+TRACK_Timer)
	jr.	nz,_pcAY_commandEND
	
	; stop note
	res	1,(ix+TRACK_Flags)	; set	note bit to	0
	res	3,(ix+TRACK_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd1d_delay:
	; note delay
	dec	(ix+TRACK_Timer)
	jr.	nz,_pcAY_commandEND	; no delay yet

	; trigger note
	ld	a,(ix+TRACK_cmd_E)		
	ld	(ix+TRACK_Note),a		; set	the note val
	set	0,(ix+TRACK_Flags)		; set	trigger note flag
	res	3,(ix+TRACK_Flags)		; reset tiggger cmd flag
	
	jr.	_pcAY_commandEND	


;----------------------------------
; Play sample
;----------------------------------
_pcAY_cmd1e_sample:
	;---- Test for release
	bit 	_ACT_NOT,(ix+TRACK_Flags)
	jr.	z,.stop

	;--- Select Sample data bank
	call	set_samplepage

	;---- Test for note
	bit	_TRG_NOT,(ix+TRACK_Flags)
	jr.	z,.skipnote
.note:
	;--- get current note value
	ld	hl,TRACK_ToneTable		; transpose not working for samples
	ld	a,(ix+TRACK_Note)
	add	a
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l,(ix+TRACK_cmd_4_depth)
	ld	h,(ix+TRACK_cmd_4_depth+1)	
	xor	a
	ex	de,hl
	sbc	hl,de
	ld	(ix+TRACK_cmd_ToneAdd),l
	ld	(ix+TRACK_cmd_ToneAdd+1),h
	ex	de,hl
	jr.	.cont

.skipnote:
	ld	e,(ix+TRACK_cmd_ToneAdd)
	ld	d,(ix+TRACK_cmd_ToneAdd+1)	
.cont:
	;--- Period update
	ld	l,(ix+TRACK_cmd_2)
	ld	h,(ix+TRACK_cmd_3)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,$ff
	cp	b
	jr.	z,.stop

	inc	hl
	ld	(ix+TRACK_cmd_2),l
	ld	(ix+TRACK_cmd_3),h
	push	bc
	pop	hl
	add	hl,de

	pop	de			; tone address is still on stack
	ex	de,hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	;--- Volume
	; Use track volume as reference.
	ld	a,(ix+TRACK_Volume)
	and	0xf0
	or	a,$0f
	ld	de,SCC_VOLUME_TABLE
	ld	l,a
	ld	h,0
	add	hl,de
	ld	a,(hl)	
	ld	(SCC_regVOLE),a

	;-- enable tone output
	ld	a,(SCC_regMIXER)
	or	16
	ld	(SCC_regMIXER),a
	

	;--- Waveform update
	ld	l,(ix+TRACK_cmd_2)
	ld	h,(ix+TRACK_cmd_3)
	ld	de,_0x9800	
	ld	a,(ix+TRACK_Timer)
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	bc,32
	ldir
	ld	(ix+TRACK_cmd_2),l
	ld	(ix+TRACK_cmd_3),h	

	call	set_patternpage_safe
	ret	

.stop:
	;--- End found
	res	_TRG_CMD,(ix+TRACK_Flags)
	set	_TRG_WAV,(ix+TRACK_Flags)		; to restore the old waveform
	ld	(SCC_regVOLE),a		; A is still 0
	call	set_patternpage_safe
	pop	hl					; tone address was still on stack.
	ret
	

	
;===========================================================
; ---replay_route
; Output the data	to the CHIP	registers
; 
; WILL DISABLE INTERRUPTS !!!!
;===========================================================
replay_route:
;---------------
; P S	G 
;---------------
	ld	a,(replay_mode)
	cp	2
	jr.	z,99f

	;--- Apply the mixer.
	ld	a,(MainMixer)
	ld	b,a
	xor	a
	bit	5,b
	jr.	nz,0f
	;-- chan 1 off
	ld	(AY_regVOLA),a
0:	
	bit	6,b
	jr.	nz,0f
	;-- chan 2 off
	ld	(AY_regVOLB),a
0:
	bit	7,b
	jr.	nz,0f
	;-- chan 3 off
	ld	(AY_regVOLC),a
0:
99:
	;--- Push values to AY HW
	ld	a,(psgport)
	ld	c,a
	ld	hl,AY_registers
      ld    b,$ff
      xor   a
_comp_loop:	
      ;--- write low with $ff (avoid clipping)
      out   (c),a
      inc   c
      out   (c),b
      dec   c
      ;--- store the low byte
      ld	e,(hl)
      inc   hl
      ;--- write high byte
      ld    d,(hl)
      inc   hl
      inc   a
	out	(c),a
	inc	c
	out	(c),d
      dec   c
      dec   a
      ;--- write low byte
	out	(c),a
	inc	c
	out	(c),e
      dec   c
      add   2
	cp	6
	jr.	nz,_comp_loop
	
_ptAY_loop:
	out	(c),a
	inc	c
	outi
	dec	c
	inc	a
	cp	13
	jr	nz,_ptAY_loop

99:	
	ld	a,(AY_regEnvShape)
	and	a
	jr.	z,_ptAY_noEnv
	
	ld	b,13
	out	(c),b
	inc	c
	out 	(c),a

	xor	a
	ld	(AY_regEnvShape),a	;reset the envwrite
	
	
_ptAY_noEnv:
scc_route:
;--------------
; S C	C 
;--------------
	;--- Apply the mixer.
	ld	hl,SCC_regMIXER
	;--- do not	apply	mmainmixer when in  mode 2
	ld	a,(replay_mode)
	cp	2
	jr.	z,99f
	ld	a,(MainMixer)
	and	(hl)	; set	to 0 to silence
	ld	(hl),a
99:
	;--- Set the waveforms
	ld	hl,TRACK_Chan4+TRACK_Flags
	bit	_TRG_WAV,(hl)
	jr.	z,0f
	;--- set wave form
	res	_TRG_WAV,(hl)
	ld	a,(TRACK_Chan4+TRACK_Waveform)
	ld	de,_0x9800
	call	_write_SCC_wave
0:
	ld	hl,TRACK_Chan5+TRACK_Flags
	bit	_TRG_WAV,(hl)
	jr.	z,0f
	;--- set wave form
	res	_TRG_WAV,(hl)
	ld	a,(TRACK_Chan5+TRACK_Waveform)
	ld	de,_0x9820
	call	_write_SCC_wave
0:
	ld	hl,TRACK_Chan6+TRACK_Flags
	bit	_TRG_WAV,(hl)
	jr.	z,0f
	;--- set wave form
	res	_TRG_WAV,(hl)
	ld	a,(TRACK_Chan6+TRACK_Waveform)
	ld	de,_0x9840
	call	_write_SCC_wave
0:
	ld	hl,TRACK_Chan7+TRACK_Flags
	bit	_TRG_WAV,(hl)
	jr.	z,0f
	;--- set wave form
	res	_TRG_WAV,(hl)
	ld	a,(TRACK_Chan7+TRACK_Waveform)
	ld	de,_0x9860
	call	_write_SCC_wave
0:

	ld	a,(SCC_slot)			; Recuperamos el slot
	ld	h,0x80
	call enaslt
 
	ld	bc,16
	ld	de,_0x9880
	ld	hl,SCC_registers
	ldir

	call scc_reg_update


	ld	a,(mapper_slot)				; Recuperamos el slot
	ld	h,0x80
	call enaslt



	ret	




			
scc_reg_update:

	ld  a,03Fh				; enable SCC
	ld  (0x9000),a

	;--- deformation register
	ld hl,oldregs
	ld de,newregs
	ld bc,0x9800
	ld a,32*4+3*5+1
loop:

	ex af,af'	;'
	ld a,(de)
	cp (hl)
	jr z,1f
	ld (hl),a	     ; update old	registers in ram
	ld (bc),a	     ; update scc	registers
1:	    
	inc hl
	inc de
	inc bc
	ex af,af'		;'
	dec a
	jr nz, loop
	ret

	
	
;==================
; _write_SCC_wave
;
; Writes waveform	data.	[DE] contains location for data
; [A]	contains waveform	number + flags for special actions
; Data is not written to SCC but into RAM	shadow registers.
;==================
_write_SCC_wave:
	bit	4,(hl)
	jr.	nz,_write_SCC_special
	add	a,a
	add	a,a
	add	a,a	

	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
		
	ld	  bc,_WAVESSCC
	add	  hl,bc
	ld	  bc,32
	ldir

	ret


_write_SCC_special:
	ld	hl,replay_morph_buffer+1
	ld	b,32
_wss_l:
	ld	a,(hl)
	ld	(de),a
	inc	hl
	inc	hl
	inc	de
	djnz	_wss_l
	 
	
	ret



	
	
	





draw_SCCdebug:		
	; THIS IS DEBUG INFO ON	THE REGISTERS!!!!
	ld	de,_TEMPSCC+1
	ld	hl,SCC_registers
	ld	a,(hl)
	ld	b,a
	inc	hl
	ld	a,(hl)
	call	draw_hex
	ld	a,b
	call	draw_hex2
	inc	hl
	inc	de
	inc	de
	
	ld	a,(hl)
	ld	b,a
	inc	hl
	ld	a,(hl)
	call	draw_hex
	ld	a,b
	call	draw_hex2
	inc	hl
	inc	de
	inc	de

	ld	a,(hl)
	ld	b,a
	inc	hl
	ld	a,(hl)
	call	draw_hex
	ld	a,b
	call	draw_hex2
	inc	hl
	inc	de
	inc	de
	
	ld	a,(hl)
	ld	b,a
	inc	hl
	ld	a,(hl)
	call	draw_hex
	ld	a,b
	call	draw_hex2
	inc	hl
	inc	de
	inc	de	
	
	ld	a,(hl)
	ld	b,a
	inc	hl
	ld	a,(hl)
	call	draw_hex
	ld	a,b
	call	draw_hex2
	inc	hl
	inc	de
	inc	de
	
	ld	a,(hl)
	call	draw_hex	;vol a
	inc	hl
	inc	de
	ld	a,(hl)
	call	draw_hex	    ;vol b
	inc	hl
	inc	de
	ld	a,(hl)
	call	draw_hex	    ;vol c
	inc	hl
	inc	de
	ld	a,(hl)
	call	draw_hex	    ;vol d
	inc	hl
	inc	de
	ld	a,(hl)
	call	draw_hex	;vol e
;	inc	hl
	inc	de	

	inc	de
	inc	hl
	ld	a,(hl)
	call	draw_hex2	; mixer 
	inc	hl	
;	inc	de
;	inc	de

	

	
	ld	hl,41
	ld	de,_TEMPSCC
	ld	b,39;44
	call	draw_label_fast					


	ret
	
;=============
; in [A] the morph active status	
replay_process_morph:
	ld	hl,replay_morph_timer
	dec	(hl)
	ret	nz
	
	;---- not sure what to do with this.
	; trigger any waveform updates
	ld	b,4
	ld	de,TRACK_REC_SIZE
	ld	hl,TRACK_Chan4+TRACK_Flags
10:	
	bit 	4,(hl)
	jr.	z,99f
	set	_TRG_WAV,(hl)
99:
	add	hl,de
	djnz	10b	
	
	
	;---- timer ended.
	inc	a
	jr.	nz,_rpm_next_step		; if status was !=255 then skip init

	;---- calculate offset
	inc	a		
	ld	(replay_morph_active),a		; set status to 1
;	ld	(replay_morph_update),a		; after this update the waveforms of the SCC

	ld	a,(replay_morph_speed)
	ld	(replay_morph_timer),a
	

	;--- calculate the delta's
	ld	de,_WAVESSCC
	ld	a,(replay_morph_waveform)
	ld	l,a
	ld	h,0	
	add	hl,hl
	add	hl,hl	
	add	hl,de
	ld	de,replay_morph_buffer

	;---- start calculating
	ld	b,32		; 32 values
_rpm_loop:	
	inc	de
	ld	a,(de)
	dec	de
	add	a,128					; Make all values negative for easier calculations
	ld	c,a
	ld	a,(hl)
	add	a,128					; Make all values negative for easier calculations
	cp	c
	jr.	c,_rpm_smaller			; dest is smaller

	
_rpm_larger:
	sub	c					; calculate the difference
	rrca						; Rotate to get in lower bits the value to add/sub eacht set_patternpage_safe
	rrca						; and in upper 3 bits when to add/sub extra in relation to replay_morph_counter
	rrca
	rrca
	and	$ef		; reset bit 5
	ld	(de),a
	
	inc	de
	inc	de
	inc	hl
	djnz	_rpm_loop
	ret	
	
_rpm_smaller:
	sub	c
	neg	
	rrca
	rrca
	rrca
	rrca
	or	$10		; set bit 5
	ld	(de),a
	
	inc	de
	inc	de
	inc	hl
	djnz	_rpm_loop
	ret		
	
;============================
_rpm_next_step:
	ld	a,(replay_morph_speed)
	ld	(replay_morph_timer),a

	;-- apply the delta's
	ld	a,(replay_morph_counter)
	ld	c,a
	add	16
	ld	(replay_morph_counter),a
	jr.	nz,99f
	;--- end morph
	ld	(replay_morph_active),a

99:
	dec 	c
	ld	hl,replay_morph_buffer
	ld	b,32
_rpm_ns_loop:	
	ld	a,(hl)
	bit 	4,a
	jr.	z,_rmp_ns_add
_rmp_ns_sub:
	;--- handle corection
	and	$ef
	cp	c		; correction < counteR?
	jr.	c,99f
	inc	a		; if smaller C was set
99:
;	xor	00010000b	; inverse add/sub bit when >15
	and	00011111b	; keep lower 5 bits
;	neg	
	inc	hl
	ld	d,a
	ld	a,(hl)
	sub	d
;	add	(hl)		; subtract waveform value
	ld	(hl),a	; load new value
	inc	hl
	djnz	_rpm_ns_loop
	ret	
_rmp_ns_add:
	;--- handle corection
	cp	c		; correction < counteR?
	jr.	c,99f
	inc	a		; if smaller C was set
99:
	and	00011111b	; keep lower 5 bits
	inc	hl
	add	(hl)		; subtract waveform value
	ld	(hl),a	; load new value
	inc	hl
	djnz	_rpm_ns_loop
	ret		
	




	
	
REPLAY_END: