FM_WRITE:	equ	0x7c	; port to set fm reg nr.
FM_DATA:	equ	0x7d	; port to set fm data for reg

;================================
; The new replayer.
;
;
;
;================================
SCC_VOLUME_TABLE 
	incbin "..\data\voltable_FM.bin"

DRM_DEFAULT_values:
	db	01111110b		; 0,1,2 = volume, 5,6,7 = freq
	dw	0x0520			; Base drum
	db	0x01			; vol
	dw	0x0550			; Snare + HiHat
	db	0x11			; vol
	dw	0x01c0			; Cymbal + TomTom
	db	0x11			; vol
	


CHIP_Vibrato_sine:
	db	0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0	; Depth 0
	db	0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  2,  2,  2,  3,  3,  2,  2,  2,  1,  1,  1,  1,  0,  0,  0,  0,  0,  0,  0,  0	; Depth 1
	db	0,  0,  0,  0,  0,  1,  1,  1,  2,  2,  3,  3,  4,  4,  5,  6,  6,  5,  4,  4,  3,  3,  2,  2,  1,  1,  1,  0,  0,  0,  0,  0 ; Depth 2
	db	0,  0,  0,  0,  1,  2,  2,  3,  4,  5,  6,  7,  8,  9, 10, 12, 12, 10,  9,  8,  7,  6,  5,  4,  3,  2,  2,  1,  0,  0,  0,  0	; Depth 3
	db	0,  0,  1,  1,  2,  4,  5,  7,  8, 10, 12, 14, 17, 19, 21, 24, 24, 21, 19, 17, 14, 12, 10,  8,  7,  5,  4,  2,  1,  1,  0,  0	; Depth 4
	db	0,  1,  2,  3,  5,  8, 11, 14, 17, 21, 25, 29, 34, 38, 43, 48, 48, 43, 38, 34, 29, 25, 21, 17, 14, 11,  8,  5,  3,  2,  1,  0	; Depth 5
	db	0,  2,  4,  7, 11, 16, 22, 28, 35, 43, 51, 59, 68, 77, 87, 96, 96, 87, 77, 68, 59, 51, 43, 35, 28, 22, 16, 11,  7,  4,  2,  0	; Depth 6	
	db	0,  4,  8, 14, 22, 32, 44, 56, 70, 86,102,118,136,154,174,192,192,174,154,136,118,102, 86, 70, 56, 44, 32, 22, 14,  8,  4,  0	; Depth 7





;	db	 0*2,	2*2, 4*2, 7*2,11*2,16*2,22*2,28*2,35*2,43*2,51*2,59*2,68*2,77*2,87*2,96*2
;	db	96*2,86*2,77*2,68*2,59*2,51*2,43*2,35*2,28*2,22*2,16*2,11*2, 7*2,	4*2, 2*2, 0*2
;
;CHIP_Vibrato_triangle:
;	db	 0, 6,12,18,24,30,36,42,48,54,60,66,72,78,84,90
;	db	96,90,84,78,72,66,60,54,48,42,36,30,24,18,12, 6
;
;CHIP_Vibrato_pulse:
;	db	255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
;;	db	255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
;	db      0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0	
	



;--- Replay	music
replay_mode1:
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
	call	nc,replay_setnextpattern
	jr.	replay_decodedata	
	
;--- Keyjazz
replay_mode2:
	;--- mode 2	- Replay the line	in 'replay_patpointer'
	ld	a,(replay_speed_timer)
	and	a
	jr.	nz,1f
	;--- test if key is still pressed.
_rpm2_3:
	ld	a,0x0f
	ld	(KH_timer),a		; F3F7 REPCNT  Delay until the auto-repeat of the key	begins	
	
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
	call	replay_init
	ret
1:
	xor	a
	ld	(replay_speed_timer),a
	
	jr.	replay_decodedata
;-- end

replay_mode3:
	;--- mode 3	- Replay the line	in 'replay_patpointer'
	ld	a,(replay_speed_timer)
	and	a
	jr.	nz,1f	
	jr.	_rpm2_3		; mode 2 and 3 work alike.
	
1:	
	call	replay_init_pre
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
;_replay_decode_light:
	;--- process thechannels (tracks)
	;xor	a
	;ld	(AY_regMIXER),a	;set mixer to silence
	;--- Set the tone table base
;	ld	hl,CHIP_ToneTable
;	ld	(replay_Tonetable),hl


	
	ld	ix,CHIP_Chan1
	call	replay_decode_chan
	ld	ix,CHIP_Chan2
	call	replay_decode_chan


	;--- check if next is PSG  or FM
	ld	a,(replay_chan_setup)
	and	a
	jp	nz,_rdd_3psg
	
;	ld	hl,CHIP_FM_ToneTable
;	ld	(replay_Tonetable),hl

	
_rdd_3psg:	

	ld	ix,CHIP_Chan3
	call	replay_decode_chan
	
	;--- check if previous was PSG  or FM
	ld	a,(replay_chan_setup)
	and	a
	jp	z,_rdd_2psg
	
;	ld	hl,CHIP_FM_ToneTable
;	ld	(replay_Tonetable),hl
	
	
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
	ld	hl,CHIP_ToneTable
	ld	(replay_Tonetable),hl

	xor	a
	ld	(SCC_regMIXER),a
	ld	a,(mainPSGvol)
	ld	(replay_mainvol),a
IFDEF TTSMS
	ld	(SN_regVOLN),a
	ld	(AY_regVOLA),a
	ld	(AY_regVOLB),a
	ld	(AY_regVOLC),a
ENDIF	

	ld	ix,CHIP_Chan1
	ld	hl,AY_regToneA
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLF)
	ld	(AY_regVOLA),a	

	ld	ix,CHIP_Chan2
	ld	hl,AY_regToneB	
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLF)
	ld	(AY_regVOLB),a

	ld	a,(replay_chan_setup)
	and	a
	jp	z,_rdd_2psg_6fm

_rdd_3psg_5fm:
	; =======================================
	;--- Play chan 3 over PSG
	; =======================================
	ld	ix,CHIP_Chan3
	ld	hl,AY_regToneC	
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLF)
	ld	(AY_regVOLC),a	

	ld	a,(SCC_regMIXER)
	srl	a
	srl	a
	;srl	a
	;srl	a	
	xor	0x3f
	ld	(AY_regMIXER),a		; save the mixer
	ld	a,(mainSCCvol)
	ld	(replay_mainvol),a		; setup volume for FM

	xor	a			; reset the mixer
	ld	(SCC_regMIXER),a

	ld	hl,CHIP_FM_ToneTable
	ld	(replay_Tonetable),hl	
	
	jp	_rdd_cont

	
_rdd_2psg_6fm:	
	; =======================================
	;--- Play chan 3 over FM
	; =======================================
	ld	a,(SCC_regMIXER)		; correct the mixer
	srl	a
	srl	a
	srl	a		

	xor	0x3f
	ld	(AY_regMIXER),a		; save the mixer
	ld	a,(mainSCCvol)
	ld	(replay_mainvol),a		; setup volume for FM

	xor	a			; reset the mixer
	ld	(SCC_regMIXER),a

	ld	hl,CHIP_FM_ToneTable
	ld	(replay_Tonetable),hl
	
	ld	ix,CHIP_Chan3
	ld	hl,SCC_regToneA	
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLF)
	ld	(FM_regVOLA),a

	
	
_rdd_cont:					; used for waveform updates
	ld	ix,CHIP_Chan4
	ld	hl,SCC_regToneB	
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLF)
	ld	(FM_regVOLB),a	

;	inc	iyh
	
	ld	ix,CHIP_Chan5
	ld	hl,SCC_regToneC
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLF)
	ld	(SCC_regVOLC),a

;	inc	iyh
		
	ld	ix,CHIP_Chan6
	ld	hl,SCC_regToneD	
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLF)
	ld	(SCC_regVOLD),a	

;	inc	iyh
		
	ld	ix,CHIP_Chan7
	ld	hl,SCC_regToneE	
	call	replay_process_chan_AY
	ld	a,(SCC_regVOLF)
	ld	(SCC_regVOLE),a	

;	inc	iyh

;	ld	a,(replay_chan_setup)
;	and	a
;	jp	z,99f
;	;-- set the	mixer	right
;	ld	hl,SCC_regMIXER
;	rrc	(hl)
;	jp	88f
	
;99:		
	ld	ix,CHIP_Chan8
	ld	hl,SCC_regToneF	
	call	replay_process_chan_AY

;	ld	a,(SCC_regMIXER)
;	rlca	
;	ld	(SCC_regMIXER),a
88:
	;---- Process the drum macros
;	xor	a
;	ld	(FM_DRUM_Flags),a
;	ld	(FM_DRUM),a
	call	replay_process_drum
;	ld	bc,FM_DRUM1_LEN
;	ld	de,FM_freqreg1	
;	ld	hl,(FM_DRUM1)
;	call	replay_process_drum
;	ld	(FM_DRUM1),hl
;	ld	bc,FM_DRUM2_LEN
;	ld	de,FM_freqreg2
;	ld	hl,(FM_DRUM2)
;	call	replay_process_drum
;	ld	(FM_DRUM2),hl
;	ld	bc,FM_DRUM3_LEN
;	ld	de,FM_freqreg3
;	ld	hl,(FM_DRUM3)
;	call	replay_process_drum	
;	ld	(FM_DRUM3),hl
	

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
	;call	draw_vu_empty
	;--- Get the start speed.
	ld	a,(song_speed)
	ld	(replay_speed),a
	ld	a,1
	ld	(replay_speed_timer),a
	dec	a
	ld	(replay_speed_subtimer),a
	ld	(replay_mode),a	

	;--- Erase channel data	in RAM
	xor	a
	ld	bc,(CHIP_REC_SIZE*8)-1
	ld	hl,CHIP_Chan1
	ld	de,CHIP_Chan1+1
	ld	(hl),a
	ldir
	
