FM_WRITE:	equ	0x7c	; port to set fm reg nr.
FM_DATA:	equ	0x7d	; port to set fm data for reg

;================================
; The new replayer.
;
;
;
;================================

DRM_DEFAULT_values:
	; values taken from XAK3 intro. Used the most used values as default
;	db	01111110b		; 0,1,2 = volume, 5,6,7 = freq
	dw	0x04E4			; Bass drum
	dw	0x0000
	db	0x00			; vol
	db	0xff
	dw	0x0120			; Snare + HiHat
	dw	0x0000
	db	0x00			; vol
	db	0xff
	dw	0x00AB			; Cymbal + TomTom
	dw	0x0000
	db	0x00			; vol
	db	0x00
	

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
	;--- process thechannels (tracks)
	;xor	a
	;ld	(AY_regMIXER),a	;set mixer to silence
	;--- Set the tone table base
	ld	hl,CHIP_ToneTable
	ld	(replay_Tonetable),hl

	ld	ix,CHIP_Chan1
	call	replay_decode_chan
	ld	ix,CHIP_Chan2
	call	replay_decode_chan


	;--- check if next is PSG  or FM
	ld	a,(replay_chan_setup)
	and	$01
	jr.	nz,_rdd_3psg
	
	ld	hl,(replay_FM_tonetable)
	ld	(replay_Tonetable),hl


_rdd_3psg:	

	ld	ix,CHIP_Chan3
	call	replay_decode_chan
	
	;--- check if previous was PSG  or FM
	ld	a,(replay_chan_setup)
	and	$01
	jr.	z,_rdd_2psg
	
	ld	hl,CHIP_FM_ToneTable
	ld	(replay_Tonetable),hl
	
	
_rdd_2psg:		

	ld	ix,CHIP_Chan4
	call	replay_decode_chan
	ld	ix,CHIP_Chan5
	call	replay_decode_chan
	ld	ix,CHIP_Chan6
	call	replay_decode_chan
	ld	ix,CHIP_Chan7
	call	replay_decode_chan
	ld	ix,CHIP_Chan8
	call	replay_decode_chan

	;--- store the pointer
	ld	(replay_patpointer),bc

	;ret
		
;===========================================================
; ---	replay_decodedata_NO
; Process changes.
; 
; 
;===========================================================
replay_decodedata_NO:
	; do what is needed when there is no new data
	ld	hl,(replay_PSG_tonetable)
	ld	(replay_Tonetable),hl

	xor	a
	ld	(FM_regMIXER),a
	ld	a,(mainPSGvol)
	ld	(replay_mainvol),a
IFDEF TTSMS
	ld	(SN_regVOLN),a
	ld	(AY_regVOLA),a
	ld	(AY_regVOLB),a
	ld	(AY_regVOLC),a
	ld	a,(replay_chan_setup)
	xor	1				; 0 = only 2 psg so start at 1
	ld	iyh,a				; for panning contains chan#
ENDIF	

	ld	ix,CHIP_Chan1
	ld	hl,AY_regToneA
	call	replay_process_chan_AY
	ld	a,(FM_regVOLF)
	ld	(AY_regVOLA),a	
	ld	(_VU_VALUES+0),a
IFDEF TTSMS
	;--- for channel mute
	ld	a,(SN_regVOLN)
	ld	(SN_regVOLNA),a
	inc	iyh
ENDIF

	ld	ix,CHIP_Chan2
	ld	hl,AY_regToneB	
	call	replay_process_chan_AY
	ld	a,(FM_regVOLF)
	ld	(AY_regVOLB),a
	ld	(_VU_VALUES+1),a
IFDEF TTSMS
	;--- for channel mute
	ld	a,(SN_regVOLN)
	ld	(SN_regVOLNB),a
	inc	iyh
ENDIF
	

	ld	a,(replay_chan_setup)
	and	$01
	jr.	z,_rdd_2psg_6fm

_rdd_3psg_5fm:
	; =======================================
	;--- Play chan 3 over PSG
	; =======================================
	ld	ix,CHIP_Chan3
	ld	hl,AY_regToneC	
	call	replay_process_chan_AY
	ld	a,(FM_regVOLF)
	ld	(AY_regVOLC),a	
	ld	(_VU_VALUES+2),a

	ld	a,(FM_regMIXER)
	srl	a
	srl	a
	;srl	a
	;srl	a	
	xor	0x3f
	ld	(AY_regMIXER),a		; save the mixer
	xor	a
	ld	(FM_regMIXER),a
	ld	a,(mainSCCvol)
	ld	(replay_mainvol),a		; setup volume for FM

	xor	a			; reset the mixer
	ld	(FM_regMIXER),a

	ld	hl,(replay_FM_tonetable)
	ld	(replay_Tonetable),hl
	
	jr.	_rdd_cont

	
_rdd_2psg_6fm:	
	; =======================================
	;--- Play chan 3 over FM
	; =======================================
	ld	a,(FM_regMIXER)		; correct the mixer
	srl	a
	srl	a
	srl	a		

	xor	0x3f
	ld	(AY_regMIXER),a		; save the mixer
	ld	a,(mainSCCvol)
	ld	(replay_mainvol),a		; setup volume for FM

	xor	a			; reset the mixer
	ld	(FM_regMIXER),a

	ld	hl,(replay_FM_tonetable)
	ld	(replay_Tonetable),hl
	
	ld	ix,CHIP_Chan3
	ld	hl,FM_regToneA	
	call	replay_process_chan_AY
	ld	a,(FM_regVOLF)
	ld	(_VU_VALUES+2),a
	ld	b,(ix+CHIP_Voice)		; Add voice to volume
	or 	b
	ld	(FM_regVOLA),a
	
_rdd_cont:					; used for waveform updates
	ld	ix,CHIP_Chan4
	ld	hl,FM_regToneB	
	call	replay_process_chan_AY
	ld	a,(FM_regVOLF)
	ld	(_VU_VALUES+3),a
	ld	b,(ix+CHIP_Voice)		; Add voice to volume
	or 	b
	ld	(FM_regVOLB),a	

;	inc	iyh
	
	ld	ix,CHIP_Chan5
	ld	hl,FM_regToneC
	call	replay_process_chan_AY
	ld	a,(FM_regVOLF)
	ld	(_VU_VALUES+4),a
	ld	b,(ix+CHIP_Voice)		; Add voice to volume
	or 	b
	ld	(FM_regVOLC),a

		
	ld	ix,CHIP_Chan6
	ld	hl,FM_regToneD	
	call	replay_process_chan_AY
	ld	a,(FM_regVOLF)
	ld	(_VU_VALUES+5),a
	ld	b,(ix+CHIP_Voice)		; Add voice to volume
	or 	b
	ld	(FM_regVOLD),a	


	ld	ix,CHIP_Chan7
	ld	hl,FM_regToneE	
	call	replay_process_chan_AY
	ld	a,(FM_regVOLF)
	ld	(_VU_VALUES+6),a
	ld	b,(ix+CHIP_Voice)		; Add voice to volume
	or 	b
	ld	(FM_regVOLE),a	


	ld	ix,CHIP_Chan8
	ld	hl,FM_regToneF	
	call	replay_process_chan_AY
	ld	a,(FM_regVOLF)
	ld	b,(ix+CHIP_Voice)		; Add voice to volume
	ld	(_VU_VALUES+7),a
	or 	b
	ld	(FM_regVOLF),a

	call	replay_process_drum
	
	ld	a,1
	ld	(_VU_UPDATE),a


	;call	processMainMixer
	




IFDEF TTSMS	
;--- Silence the Noise on SN7 if needed.
NoiseMixer:	
	;------ 
	; Handle noise on muted channels
	;------
	ld	a,(replay_mode)
	cp	2
	ret	z


	ld	a,(MainMixer)
	ld	b,a
	ld	a,(AY_regMIXER)
	ld	c,a
	
.chanC:	
	bit 5,c	; noise on chan3?
	jr.	nz,.chanB
	bit 7,b	; chan enabled?
	ret	nz
.silence
	xor	a
	ld	(SN_regVOLN),a
	ret

.chanB:
	bit 4,c	; noise on chan2?
	jr.	nz,.chanA
	bit 6,b	; noise enabled?
	jr.	z,.silence
	ld	a,(SN_regVOLNB)
	ld	(SN_regVOLN),a
	ret
.chanA:
	bit 3,c	; noise on chan1?
	ret	nz
	bit 5,b
	jr.	z,.silence
	ld	a,(SN_regVOLNA)
	ld	(SN_regVOLN),a
	
ENDIF	
	
	ret	
	
	






;===========================================================
; ---	replay_setpattern
; Process changes.
; 
; 
;===========================================================
replay_setnextpattern:
	;-- get new	page
;	ld	a,(current_song)
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

IFDEF TTSMS
	; init GG panning
	ld	a,$ff
	ld	(GG_panning),a
ENDIF
	;--- Get the start speed.
	ld	a,(song_speed)
	ld	(replay_speed),a
	ld	a,1
	ld	(replay_speed_timer),a
	dec	a
	ld	(replay_speed_subtimer),a
	ld	(replay_mode),a	
	ld	(replay_arp_speed),a

	;--- Erase channel data	in RAM
;	xor	a
	ld	bc,(CHIP_REC_SIZE*8)-1
	ld	hl,CHIP_Chan1
	ld	de,CHIP_Chan1+1
	ld	(hl),a
	ldir
	
;	;--- Set vibrato table
;	ld	hl,CHIP_Vibrato_sine
;	ld	(replay_vib_table),hl
	
	;--- Set the tone table base
	ld	hl,TRACK_ToneTable
	ld	(replay_PSG_tonetable),hl
	ld	hl,CHIP_FM_ToneTable
	ld	(replay_FM_tonetable),hl


	;--- Silence the chips
	ld	a,0x3f
	ld	(AY_regMIXER),a
	xor	a
	ld	(FM_regMIXER),a
	ld	(AY_regVOLA),a
	ld	(AY_regVOLB),a	
	ld	(AY_regVOLC),a
IFDEF	TTSMS
	ld	(SN_regVOLN),a
ENDIF	
;	;--- Init the SCC	(waveforms too)
;	ld	h,0x80
;	call enaslt
	
	ld	a,1*16
	ld	(CHIP_Chan3+CHIP_Voice),a
	ld	(CHIP_Chan4+CHIP_Voice),a
	ld	(CHIP_Chan5+CHIP_Voice),a
	ld	(CHIP_Chan6+CHIP_Voice),a	
	ld	(CHIP_Chan7+CHIP_Voice),a	
	ld	(CHIP_Chan8+CHIP_Voice),a
	ld	a,255
	ld	(replay_softvoice),a
	ld	a,128
	ld	(CHIP_Chan3+CHIP_Flags),a
	ld	(CHIP_Chan4+CHIP_Flags),a
	ld	(CHIP_Chan5+CHIP_Flags),a
	ld	(CHIP_Chan6+CHIP_Flags),a	
	ld	(CHIP_Chan7+CHIP_Flags),a	
	ld	(CHIP_Chan8+CHIP_Flags),a	
	
	;--- Check if there are 3 psg chans.
	ld	a,(replay_chan_setup)
	and	$01
	jr.	z,99f
	xor 	a
	ld	(CHIP_Chan3+CHIP_Flags),a	
99:
		
	xor	a
	ld	(FM_DRUM_LEN),a
	ld	(FM_DRUM),a
	
	call	replay_route
	ei
	
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

	; end	is here
	ret



;--- Very basic pre-scan. Old one was WAY too slow.
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

;      ;--- Get the data from the curent line of the current pattern
;	pop	af                            ; Restore the pattern line in a
;	and	a
;	jr.	z,99f
;      ;--- Calculate the offset in the pattern for the pattern line
;	ld	de,32       
;88:
;	add	hl,de
;	dec	a
;	jr.	nz,88b		
;0:
;      call  replay_init_pre_lineupdate      

;99:
;--- Process the instuments and volumes in the audition line.
      ld    bc,(replay_patpointer)
      push  bc
      ld	bc,_PRE_INIT_LINE  

	ld	ix,CHIP_Chan1
	call	replay_decode_chan
	ld	ix,CHIP_Chan2
	call	replay_decode_chan
	ld	ix,CHIP_Chan3
      call	replay_decode_chan
	ld	ix,CHIP_Chan4
	call	replay_decode_chan
	ld	ix,CHIP_Chan5
	call	replay_decode_chan
	ld	ix,CHIP_Chan6
	call	replay_decode_chan
	ld	ix,CHIP_Chan7
	call	replay_decode_chan
	ld	ix,CHIP_Chan8
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
	jr.	z,99f		      ; if there is a volume 
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
	ld	a,(ix+CHIP_Note)
	ld	(replay_previous_note),a
	res	2,(IX+CHIP_Flags)		; Reset envelope

	;=============
	; Note 
	;=============
	ld	a,(bc)
	and	a
	jr.	z,_dc_noNote
	cp	97
	jr. 	c,0f
	jr.	z,_dc_restNote	; 97 is a rest
	cp	99
	jr. 	z,_dc_vol0note	; set track volume to 0
	jr.	c,_dc_sustainNote	; 98 is a rest	
	jr.	nc,_dc_noNote	; anything higher	than 97 are	no notes
	
0:	
	ld	(ix+CHIP_Note),a
	set	0,(ix+CHIP_Flags)		; bit0=1 ; trigger a note
	set	4,(ix+CHIP_Flags)		; set key for FM
;	res	3,(ix+CHIP_Flags)		; reset running command

_dc_noNote:	
	inc	bc
	;=============
	; Instrument
	;=============	
	ld	a,(bc)
	and	a
	jr.	z,_dc_noInstr
	;--- check current instrument
	cp	(ix+CHIP_Instrument)
	jr.	z,_dc_noInstr
	
	;--- instrument found
;	set	5,(ix+CHIP_Flags)
	ld	(ix+CHIP_Instrument),a
		
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
	ld	(ix+CHIP_MacroPointer),l
	ld	(ix+CHIP_MacroPointer+1),h

	;-- test for PSG
	bit	7,(ix+CHIP_Flags)
	jr.	z,.voice0	; No update for PSG
	;--- Set the waveform  (if needed)
	inc	hl
	inc	hl
	ld	a,(hl)
	and	a
	jr.	z,.voice0
	cp	16
	jr.	c,.skip_soft
	
	;---- Check if voice is different than current
	ld	d,a
	ld	a,(replay_softvoice)
	cp	d
	jr.	nz,.getins
	;--- already loaded so set voice 0
	xor	a
	jr.	z,.zero
	;--- (pre)load the softvoice values
.getins:
	ld	a,d
	ld	(replay_softvoice),a
	ld	(replay_voicetrigger),a
	;--- Pre-load_softwarevoice 
	sub	16
	ld	h,0
	ld	l,a
	;--- times 8
	add	hl,hl
	add	hl,hl	
	add	hl,hl
	ld	de,_VOICES
	add	hl,de

	;--- Copy new values
	ld	de,FM_Voicereg
	ld	a,8
	push	bc		; safe pointer to data
.loop:
	ldi
	inc	de
	dec	a
	jr.	nz,.loop

	pop	bc		; restore pointer to data
      jr.    .zero
	
.skip_soft:
	rla	
	rla
	rla	
	rla
	and 	$f0
.zero:
	ld	(ix+CHIP_Voice),a
;	set	6,(ix+CHIP_Flags)
.voice0		
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
	ld	a,(ix+CHIP_Volume)
	and	0xf
	or	d
	ld	(ix+CHIP_Volume),a
	
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
	;--- only for tracker. fix in compiler
	; SWAP cmd 1 and 2 for FM
	bit	7,(ix+CHIP_Flags)
	jr.	z,99f
	cp	3
	jr.	nc,99f
	cp	2
	jr.	nz,88f
	ld	a,1
	jr.	99f
88:	cp	1
	jr.	nz,99f
	ld	a,2	
	
99:	
;	ld	(ix+CHIP_Command),a
	ld	d,a			; Store command in d for later

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
	ld	d,(IX+CHIP_Flags)
	bit 	0,d			; note trigger?
	jr.	z,99f
	bit 	3,d			; effect active
	jr.	z,99f
	ld	a,(ix+CHIP_Command)	; active effect is 3?
	cp	3				; tone portamento?
	jr.	z,.trigger
	cp 	5
	jr.	nz,99f			; tone portamento + fade?
.trigger:	
	;--- start new note but keep sliding to this new note
	res	0,d	; reset note trigger
	set	1,d   ; set note active
	set   4,d   ; FM link active
	ld 	(IX+CHIP_Flags),d
	ld	a,(ix+CHIP_cmd_3)
	inc	bc
	inc	bc
	jr.	_CHPcmd3_newNote
	
	
99:
	inc	bc
	inc	bc
	ret


;-------------------------
; Set volume to 0
;=========================
_dc_vol0note:
	ld	a,(ix+CHIP_Volume)
	and	0x0f
	ld	(ix+CHIP_Volume),a
	jr.	99f


;-------------------
;  Sustain the note
;===================
_dc_sustainNote:	
;	res	1,(ix+CHIP_Flags)	; set	note bit to	0
	res	4,(ix+CHIP_Flags)	; release key
	set	5,(ix+CHIP_Flags)	; sustain
	jr.	99f

;-------------------
; Rest the note
;===================
_dc_restNote:	
	res	1,(ix+CHIP_Flags)	; set	note bit to	0
	res	4,(ix+CHIP_Flags)	; release key
	res	5,(ix+CHIP_Flags)	; sustain