;	;--- Set vibrato table
;	ld	hl,CHIP_Vibrato_sine
;	ld	(replay_vib_table),hl
	
	;--- Set the tone table base
	ld	hl,CHIP_ToneTable
	ld	(replay_Tonetable),hl
	
	
	;--- Silence the chips
	ld	a,0x3f
	ld	(AY_regMIXER),a
	xor	a
	ld	(SCC_regMIXER),a
	ld	(AY_regVOLA),a
	ld	(AY_regVOLB),a	
	ld	(AY_regVOLC),a
IFDEF	TTSMS
	ld	(SN_regVOLN),a
ENDIF	
;	;--- Init the SCC	(waveforms too)
;	ld	h,0x80
;	call enaslt
	
	ld	a,1
	ld	(CHIP_Chan3+CHIP_Voice),a
	ld	(CHIP_Chan4+CHIP_Voice),a
	ld	(CHIP_Chan5+CHIP_Voice),a
	ld	(CHIP_Chan6+CHIP_Voice),a	
	ld	(CHIP_Chan7+CHIP_Voice),a	
	ld	(CHIP_Chan8+CHIP_Voice),a
	ld	a,128
	ld	(CHIP_Chan3+CHIP_Flags),a
	ld	(CHIP_Chan4+CHIP_Flags),a
	ld	(CHIP_Chan5+CHIP_Flags),a
	ld	(CHIP_Chan6+CHIP_Flags),a	
	ld	(CHIP_Chan7+CHIP_Flags),a	
	ld	(CHIP_Chan8+CHIP_Flags),a	
	
	;--- Check if there are 3 psg chans.
	ld	a,(replay_chan_setup)
	and	a
	jp	z,99f
	xor 	a
	ld	(CHIP_Chan3+CHIP_Flags),a	
99:
		
	xor	a
	ld	(FM_regVOLA),a
	ld	(FM_regVOLB),a
	ld	(FM_regVOLC),a
	ld	(FM_regVOLD),a
	ld	(FM_regVOLE),a
	ld	(FM_regVOLF),a
	
	ld	(FM_DRUM_LEN),a
	ld	(FM_DRUM),a
;	ld	(FM_DRUM2_LEN),a
;	ld	(FM_DRUM3_LEN),a
	
;call scc_reg_update
	
;	ld	a,(mapper_slot)				; Recuperamos el slot
;	ld	h,0x80
;	call enaslt
	
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

	;--- DRUM reset
	push	bc
	ld	de,FM_DRUM_Flags
	ld	hl,DRM_DEFAULT_values
	ld	bc,10
	ldir
	pop	bc

	
	; end	is here
	ret




;--- Very basic pre-scan. Old	one was WAY	too slow.
replay_init_pre:
	;di
	
	;--- Get the current values (to restore them after pre-scan
;	ld	a,(current_song)
	call	set_songpage


	ld	a,(song_pattern_line)
	push	af					; store for	later


	;--- Get the insturments from	the first line of	the song
	ld	hl,song_order
	ld	a,(hl)
	ld	b,a
	call	set_patternpage
	
	ld	de,_AUDITION_LINE
;	ld	(replay_patpointer),de		; make the code replay this line
	ld	bc,32
	ldir

	;--- Get the current line (keep instrument and volumes)
;	ld	a,(current_song)
	call	set_songpage

	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage
	
	pop	af
	and	a
	jr.	z,0f
	ld	de,32
88:
	add	hl,de
	dec	a
	jr.	nz,88b		
0:
	ld	b,8
	ld	de,_AUDITION_LINE
	;--- process current line chan data
_pe_chanloop:
	ld	a,(hl)		; copy note
	;xor	a			; don;t play note. Just	set instrument.
	ld	(de),a
	inc	hl
	inc	de
	ld	a,(hl)		; copy instrument
	and	a			; only overwrite if instr > 0
	jr.	z,99f
	ld	(de),a
99:
	;if no instrument	at all then	instr	1
	ld	a,(de)
	and	a
	jr.	nz,99f
	inc	a
	ld	(de),a
99:
	inc	de
	inc	hl
	ld	a,(hl)		; copy volume
	cp	15			; is there a volume
	jr.	nc,99f		; if there is a volume 
	ld	c,a
	ld	a,(de)
	and	$f0
	jr.	nz,88f		; if there is no volume	at all then	max volume
	ld	a,$f0
88:	add	c
99:	ld	(de),a		; write volume + command
	and	$0f			; make sure	we do	not process	pattern end
	cp	$0d			
	jr.	nz,99f
	ld	a,(de)
	and	$f0
	ld	(de),a			


99:
	inc	hl
	inc	de
	ld	a,(hl)		; copy command param.
	ld	(de),a
	inc	hl
	inc	de
	djnz	_pe_chanloop

	ld	bc,_AUDITION_LINE
	ld	hl,(replay_patpointer)
	push	hl
	ld	(replay_patpointer),bc
	call	replay_decodedata
	pop	hl
	ld	(replay_patpointer),hl

;	ld	a,(replay_patpage)
;	call	PUT_P2

	;ei
	ret
	
;	ld	a,(song_pattern)
;	ld	(_PRE_pat),a
;	ld	a,(song_pattern_line)
;	ld	c,a
;	ld	a,(song_order_pos)
;	ld	b,a
;	
;	push	bc		; save line	and order pos
;
;	;--- Set the start of preprocessing
;	cp	_PREPROCESS_LENGTH	; check if we can	go back this far
;	jr.	nc,99f			; if we can	go back this far
;	ld	a,_PREPROCESS_LENGTH-1
;99:
;	sub	_PREPROCESS_LENGTH
;	ld	(song_order_pos),a
;	
;		;xor	a
;;		ld	a,255
;;		ld	(song_order_pos),a
;		;-- set the	right	pattern and	page
;	;	ld	hl,song_order
;	;	ld	b,(hl)
;	;	call	set_patternpage
;		ld	hl,_PRE_dummy_pat
;		ld	(replay_patpointer),hl
;	
;		call	GET_P2
;		ld	(replay_patpage),a
;		ld	a,1
;		ld	(replay_line),a	
;
;	pop	bc		; restore line and order pos
;
;	;--- process all patterns till current position
;_ri_pre_loop:
;	ld	a,(current_song)
;	call	set_songpage
;	
;	;--- Are we	already at the current line?
;	ld	a,(replay_line)
;	dec	a
;	cp	c
;	jr.	c,99f
;	
;	ld	a,(song_order_pos)
;	cp	b
;	jr.	z,_ri_pre_end
;	
;99:	
;	;--- Process a line
;	push	bc
;
;;	ld	a,1
;;	ld	(replay_speed_timer),a
;
;	ld	a,(replay_patpage)	;--- set correct pattern page
;	call	PUT_P2
;	
;	call	replay_mode1	
;	
;	
;	pop	bc				;--- Restore a line
;	jr.	_ri_pre_loop
;
;_ri_pre_end:
;	;--- Restore playback/edit position
;	ld	a,b
;	ld	(song_order_pos),a
;	ld	a,c
;	ld	(song_pattern_line),a	; <--	needed? need to check
;	ld	a,(_PRE_pat)
;	ld	(song_pattern),a
;
;
;	;--- Set the correct page if prescan on pattern	not in order
;	call	set_patternpage
;	ld	(replay_patpointer),hl
;	call	GET_P2
;	ld	(replay_patpage),a
;
;
;	;ei		; important	as route will DI !!!!	
;
;	ret












;replay_init_pre_old:
;
;	;--- !!!!!!	add check for pattern note audition	for patterns not in the	order.
;
;
;
;
;
;	ld	a,(current_song)
;	call	set_songpage
;	;----- PRE-PROCESS PREVIOUS PATTERNS/LINES
;	;--- Get the start speed (to reset any in	pattern set	speeds).
;	ld	a,(song_speed)
;	ld	(replay_speed),a
;	ld	a,1
;	ld	(replay_speed_timer),a
;	dec	a
;	ld	(replay_speed_subtimer),a
;		
;	;--- save the current values
;	ld	a,(song_pattern_line)
;	ld	c,a
;	ld	a,(song_order_pos)
;	ld	b,a
;
;	;--- check if we need to skip	preprocessing
;	and	a
;	jr.	nz,88f
;	cp	c
;	ret	z;
;88:	
;	di
;
;	push	bc
;	
;	;--- Set the start of preprocessing
;	cp	_PREPROCESS_LENGTH	; check if we can	go back this far
;	jr.	nc,99f			; if we can	go back this far
;	ld	a,_PREPROCESS_LENGTH
;99:
;	sub	_PREPROCESS_LENGTH
;	ld	(song_order_pos),a
;	
;	;-- set the	right	pattern and	page
;	ld	hl,song_order
;	ld	d,0
;	ld	e,a
;	add	hl,de
;	ld	b,(hl)
;	call	set_patternpage
;	ld	(replay_patpointer),hl
;
;	call	GET_P2
;	ld	(replay_patpage),a
;	
;	;xor	a
;	ld	a,1
;	ld	(replay_line),a	
;
;	pop	bc
;	; now	loop till current	position
;;_ri_pre_loop:
;	push	bc
;
;	ld	a,(replay_patpage)	;--- set correct pattern page
;	call	PUT_P2
;
;	ld	a,1
;	ld	(replay_speed_timer),a
;	
;	call	replay_mode1	
;	pop	bc
;	; check if we are	at current line?
;	ld	a,(replay_line)
;	dec	a
;	cp	c
;	jr.	nz,_ri_pre_loop
;	
;	
;	ld	a,(current_song)
;	call	set_songpage
;	
;	; check if we are	at current pos/pattern?
;	ld	a,(song_order_pos)
;	cp	b
;	jr.	c,_ri_pre_loop
;
;	;--- Silence the chips
;	ld	a,0x3f
;	ld	(AY_regMIXER),a
;	xor	a
;	ld	(SCC_regMIXER),a
;
;	ld	a,(current_song)
;	call	set_songpage	
;;	call	replay_route	
;
;	ei		; important	as route will DI !!!!	
;
;	ret





	
_TEMPAY:	db "aAAA bBBB cCCC nNN mMM aVbVcVnV"
draw_PSGdebug:		
	; THIS IS DEBUG INFO ON	THE REGISTERS!!!!
	ld	de,_TEMPAY+1
	ld	hl,AY_registers
	ld	a,(hl)
	inc	hl
;	add	1
	ld	b,a
	ld	a,(hl)
;	adc	0
	call	draw_hex
	ld	a,b
	call	draw_hex2
	inc	hl
	inc	de
	inc	de
	
	ld	a,(hl)
	inc	hl
;	add	1
	ld	b,a
	ld	a,(hl)
;	adc	0
	call	draw_hex
	ld	a,b
	call	draw_hex2
	inc	hl
	inc	de
	inc	de
	
	ld	a,(hl)
	inc	hl
;	add	1
	ld	b,a
	ld	a,(hl)
;	adc	0
	call	draw_hex
	ld	a,b
	call	draw_hex2
	inc	hl
	inc	de
	inc	de
	
	;inc	hl
	ld	a,(hl)
;	and	0x0f
	call	draw_hex2	; noise	
	inc	de

	inc	de
	inc	hl
	ld	a,(hl)
	and	0x3F
	call	draw_hex2	; mixer 
	inc	hl	
	inc	de
	inc	de
	
	
	ld	a,(hl)
	call	draw_fakehex	;vol a
	inc	hl
	inc	de
	ld	a,(hl)
	call	draw_fakehex	    ;vol b
	inc	hl
	inc	de
	ld	a,(hl)
	call	draw_fakehex	; vol	c
	inc	hl
	inc	de	
	ld	a,(SN_regVOLN)
	call	draw_fakehex	; envelope/noise	
	
	
	
	ld	hl,0
	ld	de,_TEMPAY
	ld	b,31;31
	call	draw_label_fast
	
;	call	debug_instruments	
	
	
	
	ret				
	
;replay_patline:
;	ret
	

		

	

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
	jr.	z,_dc_restNote	; 97 is a rest
	jr.	nc,_dc_noNote	; anything higher	than 97 are	no notes
	
	ld	(ix+CHIP_Note),a
	set	0,(ix+CHIP_Flags)		; bit0=1 ; trigger a note
	res	4,(ix+CHIP_Flags)		; set key for FM
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
	
	;--- Set the waveform  (if needed)
	inc	hl
	inc	hl
	ld	a,(hl)
	
	cp	16
	jp	c,.skip_soft
	
	ld	(FM_softvoice_req),a
	xor	a
	
.skip_soft:
	ld	(ix+CHIP_Voice),a
;	set	6,(ix+CHIP_Flags)
		
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
	ld	(ix+CHIP_Command),a
	;--- calculate cmd address
	add	a
	ld	hl,_CHIPcmdlist
	ld	d,0
	ld	e,a
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	inc	bc
	ld	a,(bc)		; get	parameter(s)
	inc	bc
	jp	hl			; jump to the command
	; END

;-------------------
; Rest the note
;===================
_dc_restNote:	
	res	1,(ix+CHIP_Flags)	; set	note bit to	0
;	res	4,(ix+CHIP_Flags)	; release key
	res	5,(ix+CHIP_Flags)	; sustain
	xor	a
	ld	a,(replay_previous_note)
	ld	(ix+CHIP_Note),a
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
	dw	_CHIPcmd7
	dw	_CHIPcmd8_env_mul
	dw	_CHIPcmd9_macro_offset
	dw	_CHIPcmdA_volSlide
	dw	_CHIPcmdB_scc_commands
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
	jr.	nz,_CHIPcmd0_trig
;	ld	(ix+CHIP_cmd_ToneAdd+1),0
;	ld	a,(ix+CHIP_cmd_detune)
	ld	(ix+CHIP_cmd_NoteAdd),0		
	res	3,(ix+CHIP_Flags)
;	ld	(ix+CHIP_cmd_ToneAdd),a
;	cp	16
;	ret	nc
;	ld	(ix+CHIP_cmd_ToneAdd+1),0
	ret	

_CHIPcmd0_trig:
	;--- Init values
	ld	(ix+CHIP_cmd_0),a
	set	3,(ix+CHIP_Flags)
;	xor	a
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
	jr.	z,_CHIPcmd1_retrig
	ld	(ix+CHIP_cmd_1),a

_CHIPcmd1_retrig:
	;--- Init values
	set	3,(ix+CHIP_Flags)
;	ld	(ix+CHIP_Timer),2
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
	jr.	z,_CHIPcmd2_retrig
	ld	(ix+CHIP_cmd_2),a	
	
_CHIPcmd2_retrig:
	;--- Init values
	set	3,(ix+CHIP_Flags)
;	ld	(ix+CHIP_Timer),2
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
	jr.	z,_CHIPcmd3_retrig
	ld	(ix+CHIP_cmd_3),a
	ld	(ix+CHIP_Timer),2
		
_CHIPcmd3_retrig:
	;--- Check if we have a	note on the	same event
	ld	h,(ix+CHIP_Flags)
	bit	0,h
	ret	z

	;-- determine which table to use
	bit 	7,h
	jp	nz,_cmd3_fm
_cmd3_psg:
	ld	hl,CHIP_ToneTable	;TRACK_ToneTable
	jp	99f
_cmd3_fm:
	ld	hl,CHIP_FM_ToneTable	;TRACK_ToneTable
	set	4,(ix+CHIP_Flags)		; FM notelink bit

99:
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

	res	0,(ix+CHIP_Flags)
	ret





	
_CHIPcmd4_vibrato:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; Vibrato with speed x and depth y.	This command 
	; will oscillate the frequency of the current note
	; with a sine wave. (You can change	the vibrato
	; waveform to a triangle wave, a square wave, or a
	; random table by	using	the E4x command).

	
	;--- Init values
	and	a
	jr.	z,_CHIP_cmd4_retrig
	ld	e,a
	
	;--- Set the speed
	rra
	rra
	rra
	rra
	and	$0f
	inc	a
	ld	(ix+CHIP_cmd_4_step),a	
	neg	
	ld	(ix+CHIP_Step),a	
	
	;-- set the depth
	ld	a,$0f
	and	e
	cp	9
	jp	c,99f
	ld	(ix+CHIP_cmd_4_step),0	
	ld	a,1
99:
	dec	a
	rrc	a
	rrc	a
	rrc	a
	ld	(ix+CHIP_cmd_4_depth),a	

;	;--- reverse detph. this is not good for stand alonereplayer?
;	ld	e,a
;	ld	a,8
;	sub	e
;	ld	(ix+CHIP_cmd_4_depth),a
;	ld	a,d
;	rra
;	rra
;	rra
;	rra
;	and	$0f
;	ld	(ix+CHIP_cmd_4_step),a
;	neg	
;	ld	(ix+CHIP_Step),a

_CHIP_cmd4_retrig:	
	set	3,(ix+CHIP_Flags)
;	xor	a
;	ld	(ix+CHIP_Timer),a
	
	ret
	
	

	
	
_CHIPcmd7:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	;  
	
	ret
	
	

	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This command set the envelope frequency using a
	; multiplier value (00-ff)
_CHIPcmd8_env_mul:
;	ld	d,a
;	xor	a
;	srl	d
;	rra	
;	srl	d
;	rra		
;	srl	d
;	rra	
	ld	(AY_regEnvL),a
;	ld	a,d
;	ld	(AY_regEnvH),a
	ret	

	  
_CHIPcmd9_macro_offset:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; This command, when used together with a	note,	
	; will start playing the sample at the position	xx 
	; (instead of position 0). If	xx is	00 (900), the 
	; previous value will be used.

	;--- Init values
	and	a
	jr.	z,_CHIPcmd9_retrig
	ld	(ix+CHIP_cmd_9),a
_CHIPcmd9_retrig:	
	set	3,(ix+CHIP_Flags)
	ld	(ix+CHIP_Timer),2		; timer is set as	we process cmd
						; before new notes.
	
	ret
	


_CHIPcmd5:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; portTone	+ volumeslide
	;--- Init values
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
	jr.	z,_CHIPcmdA_retrig
;	ld	(ix+CHIP_cmd_1),a

	;--- neg or	pos
	cp	16
	jr.	c,_CHIPcmdA_neg
	
	;-- pos
	rra		; only use high 4	bits
	rra
	rra
	rra
	and	$0f
	jr.	99f

	
_CHIPcmdA_neg:
	;-- neg


;	sla	a
	add	128
	
99:	ld	(ix+CHIP_cmd_A),a
	ld	(ix+CHIP_Timer),1
	
_CHIPcmdA_retrig:
	;--- Init values
	set	3,(ix+CHIP_Flags)
	ret



_CHIPcmdB_scc_commands:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	and	1
	ld	(replay_chan_setup),a
	jp	z,0f
	
	; set PSG
	res	7,(ix+CHIP_Flags)
	jp	99f
	
	; set FM
0:	set	7,(ix+CHIP_Flags)
99:
	ret	
	
_CHIPcmdC_drum:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	cp	MAX_DRUMS		;- only 20 drum macros allowed
	ret	nc

	and	a
	jr.	nz,0f
	;--- DRUM reset
	push	bc
	ld	de,FM_DRUM_Flags
	ld	hl,DRM_DEFAULT_values
	ld	bc,10
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
	jp	nz,88b

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
	set	3,(ix+CHIP_Flags)
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
	and	0xf0	; get	the extended comand
	jr.	z,_CHIPcmdE_shortarp
	cp	0x60	; track detune
	jr.	z,_CHIPcmdE_trackdetune
	cp	0xe0
	jp	z,_CHIPcmdE_envelope
	cp	0x10	
	jr.	z,_CHIPcmdE_fineup
	cp	0x20
	jr.	z,_CHIPcmdE_finedown
	cp	0xd0	; delay cmd?
	jr.	z,_CHIPcmdE_delay
	cp	$40	; set	vibrato
	jr.	z,_CHIPcmdE_vibrato
	cp	0x50	; note_link
	jr.	z,_CHIPcmdE_notelink
	cp	0x70	; note_link
	jr.	z,_CHIPcmdE_notesus
	cp	0x80	; global transpose
	jr.	z,_CHIPcmdE_transpose
	cp	0xc0	; note cut
	jr.	z,_CHIPcmdE_notecut

	ret


_CHIPcmdE_shortarp:
	ld	a,d			;- Get the parameter
	and	0x0f
;	jr.	z,_CHIPcmdE_shortarp_retrig	;-- Jump if value is 0

	ld	(ix+CHIP_cmd_E),a		; store the halve not to add
	ld	(ix+CHIP_Timer),0
_CHIPcmdE_shortarp_retrig:
	set	3,(ix+CHIP_Flags)		; command active		
	ld	(ix+CHIP_Command),0x10
	ret	

_CHIPcmdE_notecut:
	set	3,(ix+CHIP_Flags)
	ld	(ix+CHIP_Command),0x1C		; set	the command#
	ld	a,d
	and	0x0f
	inc	a
	ld	(ix+CHIP_Timer),a		; set	the timer to param y
	ret
	
_CHIPcmdE_delay:
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

_CHIPcmdE_vibrato:
;	ld	hl,CHIP_Vibrato_sine
;	ld	a,d
;	and	3
;	jr.	z,99f
;	ld	de,32
;88:	add	hl,de
;	dec	a
;	jr.	nz,88b
;99:	ld	(replay_vib_table),hl
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
	ld	(ix+CHIP_cmd_E),a
	ld	(ix+CHIP_Timer),2
	set	3,(ix+CHIP_Flags)		; command active
	ld	(ix+CHIP_Command),0x12	; set	the command#
	ret

_CHIPcmdE_notelink:
	set	4,(ix+CHIP_Flags)		; FM notelink bit
	res	0,(ix+CHIP_Flags)
	ret
_CHIPcmdE_notesus:
	ld	a,d
	and	a
	jp	z,99f
	set	5,(ix+CHIP_Flags)
	ret
99:
	res	5,(ix+CHIP_Flags)
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
	res	3,(ix+CHIP_Flags)		; command in-active

	ld	a,d
	add	a
	ld	hl,CHIP_ToneTable;(replay_Tonetable)
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

_CHIPcmdE_envelope:
	set	2,(IX+CHIP_Flags)
	ld	a,d
	and	$0f
	jp	z,_CHIPcmdE_envelope_retrig

	;--- store new envelope shape (anything other than 0 is written)
	ld	(AY_regEnvShape),a
_CHIPcmdE_envelope_retrig:
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

;===========================================================
; ---replay_process_drum
; Process the current drum macro
; 
;===========================================================
replay_process_drum:
	ld	a,(FM_DRUM_LEN)
	and	a
	ret	z		; do nothing if end of macro is reached
	dec	a
	ld	(FM_DRUM_LEN),a

	ld	bc,(FM_DRUM_MACRO)
	ld	d,0
	;--- process step
	; drum bits
	ld	a,(bc)
	and	a
	jr	z,0f			; jump if no data
;	set 5,a			; key on for percussion
	ld	(FM_DRUM),a		; store the percusion bits
	set	0,d


0:	
	sla	d
	inc	bc
	; tone Basedrum
	ld	a,(bc)
	and	a
	jp	z,0f			; jump if no data
	bit	7,a
	jp	nz,1f			; tone deviation

	; Note
	ld	hl,(replay_Tonetable)
	add	a
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(hl)
	ld	(FM_freqreg1),a
	inc	hl
	ld	a,(hl)
	ld	(FM_freqreg1+1),a	
	jr.	4f				; continue
1:
	; Tone deviation
	bit	6,a
	jp	z,2f 			; positive
	;negative
	and	00111111b
	neg
	ld	hl,(FM_freqreg1)
	dec	h
	add	a,l
	ld	l,a
	adc a,h
	sub	l
	ld	h,a
99:
	jr.	3f
2:	
	;positive
	ld	hl,(FM_freqreg1)
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
3:
	ld 	(FM_freqreg1),hl

4:	set	0,d

0:
	sla	d
	inc	bc
	; volume Basedrum
	ld	a,(bc)
	and	a
	jp	z,0f			; jump if no data
	set	0,d
	

	;--- apply main volume balance
	ld	hl,replay_mainvol
	CP	(HL)
	jr.	C,88F
	sub	(hl)
	jr.	99f
88:	xor	a
99:	
	ld	l,a
	ld	a,0x0f
	sub	l
	ld	(FM_volreg1),a

	
	
	
0:
	sla	d
	inc	bc
	; tone Snare Hhat
	ld	a,(bc)
	and	a
	jp	z,0f			; jump if no data
	bit	7,a
	jp	nz,1f			; tone deviation

	; Note
	ld	hl,(replay_Tonetable)
	add	a
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(hl)
	ld	(FM_freqreg2),a
	inc	hl
	ld	a,(hl)
	ld	(FM_freqreg2+1),a	
	jr.	4f				; continue
1:
	; Tone deviation
	bit	6,a
	jp	z,2f 			; positive
	;negative
	and	00111111b
	neg
	ld	hl,(FM_freqreg1)
	dec	h
	add	a,l
	ld	l,a
	adc a,h
	sub	l
	ld	h,a
99:
	jr.	3f
2:	
	;positive
	ld	hl,(FM_freqreg2)
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
3:
	ld 	(FM_freqreg2),hl

4:	set	0,d

0:
	sla	d
	inc	bc
	; volume snare Hhat
	ld	a,(bc)
	and	a
	jp	z,0f			; jump if no data
	set	0,d

	;high vol
	and	0xf0
	jp	z,1f			; no high update
	
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
	ld	a,(FM_volreg2)
	and	0x0f
	ld	h,a
	ld	a,0x0f
	sub	l
[4]	sla	a
	or	h
	ld	(FM_volreg2),a

1:	;- low vol	
	ld	a,(bc)
	and	0x0f
	jp	z,0f			; no low update

	;--- apply main volume balance
	ld	hl,replay_mainvol
	CP	(HL)
	jr.	C,88F
	sub	(hl)
	jr.	99f

88:	xor	a
99:	
	ld	l,a
	ld	a,(FM_volreg2)
	and	0xf0
	ld	h,a
	ld	a,0x0f
	sub	l
	or	h
	ld	(FM_volreg2),a
	
0:
	sla	d
	inc	bc
	; tone Cy Tom
	ld	a,(bc)
	and	a
	jp	z,0f			; jump if no data
	bit	7,a
	jp	nz,1f			; tone deviation

	; Note
	ld	hl,(replay_Tonetable)
	add	a
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(hl)
	ld	(FM_freqreg3),a
	inc	hl
	ld	a,(hl)
	ld	(FM_freqreg3+1),a	
	jr.	4f				; continue
1:
	; Tone deviation
	bit	6,a
	jp	z,2f 			; positive
	;negative
	and	00111111b
	neg
	ld	hl,(FM_freqreg1)
	dec	h
	add	a,l
	ld	l,a
	adc a,h
	sub	l
	ld	h,a
99:
	jr.	3f
2:	
	;positive
	ld	hl,(FM_freqreg3)
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
3:
	ld 	(FM_freqreg3),hl

4:	set	0,d

0:

	sla	d
	inc	bc
	; volume Cy Tom
	ld	a,(bc)
	and	a
	jp	z,0f			; jump if no data
	set	0,d
	;high vol
	and	0xf0
	jp	z,1f			; no high update
	
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
	ld	a,(FM_volreg3)
	and	0x0f
	ld	h,a
	ld	a,0x0f
	sub	l
[4]	sla	a
	or	h
	ld	(FM_volreg3),a	


1:	;- low vol	
	ld	a,(bc)
	and	0x0f
	jp	z,0f			; no low update

	;--- apply main volume balance
	ld	hl,replay_mainvol
	CP	(HL)
	jr.	C,88F
	sub	(hl)
	jr.	99f

88:	xor	a
99:	
	ld	l,a
	ld	a,(FM_volreg3)
	and	0xf0
	ld	h,a
	ld	a,0x0f
	sub	l
	or	h
	ld	(FM_volreg3),a
	
0:
	sla	d
	inc	bc
	ld	hl,FM_DRUM_MACRO
	ld	(hl),c
	inc	hl
	ld	(hl),b
	

	ld	a,d
	ld	(FM_DRUM_Flags),a
	ret


;	;--- set FRM FLAGs in C (and set to next drum channel)
;	ld	a,(FM_DRUM_Flags)
;	srl	a
;	ld	c,a
;	;--- apply drum mask
;	ld	b,(hl)
;	ld	a,(FM_DRUM)
;	or	b
;	ld	(FM_DRUM),a
;	inc	hl
;	
;	;--- apply tone value
;	ld	b,(hl)
;	inc	hl
;	ld	a,(hl)
;	inc	hl
;	or	b
;	jp	z,_rpd_no_tone
;	xor	b
;	set	5,c			; set tone update flag
;_rpd_no_tone:	
;	ld	(de),a
;	inc	de
;	ld	a,b
;	ld	(de),a
;	inc	de
;	
;	ld	a,(hl)
;	inc	hl
;	and	a
;	jp	z,_rpd_no_vol
;	set	2,c			; set the volume flag
;_rpd_no_vol:
;	ld	b,a
;	ld	a,c
;	ld	(FM_DRUM_Flags),a
;	
;	;--- low volume
;	ld	a,b
;	and	0x0f
;	jp	z,0f
;		ld	c,a
;
;		ld	a,0x0f	;- invert volume
;		sub	c
;		ld	c,a
;		
;		ld	a,(de)
;		and 0xf0
;		or	c
;		ld	(de),a
;0:	;--- high volume
;	ld	a,b
;	and	0xf0
;	jp	z,0f
;		ld	c,a
;		
;		ld	a,0xf0	;- invert volume
;		sub	c
;		ld	c,a
;		
;		ld	a,(de)
;		and 0x0f
;		or	c
;		ld	(de),a	
;
;0:	
;	ret
;	;end
	
	
	
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
	rrc	(hl)
	;srl	(hl)
	
	
;	ld	a,(current_song)
	call	set_songpage

	;===== 
	; Speed equalization check
	;=====
	ld	a,(equalization_flag)			; check for speed equalization
	and	a
	jp	nz,_pcAY_noNoteTrigger			; Only process instruments
	
	;=====
	; COMMAND
	;=====
	bit	3,(ix+CHIP_Flags)
	jr.	z,_pcAY_noCommand
	
	ld	hl,_pcAY_cmdlist
	ld	a,(ix+CHIP_Command)
	add	a
	ld	e,a
	ld	d,0
	add	hl,de
	
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a	
	jp	(hl)
	
_pcAY_noCommand:	
_pcAY_commandEND:

	;=====
	; NOTE
	;=====
	;--- Check if we need to trigger a new note
	bit	0,(ix+CHIP_Flags)
	jr.	z,_pcAY_noNoteTrigger
	
;	;--- Check for CMD Edx
;	bit	3,(ix+CHIP_Flags)
;	jr.	z,_pcAY_triggerNote
;	ld	a,0x1D		; Ed.
;	cp	(ix+CHIP_Command)
;	jr.	z,_pcAY_noNoteTrigger

_pcAY_triggerNote:	
	;--- get new Note
	res	0,(ix+CHIP_Flags)		; reset trigger note flag
	set	1,(ix+CHIP_Flags)		; set	note active	flag
;	res	2,(ix+CHIP_Flags)		; key flag for FM
	; init macrostep but check for cmd9
	xor	a
	ld	b,a
	bit	3,(ix+CHIP_Flags)
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

_pcAY_noNoteTrigger:
	;Get note freq
	ld	a,(ix+CHIP_Note)
	add	a,(ix+CHIP_cmd_NoteAdd)
	add	a
	ld	(ix+CHIP_cmd_NoteAdd),0	
	ex	af,af'			;'store the	note offset

	;==============
	; Macro instrument
	;==============
	bit	1,(ix+CHIP_Flags)
	jr.	z,_pcAY_noNoteActive

	ld	(_SP_Storage),SP

	
	;-- skip macro if not PSG
;	bit 	7,(ix+CHIP_Flags)
;	jr.	nz,_pcAY_FMinstr



	
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
	jp	z,_noVoicelink	
	
	res	7,h			; reset bit
	set	6,(ix+CHIP_Flags)	; set voice update flag
	ld	a,c
	ld	(ix+CHIP_Voice),c	; set new voice to be loaded
	res	7,c			; reset noise bit

_noVoicelink:
	
;--- Is tone active this step?
	bit	7,b		; do we have tone?
	jr.	z,_pcAY_noTone

	;-- enable tone output
	
	ld	a,(SCC_regMIXER)
	or	16
	ld	(SCC_regMIXER),a
_pcAY_noTone:



	ld	e,(ix+CHIP_ToneAdd)	; get	the current	deviation	
	ld	d,(ix+CHIP_ToneAdd+1)
	
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
	ld	(ix+CHIP_ToneAdd),l
	ld	(ix+CHIP_ToneAdd+1),h

	;-- skip macro if not PSG
	bit 	7,(ix+CHIP_Flags)
	jr.	nz,pcAY_FMinstr
	
	ex	de,hl				; store macro deviation	in [DE]

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
	ld	a,(SCC_regMIXER)
	or	128
	ld	(SCC_regMIXER),a

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
	ld	a,(SCC_regMIXER)
	or	128
	ld	(SCC_regMIXER),a
	
	; volume
	ld	a,c
	rrca
	rrca	
	rrca
	rrca
	and	0x07
	ld	(AY_regNOISE),a	

debug:	

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
	jp	nc,99f
	inc	d
99:
	ld	a,(de)			
	ld	(SN_regVOLN),a



ENDIF
	

_pcAY_noNoise:
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
	ld	b,a		; set	deviation in b
	ld	a,c		; set	current volume add back	in c
	jr.	nz,1f
	;--- add 
	add	b
	cp	16
	jr.	c,4f
	ld	a,15
	jr.	4f
1:
	;--- sub 
	sub	b
	cp	16
	jr.	c,4f
	xor	a
4:
	ld	(ix+CHIP_VolumeAdd),a
	ld	c,a
	
IFDEF TTSMS
	ld	a,(SCC_regMIXER)
	and	16

	jp	nz,7f
	xor	a
	ld	(SCC_regVOLF),a	
	ret
	
7:
	ld	a,c
ENDIF
	;---- envelope check
	; is done here to be able to continue
	; macro volume values.
	bit	2,(IX+CHIP_Flags)
	jp	z,_noEnv		; if not set then normal volume calculation
	ld	a,16			; set volume to 16 == envelope
	ld	(SCC_regVOLF),a
	ret	
	
_noEnv:
	or	(ix+CHIP_Volume)
	ld	c,a
	ld	a,(IX+CHIP_cmd_VolumeAdd)	
	rla						; C flag contains devitation bit (C flag was reset in the previous OR)
	jr.	c,_sub_Vadd
_add_Vadd:
	add	a,c
	jr.	nc,_Vadd
	ld	a,c
	or	0xf0
	jr.	_Vadd
_sub_Vadd:
	ld	b,a
	xor	a
	sub	b
	ld	b,a
	ld	a,c
	sub	a,b
	jr.	nc,_Vadd
	ld	a,c
	and	0x0f	
	;-- next is _Vadd
;	bit	7,(IX+CHIP_cmd_VolumeAdd)
;	jr.	nz,1f
;;--- pos
;	add	(ix+CHIP_cmd_VolumeAdd)
;	jr.	nc,99f
;	ld	a,l
;	jr.	99f
;1:
;;--- neg
;	sub	(ix+CHIP_cmd_VolumeAdd)
;	jr.	nc,99f
;	ld	a,l
;	jr.	99f
;99:
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
	ld	(SCC_regVOLF),a
	
	ret
	

_pcAY_noNoteActive:
	pop	hl
	xor	a
	ld	(SCC_regVOLF),a
	
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
	cp	$60		; $46 is the strict limit
	jr.	c,_wrap_skip		; stop if smaller
	
	push	hl
	;--- Set 12 notes (1 octave) higher
	ld	a,(ix+CHIP_Note)
	add	12
	cp	96
	jr.	c,99f
	add	160		; wrap notes
99:
	ld	(ix+CHIP_Note),a
	;--- Set new ToneSlide Add
	rr	h
	rr	l			
	ld	h,0
	xor	a
	ex	de,hl
	sbc	hl,de			; subtract new wraped base tone - note tone to get delta slide add.
	ld	(ix+CHIP_cmd_ToneSlideAdd),l
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),h	
	pop	hl
	jr.	_wrap_skip