99:	
;	xor	a
	ld	a,(replay_previous_note)
	ld	(ix+CHIP_Note),a
	jr.	_dc_noNote

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
	dw	_CHIPcmdB_auto_envelope
	dw	_CHIPcmdC_drum
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
	;--- Init value
	ld	(ix+CHIP_Command),d
	ld	(ix+CHIP_cmd_0),a
	set	3,(ix+CHIP_Flags)
	ld	(ix+CHIP_Step),2
	ld	(ix+CHIP_Timer),0

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
	ld	(ix+CHIP_Command),d
	ld	(ix+CHIP_cmd_1),a
	set	3,(ix+CHIP_Flags)
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
	ld	(ix+CHIP_Command),d
	ld	(ix+CHIP_cmd_2),a	

	set	3,(ix+CHIP_Flags)
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
	set	3,(ix+CHIP_Flags)
	set	1,(ix+CHIP_Flags)
	and	a
	jr.	z,_CHIPcmd_end
	ld	(ix+CHIP_Command),d
	ld	(ix+CHIP_cmd_3),a
	ld	(ix+CHIP_Timer),2
;		
;_CHIPcmd3_retrig:
	;--- Check if we have a	note on the	same event
	bit 	0,(ix+CHIP_Flags)
	ret	z
	
	set	4,(ix+CHIP_Flags)		; FM notelink bit
	res	0,(ix+CHIP_Flags)
_CHPcmd3_newNote:
;	ld	a,(ix+CHIP_cmd_3)
	and	$7f				; reset deviation
	ex	af,af'			;'
	
	;-- get the	previous note freq
	ld	a,(replay_previous_note)
	add	a
	ld	hl,(replay_Tonetable);CHIP_ToneTable
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	e,(hl)
	inc	hl
	ld	d,(hl)

	; add	the toneadd
	ld	l,(ix+CHIP_cmd_ToneSlideAdd)
	ld	h,(ix+CHIP_cmd_ToneSlideAdd+1)

	add	hl,de	
	ex	de,hl				; store current freq in	[de]
	;--- get the current note freq
	ld	a,(ix+CHIP_Note)
	add	a
	ld	hl,(replay_Tonetable);CHIP_ToneTable
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
;	;-- set previous note to be able to slide over new notes.
;	ld	a,(replay_previous_note)
;	ld	(ix+CHIP_Note),a
	
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a				; destination freq in [hl]
	
	;--- Calculate the delta
	xor	a
	ex	de,hl
	sbc	hl,de				; results in pos/neg delta
	
	ld	(ix+CHIP_cmd_ToneSlideAdd),l
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),h	

	ex	af,af'			;'
	bit	7,h
	jr.	nz,99f
	or 	128
99:
	ld 	(ix+CHIP_cmd_3),a
	ret


_CHIPcmd_end:
	res	3,(ix+CHIP_Flags)
	ret	

_CHIPcmd7_tremolo:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; Tremolo with speed x and depth y.	This command 
	; will oscillate the volume of the current note
	; with a sine wave.
	cp	$11
	jr.	c,_CHIPcmd_end
;	ld	(ix+CHIP_Command),d
	
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
	ld	(ix+CHIP_Command),d
	rrca
	rrca
	rrca
	rrca
	ld	e,a
	
	;--- Set the speed
	and	$0f
	jr.	z,.depth 	; 0 -> no speed update
;	inc	a
	ld	(ix+CHIP_cmd_4_step),a	
	neg	
	ld	(ix+CHIP_Step),a	
	
.depth
	;-- set the depth
	ld	a,e
	and	$f0
	jr.	z,.end	; set depth when 0 only when command was not active.
;	bit 	3,(ix+CHIP_Flags)	
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
	ld	(ix+CHIP_cmd_4_depth),l
	ld	(ix+CHIP_cmd_4_depth+1),h
.end	set	3,(ix+CHIP_Flags)	
	
	ret


	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This command set the envelope frequency using a
	; multiplier value (00-ff)
_CHIPcmd8_env_low:
	ld	(AY_regEnvL),a
	ret	

	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This command set the envelope frequency using a
	; multiplier value (00-ff)
_CHIPcmd9_env_high:
	ld	(AY_regEnvH),a
	ret	


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
	
	ld	(ix+CHIP_Command),d
	bit 	0,(ix+CHIP_Flags)
	jr.	z,_CHIPcmdA_volSlide_cont
	
	set	4,(ix+CHIP_Flags)		; FM notelink bit
	res	0,(ix+CHIP_Flags)

	ld	iyh,a
	ld	a,(ix+CHIP_cmd_3)
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
	ld	(ix+CHIP_Command),d
	
	
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
99:	ld	(ix+CHIP_cmd_A),a
	and	$0f
	ld	(ix+CHIP_Timer),a
;	
;_CHIPcmdA_retrig:
	;--- Init values
	set	3,(ix+CHIP_Flags)
	ret


; Taken from http://www.massmind.org/techref/zilog/z80/part4.htm
Divide:                          ; this routine performs the operation BC=HL/A
  	ld 	e,a                         ; checking the divisor; returning if it is zero
  	or 	a                           ; from this time on the carry is cleared
  	ret	z
  	ld 	bc,-1                       ; BC is used to accumulate the result
  	ld 	d,0                         ; clearing D, so DE holds the divisor
DivLoop:                         ; subtracting DE from HL until the first overflow
  	sbc 	hl,de                      ; since the carry is zero, SBC works as if it was a SUB
  	inc 	bc                         ; note that this instruction does not alter the flags
  	jr 	nc,DivLoop                  ; no carry means that there was no overflow
  	ret

_CHIPcmdB_auto_envelope:
IFDEF TTFM
	and	a
	jr.	z,.skip_parameter

	ld	d,a
	;-- set new parameters
	and	0x0f
	ld	(auto_env_divide),a
	ld	a,d
[4]	srl	a	
	ld	(auto_env_times),a

.skip_parameter:
	ld	hl,CHIP_ToneTable+96	;-- set base to C-5
	ld	a,(IX+CHIP_Note)
	add	a
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	push	bc
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,0
	ld	a,(auto_env_times)
	and	0x0f		; make sure it is at leas 1 or higher
	jr.	nz,99f
	inc	a
99:
	;--- now we add the base tone value x times 
.timesloop:
	add	hl,de
	dec	a
	jr.	nz,.timesloop

	;--- now we do a divide over the result
	ld	a,(auto_env_divide)
	cp	2		; make sure divider is 1 minimal
	jr.	nc,99f
	;-- 0 and 1 then no devide needed
	ld	(AY_regEnvL),hl
	pop	bc
	ret
99:
	call	Divide

	;-- correct rounding
	xor	a
	adc	hl,de
	ld	a,e
	srl	a
	cp	l
	jr.	nc,99f
	inc	bc
99:
	ld	(AY_regEnvL),bc
	pop	bc
	ret
ENDIF
	
_CHIPcmdC_drum:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	cp	MAX_DRUMS		;- only 20 drum macros allowed
	ret	nc

	and	a
;	ret	z			; B00 does nothing
	jr.	nz,0f

	push	bc
	;--- DRUM default values
	ld	de,DRUM_regToneBD
	ld	hl,DRM_DEFAULT_values
	ld	bc,18
	ldir
	pop	bc
	ret
0:	
	;--- Set the song page
	call	set_songpage_safe
	;--- location in RAM
	ld	hl,drum_macros	
	ld	de,DRUMMACRO_SIZE
88:
	add	hl,de
	dec	a
	jr.	nz,88b

	;--- drum len
	ld	de,FM_DRUM_LEN
	ld	a,(hl)
	ld	(de),a
	
	;--- store pointer to macro data
	inc	de			; now points to the macro pointer in ram
	inc	hl
	ex	de,hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	
	call	set_patternpage_safe
	ret
	





_CHIPcmdD_patBreak:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This command will stop playing the current 
	; pattern and will jump	to the next	one in the 
	; order list (pattern sequence). 
	;set	3,(ix+CHIP_Flags)
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
	inc	h
99:	
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	hl

_CHIPcmdExtended_List:
	dw	_CHIPcmdE_arpspeed	;0
	dw	_CHIPcmdE_fineup		;1
	dw	_CHIPcmdE_finedown	;2
	dw	_CHIPcmdE_none		;3
	dw	_CHIPcmdE_none		;4
	dw	_CHIPcmdE_notelink	;5
	dw	_CHIPcmdE_trackdetune	;6
	dw	_CHIPcmdE_none		;7
	dw	_CHIPcmdE_transpose	;8
	dw	_CHIPcmdE_none	;9
	dw	_CHIPcmdE_none		;A
	dw	_CHIPcmdE_brightness	;B
	dw	_CHIPcmdE_notecut		;C	
	dw	_CHIPcmdE_notedelay	;D	
	dw	_CHIPcmdE_none	;E
	dw	_CHIPcmdE_none		;F