wrap_lowcheck:
	ld	a,l
	cp	$90		; $ad is the strict limit
	jr.	nc,_wrap_skip		; stop if smaller
	
	push	hl
	;--- Set 12 notes (1 octave) lower
	ld	a,(ix+CHIP_Note)
	sub	12
	cp	96
	jr.	c,99f
	sub	160			; wrap notes
99:
	ld	(ix+CHIP_Note),a
	;--- Set new ToneSlide Add
;	xor	a
	ld	h,0
	add	hl,de
;	rl	l
;;	rl	h			
;	ld	h,1
;	xor	a
;	ex	de,hl
;	sbc	hl,de			; subtract new wraped base tone - note tone to get delta slide add.
	ld	(ix+CHIP_cmd_ToneSlideAdd),l
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),h	
	pop	hl
_wrap_skip:

	; replace the last pushed value on stack
	pop	de
	ex	de,hl
	ld	(hl),e
	inc	hl
	ld	(hl),d

;	;---- change voice
;	bit	7,c
;	jr.	nz,_pcFM_noVoice
;	
;	ld	a,c
;	and	31
;	jp	z,_pcFM_noVoice
;	cp	(ix+CHIP_Voice)	; get	the current	deviation	
;	jp	z,_pcFM_noVoice
;
;	;/// Set here the new voice	
;	ld	(ix+CHIP_Voice),a
;	set	6,(ix+CHIP_Flags)

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
	ld	b,a		; set	deviation in b
	ld	a,c		; set	current volume add back	in c
	jr.	nz,1f
	;--- add 
	add	b
	cp	16
	jr.	c,4f
	ld	a,15
	jr.	4f