_CHIPcmdE_none:
	ret

IFDEF TTSMS

_panning_masks:
	db	11101110b	; chan1
	db	11011101b	; chan2
	db	10111011b	; chan3
	db	01110111b	; noise
_paning_values:
	db	00000000b	; silent
	db	00010000b	; left
	db	00000001b   ; right
	db	00010001b	; stereo
	db	00000000b	; silent
	db	00100000b	; left
	db	00000010b   ; right
	db	00100010b	; stereo
	db	00000000b	; silent
	db	01000000b	; left
	db	00000100b   ; right
	db	01000100b	; stereo
	db	00000000b	; silent
	db	10000000b	; left
	db	00001000b   ; right
	db	10001000b	; stereo
	
_CHIPcmdE_tonepanning:
	;--- get mask
	ld	a,iyh		; contains channel nr
_cmdep_cont:	
	ld	iyl,a	
	ld	hl,_panning_masks
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	e,(hl)	; store mask in e
	
	;--- Get parameter
	ld	a,d
	and	$0f
	ld	d,a	
	
	;--- get value
	ld 	hl,_paning_values
	ld	a,iyl
	add	a,a
	add	a,a
	add	a,d
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc 	h
99:
	ld	d,(hl)	; store value in d
	
	;--- Apply values
	ld	a,(GG_panning)
	and	e			; erase current bits
	or	d			; set new bits
	ld	(GG_panning),a
	ret

_CHIPcmdE_noisepanning:
	; init
	ld	a,3	
	jr.	_cmdep_cont	

ELSE

_CHIPcmdE_noisepanning:
_CHIPcmdE_tonepanning:
	ret
ENDIF



_CHIPcmdE_arpspeed:
	ld	a,d
	and	$0f
	ld	(replay_arp_speed),a
	ret

_CHIPcmdE_brightness:
	ld	a,d
	; This comment sets the	detune of the track.
	and	0x07		; low	4 bits is value
	ret	z		;jr.	z,.set
	ld (replay_voicetrigger),a

	bit	3,d		; Center around 8
	jr.	z,.add
.sub:
	ld	d,a
	ld	a,(FM_Voicereg+4)
	ld	e,a
;	and	00111111b
	sub	d
	and	00111111b
	jr.	.set
.add:
	ld	d,a
	ld	a,(FM_Voicereg+4)
	ld	e,a
;	and	00111111b
	add	d
	and	00111111b
.set:
	ld	d,a
	ld	e,a
	and	11000000b
	or	d
	ld	(FM_Voicereg+4),a
	ret

_CHIPcmdE_notecut:
	set	3,(ix+CHIP_Flags)
	ld	(ix+CHIP_Command),0x1C		; set	the command#
	ld	a,d
	and	0x0f
	inc	a
	ld	(ix+CHIP_Timer),a		; set	the timer to param y
	ret
	
_CHIPcmdE_notedelay:
	bit	0,(ix+CHIP_Flags)		; is there a note	in this eventstep?
	ret	z				; return if	no note
	
	set	3,(ix+CHIP_Flags)		; command active
	ld	(ix+CHIP_Command),0x1D	; set	the command#
	ld	a,d
	and	0x0f
	inc	a
	ld	(ix+CHIP_Timer),a		; set	the timer to param y
	ld	a,(ix+CHIP_Note)
	ld	(ix+CHIP_cmd_E),a		; store the	new note
	ld	a,(replay_previous_note)
	ld	(ix+CHIP_Note),a		; restore the old	note
	res	0,(ix+CHIP_Flags)		; reset any	triggernote
	ret

_CHIPcmdE_fineup:
	ld	a,d
	and	0x0f
	ld	(ix+CHIP_cmd_E),a
	ld	(ix+CHIP_Timer),2
	set	3,(ix+CHIP_Flags)		; command active
	ld	(ix+CHIP_Command),0x11	; set	the command#
	ret

_CHIPcmdE_finedown:
	ld	a,d
	and	0x0f
	neg
	ld	(ix+CHIP_cmd_E),a
	ld	(ix+CHIP_Timer),2
	set	3,(ix+CHIP_Flags)		; command active
	ld	(ix+CHIP_Command),0x12	; set	the command#
	ret

_CHIPcmdE_notelink:
	set	4,(ix+CHIP_Flags)		; FM notelink bit
	res	0,(ix+CHIP_Flags)
	ret
	

_CHIPcmdE_trackdetune:
	ld	a,d
	; This comment sets the	detune of the track.
	and	0x07		; low	4 bits is value
	bit	3,d		; Center around 8
	jr.	z,99f
	inc	a
	neg			; make correct value
	ld	(ix+CHIP_cmd_detune),a
	ld	(ix+CHIP_cmd_detune+1),0xff
	ret
99:
	ld	(ix+CHIP_cmd_detune),a
	ld	(ix+CHIP_cmd_detune+1),0x00	
	ret
	
_CHIPcmdE_transpose:
	ld	a,d
	add	a
	; This comment sets the	detune of the track.
	and	15		; low	4 bits is value
	bit	3,d		; Center around 8
	ld	d,0
	ld	e,a

	ld	hl,TRACK_ToneTable;(replay_Tonetable)
	jr.	z,.neg
;neg	
	xor	a
	sbc	hl,de
	ld	(replay_PSG_tonetable),hl
	ld	hl,CHIP_FM_ToneTable
	sbc	hl,de
	ld	(replay_FM_tonetable),hl
	ret
; pos
.neg:	
	add	hl,de
	ld	(replay_PSG_tonetable),hl
	ld	hl,CHIP_FM_ToneTable
	add	hl,de
	ld	(replay_FM_tonetable),hl
	ret




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



_rpd_noDrum:
	ld	(FM_DRUM),a		; store the percusion bits
	ret
;===========================================================
; ---replay_process_drum
; Process the current drum macro
; 
;===========================================================
replay_process_drum:
	ld	a,(FM_DRUM_LEN)
	and	a
	jr.	z,_rpd_noDrum		; do nothing if end of macro is reached
	dec	a
	ld	(FM_DRUM_LEN),a

	ld	bc,(FM_DRUM_MACRO)

	; drum bits
	ld	a,(bc)
	and	a
	jr.	z,.skip_p
	or	$20
.skip_p:	
	ld	(FM_DRUM),a		; store the percusion bits
	inc	bc
	;- Bass drum
	ld	hl,DRUM_regToneBD
	call	replay_process_drum_tone
	ld	de,DRUM_regVolBD
	call	replay_process_drum_volume_BD
	;- Snare Hihat
	ld	hl,DRUM_regToneSH
	call	replay_process_drum_tone	
	ld	de,DRUM_regVolSH
	call	replay_process_drum_volume
	;- Cymbal Tom
	ld	hl,DRUM_regToneCT
	call	replay_process_drum_tone	
	ld	de,DRUM_regVolCT
	call	replay_process_drum_volume	
	
	ld	(FM_DRUM_MACRO),bc
	ret

;==================================================
; replay_process_drum_tone
;
; Process the data [BC] into drumreg [HL]
;==================================================
replay_process_drum_tone:
	; tone 
	ld	a,(bc)
	inc	bc
	and	a
	ret	z			; return if no data
	
	bit	7,a
	jr.	nz,.deviation	; tone deviation

.note:				; Note
	ld	de,(replay_Tonetable)
	add	a
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	a,(de)
	ld	(hl),a
	inc	hl
	inc	de
	ld	a,(de)
	ld	(hl),a	
	ret				; end
.deviation:
	; Tone deviation
	bit	6,a
	jr.	z,.positive 			; positive
	;negative
.negative:
	and	00111111b
	neg
	ld	e,(hl)		; get current tone value
	inc	hl
	ld	d,(hl)
	
	dec	d			; subtract a from de
	add	a,e
	ld	e,a
	adc 	a,d
	sub	e
	ld	d,a
.cont:
	ld	(hl),d		; store the new value
	dec	hl
	ld	(hl),e
	ret

.positive:	
	ld	e,(hl)		; get current tone value
	inc	hl
	ld	d,(hl)
	
	add	a,e			; add value a to de
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	jr.	.cont			; store the value 
;------- END ---------


;==================================================
; replay_process_drum_volume_BD
;
; Process the data [BC] into drumreg [de]
;==================================================
replay_process_drum_volume_BD
	ld	a,(bc)
	inc	bc
	and	a
	ret	z			; return if no data
	jr.	replay_process_drum_volume.cont	; jmp
;==================================================
; replay_process_drum_volume
;
; Process the data [BC] into drumreg [de]
;==================================================
replay_process_drum_volume:
	ld	a,(bc)
	ex	af,af'		; store for low
	ld	a,(bc)		; load  for high
	inc	bc
	and	a
	ret	z			; return if no data

	;high vol
	and	0xf0
	jr.	z,.low		; no high update
	
.high:
[4]	srl	a			; move high to low
	;--- apply main volume balance
	ld	hl,replay_mainvol
	CP	(HL)
	jr.	C,88F
	sub	(hl)
	jr.	99f
88:	xor	a
99:	
	ld	l,a
	ld	a,(de)		; get current volume
	and	0x0f
	ld	h,a
	ld	a,0x0f
	sub	l
[4]	sla	a
	or	h
	ld	(de),a		; store new volume

.low:
	;- low vol	
	ex	af,af'		; restore the value loaded
.cont:
	and	0x0f
	ret	z			; no low update

	;--- apply main volume balance
	ld	hl,replay_mainvol
	CP	(HL)
	jr.	C,88F
	sub	(hl)
	jr.	99f
88:	xor	a
99:	
	ld	l,a
	ld	a,(de)
	and	0xf0
	ld	h,a
	ld	a,0x0f
	sub	l
	or	h
	ld	(de),a
	ret
	
;------- END ---------	

	
	
;===========================================================
; ---replay_process_chan_AY
; Process the cmd/instrument/note and vol data 
; in HL is the current tone freq
;===========================================================
replay_process_chan_AY:
	push	hl

	;-- set the	mixer	right
	ld	hl,FM_regMIXER
	rrc	(hl)
	call	set_songpage

	;=====
	; COMMAND
	;=====
	ld	(ix+CHIP_cmd_NoteAdd),0			; reset ARP. Make sure to do this outside the
								; equalization skip
	bit	3,(ix+CHIP_Flags)
	jr.	z,_pcAY_noCommand
	
	ld	a,(ix+CHIP_Command)

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
	ld	a,(ix+CHIP_Flags)
	bit	0,a
	jr.	z,_pcAY_noNoteTrigger
	

_pcAY_triggerNote:	
	;--- get new Note
	set	1,a		; set	note active	flag
	res	0,a		; reset trigger flag
	ld	(ix+CHIP_Flags),a
	; init macrostep but check for cmd9
	ld	b,0
	bit	3,a
	jr.	z,99f
	ld	a,0x09		; Macro offset
	cp	(ix+CHIP_Command)
	jr.	nz,99f
	ld	b,(ix+CHIP_cmd_9)
99:	ld	(ix+CHIP_MacroStep),b

	ld	(ix+CHIP_ToneAdd),0
	ld	(ix+CHIP_ToneAdd+1),0
	ld	(ix+CHIP_VolumeAdd),0	
	ld	(ix+CHIP_cmd_ToneAdd),0
	ld	(ix+CHIP_cmd_ToneAdd+1),0
	ld	(ix+CHIP_cmd_VolumeAdd),0
	ld	(ix+CHIP_Noise),0
	ld	(ix+CHIP_cmd_ToneSlideAdd),0
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),0

	ld	iyl,64			; keyon flip trigger
	jr.	_pcAY_instrument

_pcAY_noNoteTrigger:
	ld	iyl,0				; keyon flip trigger
_pcAY_instrument:
	;Get note freq
	ld	a,(ix+CHIP_Note)
	add	a,(ix+CHIP_cmd_NoteAdd)
	add	a
	ex	af,af'			;'store the	note offset

	;==============
	; Macro instrument
	;==============
	bit	1,(ix+CHIP_Flags)
	jr.	z,_pcAY_noNoteActive
	ld	(_SP_Storage),SP
	
	;--- Get the macro len and loop
	ld	l,(ix+CHIP_MacroPointer)
	ld	h,(ix+CHIP_MacroPointer+1)
	ld	sp,hl
	pop	de	;	set [E] = len
			;	set [D] = loop
			
	;--- Get the macro step	data		
	ld	a,(ix+CHIP_MacroStep)
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
_pcAY_noMacroEnd:
	; tone deviation.
	ld	(ix+CHIP_MacroStep),a
	pop	bc		
	pop	hl		; tone deviation

;--- Voice link check here as now we still have all macro row values
	bit 	7,h
	jr.	z,_noVoicelink	

_voiceLink:	
	res	7,h			; reset bit
	set	6,(ix+CHIP_Flags)	; set voice update flag
	ld	a,c
	rla	
	rla
	rla
	rla
	and 	$f0
	ld	(ix+CHIP_Voice),a	; set new voice to be loaded
	res	7,c			; reset noise bit

_noVoicelink:
	ld	e,(ix+CHIP_ToneAdd)	; get	the current	deviation	
	ld	d,(ix+CHIP_ToneAdd+1)
	
;--- Is tone active this step?
	bit	7,b		; do we have tone?
	jr.	z,_pcAY_noTone

	;-- enable tone output
	ld	a,(FM_regMIXER)
	or	16
	ld	(FM_regMIXER),a
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
88:	

	;--- Store new deviation
	ld	(ix+CHIP_ToneAdd),l
	ld	(ix+CHIP_ToneAdd+1),h

	ex	de,hl				; store macro deviation	in [DE]
_pcAY_noTone:	
	;-- skip macro if not PSG
	bit 	7,(ix+CHIP_Flags)
	jr.	nz,pcAY_FMinstr
	
;	res	0,(ix+CHIP_Flags) 	; reset any note trigger for PSG. FM needs it.

	ex	af,af'			;' get note	offset
	ld	sp,(replay_Tonetable)	;CHIP_ToneTable-2	; -2 as note 0 is	no note
	ld	l,a
	ld	h,0
	add	hl,sp
	ld	sp,hl
	pop	hl				; in HL note value
	add	hl,de				; add	deviation

	; set	the detune.
	ld	e,(ix+CHIP_cmd_detune)
	ld	d,(ix+CHIP_cmd_detune+1)
	add	hl,de

	ld	e,(ix+CHIP_cmd_ToneAdd)
	ld	d,(ix+CHIP_cmd_ToneAdd+1)
	add	hl,de
	ld	e,(ix+CHIP_cmd_ToneSlideAdd)
	ld	d,(ix+CHIP_cmd_ToneSlideAdd+1)
	add	hl,de
	

	
_pcAY_noCMDToneAdd:	
;_pcAY_noTone:	
	ld	sp,(_SP_Storage)
;	ex	(sp),hl		; replace the last pushed value on stack
	pop	de
	ex	de,hl
	ld	(hl),e
	inc	hl	
	ld	(hl),d

	;-- Test for noise
	bit	7,c
	jr.	z,_pcAY_noNoise
	
	; noise
	;--- prevent SCC and noise
;	bit	7,(ix+CHIP_Flags)
;	jr.	nz,_pcAY_noNoise


IFDEF TTFM
	;--- Set the mixer for noise
	ld	a,(FM_regMIXER)
	or	128
	ld	(FM_regMIXER),a

	ld	e,(ix+CHIP_Noise)	; get	the current	deviation	
	ld	a,c
	and	0x1f
	ld	d,a

	;--- base or add/min
	bit	6,c
	jr.	nz,99f
	;--- base
	ld	e,0
99:
	bit	5,c
	jr.	z,99f
	;-- minus the deviation	of the macro
	ld	a,e
	sub	c	
	jr.	88f
99:	;--- Add the deviation
	ld	a,d
	add	e
88:	
	ld	(ix+CHIP_Noise),a
	ld	(AY_regNOISE),a
ELSE
	; SN PSG 
	;--- Set the mixer for noise
	ld	a,(FM_regMIXER)
	or	128
	ld	(FM_regMIXER),a

	; volume
	ld	a,c
	rrca
	rrca	
	rrca
	rrca
	and	0x07
	ld	(AY_regNOISE),a	


	;--- apply main volume balance
	ld	a,(replay_mainvol)
	ld	d,a
	ld	a,c
	and 	$0f
	or	(ix+CHIP_Volume)
	cp	d
	jr.	c,88F
	sub	d
	jr.	99f
88:	xor	a
99:	
	ld	de,AY_VOLUME_TABLE
	add	a,e
	ld 	e,a
	jr.	nc,99f
	inc	d
99:
	ld	a,(de)			
	ld	(SN_regVOLN),a



ENDIF
	

_pcAY_noNoise:
	;volume
	ld	a,b
	and	00110000b
	jr.	z,_pcay_volbase
	cp	00110000b
	jr.	z,_pcay_volsub
	cp	00100000b
	jr.	z,_pcay_voladd

IFDEF TTFM
_pcay_evelope:
	ld	a,16			; set volume to 16 == envelope
	ld	(FM_regVOLF),a
	ld	a,b
	and	0x0f
	ld	(AY_regEnvShape),a		; set the new envelope shape
	ret						; no further processing.
ENDIF

_pcay_volbase:
	ld	a,b
	and	0x0f
	jr.	_pcay_volend