1:
	;--- sub 
	sub	b
	cp	16
	jr.	c,4f
	xor	a
4:
	ld	(ix+CHIP_VolumeAdd),a
	or	(ix+CHIP_Volume)
	ld	c,a
	ld	a,(IX+CHIP_cmd_VolumeAdd)	
	rla						; C flag contains devitation bit (C flag was reset in the previous OR)
	jr.	c,_sub_FMVadd
_add_FMVadd:
	add	a,c
	jr.	nc,_FMVadd
	ld	a,c
	or	0xf0
	jr.	_FMVadd
_sub_FMVadd:
	ld	b,a
	xor	a
	sub	b
	ld	b,a
	ld	a,c
	sub	a,b
	jr.	nc,_FMVadd
	ld	a,c
	and	0x0f	
	;-- next is _Vadd
_FMVadd:

	;--- Volume
;	ld	a,15	; debug max vol
	or	(ix+CHIP_Volume)
	ld	c,a
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
	ld	(SCC_regVOLF),a
	
	ret
	

	









	
AA_COMMANDS_process:	
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
	ld	a,(ix+CHIP_Timer)
	bit	0,a
	jr.	z,99f

	;--- set x
		ld	(ix+CHIP_Timer),2
		xor	a
		ld	a,(ix+CHIP_cmd_0)
		and	0xf0
		rra
		rra
		rra
		rra
		ld	(ix+CHIP_cmd_NoteAdd),a		
		jr.	_pcAY_commandEND

	
99:
	bit	1,a
	jr.	z,99f

	;--- set y
		ld	(ix+CHIP_Timer),0
		ld	a,(ix+CHIP_cmd_0)
		and	0x0f
		ld	(ix+CHIP_cmd_NoteAdd),a		
		jr.	_pcAY_commandEND
	
99:
	;--- set none
	ld	(ix+CHIP_Timer),1
;	ld	(ix+CHIP_cmd_NoteAdd),0		
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
	bit	7,h
	jr.	z,_pcAY_cmd3_sub
_pcAY_cmd3_add:
	;pos slide
	add	a,l
	ld	(ix+CHIP_cmd_ToneSlideAdd),a
	jr.	nc,_pcAY_commandEND
	inc	h					
	bit	7,h
	jr.	z,_pcAY_cmd3_stop			; delta turned pos ?
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),h
	jr.	_pcAY_commandEND
_pcAY_cmd3_sub:
	;negative slide	
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
	res	3,(ix+CHIP_Flags)
	ld	(ix+CHIP_cmd_ToneSlideAdd),0
	ld	(ix+CHIP_cmd_ToneSlideAdd+1),0	
	jr.	_pcAY_commandEND


	;-- vibrato	
_pcAY_cmd4:
	ld 	hl,CHIP_Vibrato_sine
	
	;--- Get next step
	ld	a,(IX+CHIP_Step)
	add	(ix+CHIP_cmd_4_step)
	and	$3F			; max	64
	ld	(ix+CHIP_Step),a
	
	bit	5,a			; step 32-63 the neg	
	jp	z,.pos	
	
.neg:
	and	$1f	; make it 32 steps again
	add	a,(ix+CHIP_cmd_4_depth)
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(hl)
	neg
	jp	z,.zero			; $ff00 gives strange result ;)	
	ld	(ix+CHIP_cmd_ToneAdd),a
	ld	(ix+CHIP_cmd_ToneAdd+1),0xff
	jp	_pcAY_commandEND	

.pos:
	add	a,(ix+CHIP_cmd_4_depth)
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(hl)
.zero:	
	ld	(ix+CHIP_cmd_ToneAdd),a
	ld	(ix+CHIP_cmd_ToneAdd+1),0
	jp	_pcAY_commandEND	

	
	
	
;	ld	hl,(replay_vib_table)
;	;--- Get next step
;	ld	a,(IX+CHIP_Step)
;	add	(ix+CHIP_cmd_4_step)
;	and	$3F			; max	32
;	ld	(ix+CHIP_Step),a
;	
;	bit	5,a			; step 32-63 the neg	
;	jr.	z,_pcAY_cmd4pos
;
;; neg	
;	and	$1f
;	add	l
;	ld	l,a
;	jr.	nc,99f
;	inc	h
;99:
;	ld	a,(hl)
;	;apply depth
;	ld	b,(ix+CHIP_cmd_4_depth)
;11:	srl	a
;	djnz	11b
;;	and	$0f
;
;	neg
;	jr.	z,33f			; $ff00 gives strange result ;)	
;	ld	(ix+CHIP_cmd_ToneAdd),a
;	ld	(ix+CHIP_cmd_ToneAdd+1),0xff
;	jr.	_pcAY_commandEND
;
;_pcAY_cmd4pos:	
;;	and	$1f
;	add	l
;	ld	l,a
;	jr.	nc,99f
;	inc	h
;99:
;	ld	a,(hl)
;	;apply depth
;	ld	b,(ix+CHIP_cmd_4_depth)
;11:	srl	a
;	djnz	11b
;;	and	$0f
;33:	ld	(ix+CHIP_cmd_ToneAdd),a
;	ld	(ix+CHIP_cmd_ToneAdd+1),0
;	jr.	_pcAY_commandEND
		
	

_pcAY_cmd5:
	call	_pcAY_cmdasub
	jr.	_pcAY_cmd3
	
	
;	jr.	z,_pcAY_cmd5_pos
;	;--- neg
;	and	$1f
;	ld	(ix+CHIP_Timer),a
;	ld	a,(ix+CHIP_cmd_VolumeAdd)
;	and	a
;	jr.	z,_pcAY_cmd3
;	sub	16
;;	cp	-16		; only store values smaller then -15
;;	jr.	z,_pcAY_cmd3
;	ld	(ix+CHIP_cmd_VolumeAdd),a
;	jr.	_pcAY_cmd3
;_pcAY_cmd5_pos:
;	ld	(ix+CHIP_Timer),a
;	ld	a,(ix+CHIP_cmd_VolumeAdd)
;	add	16
;	jr.	z,_pcAY_cmd3
;	inc	a
;	cp	16		; only store values smaller then -15
;	jr.	z,_pcAY_cmd3
;	ld	(ix+CHIP_cmd_VolumeAdd),a
;	jr.	_pcAY_cmd3		




_pcAY_cmd6:
	call	_pcAY_cmdasub
	jr.	_pcAY_cmd4		

;	;retrig
;	dec	(ix+CHIP_Timer)
;	jr.	nz,_pcAY_cmd4
;	
;	; vol	slide
;	ld	a,(ix+CHIP_cmd_A)
;	bit	7,a		;- if	set vol slide is neg
;	jr.	z,_pcAY_cmd6_pos
;	;--- neg
;	and	$1f
;	ld	(ix+CHIP_Timer),a
;	ld	a,(ix+CHIP_cmd_VolumeAdd)
;	and	a
;	jr.	z,_pcAY_cmd4
;	sub	16
;;	dec	a
;;	cp	-16		; only store values smaller then -15
;;	jr.	z,_pcAY_cmd4
;	ld	(ix+CHIP_cmd_VolumeAdd),a
;	jr.	_pcAY_cmd4
;_pcAY_cmd6_pos:
;	ld	(ix+CHIP_Timer),a
;	ld	a,(ix+CHIP_cmd_VolumeAdd)
;	add	16
;	jr.	z,_pcAY_cmd4
;;	inc	a
;;	cp	16		; only store values smaller then -15
;;	jr.	z,_pcAY_cmd4
;	ld	(ix+CHIP_cmd_VolumeAdd),a



_pcAY_cmd7:
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND
_pcAY_cmd8:
	res	3,(ix+CHIP_Flags)
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

_pcAY_cmdasub
	dec	(ix+CHIP_Timer)
;	jr.	nz,_pcAY_cmd3
	ret	nz
		
	; vol	slide
	ld	a,(ix+CHIP_cmd_A)
	ld	d,a
	and	0x7f
	ld	(ix+CHIP_Timer),a
	ld	a,(IX+CHIP_cmd_VolumeAdd)
	bit	7,d
	jr.	z,_pcAY_cmda_inc
_pcAY_cmda_dec:
	cp	0x88
	ret	z
	sub	8
	ld	(ix+CHIP_cmd_VolumeAdd),a
	ret
_pcAY_cmda_inc:
	cp	0x78
	ret	z
	add	8	
	ld	(ix+CHIP_cmd_VolumeAdd),a
	ret
	
;	; vol	slide
;	ld	a,(ix+CHIP_cmd_A)
;	bit	7,a		;- if	set vol slide is neg
;	jr.	z,_pcAY_cmda_pos
;	;--- neg
;	and	$1f
;	ld	(ix+CHIP_Timer),a
;	ld	a,(ix+CHIP_cmd_VolumeAdd)
;	sub	16
;	jr.	c,_pcAY_commandEND
;	dec	a
;	cp	-16		; only store values smaller then -15
;	jr.	z,_pcAY_commandEND
;	ld	(ix+CHIP_cmd_VolumeAdd),a
;	jr.	_pcAY_commandEND
;_pcAY_cmda_pos:
;	ld	(ix+CHIP_Timer),a
;	ld	a,(ix+CHIP_cmd_VolumeAdd)
;	add	16
;	jr.	c,_pcAY_commandEND
;;	inc	a
;;	cp	16		; only store values smaller then 16
;;	jr.	z,_pcAY_commandEND
;	ld	(ix+CHIP_cmd_VolumeAdd),a


;	jr.	_pcAY_commandEND		
	


_pcAY_cmdb:
	
	jr.	_pcAY_commandEND
_pcAY_cmdc:
;	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND
_pcAY_cmdd:
	;call	replay_setnextpattern
	ld	a,64
	ld	(replay_line),a
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND
	
_pcAY_cmde:
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND
_pcAY_cmdf:
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND
;--- SHORT ARP
_pcAY_cmd10:
	dec	(ix+CHIP_Timer)
	bit	0,(ix+CHIP_Timer)
	jr.	z,_pcAY_commandEND
	ld	a,(ix+CHIP_cmd_E)
	ld	(ix+CHIP_cmd_NoteAdd),a		
	jr.	_pcAY_commandEND
	
_pcAY_cmd11:
	dec	(ix+CHIP_Timer)
	jr.	nz,_pcAY_commandEND

	res	3,(ix+CHIP_Flags)
	ld	a,(ix+CHIP_cmd_ToneSlideAdd)
	add	(ix+CHIP_cmd_E)
	ld	(ix+CHIP_cmd_ToneSlideAdd),a
	jr.	nc,_pcAY_commandEND	
	inc	(ix+CHIP_cmd_ToneSlideAdd+1)
	jr.	_pcAY_commandEND	

_pcAY_cmd12:
	dec	(ix+CHIP_Timer)
	jr.	nz,_pcAY_commandEND

	res	3,(ix+CHIP_Flags)
	ld	a,(ix+CHIP_cmd_ToneSlideAdd)
	sub	(ix+CHIP_cmd_E)
	ld	(ix+CHIP_cmd_ToneSlideAdd),a
	jr.	nc,_pcAY_commandEND	
	dec	(ix+CHIP_cmd_ToneSlideAdd+1)
	jr.	_pcAY_commandEND	