_pcay_voladd:
	ld	a,b
	and	$0f
	ld	d,a
	ld	a,(ix+CHIP_VolumeAdd)
	add	d
	cp	16
	jr.	c,_pcay_volend
	ld	a,15
	jr.	_pcay_volend

_pcay_volsub:
	ld	a,b
	and	$0f
	ld	d,a
	ld	a,(ix+CHIP_VolumeAdd)
	sub	d
	cp	16
	jr.	c,_pcay_volend
	xor	a
_pcay_volend:
	ld	(ix+CHIP_VolumeAdd),a
	or	(ix+CHIP_Volume)
	ld	c,a

	ld	d,(ix+CHIP_cmd_VolumeAdd)
	
IFDEF TTSMS
	bit	7,b		; do we have tone?
	jr.	nz,7f
	xor	a
	ld	(FM_regVOLF),a	
	ret
	
7:

ENDIF


	sub	a,d
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
;	bit	7,(ix+CHIP_Flags)
;	jr.	nz,99f
	ld	de,AY_VOLUME_TABLE
;	jr.	88f
;99:
;	ld	de,SCC_VOLUME_TABLE
;88:
	add	hl,de
	ld	a,(hl)	
	ld	(FM_regVOLF),a
	
	ret
	

_pcAY_noNoteActive:
	pop	hl
	inc	hl
	ld	a,(ix+CHIP_Flags)
	bit	7,a
	jr.	z,.psg
.fm:
	and	16+32	; keep key and sustain flags
	ld	b,a
	ld	a,(hl)
	and 	$0f
	or 	b
	ld	(hl),a
	ld	a,$0f
	ld	(FM_regVOLF),a
	ret
.psg:
	xor	a
	ld	(FM_regVOLF),a
	ret
	
pcAY_FMinstr:	
	ex	de,hl				; store macro deviation	in [DE]

	ex	af,af'			;' get note	offset
	ld	sp,(replay_Tonetable)	;CHIP_ToneTable-2	; -2 as note 0 is	no note
	ld	l,a
	ld	h,0
	add	hl,sp
	ld	sp,hl
	pop	hl				; in HL note value
	add	hl,de				; add	deviation
	ld	sp,(_SP_Storage)

	; set	the detune.
	ld	e,(ix+CHIP_cmd_detune)
	ld	d,(ix+CHIP_cmd_detune+1)
	add	hl,de

	ld	e,(ix+CHIP_cmd_ToneAdd)
	ld	d,(ix+CHIP_cmd_ToneAdd+1)
	add	hl,de
	ld	e,(ix+CHIP_cmd_ToneSlideAdd)
	ld	d,(ix+CHIP_cmd_ToneSlideAdd+1)
	add	hl,de

	;---- FM PAC octave wrapper to enable slides over multiple octaves.
	; [DE] still contains the note freq value!!!
	bit	0,h				; is value $1xx or $0xx
	jr.	z,wrap_lowcheck
wrap_highcheck:
	ld	a,l
	cp	$5a		; $46 is the strict limit
	jr.	c,_wrap_skip		; stop if smaller

	push 	hl
	push	de
	
	;--- set new tone value for same note (but octave lower)
;	add	a,a		; divide by 2 in de 
	srl	a
	bit 	0,h		; test 9th bit
	jr.	z,99f
	add	128
99:
	ld	e,a
;	ld	d,0
	;--- set octave higher
	ld	a,h
	and	$fe
	add	$02
;	add	d		; merge with tone value
	ld	d,a
	;--- get difference between now and new
	ex	de,hl
	xor	a		; reset carry flag
	sbc	hl,de
	;--- add difference to current slide
	pop	de		; restore slide
	add	hl,de
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),h
	ld	(ix+CHIP_cmd_ToneSlideAdd),l
	
	pop hl
	jr.	_wrap_skip
	

wrap_lowcheck:
	ld	a,l
	cp	$3b		; $ad is the strict limit
	jr.	nc,_wrap_skip		; stop if smaller


	push 	hl		; store freq
	push	de		; store slide
	;--- set new tone value for same note (but octave lower)
	add	a,a		; multiply by 2 in de 
	ld	e,a
	ld	d,0
	jr.	nc,99f
	inc	d	
99:
	;--- set octave higher
	ld	a,h
	and	$fe
	sub	$02
	add	d		; merge with tone value
	ld	d,a
	;--- get difference between now and new
	ex	de,hl
	xor	a		; reset carry flag
	sbc	hl,de
	;--- add difference to current slide
	pop	de		; restore slide
	add	hl,de
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),h
	ld	(ix+CHIP_cmd_ToneSlideAdd),l
	
	pop hl
_wrap_skip:

	; replace the last pushed value on stack
	pop	de
	ex	de,hl
	ld	(hl),e
	inc	hl
	ld	a,d			; reset keyon and sustain
	and	$0f
	ld	d,a
	ld	a,(ix+CHIP_Flags)	; Add the sustain and key bits.
	and	16+32
	or	d
	or	iyl			; iyl is 64 if there is a note trigger
	ld	(hl),a


_pcFM_noVoice:
	;volume
	ld	a,(ix+CHIP_VolumeAdd)
	bit	5,b
	jr.	nz,0f
	;-- base volume
	ld	a,b
	and	0x0f
	jr.	4f
0:
	;relative volume
	ld	c,a		; store current volume add
	ld	a,b		
	and	0x0f		; get	low 3	bits for volume deviation
	
	bit	4,b		; bit	6 set	= subtract?
	ld	d,a		; set	deviation in b
	ld	a,c		; set	current volume add back	in c
	jr.	nz,1f
	;--- add 
	add	d
	cp	16
	jr.	c,4f
	ld	a,15
	jr.	4f
1:
	;--- sub 
	sub	d
	cp	16
	jr.	c,4f
	xor	a
4:
	ld	(ix+CHIP_VolumeAdd),a

	;--- software mixer for fm
	bit	7,b		; tone?
	jr.	nz,99f
	ld	a,15
	ld	(FM_regVOLF),a
	ret

99:
	or	(ix+CHIP_Volume)
	ld	c,a
	ld	b,(IX+CHIP_cmd_VolumeAdd)	
;	rla						; C flag contains devitation bit (C flag was reset in the previous OR)
;	jr.	nc,_sub_FMVadd
;
;_add_FMVadd:
;	add	a,c
;	jr.	nc,_FMVadd
;	ld	a,c
;	or	0xf0
;	jr.	_FMVadd
;
;_sub_FMVadd:
;	ld	b,a
;	ld	a,c
	sub	a,b
	jr.	nc,_FMVadd
	ld	a,c
	and	0x0f	
	;-- next is _Vadd

_FMVadd:

	;--- Volume
;	ld	a,15	; debug max vol
;	or	(ix+CHIP_Volume)
;	ld	c,a
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
	ld	de,SCC_VOLUME_TABLE
	add	hl,de
	ld	a,(hl)	
	ld	(FM_regVOLF),a
	
	ret
	

	
_pcAY_cmdlist:
	dw	_pcAY_cmd0
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
	dw	_pcAY_cmd1d		
	dw	_pcAY_cmd1e
	dw	_pcAY_cmd1f	
	dw	_pcAY_cmd20
	dw	_pcAY_cmd21
	dw	_pcAY_cmd22
	dw	_pcAY_cmd23
	dw	_pcAY_cmd24
			
_pcAY_cmd0:
	ld	a,(IX+CHIP_Timer)
	and	a
	jr.	z,.nextNote

	dec	a
	ld	(IX+CHIP_Timer),a
	ld	a,(ix+CHIP_Step)
	and	a
	jr.	z,99f
	ld	a,(IX+CHIP_cmd_0)
	and	$0f
	ld	(ix+CHIP_cmd_NoteAdd),a	
	jr.	_pcAY_commandEND
99:
	ld	(ix+CHIP_cmd_NoteAdd),0	
	jr.	_pcAY_commandEND


.nextNote:
	; re-init the speed.
	ld	a,(replay_arp_speed)
	ld	(IX+CHIP_Timer),a
	
	ld	a,(ix+CHIP_Step)
	and	a
	jr.	nz,99f

	;--- set x
		ld	(ix+CHIP_Step),1
		ld	a,(ix+CHIP_cmd_0)
		rlca
		rlca
		rlca
		rlca		
		ld	(ix+CHIP_cmd_0),a	
		and	$0f
		ld	(ix+CHIP_cmd_NoteAdd),a
		jr.	_pcAY_commandEND
	
99:
	dec	a
	jr.	nz,99f

	;--- set y
		ld	(ix+CHIP_Step),2
		ld	a,(ix+CHIP_cmd_0)
		rlca
		rlca
		rlca
		rlca		
		ld	(ix+CHIP_cmd_0),a			
		and	0x0f
		jr.	nz,0f
		;--- if zero then skip this note and set step to start
		ld	(ix+CHIP_Step),0