_pcAY_cmd13:
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd14:
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd15:
;	dec	(ix+CHIP_Timer)
;	jr.	nz,_pcAY_commandEND
;
;	res	3,(ix+CHIP_Flags)
;	ld	a,(ix+CHIP_cmd_E)
;	ld	d,a
;	ld	e,(ix+CHIP_cmd_ToneAdd)
;	add	e
;	ld	(ix+CHIP_ToneAdd),a
;	jr.	nc,_pcAY_commandEND	
;	
;	bit	7,d
;	jr.	z,1f
;	dec	(ix+CHIP_ToneAdd+1)
;	jr.	_pcAY_commandEND	
;1:	inc	(ix+CHIP_ToneAdd+1)
;	jr.	_pcAY_commandEND	
;
;
;
;	

_pcAY_cmd16:
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd17:
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd18:
	res	3,(ix+CHIP_Flags)
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
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd1b:
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd1c:
	dec	(ix+CHIP_Timer)
	jp	nz,_pcAY_commandEND
	
	; stop note
	res	1,(ix+CHIP_Flags)	; set	note bit to	0
	res	3,(ix+CHIP_Flags)
	jp	_pcAY_commandEND	
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
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd1f:
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
_pcAY_cmd20:
	res	3,(ix+CHIP_Flags)
	jr.	_pcAY_commandEND	
	
_pcAY_cmd21:
	;=================
	; Waveform PWM / Duty Cycle
	;=================
;	res	3,(ix+CHIP_Flags)	; reset command
;	res	6,(ix+CHIP_Flags)	; reset normal wave update
;
;	;get the waveform	start	in [DE]
;	ld	hl,_0x9800
;	ld	a,iyh		;ixh contains chan#
;	rrca			; a mac value is 4 so
;	rrca			; 3 times rrca is	X32
;	rrca			; max	result is 128.
;	add	a,l
;	ld	l,a
;	jr.	nc,99f
;	inc	h
;99:
;	ld	b,(ix+CHIP_cmd_B)
;	inc	b
;
;	ld	c,96	
;	ld	a,32
;	sub	b
;_wspw_loop_h:
;	ld	(hl),c
;	inc	hl
;	djnz	_wspw_loop_h
;	
;	and	a
;	jr.	z,_pcAY_commandEND
;	
;	ld	c,-96
;	ld	b,a
;_wspw_loop_l:
;	ld	(hl),c
;	inc	hl
;	djnz	_wspw_loop_l
;
	jr.	_pcAY_commandEND
	
_pcAY_cmd22:
	;=================
	; Waveform Cut
	;=================

;	res	3,(ix+CHIP_Flags)	; reset command
;	res	6,(ix+CHIP_Flags)	; reset normal wave update
;
;	;get the waveform	start	in [DE]
;	ld	de,_0x9800
;	ld	a,iyh		;ixh contains chan#
;	rrca			; a mac value is 4 so
;	rrca			; 3 times rrca is	X32
;	rrca			; max	result is 128.
;	add	a,e
;	ld	e,a
;	jr.	nc,99f
;	inc	d
;99:
;	ld	a,(ix+CHIP_Waveform)
;	add	a,a
;	add	a,a
;	add	a,a	
;
;	ld	l,a
;	ld	h,0
;	add	hl,hl
;	add	hl,hl
;		
;	ld	  bc,_WAVESSCC
;	add	  hl,bc
;
;	ld	a,(ix+CHIP_cmd_B)
;	inc	a
;	add	a
;	ld	c,a
;	ld	b,0
;	ldir
;	
;	sub	32
;	neg	
;	jr.	z,_pcAY_commandEND	
;	
;	ld	b,a
;	xor	a
;_wsc_l:
;	ld	(de),a
;	inc	de
;	djnz	_wsc_l
	
	jr.	_pcAY_commandEND
	
_pcAY_cmd23:	
	jr.	_pcAY_commandEND	
_pcAY_cmd24:
	;=================
	; Waveform Compress
	;=================
;	res	3,(ix+CHIP_Flags)	; reset command
;	res	6,(ix+CHIP_Flags)	; reset normal wave update
;
;	;get the waveform	start	in [DE]
;	ld	de,_0x9800
;	ld	a,iyh		;ixh contains chan#
;	rrca			; a mac value is 4 so
;	rrca			; 3 times rrca is	X32
;	rrca			; max	result is 128.
;	add	a,e
;	ld	e,a
;	jr.	nc,99f
;	inc	d
;99:
;	ld	a,(ix+CHIP_Waveform)
;	add	a,a
;	add	a,a
;	add	a,a	
;
;	ld	l,a
;	ld	h,0
;	add	hl,hl
;	add	hl,hl
;		
;	ld	  bc,_WAVESSCC
;	add	  hl,bc
;
;	ld	a,(ix+CHIP_cmd_B)
;	ld	bc,0x0040
;	rrca	; x32
;	rrca
;	rrca
;	add	31
;	ld	iyl,a		; fraction
;	xor	a	
;_wcomp_loop:
;	ldi			
;	dec	c
;	jr.	z,1f
;	add	iyl
;	jr.	nc,_wcomp_loop
;	inc	hl
;	inc	b
;	dec	c
;	dec	c
;	jr.	nz,_wcomp_loop
;	
;	;--- remaining data
;1:
;	dec	hl
;	ld	a,(hl)
;2:	ld	(de),a
;	inc	de
;	djnz	2b
	jr.	_pcAY_commandEND	
	
;===========================================================
; ---replay_route
; Output the data	to the CHIP	registers
; 
; WILL DISABLE INTERRUPTS !!!!
;===========================================================
replay_route:

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
	ld	b,0
	ld	a,(psgport)
	ld	c,a
	ld	hl,AY_registers
_comp_loop:	
	out	(c),b
	ld	a,(hl)
	add	1
	inc	c
	out	(c),a
	inc	hl
	ld	a,(hl)
	adc	a,0
	inc	b
	dec	c
	out	(c),b	
	inc	hl
	inc	c
	out	(c),a
	dec	c
	inc	b
	ld	a,6
	cp	b
	jp	nz,_comp_loop
	
	ld	a,b	
	
	
_ptAY_loop:
	out	(c),a
	inc	c
	outi
	dec	c
	inc	a
	cp	11
	jr	nz,_ptAY_loop

	;--- envelope freq update?

	ld	a,(hl)
	and	a
	jp	z,99f		; if bit 0 is not set no update

	ld	b,11
	out 	(c),b
	inc	c
	out	(c),a
	dec	c
	ld	(hl),0	
99:	
	ld	a,(AY_regEnvShape)
	and	a
	jp	z,_ptAY_noEnv
	
	ld	b,13
	out	(c),b
	inc	c
	out 	(c),a

	xor	a
	ld	(AY_regEnvShape),a	;reset the envwrite
	
	
_ptAY_noEnv:


ELSE
route_SN:
	ld	a,(_CONFIG_PSGPORT)
	ld	c,$3f
99:	
	; vol chan 1
	ld	a,(AY_regVOLA)
	inc	a
	neg
	and	$0f
	or	10010000b
	out	(c),a	
	
	; vol chan 2
	ld	a,(AY_regVOLB)
	inc	a
	neg
	and	$0f
	or	10110000b
	out	(c),a		
		
;	;-- check if we need 3rd psg
;	ld	a,10110000b
;	cp	b
;	jp	z,99f
		
	; vol chan 3
	ld	a,(AY_regVOLC)
	inc	a
	neg
	and	$0f
	or	11010000b 
	out	(c),a			

;99:	
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
	jp	z,0f
	ld	(hl),a
	or	11100000b
;	ld	a,0 ; debug
	out	($3f),a
0:
	; tone chan a
	ld	bc,(AY_regToneA)
	ld	a,c
	and	$0f
	or	10000000b
	out	($3f),a	
	rl	c
	rl	b
	rl	c
	rl	b
	rl	c
	rl	b
	rl	c
	rl	b
	ld	a,00111111b
	and	b
	out	($3f),a		
	
	
	; tone chan b
	ld	bc,(AY_regToneB)
	ld	a,c
	and	$0f
	or	10100000b
	out	($3f),a	
	rl	c
	rl	b
	rl	c
	rl	b
	rl	c
	rl	b
	rl	c
	rl	b
	ld	a,00111111b
	and	b
	out	($3f),a	
	
	; tone chan c
	ld	bc,(AY_regToneC)
	ld	a,c
	and	$0f
	or	11000000b
	out	($3f),a	
	rl	c
	rl	b
	rl	c
	rl	b
	rl	c
	rl	b
	rl	c
	rl	b
	ld	a,00111111b
	and	b
	out	($3f),a	




ENDIF
	
	
	
;--------------
; F M P A C 
;--------------
	ld	hl,FM_softvoice_req
	ld	a,(hl)
	inc	hl
	cp	(hl)
	jp	z,.noVoice
	
	ld	(hl),a
	call	load_softwarevoice
.noVoice:
;	ld	b,6
;	ld	ix,CHIP_Chan3
;_ptAY_voice_loop:	
;	bit	6,(IX+CHIP_Flags)
;	jp	z,0f
;	res	6,(ix+CHIP_Flags)
;	ld	a,(ix+CHIP_Voice)
;;	and	a
;;	jp	nz,99f
;;	inc	a
;99:
;	cp	16
;	call	nc,load_softwarevoice
;	ld	(ix+CHIP_Waveform),a
;0:
;	ld	de,CHIP_REC_SIZE
;	add	ix,de
;	djnz	_ptAY_voice_loop



	;--- Apply the mixer.
	ld	hl,SCC_regMIXER
	;--- do not	apply	mmainmixer when in  mode 2
;	ld	a,(keyjazz)
;	and	a
;;	jr.	nz,99f
	ld	a,(replay_mode)
	cp	2
	jr.	z,99f
;fmmixer:
	ld	a,(MainMixer)
	and	(hl)	; set	to 0 to silence
	ld	(hl),a
99:
;
	;--- write volume register
	ld	de,FM_regVOLA
	ld	hl,CHIP_Chan3+CHIP_Waveform
	ld	b,6		; 5 tracks
	ld	a,$30
;	ex	af,af'	;'
_tt_route_fmvol:
	ex	af,af'	; '
	ld	a,(hl)
	rla
	rla
	rla
	rla
	and	$f0
	ld	c,a
	
	ld	a,(de)	
	push	hl
	ld	hl,SCC_regMIXER

	bit	7,(hl)
	jr	nz,33f
	ld	a,$0f			; silentio
33:
	rrc	(hl)
	pop	hl	
	
	and	0x0f
	or	c
	ex	af,af'		;'
	out	(FM_WRITE),a
	inc	a			; 4 cycles
	ex	af,af'		; 4 cycles	 '
	inc	de			; 6 cycles
	out	(FM_DATA),a

	ld	a,CHIP_REC_SIZE
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ex	af,af'		;	'


	djnz	_tt_route_fmvol

;	pop	af
;	ld	(MainMixer),a




	;--- write tone register
	ld	hl,FM_registers
	ld	de,CHIP_Chan3+CHIP_Flags
	ld	b,6		; 5 tracks
	ld	a,$10
;	ex	af,af'	;'
_tt_route_fmtone:

	out	(FM_WRITE),a
	ex	af,af'		; 4 cycles 	'
	ld	a,(hl)		; 13 cycles  	the low byte
	out	(FM_DATA),a
	inc	hl
	ld	a,(de)		; the flags (bit 4 has key)
	ld	c,a
	and	48			; preserve key and sustain

	;--- check for new note (keyon is off '0')
	bit	4,a
	jp	nz,99f		; skip if no keyoff

	or	(hl)
	ex	af,af'		;'
	add	a,$10
	out	(FM_WRITE),a
	ex	af,af'		; 4 cycles '
	out 	(FM_DATA),a

	or	16			; set keyon on '1'
	ld	(de),a		; store keyon
	ex	af,af'		;'
	jp 	88f	
			
	


99:
	or	(hl)			; add the tone high byte

	ex	af,af'		;'
	add	a,$10
	
	;--- delay to get 84 cycles at least
;	push ix
;	pop ix
;	nop
	
	
	
88:	out	(FM_WRITE),a
	ex	af,af'		; 4 cycles '
	inc	hl			; 6 cycles 
	out 	(FM_DATA),a
	ld	a,16
	or	c
	ld	(de),a		; write key flag enabled to disable retrigger of note
	ld	a,CHIP_REC_SIZE
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ex	af,af'		;'
	sub	$f
	djnz	_tt_route_fmtone



	;-----------------
	; Update drum registers
	;-----------------
;	ld	a,(DrumMixer)
;	and	a
;	ret	z	; skip drums if disabled

	ld	a,(FM_DRUM_Flags)
	ld	d,a		

	;; just for debug purposes
	and	a
	ret	z


	rl	d
	jp	nc,route_FM_Tone1
	;---- Percusion bits
route_FM_Rythm:	
	ld	c,0x0e
	;-- load the new values
	ld	a,c
	out	(FM_WRITE),a	; Select rythm register
	
	ld	a,(FM_DRUM)		; 7 cycles
	and	011111b		; erase bit 5 to enable retrigger drum
	out	(FM_DATA),a		
	
	ld	a,(DrumMixer)
	ld	b,a
	ld	a,(FM_DRUM)		; 7 cycles
	or	b			; Mask with drum mixer (bit 5 is set)
	out	(FM_DATA),a
	
	
route_FM_Tone1:	
	rl	d
	jp	nc,route_FM_Vol1
	
	ld	a,0x16		; register
	ld	hl,FM_freqreg1	; value
	call	route_FM_toneUpdate
	

route_FM_Vol1:
	rl	d
	jp	nc,route_FM_Tone2
	
	ld	a,0x36		; register
	ld	hl,FM_volreg1	; value
	call	route_FM_volumeUpdate

route_FM_Tone2:	
	rl	d
	jp	nc,route_FM_Vol2
	
	ld	a,0x17		; register
	ld	hl,FM_freqreg2	; value
	call	route_FM_toneUpdate
	

route_FM_Vol2:
	rl	d
	jp	nc,route_FM_Tone3
	
	ld	a,0x37		; register
	ld	hl,FM_volreg2	; value
	call	route_FM_volumeUpdate

route_FM_Tone3:	
	rl	d
	jp	nc,route_FM_Vol3
	
	ld	a,0x18		; register
	ld	hl,FM_freqreg3	; value
	call	route_FM_toneUpdate
	

route_FM_Vol3:
	rl	d
	jp	nc,route_FM_end
	
	ld	a,0x38		; register
	ld	hl,FM_volreg3	; value
	call	route_FM_volumeUpdate

route_FM_end:
	xor	a
	ld	(FM_DRUM_Flags),a
	
	ret


route_FM_toneUpdate:
	;-- write tone
	ld	c,a
	out	(FM_WRITE),a
	ld	a,(hl)
	inc	hl
	out 	(FM_DATA),a
	ld	a,0x10
	add	c
	out	(FM_WRITE),a
	ld	a,(hl)
	out 	(FM_DATA),a
	ret

route_FM_volumeUpdate:
	;-- write volumes
	out	(FM_WRITE),a
	ld	a,(hl)
	inc	hl
	out 	(FM_DATA),a
	ret



	



;;--- FM DRUM VOL
;	ld	a,(FM_DRUM_Flags)
;	ld	d,a			; 4 cycles
;	
;	ld	c,$36			; 7 cycles
;	ld	b,3			; 7 cycles
;	ld	hl,FM_volreg1
;_drmvolloop:
;	srl	d
;	jr.	nc,0f
;	;-- load the new values
;	ld	a,c
;	out	(FM_WRITE),a
;	ld	a,(hl)		; 7 cycles
;	
;	out	(FM_DATA),a
;0:	inc	hl
;	inc	hl
;	inc	hl
;	inc	c
;	djnz	_drmvolloop	
;
;
;;--- FM DRUM FREQ
;	ld	c,$16
;	ld	e,$26
;	ld	b,3
;	ld	hl,FM_freqreg1
;_drmfreqloop:
;	srl	d
;	jr.	nc,0f
;	;-- load the new values
;	ld	a,c
;	out	(FM_WRITE),a
;	ld	a,(hl)		; 7 cycles
;	out	(FM_DATA),a
;	ld	a,e
;	inc	hl			; 6 cycles
;	
;	;--- delay to have at least 84 cycles
;	push	ix
;	pop	ix
;	push 	ix
;	pop 	ix
;	
;		
;	out	(FM_WRITE),a
;	ld	a,(hl)		; 7 cycles
;
;	out	(FM_DATA),a
;	dec	hl			; 6 cycles
;	nop
;0:
;	inc	hl
;	inc	hl
;	inc	hl
;	inc	c
;	inc	e
;	djnz	_drmfreqloop	
;
;	xor	a
;	ld	(FM_DRUM_Flags),a
;
;
;;--- FM DRUMS
;	ld	a,(DrumMixer)
;	and	a
;	jp	z,99f		; skip drums if disabled
;
;	ld	a,(FM_DRUM)
;	and	a
;	jr.	z,99f
;	; enable new drum
;	ex	af,af'		;'
;	ld	a,0x0e
;	out	(FM_WRITE),a
;	ld	a,0			; 7 cycles
;	ld	(FM_DRUM),a		; 13 cycles
;	ld	a,10000b
;;	ld	hl,_drumset-1
;	out	(FM_DATA),a
;	
;	;--- delay to have at least 84 cycles
;	push	ix
;	pop	ix
;	push 	ix
;	pop 	ix	
;	
;	
;;	ex	af,af'		;'
;;	add	a,l
;;	ld	l,a
;;	jr.	nc,11f
;;	inc	h
;;11:
;;	ld	a,(hl)
;
;;	ex	af,af'	;'
;	ld	a,0x0e
;	out	(FM_WRITE),a
;	ex	af,af'		; 4 cycles	'
;	or	100000b
;	out	(FM_DATA),a
;99:
;	ret


load_softwarevoice:
	ld	hl,_VOICES	
	sub	16
	jr.	z,99f
	ld	de,8
55:
	add	hl,de
	dec	a
	jr.	nz,55b
99:	
	;--- copy data to FM custom voice register
	ld	d,8
	ld	a,$0
_tt_voice_fmloop:
	out	(FM_WRITE),a
	inc	a			; 4 cycles
	ex	af,af'		; 4 cycles	'
	ld	a,(hl)		; 7 cycles    the low byte
	out	(FM_DATA),a
	
	;--- delay
	push 	ix
	pop	ix
	nop
	nop
		
	
	inc	hl
	ex	af,af'		;'
	dec	d
	jr.	nz,_tt_voice_fmloop

	xor	a

	ret



_drumset:
	db	00100000b ; none
	db	00110000b ; bdrum
	db	00101000b ; snare
	db	00111000b ; bdrum+snare
	db	00100001b ; hihat
	db	00100010b ; Cymbal
	db	00110010b ; bdrum + cymbal
	db	00101010b ; snare + cymbal
	db	00111010b ; 
	db	00100100b
	db	00110100b
	db	00110001b
	db	00101001b
	db	00111001b
	db	00110110b
	db	00100011b



_TEMPSCC:	db "aAAA bBBB cCCC dDDD eEEE fFFF aVbVcVdVeVfV mMM"
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
	call	draw_hex	    ;vol e
	inc	hl
	inc	de
	ld	a,(hl)
	call	draw_hex	;vol f
;	inc	hl
	inc	de	

;	inc	de
;	inc	hl
;	ld	a,(hl)
;	call	draw_hex2	; mixer 
;	inc	hl	
;	inc	de
;	inc	de

	

	
	ld	hl,41
	ld	de,_TEMPSCC
	ld	b,39;44
	call	draw_label_fast					


	ret

REPLAY_END:


	