0:		
		ld	(ix+CHIP_cmd_NoteAdd),a	
		jr.	_pcAY_commandEND
	
99:
	;--- set none
	ld	(ix+CHIP_Step),0
	ld	(ix+CHIP_cmd_NoteAdd),0		
	jr.	_pcAY_commandEND
		
	
_pcAY_cmd1:
	ld	a,(ix+CHIP_cmd_1)
	ld	b,a
	ld	a,(ix+CHIP_cmd_ToneSlideAdd)
	sub	b
	ld	(ix+CHIP_cmd_ToneSlideAdd),a
	jr.	nc,_pcAY_commandEND
	dec	(ix+CHIP_cmd_ToneSlideAdd+1)
	jr.	_pcAY_commandEND
	
_pcAY_cmd2:

	ld	a,(ix+CHIP_cmd_2)
	ld	b,a
	ld	a,(ix+CHIP_cmd_ToneSlideAdd)
	add	b
	ld	(ix+CHIP_cmd_ToneSlideAdd),a
	jr.	nc,_pcAY_commandEND
	inc	(ix+CHIP_cmd_ToneSlideAdd+1)
	jr.	_pcAY_commandEND


_pcAY_cmd3:
	ld	a,(ix+CHIP_cmd_3)
	ld	l,(ix+CHIP_cmd_ToneSlideAdd)
	ld	h,(ix+CHIP_cmd_ToneSlideAdd+1)
	bit	7,a
	jr.	nz,_pcAY_cmd3_sub
_pcAY_cmd3_add:
	;pos slide
;	and	$7f
	add	a,l
	ld	(ix+CHIP_cmd_ToneSlideAdd),a
	jr.	nc,99f
	inc	h					
99:	bit	7,h
	jr.	z,_pcAY_cmd3_stop			; delta turned pos ?
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),h
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
	ld	(ix+CHIP_cmd_ToneSlideAdd),l
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),h
	jr.	_pcAY_commandEND
_pcAY_cmd3_stop:	
	;res	3,(ix+CHIP_Flags)
	ld	(ix+CHIP_cmd_ToneSlideAdd),0
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),0	
	jr.	_pcAY_commandEND


	;-- vibrato	
_pcAY_cmd4:
	ld	l,(ix+CHIP_cmd_4_depth)
	ld	h,(ix+CHIP_cmd_4_depth+1)	
	
	;--- Get next step
	ld	a,(IX+CHIP_Step)
	add	(ix+CHIP_cmd_4_step)
	and	$3F			; max	64
	ld	(ix+CHIP_Step),a
	
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
	ld	(ix+CHIP_cmd_ToneAdd),a
	ld	(ix+CHIP_cmd_ToneAdd+1),0xff
	jr.	_pcAY_commandEND	

.pos:
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
.zero:	
	ld	(ix+CHIP_cmd_ToneAdd),a
	ld	(ix+CHIP_cmd_ToneAdd+1),0
	jr.	_pcAY_commandEND	

_pcAY_cmd5:
	call	_pcAY_cmdasub
	jr.	_pcAY_cmd3
	
	


_pcAY_cmd6:
	call	_pcAY_cmdasub
	jr.	_pcAY_cmd4		


	;-- Tremolo
_pcAY_cmd7:
	ld	l,(ix+CHIP_cmd_4_depth)
	ld	h,(ix+CHIP_cmd_4_depth+1)	
	
	;--- Get next step
	ld	a,(IX+CHIP_Step)
	add	(ix+CHIP_cmd_4_step)
	and	$3F			; max	64
	ld	(ix+CHIP_Step),a
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
	ld	(ix+CHIP_cmd_VolumeAdd),a
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
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND
_pcAY_cmd9:
	dec	(ix+CHIP_Timer)
	jr.	nz,_pcAY_commandEND
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND



_pcAY_cmda:
	;retrig
;	dec	(ix+CHIP_Timer)
	call	_pcAY_cmdasub
	jr.	_pcAY_commandEND

_pcAY_cmdasub:
	dec	(ix+CHIP_Timer)
;	jr.	nz,_pcAY_cmd3
	ret	nz
		
	; vol	slide
	ld	a,(ix+CHIP_cmd_A)
	ld	d,a
	and	0x7f
	ld	(ix+CHIP_Timer),a

	ld	a,(ix+CHIP_Volume)
	bit	7,d
	jr.	z,.inc
.dec:
	and	a
	ret	z
	sub	$10
	ld	(ix+CHIP_Volume),a
	ret
.inc:
	cp	$F0
	ret	nc
	add	$10
	ld	(ix+CHIP_Volume),a
	ret
	

_pcAY_cmdb:
_pcAY_cmdc:	
;	jr.	_pcAY_commandEND
_pcAY_cmdd:
;	;call	replay_setnextpattern
;	ld	a,64
;	ld	(replay_line),a
;	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND
	
_pcAY_cmd10:
_pcAY_cmde:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND
_pcAY_cmdf:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND

	
_pcAY_cmd11:
;	dec	(ix+CHIP_Timer)
;	jr.	nz,_pcAY_commandEND

;	res	3,(ix+CHIP_Flags)
;	ld	a,(ix+CHIP_cmd_ToneSlideAdd)
	ld	a,(ix+CHIP_cmd_E)
	ld	(ix+CHIP_cmd_ToneSlideAdd),a
	xor	a
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),a	
;	jr.	nc,_pcAY_commandEND	
	jr.	_pcAY_commandEND	

_pcAY_cmd12:
;	dec	(ix+CHIP_Timer)
;	jr.	nz,_pcAY_commandEND

	;res	3,(ix+CHIP_Flags)
;	ld	a,(ix+CHIP_cmd_ToneSlideAdd)
	ld	a,(ix+CHIP_cmd_E)
	ld	(ix+CHIP_cmd_ToneSlideAdd),a
	ld	a,$ff
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),a
	jr.	_pcAY_commandEND	

_pcAY_cmd13:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd14:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd15:
;	

_pcAY_cmd16:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd17:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd18:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd19:
	;retrig
	dec	(ix+CHIP_Timer)
	jr.	nz,_pcAY_commandEND
	
	; retrig note
	ld	a,(ix+CHIP_cmd_E)
	ld	(ix+CHIP_Timer),a
	set	0,(ix+CHIP_Flags)
	
	jr.	_pcAY_commandEND	
_pcAY_cmd1a:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd1b:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd1c:
	dec	(ix+CHIP_Timer)
	jr.	nz,_pcAY_commandEND
	
	; stop note
	res	1,(ix+CHIP_Flags)	; set	note bit to	0
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd1d:
	; note delay
	dec	(ix+CHIP_Timer)
	jr.	nz,_pcAY_commandEND	; no delay yet

	; trigger note
	ld	a,(ix+CHIP_cmd_E)		
	ld	(ix+CHIP_Note),a		; set	the note val
	set	0,(ix+CHIP_Flags)		; set	trigger note flag
	res	3,(ix+CHIP_Flags)		; reset tiggger cmd flag
	
	jr.	_pcAY_commandEND	
_pcAY_cmd1e:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd1f:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd20:
	;res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
	
_pcAY_cmd21:
;
	jr.	_pcAY_commandEND
	
_pcAY_cmd22:
	jr.	_pcAY_commandEND
	
_pcAY_cmd23:	
	jr.	_pcAY_commandEND	
_pcAY_cmd24:
	jr.	_pcAY_commandEND	
	
;===========================================================
; ---replay_route
; Output the data	to the CHIP	registers
; 
; WILL DISABLE INTERRUPTS !!!!
;===========================================================
replay_route:

replay_route_PSG:
;---------------
; P S G 
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
IFDEF TTFM
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


ELSE
route_SN:
	ld	b,10010000b		; volume chan 1
	ld	a,(replay_chan_setup)
	and	$01
	jr.	nz,99f
	ld	b,10110000b		;volume chan 2
99:
	ld	c,$3f
99:	
	; vol chan 1
	ld	a,(AY_regVOLA)
	inc	a
	neg
	and	$0f
	or	b
	out	(c),a	
	
	ld	a,00100000b
	add	b
	ld	b,a

	; vol chan 2
	ld	a,(AY_regVOLB)
	inc	a
	neg
	and	$0f
	or	b
	out	(c),a		
		
	;-- check if we need 3rd psg
	ld	a,11010000b
	cp	b
	jr.	z,99f
		
	; vol chan 3
	ld	a,(AY_regVOLC)
	inc	a
	neg
	and	$0f
	or	11010000b 
	out	(c),a			

99:	
	;--- next reg
	; vol noise
	ld	a,(SN_regVOLN)
	inc	a
	neg
	and	$0f
	or	11110000b

	out	(c),a	

	; noise chan 
	ld	hl,SN_regNOISEold
	ld	a,(AY_regNOISE)
	cp	(hl)
	jr.	z,0f
	ld	(hl),a
	or	11100000b
	out	($3f),a
0:
	;--- check the channel to write
	ld	b,10000000b			; chan 1 update
	ld	a,(replay_chan_setup)
	and	$01
	jr.	nz,99f
	ld	b,10100000b			; chan 2 update
99:
	; tone chan a
	ld	hl,(AY_regToneA)
	ld	a,l
	and	$0f
	or	b
	out	($3f),a	
	add	hl,hl
	add	hl,hl	
	add	hl,hl
	add	hl,hl	
	ld	a,00111111b
	and	h
	out	($3f),a		

	; Set data mask to update next channel
	ld	a,00100000b
	add	b
	ld	b,a
	
	; tone chan b
	ld	hl,(AY_regToneB)
	ld	a,l
	and	$0f
	or	b
	out	($3f),a	
	add	hl,hl
	add	hl,hl	
	add	hl,hl
	add	hl,hl	
	ld	a,00111111b
	and	h
	out	($3f),a

	;--- test if we need to update third channel
	ld	a,11000000b
	cp	b
	jr.	z,route_gg


	; tone chan c
	ld	hl,(AY_regToneC)
	ld	a,l
	and	$0f
	or	11000000b
	out	($3f),a	
	add	hl,hl
	add	hl,hl	
	add	hl,hl
	add	hl,hl	
	ld	a,00111111b
	and	h
	out	($3f),a	

route_gg:
	;==== output the GG stereo panning
	ld	a,(GG_panning)
	out	($06),a

ENDIF
	
	
	
;--------------
; F M P A C 
;--------------
replay_route_FM:
	ld	a,(replay_mode)
	cp	2
	jr.	z,_skipMixer
	

replay_route_mixer:
	;--- Determine the channel setup
	ld	a,(replay_chan_setup)
	and	$01
	jr.	z,.setup26
.setup35:
	ld	b,5
	ld	hl,FM_regToneB+1		; contains the keyON bit
	ld	a,(MainMixer)
	jr.	0f
.setup26:
	ld	b,6
	ld	hl,FM_regToneA+1		; contains the keyON bit
	ld	a,(MainMixer)
	rlc	a				; setup mixer for 6 FM chans
0:
	ld	c,a
.loop:
	rrc	c
	jr.	c,99f		; if flag was set skip silencing the channel
	res	4,(hl)
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	or	$0f
	ld	(hl),a
	jr.	3f
99:
	inc	hl
	inc	hl
	inc	hl
3:
	inc	hl
	inc	hl
	inc	hl	
	djnz	.loop


_skipMixer:
replay_route_FM_chans:
	;--- 	Write FM channel registers
	;--- Store CPU type for later.
	ld	a,(r800)
	ld	e,a
	and	a
	jr.	z,99f
	;--- init the r800 wait timer
	in	a,($e6)
	ld	(count_low),a
99:
	;--- Check if we need to update the voice regs
	ld	a,(replay_voicetrigger)
	and	a
	jr.	z,.channels
	;--- update the voice registers
	xor	a
	ld	(replay_voicetrigger),a
	ld	hl,FM_Voicereg
	ld	bc,$0800		; 8 values, base register 0
	ex	af,af'
.voiceloop:
	ld	a,(hl)
	inc	hl
	cp	(hl)
	jr.	z,99f
	ld	d,a
	ld	a,c
	call	_writeFM	

99:
	inc	hl
	inc	c
	djnz	.voiceloop


.channels:
	ld	bc, $0910			; 9 channels, start reg# is $10
	ld	hl,FM_regToneA+1		; pointer to the backup of reg# $2x
.channel_loop:
;	;--- Check if channel is active
	ld	a,(hl)
;	cp	128		; test bit 7	0 = chan not active
;	jr.	c,.notActive
	cp	64		; test bit 6	1 = note trigger
	jr.	c,.noKeyOnSwitch

.keyOnSwitch:
	;--- Flip KeyOn bit
	; To be honest I am a little confused on the this part as 
	; with certain FM instruments ($14) it is not sufficient to 
	; disable the keyon bit and enable it.  It needs to be a 
	; full on-off-on sequence to work on all instruments.
	inc	hl
	inc	hl
	ld	a,(hl)
	;--- Check if Key is already ON
	bit	4,a
	jr.	nz,99f		; skip if key was already set
	or	00010000b		; set bit
	ld	d,a
	ld	a,$10
	add	c
	call	_writeFM
	ld	a,(hl)	
99:
	and	00101111b		; reset keyon bit
	ld	d,a
	ld	a,$10
	add	c
	call	_writeFM
	dec	hl
	dec	hl
.noKeyOnSwitch:
	dec	hl
	;--- Write reg $1x
	ld	a,(hl)
	inc	hl
	inc	hl
	cp	(hl)
	jr.	z,99f			; No change in value
	ld	d,a			; Store value in D
	ld	a,c			; Store reg# in C
	call	_writeFM
99:
	dec	hl
	;--- Write reg $2x
	ld	a,(hl)
	inc	hl
	inc	hl
	cp	(hl)
	jr.	z,99f			; No change in value
	ld	d,a			; Store value in D
	ld	a,$10
	add	a,c			; Store reg# in C+10
	call	_writeFM
99:
	inc	hl	
	;--- Write reg $3x
	ld	a,(hl)
	inc	hl
	cp	(hl)
	jr.	z,99f			; No change in value
	ld	d,a			; Store value in D
	ld	a,$20
	add	c			; Store reg# in C
	call	_writeFM
99:
	inc	hl
	inc	hl
.continue:	
	inc	c			; increase base register with 1
	djnz	.channel_loop

	;--- write rythm register
.rythm:
	ld	a,(DrumMixer)
	and	a
	ret	z			; Drums on mute

	ld	b,(hl)		; save old
	dec	hl
	ld	a,(hl)
	and	a
	ret	z

	inc	hl
	ld	c,a			; save new
	xor	$1f			; create key off mask
	and	b			; reset bits to trigger
	ld	d,a			
	ld	a,$0e			
	call	_writeFM

	ld	a,c			; restore new
	or	b			; add old key-on bits
	ld	d,a
	call	_writeFM_data
	ret

.notActive:
	ld	de,6
	add	hl,de
	jr.	.continue
	;--- Points to start address of next chan



; [A] reg#
; [D] value
; [E] R800	(0=Z80, 1 = R800)
; [HL] points to previous value
_writeFM:
	bit	0,e				;  8 cycles
	jr.	nz,_writeFM_R800		; 10 cycles
	out	(FM_WRITE),a		; 11 cycles
	ld	a,d				;  4 cycles
_writeFM_cont:
	ld	(hl),a			;  7 cycles	
	out	(FM_DATA),a			; 11 cycles
	ret					; 10 cycles

; [D] value
; [E] R800	(0=Z80, 1 = R800)
; [HL] points to previous value
_writeFM_data:
	bit	0,e				;  8 cycles
	jr.	nz,_writeFM_data_R800	; 10 cycles
	push	bc				; 11 cycles	Dummy for write delay
	pop	bc				; 11 cycles	Dummy for write delay
	jr.	_writeFM_cont		; 10 cycles

; [A] reg#
; [D] value
; [HL] points to previous value
_writeFM_R800:		
	;--- wait to write
	push	de
	ex	af,af'
	ld	a,(count_low)
	ld	d,a
.loop_long:
	in	a,($e6)
	sub	d
	cp	6
	jr.	c,.loop_long

	pop	de
	ex	af,af'
	;-- write address
	out	(FM_WRITE),a		; 11 cycles

	in	a,($e6)
	;--- wait to write
	push	de
	ld	d,a
.loop_short
	in	a,($e6)
	sub	d
	cp	1
	jr.	c,.loop_short
	pop	de
_writeFM_R800_cont:
	;--- write data
	ld	a,d				;  4 cycles
	ld	(hl),d			;  7 cycles	
	out	(FM_DATA),a			; 11 cycles
	in	a,($e6)
	ld	(count_low),a
	ret					; 10 cycles

; [D] value
; [HL] points to previous value
_writeFM_data_R800:
	;--- wait to write
	push	de
	ld	a,(count_low)
	ld	d,a
.loop_long:
	in	a,($e6)
	sub	d
	cp	6
	jr.	c,.loop_long
	pop	de
	jr.	_writeFM_R800_cont
	;--- end


;_drumset:
;	db	00100000b ; none
;	db	00110000b ; bdrum
;	db	00101000b ; snare
;	db	00111000b ; bdrum+snare
;	db	00100001b ; hihat
;	db	00100010b ; Cymbal
;	db	00110010b ; bdrum + cymbal
;	db	00101010b ; snare + cymbal
;	db	00111010b ; 
;	db	00100100b
;	db	00110100b
;	db	00110001b
;	db	00101001b
;	db	00111001b
;	db	00110110b
;	db	00100011b

REPLAY_END:


	