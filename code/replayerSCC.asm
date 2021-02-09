;================================
; The new replayer.
;
; Swappable part
;
;================================
REPLAY_START:

_TEMPAY:	db "aAAA bBBB cCCC nNN mMM aVbVcV "
_TEMPSCC:	db "aAAA bBBB cCCC dDDD eEEE aVbVcVdVeV mMM"


AY_VOLUME_TABLE 
	; No tail
;	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db $00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01
;	db $00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02
;	db $00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03
;	db $00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04
;	db $00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05
;	db $00,$00,$01,$01,$02,$02,$02,$03,$03,$04,$04,$04,$05,$05,$06,$06
;	db $00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07
;	db $00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07,$08
;	db $00,$01,$01,$02,$02,$03,$04,$04,$05,$05,$06,$07,$07,$08,$08,$09
;	db $00,$01,$01,$02,$03,$03,$04,$05,$05,$06,$07,$07,$08,$09,$09,$0A
;	db $00,$01,$01,$02,$03,$04,$04,$05,$06,$07,$07,$08,$09,$0A,$0A,$0B
;	db $00,$01,$02,$02,$03,$04,$05,$06,$06,$07,$08,$09,$0A,$0A,$0B,$0C
;	db $00,$01,$02,$03,$03,$04,$05,$06,$07,$08,$09,$0A,$0A,$0B,$0C,$0D
;	db $00,$01,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
;	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
	; Tail mode (1)
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02
;	db $01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03
;	db $01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04
;	db $01,$01,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05
;	db $01,$01,$01,$01,$02,$02,$02,$03,$03,$04,$04,$04,$05,$05,$06,$06
;	db $01,$01,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07
;	db $01,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07,$08
;	db $01,$01,$01,$02,$02,$03,$04,$04,$05,$05,$06,$07,$07,$08,$08,$09
;	db $01,$01,$01,$02,$03,$03,$04,$05,$05,$06,$07,$07,$08,$09,$09,$0A
;	db $01,$01,$01,$02,$03,$04,$04,$05,$06,$07,$07,$08,$09,$0A,$0A,$0B
;	db $01,$01,$02,$02,$03,$04,$05,$06,$06,$07,$08,$09,$0A,$0A,$0B,$0C
;	db $01,$01,$02,$03,$03,$04,$05,$06,$07,$08,$09,$0A,$0A,$0B,$0C,$0D
;	db $01,$01,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
;	db $01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F

	; Tail mode (2)
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$03,$03,$03
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04
	db $02,$02,$02,$02,$02,$02,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05
	db $02,$02,$02,$02,$02,$02,$02,$03,$03,$04,$04,$04,$05,$05,$06,$06
	db $02,$02,$02,$02,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07
	db $02,$02,$02,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07,$08
	db $02,$02,$02,$02,$02,$03,$04,$04,$05,$05,$06,$07,$07,$08,$08,$09
	db $02,$02,$02,$02,$03,$03,$04,$05,$05,$06,$07,$07,$08,$09,$09,$0A
	db $02,$02,$02,$02,$03,$04,$04,$05,$06,$07,$07,$08,$09,$0A,$0A,$0B
	db $02,$02,$02,$02,$03,$04,$05,$06,$06,$07,$08,$09,$0A,$0A,$0B,$0C
	db $02,$02,$02,$03,$03,$04,$05,$06,$07,$08,$09,$0A,$0A,$0B,$0C,$0D
	db $02,$02,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
	db $02,$02,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F

SCC_VOLUME_TABLE 
	; Tail mode off
;	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
;	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02
;	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03
;	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04
;	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05
;	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06
;	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07
;	db $00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08
;	db $00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09
;	db $00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A
;	db $00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B
;	db $00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C
;	db $00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D
;	db $00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
;	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
	; Tail mode ON
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08
	db $01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09
	db $01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A
	db $01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B
	db $01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C
	db $01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D
	db $01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
	db $01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F	






;Konami values found in	nemesis 2 replayer.
;db	0x6a,	0x64,	0x5e,	0x59,	0x54,	0x4f,	0x4a,	0x46,	0x42,	0x3f,	0x3b,	0x38,	0x35
C_PER		equ	$6a*32	
C1_PER	equ	$64*32
D_PER		equ	$5e*32
D1_PER	equ	$59*32
E_PER		equ	$54*32
F_PER		equ	$4f*32
F1_PER	equ	$4a*32
G_PER		equ	$46*32
G1_PER	equ	$42*32
A_PER		equ	$3f*32
A1_PER	equ	$3b*32
B_PER		equ	$38*32

TRACK_ToneTable:	
	dw	0	;	Dummy value (note 0)
	dw C_PER/1	,C1_PER/1  ,D_PER/1  ,D1_PER/1  ,E_PER/1	,F_PER/1  ,F1_PER/1  ,G_PER/1	 ,G1_PER/1	,A_PER/1  ,A1_PER/1  ,B_PER/1
	dw C_PER/2	,C1_PER/2  ,D_PER/2  ,D1_PER/2  ,E_PER/2	,F_PER/2  ,F1_PER/2  ,G_PER/2	 ,G1_PER/2	,A_PER/2  ,A1_PER/2  ,B_PER/2
	dw C_PER/4	,C1_PER/4  ,D_PER/4  ,D1_PER/4  ,E_PER/4	,F_PER/4  ,F1_PER/4  ,G_PER/4	 ,G1_PER/4	,A_PER/4  ,A1_PER/4  ,B_PER/4
	dw C_PER/8	,C1_PER/8  ,D_PER/8  ,D1_PER/8  ,E_PER/8	,F_PER/8  ,F1_PER/8  ,G_PER/8	 ,G1_PER/8	,A_PER/8  ,A1_PER/8  ,B_PER/8
	dw C_PER/16	,C1_PER/16 ,D_PER/16 ,D1_PER/16 ,E_PER/16	,F_PER/16 ,F1_PER/16 ,G_PER/16 ,G1_PER/16	,A_PER/16 ,A1_PER/16 ,B_PER/16
	dw C_PER/32	,C1_PER/32 ,D_PER/32 ,D1_PER/32 ,E_PER/32	,F_PER/32 ,F1_PER/32 ,G_PER/32 ,G1_PER/32	,A_PER/32 ,A1_PER/32 ,B_PER/32
	dw C_PER/64	,C1_PER/64 ,D_PER/64 ,D1_PER/64 ,E_PER/64	,F_PER/64 ,F1_PER/64 ,G_PER/64 ,G1_PER/64	,A_PER/64 ,A1_PER/64 ,B_PER/64
	dw C_PER/128,C1_PER/128,D_PER/128,D1_PER/128,E_PER/128,F_PER/128,F1_PER/128,G_PER/128,G1_PER/128,A_PER/128,A1_PER/128,B_PER/128


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
;TRACK_Vibrato_sine:
;	db	 0*2,	2*2, 4*2, 7;*2,11*2,16*2,22*2,28*2,35*2,43*2,51*2,59*2,68*2,77*2,87*2,96*2
;	db	96*2,86*2,77*2,68*2,59*2,51*2,43*2,35*2,28*2,22*2,16*2,11*2, 7*2,	4*2, 2*2, 0*2

;TRACK_Vibrato_triangle:
;	db	 0, 6,12,18,24,30,36,42,48,54,60,66,72,78,84,90
;	db	96,90,84,78,72,66,60,54,48,42,36,30,24,18,12, 6

;TRACK_Vibrato_pulse:
;	db	255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
;;	db	255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
;	db      0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0	
	
;_morph_timer_table:
;	db	2,3,4,5,6,12,25,50,60,70,90,100,112,125,125,150,175,200,225,250

;PT3:
;	dw 0x0D10,0x0C55,0x0BA4,0x0AFC,0x0A5F,0x09CA,0x093D,0x08B8,0x083B,0x07C5,0x0755,0x06EC
;	dw 0x0688,0x062A,0x05D2,0x057E,0x052F,0x04E5,0x049E,0x045C,0x041D,0x03E2,0x03AB,0x0376
;	dw 0x0344,0x0315,0x02E9,0x02BF,0x0298,0x0272,0x024F,0x022E,0x020F,0x01F1,0x01D5,0x01BB
;	dw 0x01A2,0x018B,0x0174,0x0160,0x014C,0x0139,0x0128,0x0117,0x0107,0x00F9,0x00EB,0x00DD
;	dw 0x00D1,0x00C5,0x00BA,0x00B0,0x00A6,0x009D,0x0094,0x008C,0x0084,0x007C,0x0075,0x006F
;	dw 0x0069,0x0063,0x005D,0x0058,0x0053,0x004E,0x004A,0x0046,0x0042,0x003E,0x003B,0x0037
;	dw 0x0034,0x0031,0x002F,0x002C,0x0029,0x0027,0x0025,0x0023,0x0021,0x001F,0x001D,0x001C
;	dw 0x001A,0x0019,0x0017,0x0016,0x0015,0x0014,0x0012,0x0011,0x0010,0x000F,0x000E,0x000D


			
;--- Replay	music stepped
replay_mode5:
	;--- The speed timer
	ld	hl,replay_speed_timer
	dec	(hl)

	jr.	nz,replay_decodedata_NO	; jmp	if timer > 0

	ld	a,(key)
	and	a
	jp	nz,.key
.nokey:
	inc	(hl)
	jr. 	replay_decodedata_NO
.key:
	jp	_rplmd_cont

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
	jp	z,.testkb
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
	jp	nz,1f	
	jp	_rpm2_3		; mode 2 and 3 work alike.
	
1:	
	call	replay_init_pre
	jp	replay_mode2


;-- end
;--- Replay	music	looped pattern
replay_mode4:
	;--- The speed timer
	ld	hl,replay_speed_timer
	dec	(hl)
	
	jp	nz,replay_decodedata_NO	; jmp	if timer > 0
	
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
	jp	c,replay_decodedata
	
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
	jp	replay_decodedata
	




	
	
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
	ld	hl,TRACK_ToneTable
	ld	(replay_Tonetable),hl
	
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
;
;	;---- Morphing routine
;	ld	a,(replay_morph_active)
;	and	a
;	ret	z
;	
;	ld	hl,(replay_morph_timer)
;	dec	(hl)
;	ret	nz
;	
;	;----- reset timer
;	ld	a,8
;	ld	(replay_morph_timer),a
;	ld	(replay_morph_update),a
;	
;	;----- calc new morph step
;	ld	hl,replay_morph_buffer
;	ld	b,32
;	ld	a,(replay_morph_counter)
;	ld	c,a
;_m_loop:
;	ld	a,(hl)	; calc
;	ld	d,a
;	inc	hl
;	bit	5,a
;	jp	z,_m_add
;_m_sub:
;	;--- test if we need correction
;	cp	c
;	jp	nc,99f
;	dec	(hl)		; correction
;99:
;	and	$0f
;	sub	(hl)
;	neg
;	ld	(hl),a
;	inc	hl
;	djnz	_m_loop
;	jp	0f
;	
;_m_add:
;	;--- test if we need correction
;	cp	c
;	jp	nc,99f
;	dec	(hl)		; correction
;99:
;	and	$0f
;	sub	(hl)
;	ld	(hl),a
;	inc	hl
;	djnz	_m_loop
;
;0:
;	ld	a,16
;	add	c
;	ld	(replay_morph_counter),a
;	ret	nz
;	ld	(replay_morph_active),a		; stop morphing
;	ret





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
	jp	nc,_snp_loop
	jp	_snp_continue		
	
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
;	call	draw_vu_empty
	;--- Get the start speed.
	ld	a,(song_speed)
	ld	(replay_speed),a
	ld	a,1
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
	
	call scc_reg_update
	
	ld	a,(mapper_slot)				; Recuperamos el slot
	ld	h,0x80
	call enaslt
	
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
	jp	z,6f
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
	ret


;_PRE_pat:	db	0
;_PRE_order:	db	0
;_PRE_line:	db	0

;_PRE_dummy_pat:
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...	
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...
;	db	$00,$01,$f0,$00	; ---1F...	
;	db	$00,$01,$fD,$00	; ---1FD00
	
;_PREPROCESS_LENGTH	equ	1



;--- Very basic pre-scan. Old	one was WAY	too slow.
replay_init_pre:
	;di
	call	reset_hook		; prevent any replayer update while we are preparing
	;--- Get the current values (to restore them after pre-scan
;	ld	a,(current_song)
	call	set_songpage


	ld	a,(song_pattern_line)
	push	af					; store for	later


	;--- Get the instruments from	the first line of	the song
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
	jp	z,0f
	ld	de,32
88:
	add	hl,de
	dec	a
	jp	nz,88b		
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
	jp	z,99f
	ld	(de),a
99:
	;if no instrument	at all then	instr	1
	ld	a,(de)
	and	a
	jp	nz,99f
	inc	a
	ld	(de),a
99:
	inc	de
	inc	hl
	ld	a,(hl)		; copy volume
	cp	15			; is there a volume
	jp	nc,99f		; if there is a volume 
	ld	c,a
	ld	a,(de)
	and	$f0
	jp	nz,88f		; if there is no volume	at all then	max volume
	ld	a,$f0
88:	add	c
99:	ld	(de),a		; write volume + command
	and	$0f			; make sure	we do	not process	pattern end
	cp	$0d			
	jp	nz,99f
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

	
	call	set_hook		; re-enable the replayer in the ISR
	ret
	
draw_PSGdebug:		
	; THIS IS DEBUG INFO ON	THE REGISTERS!!!!
	ld	de,_TEMPAY+1
	ld	hl,AY_registers
	ld	a,(hl)
	inc	hl
	add	1
	ld	b,a
	ld	a,(hl)
	adc	0
	call	draw_hex
	ld	a,b
	call	draw_hex2
	inc	hl
	inc	de
	inc	de
	
	ld	a,(hl)
	inc	hl
	add	1
	ld	b,a
	ld	a,(hl)
	adc	0
	call	draw_hex
	ld	a,b
	call	draw_hex2
	inc	hl
	inc	de
	inc	de
	
	ld	a,(hl)
	inc	hl
	add	1
	ld	b,a
	ld	a,(hl)
	adc	0
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
;	inc	de	
	
	ld	hl,0
	ld	de,_TEMPAY
	ld	b,29;31
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
	ld	a,(ix+TRACK_Note)
	ld	(replay_previous_note),a
	res	2,(IX+TRACK_Flags)		; Reset envelope

	;=============
	; Note 
	;=============
	ld	a,(bc)
	and	a
	jp	z,_dc_noNote
	cp	97
	jp	z,_dc_restNote	; 97 is a rest
	jp	nc,_dc_noNote	; anything higher	than 97 are	no notes
	
	ld	(ix+TRACK_Note),a
	
	set	0,(ix+TRACK_Flags)	; set note trigger
	res	4,(ix+TRACK_Flags)	; reset morph slave mode

_dc_noNote:	
	inc	bc
	;=============
	; Instrument
	;=============	
	ld	a,(bc)
	and	a
	jp	z,_dc_noInstr
	;--- check current instrument
	res	4,(ix+TRACK_Flags)	; reset morph slave mode
	
	cp	(ix+TRACK_Instrument)
	jp	z,_dc_noInstr
	
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
	jp	nz,0b
	
	;--- Store the macro start
	ld	(ix+TRACK_MacroPointer),l
	ld	(ix+TRACK_MacroPointer+1),h
	
	;--- Set the waveform  (if needed)
	inc	hl
	inc	hl
	ld	a,(hl)
	cp	(ix+TRACK_Waveform)
	jp	z,_dc_noNewWaveform
	
	;--- this is a new waveform
	ld	(ix+TRACK_Waveform),a
	set	6,(ix+TRACK_Flags)
	
_dc_noNewWaveform:	
	call	set_patternpage_safe
	
_dc_noInstr:
	inc	bc
	
	;=============
	; Volume
	;=============	
	ld	a,(bc)
	and	0xf0
	jp	z,_dc_noVolume
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
	jp	nz,99f
	;-- arpeggio of parameters is 0
	inc	bc
	ld	a,(bc)
	dec	bc
	and	a
	jp	z,noCMDchange
	xor 	a
99:	    
;	ld	(ix+TRACK_Command),a
	ld	d,a			; Store command in d for later
	
	;--- Hack to disable commands > $f Otherwise it could crash
	cp	$10
	jp	c,99f
	xor	a
99:									
	;--- calculate cmd address
	add	a
	ld	hl,_CHIPcmdlist
	add	a,l
	ld	l,a
	jp	nc,99f
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
	jp	z,99f
	bit 	3,d			; effect active
	jp	z,99f
	
	ld	a,(ix+TRACK_Command)	; active effect is 3?
	cp	3				; tone portamento?
	jp	z,.trigger
	cp 	5
	jp	z,.trigger		; tone portamento + fade?
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
	jp	_CHPcmd3_newNote
	
	


;-------------------
; Rest the note
;===================
_dc_restNote:	
	res	1,(ix+TRACK_Flags)	; set	note bit to	0
	res	4,(ix+TRACK_Flags)	; reset morph slave mode

	ld	a,(replay_previous_note)
	ld	(ix+TRACK_Note),a
	jp	_dc_noNote

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
	dw	_CHIPcmd8_env_mul
	dw	_CHIPcmd9_macro_offset
	dw	_CHIPcmdA_volSlide
	dw	_CHIPcmdB_scc_commands
	dw	_CHIPcmdC
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
	jp	z,_CHIPcmd_end
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
	
	set	4,(ix+TRACK_Flags)		; FM notelink bit
	res	0,(ix+TRACK_Flags)
_CHPcmd3_newNote:
;	ld	a,(ix+CHIP_cmd_3)
	and	$7f				; reset deviation
	ex	af,af'			;'
	
	;-- get the	previous note freq
	ld	a,(replay_previous_note)
	add	a
	ld	hl,(replay_Tonetable);TRACK_ToneTable
	add	a,l
	ld	l,a
	jp	nc,99f
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
	jp	nc,99f
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
	jp	nz,99f
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
	cp	$10
	jp	c,_CHIPcmd_end
	
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
	jp	z,.depth 	; 0 -> no speed update
;	inc	a
	ld	(ix+TRACK_cmd_4_step),a	
	neg	
	ld	(ix+TRACK_Step),a	
	
.depth
	;-- set the depth
	ld	a,e
	and	$f0
	jp	z,.end	; set depth when 0 only when command was not active.
;	bit 	3,(ix+TRACK_Flags)	
;	ld	a,16

99:	cp	$D0		; max 1-12
	jp	c,99f
	ld	a,$C0
99:
	sub	16
	ld	hl,CHIP_Vibrato_sine
	add	a,a
	jp	nc,99f
	inc	h
99:	
	add	a,l
	ld 	l,a
	jp	nc,99f
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
_CHIPcmd8_env_mul:
;	ld	d,a
;	xor	a
;	srl	d
;	rra	
;	srl	d
;	rra		
;	srl	d
;	rra	
;	srl	d
;	rra	
;	or	1	; set envelope update flag
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
	jr.	z,_CHIPcmd_end
	ld	(ix+TRACK_cmd_9),a
;_CHIPcmd9_retrig:	
	set	3,(ix+TRACK_Flags)
	ld	(ix+TRACK_Timer),2		; timer is set as	we process cmd
						; before new notes.
	
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
	jp	z,_CHIPcmd_end
	
	ld	(ix+TRACK_Command),d
	bit 	0,(ix+TRACK_Flags)
	jp	z,_CHIPcmdA_volSlide_cont
	
	set	4,(ix+TRACK_Flags)		; FM notelink bit
	res	0,(ix+TRACK_Flags)

	ld	iyh,a
	ld	a,(ix+TRACK_cmd_3)
	call	_CHPcmd3_newNote

	ld	a,iyh
	jp 	_CHIPcmdA_volSlide_cont
 
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


_CHIPcmdB_scc_commands:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	; 
	ld	d,a	
	and	0xf0	; get	the extended comand
			; reset
	jp	z,_CHIPcmdB_reset	
	cp	0x10	; duty cycle
	jp	z,_CHIPcmdB_pwm
	cp	0x20	; waveform cut
	jp	z,_CHIPcmdB_cut
;	cp	0x40	; waveform compress
;	jp	z,_CHIPcmdB_compress
	cp	0xB0	; set	waveform
	jp	z,_CHIPcmdB_setwave
	cp	0xC0	; set	waveform2
	jp	z,_CHIPcmdB_setwave2
	cp	0xe0
;	jp	z,_CHIPcmdB_morphset
;	cp	0xF0
;	jp	z,_CHIPcmdB_morphoption

	ret

;_CHIPcmdB_morphset:
;	;--- Set morph destination and init
;	set	4,(ix+TRACK_Flags)		; set morph
;	ld	a,d
;	and	$0f
;	ld	(ix+TRACK_cmd_B),a		; store dest form
;	ld	(ix+TRACK_Command),0x25	; set	the command#
;	
;	xor	a
;	ld	(replay_morph_counter),a
;	dec	a
;	ld	(replay_morph_active),a
;	ld	a,8
;	ld	(replay_morph_timer),a
;	jp	1f

	
_CHIPcmdB_reset:
	;--- retrigger the original waveform
	set	6,(ix+TRACK_Flags)
	res	4,(ix+TRACK_Flags)
	ret
	
	
_CHIPcmdB_pwm:	
	ld	(ix+TRACK_Command),0x21	; set	the command#

1:	ld	a,d
	and	0x0f

2:	ld	(ix+TRACK_cmd_B),a
	set	3,(ix+TRACK_Flags)
	res	4,(ix+TRACK_Flags)
	ret

_CHIPcmdB_cut:	
	ld	(ix+TRACK_Command),0x22	; set	the command#
	jp	1b

_CHIPcmdB_setwave:
	;--- Set a new waveform
	ld	a,d
	and	0xf
4:	ld	(ix+TRACK_Waveform),a
	set	6,(ix+TRACK_Flags)
	res	4,(ix+TRACK_Flags)
	ret	

_CHIPcmdB_setwave2:
	;--- Set a new waveform
	ld	a,d
	and	0xf
	add	16
	jp	4b

	
_CHIPcmdC:
	; in:	[A] contains the paramvalue
	; 
	; ! do not change	[BC] this is the data pointer
	;--------------------------------------------------
	;
	and	a
	jp	z,_CHIPcmdC_setslave

	ld	d,a
	;---- init new morph
	and	0xf0	
	ld	(replay_morph_waveform),a	; store dest form offset
	
	xor	a
	ld	(replay_morph_counter),a
	inc	a
	ld	(replay_morph_timer),a
	
	ld	a,d
	;--- set speed
	and	0x0f
	jp	z,_morph_cont	; don't load waveform in buffer
	
	;---- set new timer
;	ld	hl,_morph_timer_table-1
;	add	a,l
;	ld	l,a
;	jp	nc,99f
;	inc	h
;99:
;	ld	a,(hl)
	ld	(replay_morph_speed),a
	
	;--- load the waveformbuffer
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

	ld	de,replay_morph_buffer
	ld	a,32
44:
	ex	af,af'	;'
	ld	a,(hl)
	ld	(de),a		; copy value to both wave and delta pos
	inc	de
	ld	(de),a
	inc	hl
	inc	de
	ex	af,af'	;'
	dec	a
	jp	nz,44b
	
	
	
	;--- calculate the delta's	
_morph_cont:
	ld	a,255				; 255 triggers calc init
	ld	(replay_morph_active),a		
	
	
_CHIPcmdC_setslave:
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
	jp	nc,99f
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
	dw	_CHIPcmdE_none		;8
	dw	_CHIPcmdE_none		;9
    
	dw	_CHIPcmdE_none		;A
	dw	_CHIPcmdE_none		;B
	dw	_CHIPcmdE_notecut		;C	
	dw	_CHIPcmdE_notedelay	;D	
	dw	_CHIPcmdE_envelope	;E
	dw	_CHIPcmdE_none		;F
	

_CHIPcmdE_none:
	ret
	
	
_CHIPcmdE_arpspeed:
	ld	a,d
	and	$0f
	ld	(replay_arp_speed),a
	ret	
	
	
_CHIPE_noiseOR:
	ld	a,d
	ld	(AY_NoiseOR),a
	ret
_CHIPcmdE_noiseAND:
	ld	a,d
	ld	(AY_NoiseAND),a
	ret

_CHIPE_noiseAND:


_CHIPcmdE_psgmode:
	ld	a,d
	and	1
	ld	(psgmode),a
	ret

_CHIPcmdE_duty1:
	ld	a,d
	and	15
	ld	(AY_duty1),a
	ret
_CHIPcmdE_duty2:
	ld	a,d
	and	15
	ld	(AY_duty2),a
	ret
_CHIPcmdE_duty3:
	ld	a,d
	and	15
	ld	(AY_duty3),a
	ret





;_CHIPcmdE_shortarp:
;	ld	a,d			;- Get the parameter
;	and	0x0f
;;	jp	z,_CHIPcmdE_shortarp_retrig	;-- Jump if value is 0
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

;_CHIPcmdE_vibrato:
;	ld	hl,TRACK_Vibrato_sine
;	ld	a,d
;	and	3
;	jp	z,99f
;	ld	de,32
;88:	add	hl,de
;	dec	a
;	jp	nz,88b
;99:	ld	(replay_vib_table),hl
;	ret

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
	jp	z,99f
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
;	res	3,(ix+TRACK_Flags)		; command in-active
;
;	ld	a,d
;	add	a
;	ld	hl,TRACK_ToneTable;(replay_Tonetable)
;	; This comment sets the	detune of the track.
;	and	15		; low	4 bits is value
;	bit	3,d		; Center around 8
;	ld	d,0
;	ld	e,a
;
;	jp	z,99f
;
;;neg	
;	xor	a
;	sbc	hl,de
;	ld	(replay_Tonetable),hl
;	ret
;; pos
;99:	
;	add	hl,de
;	ld	(replay_Tonetable),hl
	ret

_CHIPcmdE_envelope:
	set	2,(IX+TRACK_Flags)
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
	ld	a,(equalization_flag)			; check for speed equalization
	and	a
	jp	nz,_pcAY_noNoteTrigger			; Only process instruments

	;=====
	; COMMAND
	;=====
	ld	(ix+TRACK_cmd_NoteAdd),0			; reset ARP. Make sure to do this outside the
								; equalization skip	
	bit	3,(ix+TRACK_Flags)
	jp	z,_pcAY_noCommand
	

	ld	a,(ix+TRACK_Command)

	;--- Hack to disable commands > $24 Otherwise it might crash
	cp	$25
	jp	c,99f
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
	; NOTE
	;=====
	;--- Check if we need to trigger a new note
	bit	0,(ix+TRACK_Flags)
	jp	z,_pcAY_noNoteTrigger
	
;	;--- Check for CMD Edx
;	bit	3,(ix+TRACK_Flags)
;	jp	z,_pcAY_triggerNote
;	ld	a,0x1D		; Ed.
;	cp	(ix+TRACK_Command)
;	jp	z,_pcAY_noNoteTrigger

_pcAY_triggerNote:	
	;--- get new Note
	res	0,(ix+TRACK_Flags)		; reset trigger note flag
	set	1,(ix+TRACK_Flags)		; set	note active	flag

	; init macrostep but check for cmd9
	xor	a
	ld	b,a
	bit	3,(ix+TRACK_Flags)
	jp	z,99f
	ld	a,0x09		; Macro offset
	cp	(ix+TRACK_Command)
	jp	nz,99f
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
	jp	z,_pcAY_noNoteActive
	
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
	jp	c,_pcAY_noMacroEnd
	ld	a,d		; loop the macro.
_pcAY_noMacroEnd:
	; tone deviation.
	ld	(ix+TRACK_MacroStep),a
	pop	bc		
	pop	hl		; tone deviation
	
;--- Is tone active this step?
	bit	7,b		; do we have tone?
	jp	z,_pcAY_noTone

	;-- enable tone output
	ld	a,(SCC_regMIXER)
	or	16
	ld	(SCC_regMIXER),a
_pcAY_noTone:



	ld	e,(ix+TRACK_ToneAdd)	; get	the current	deviation	
	ld	d,(ix+TRACK_ToneAdd+1)
	
	;--- base or add/minus
	bit	6,b		; deviation	type
	jp	nz,_pcAY_Tminus
_pcAY_Tplus:
	add	hl,de		
	jp	88f

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
	ld	(hl),e
	inc	hl
	ld	(hl),d
		
	;-- Test for noise
	bit	7,c
	jp	z,_pcAY_noNoise
	
	; noise
	;--- prevent SCC and noise
	bit	7,(ix+TRACK_Flags)
	jp	nz,_pcAY_noNoise

	;--- Set the mixer for noise
	ld	a,(SCC_regMIXER)
	or	128
	ld	(SCC_regMIXER),a

	ld	e,(ix+TRACK_Noise)	; get	the current	deviation	
	ld	a,c
	and	0x1f
	ld	d,a

	;--- base or add/min
	bit	6,c
	jp	nz,99f
	;--- base
	ld	e,0
99:
	bit	5,c
	jp	z,99f
	;-- minus the deviation	of the macro
	ld	a,e
	sub	c	
	jp	88f
99:	;--- Add the deviation
	ld	a,d
	add	e
88:	
	ld	(ix+TRACK_Noise),a
	ld	(AY_regNOISE),a
	
	

_pcAY_noNoise:
	;volume
	ld	a,(ix+TRACK_VolumeAdd)
	bit	5,b
	jp	nz,0f
	;-- base volume
	ld	a,b
	and	0x0f
	jp	4f
0:
	;relative volume
	ld	c,a		; store current volume add
	ld	a,b		
	and	0x0f		; get	low 3	bits for volume deviation
	
	bit	4,b		; bit	6 set	= subtract?
	ld	b,a		; set	deviation in b
	ld	a,c		; set	current volume add back	in c
	jp	nz,1f
	;--- add 
	add	b
	cp	16
	jp	c,4f
	ld	a,15
	jp	4f
1:
	;--- sub 
	sub	b
	cp	16
	jp	c,4f
	xor	a
4:
	ld	(ix+TRACK_VolumeAdd),a
	
	;---- envelope check
	; is done here to be able to continue
	; macro volume values.
	bit	2,(IX+TRACK_Flags)
	jp	z,_noEnv		; if not set then normal volume calculation
	ld	a,16			; set volume to 16 == envelope
	ld	(SCC_regVOLE),a
	ret	
	
_noEnv:
	or	(ix+TRACK_Volume)
	ld	c,a
	
	; This part is only for tremolo
	
	ld	a,(IX+TRACK_cmd_VolumeAdd)	
;	rla						; C flag contains devitation bit (C flag was reset in the previous OR)
;	jp	c,_sub_Vadd
;_add_Vadd:
;	add	a,c
;	jp	nc,_Vadd
;	ld	a,c
;	or	0xf0
;	jp	_Vadd
;_sub_Vadd:
	ld	b,a
;	xor	a
;	sub	b
;	ld	b,a
	ld	a,c
	sub	a,b
	jp	nc,_Vadd
	ld	a,c
	and	0x0f	
	;-- next is _Vadd
_Vadd:
	;--- apply main volume balance
	ld	hl,replay_mainvol
	CP	(HL)
	JP	C,88F
	sub	(hl)
	jp	99f
88:	xor	a
99:	
	ld	l,a
	ld	h,0
	; Test which CHIP.
	bit	7,(ix+TRACK_Flags)
	jp	nz,99f
	ld	de,AY_VOLUME_TABLE
	jp	88f
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
	dw	_pcAY_cmd1d		
	dw	_pcAY_cmd1e
	dw	_pcAY_cmd1f	
	dw	_pcAY_cmd20
	dw	_pcAY_cmd21
	dw	_pcAY_cmd22
	dw	_pcAY_cmd23
	dw	_pcAY_cmd24
;	dw	_pcAY_cmd25
			
_pcAY_cmd0:
	ld	a,(IX+TRACK_Timer)
	and	a
	jp	z,.nextNote

	dec	a
	ld	(IX+TRACK_Timer),a
	ld	a,(ix+TRACK_Step)
	and	a
	jp	z,99f
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
		jp	nz,0f
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
	jp	nc,_pcAY_commandEND
	dec	(ix+TRACK_cmd_ToneSlideAdd+1)
	jp	_pcAY_commandEND
	
_pcAY_cmd2:
	ld	a,(ix+TRACK_cmd_2)
	ld	b,a
	ld	a,(ix+TRACK_cmd_ToneSlideAdd)
	add	b
	ld	(ix+TRACK_cmd_ToneSlideAdd),a
	jp	nc,_pcAY_commandEND
	inc	(ix+TRACK_cmd_ToneSlideAdd+1)
	jp	_pcAY_commandEND


_pcAY_cmd3:
	ld	a,(ix+TRACK_cmd_3)
	ld	l,(ix+TRACK_cmd_ToneSlideAdd)
	ld	h,(ix+TRACK_cmd_ToneSlideAdd+1)
	bit	7,a
	jp	nz,_pcAY_cmd3_sub
_pcAY_cmd3_add:
	;pos slide
	add	a,l
	ld	(ix+TRACK_cmd_ToneSlideAdd),a
	jp	nc,99f
	inc	h	
99:	bit	7,h
	jp	z,_pcAY_cmd3_stop			; delta turned pos ?
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),h
	jp	_pcAY_commandEND
_pcAY_cmd3_sub:
	;negative slide	
	and	$7f	  
	ld	c,a
	xor	a
	ld	b,a
	sbc	hl,bc
	bit	7,h
	jp	nz,_pcAY_cmd3_stop			; delta turned neg ?
	ld	(ix+TRACK_cmd_ToneSlideAdd),l
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),h
	jp	_pcAY_commandEND
_pcAY_cmd3_stop:	
	res	3,(ix+TRACK_Flags)
	ld	(ix+TRACK_cmd_ToneSlideAdd),0
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),0	
	jp	_pcAY_commandEND


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
	jp	z,.pos	
	
.neg:
	and	$1f	; make it 32 steps again
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(hl)
	neg
	jp	z,.zero			; $ff00 gives strange result ;)	
	ld	(ix+TRACK_cmd_ToneAdd),a
	ld	(ix+TRACK_cmd_ToneAdd+1),0xff
	jp	_pcAY_commandEND	

.pos:
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(hl)
.zero:	
	ld	(ix+TRACK_cmd_ToneAdd),a
	ld	(ix+TRACK_cmd_ToneAdd+1),0
	jp	_pcAY_commandEND	

_pcAY_cmd5:
	call	_pcAY_cmdasub
	jp	_pcAY_cmd3
	
	
;	jp	z,_pcAY_cmd5_pos
;	;--- neg
;	and	$1f
;	ld	(ix+TRACK_Timer),a
;	ld	a,(ix+TRACK_cmd_VolumeAdd)
;	and	a
;	jp	z,_pcAY_cmd3
;	sub	16
;;	cp	-16		; only store values smaller then -15
;;	jp	z,_pcAY_cmd3
;	ld	(ix+TRACK_cmd_VolumeAdd),a
;	jp	_pcAY_cmd3
;_pcAY_cmd5_pos:
;	ld	(ix+TRACK_Timer),a
;	ld	a,(ix+TRACK_cmd_VolumeAdd)
;	add	16
;	jp	z,_pcAY_cmd3
;	inc	a
;	cp	16		; only store values smaller then -15
;	jp	z,_pcAY_cmd3
;	ld	(ix+TRACK_cmd_VolumeAdd),a
;	jp	_pcAY_cmd3		




_pcAY_cmd6:
	call	_pcAY_cmdasub
	jp	_pcAY_cmd4		

;	;retrig
;	dec	(ix+TRACK_Timer)
;	jp	nz,_pcAY_cmd4
;	
;	; vol	slide
;	ld	a,(ix+TRACK_cmd_A)
;	bit	7,a		;- if	set vol slide is neg
;	jp	z,_pcAY_cmd6_pos
;	;--- neg
;	and	$1f
;	ld	(ix+TRACK_Timer),a
;	ld	a,(ix+TRACK_cmd_VolumeAdd)
;	and	a
;	jp	z,_pcAY_cmd4
;	sub	16
;;	dec	a
;;	cp	-16		; only store values smaller then -15
;;	jp	z,_pcAY_cmd4
;	ld	(ix+TRACK_cmd_VolumeAdd),a
;	jp	_pcAY_cmd4
;_pcAY_cmd6_pos:
;	ld	(ix+TRACK_Timer),a
;	ld	a,(ix+TRACK_cmd_VolumeAdd)
;	add	16
;	jp	z,_pcAY_cmd4
;;	inc	a
;;	cp	16		; only store values smaller then -15
;;	jp	z,_pcAY_cmd4
;	ld	(ix+TRACK_cmd_VolumeAdd),a

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
;	jp	z,.pos	
	
.neg:
	and	$1f	; make it 32 steps again
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(hl)
	sla	a
	sla	a	
	sla	a
	sla	a
;	jp	z,.zero			; $ff00 gives strange result ;)
;	or 	128				; set the neg bit
;.zero:
	ld	(ix+TRACK_cmd_VolumeAdd),a
	jp	_pcAY_commandEND		
;.pos:
;	add	a,l
;	ld	l,a
;	jp	nc,99f
;	inc	h
;99:
;	ld	a,(hl)
;	sla	a
;	sla	a	
;	sla	a
;	or 128
;;.zero:	
;	ld	(ix+CHIP_cmd_VolumeAdd),a
;	jp	_pcAY_commandEND	





_pcAY_cmd8:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND
_pcAY_cmd9:
	dec	(ix+TRACK_Timer)
	jp	nz,_pcAY_commandEND
	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND



_pcAY_cmda:
	;retrig
;	dec	(ix+TRACK_Timer)
	call	_pcAY_cmdasub
	jp	_pcAY_commandEND

_pcAY_cmdasub
	dec	(ix+TRACK_Timer)
;	jp	nz,_pcAY_cmd3
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
	
;	jp	_pcAY_commandEND
_pcAY_cmdc:
;	res	3,(ix+TRACK_Flags)
;	jp	_pcAY_commandEND
_pcAY_cmdd:
;	;call	replay_setnextpattern
;	ld	a,64
;	ld	(replay_line),a
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND
	
_pcAY_cmde:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND
_pcAY_cmdf:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND
;--- SHORT ARP
_pcAY_cmd10:
	dec	(ix+TRACK_Timer)
	bit	0,(ix+TRACK_Timer)
	jp	z,_pcAY_commandEND
	ld	a,(ix+TRACK_cmd_E)
	ld	(ix+TRACK_cmd_NoteAdd),a		
	jp	_pcAY_commandEND
	
	
_pcAY_cmd11:
;	dec	(ix+TRACK_Timer)
;	jp	nz,_pcAY_commandEND

;	res	3,(ix+TRACK_Flags)
;	ld	a,(ix+TRACK_cmd_ToneSlideAdd)
	ld	a,(ix+TRACK_cmd_E)
	ld	(ix+TRACK_cmd_ToneSlideAdd),a
	xor	a
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),a
	jp	_pcAY_commandEND	

_pcAY_cmd12:
;	dec	(ix+TRACK_Timer)
;	jp	nz,_pcAY_commandEND

;	res	3,(ix+TRACK_Flags)
;	ld	a,(ix+TRACK_cmd_ToneSlideAdd)
	ld	a,(ix+TRACK_cmd_E)
	ld	(ix+TRACK_cmd_ToneSlideAdd),a
	ld	a,$ff
	ld	(ix+TRACK_cmd_ToneSlideAdd+1),a
	jp	_pcAY_commandEND	

_pcAY_cmd13:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND	
_pcAY_cmd14:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND	
_pcAY_cmd15:
;	dec	(ix+TRACK_Timer)
;	jp	nz,_pcAY_commandEND
;
;	;res	3,(ix+TRACK_Flags)
;	ld	a,(ix+TRACK_cmd_E)
;	ld	d,a
;	ld	e,(ix+TRACK_cmd_ToneAdd)
;	add	e
;	ld	(ix+TRACK_ToneAdd),a
;	jp	nc,_pcAY_commandEND	
;	
;	bit	7,d
;	jp	z,1f
;	dec	(ix+TRACK_ToneAdd+1)
;	jp	_pcAY_commandEND	
;1:	inc	(ix+TRACK_ToneAdd+1)
;	jp	_pcAY_commandEND	
;
;
;
;	

_pcAY_cmd16:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND	
_pcAY_cmd17:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND	
_pcAY_cmd18:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND	
_pcAY_cmd19:
	;retrig
	dec	(ix+TRACK_Timer)
	jp	nz,_pcAY_commandEND
	
	; retrig note
	ld	a,(ix+TRACK_cmd_E)
	ld	(ix+TRACK_Timer),a
	set	0,(ix+TRACK_Flags)
	
	jp	_pcAY_commandEND	
_pcAY_cmd1a:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND	
_pcAY_cmd1b:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND	
_pcAY_cmd1c:
	dec	(ix+TRACK_Timer)
	jp	nz,_pcAY_commandEND
	
	; stop note
	res	1,(ix+TRACK_Flags)	; set	note bit to	0
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND	
_pcAY_cmd1d:
	; note delay
	dec	(ix+TRACK_Timer)
	jp	nz,_pcAY_commandEND	; no delay yet

	; trigger note
	ld	a,(ix+TRACK_cmd_E)		
	ld	(ix+TRACK_Note),a		; set	the note val
	set	0,(ix+TRACK_Flags)		; set	trigger note flag
;	res	3,(ix+TRACK_Flags)		; reset tiggger cmd flag
	
	jp	_pcAY_commandEND	
_pcAY_cmd1e:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND	
_pcAY_cmd1f:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND	
_pcAY_cmd20:
;	res	3,(ix+TRACK_Flags)
	jp	_pcAY_commandEND	
	
_pcAY_cmd21:
	;=================
	; Waveform PWM / Duty Cycle
	;=================
	res	3,(ix+TRACK_Flags)	; reset command
	res	6,(ix+TRACK_Flags)	; reset normal wave update

	;get the waveform	start	in [DE]
	ld	hl,_0x9800
	ld	a,iyh		;ixh contains chan#
	rrca			; a mac value is 4 so
	rrca			; 3 times rrca is	X32
	rrca			; max	result is 128.
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	b,(ix+TRACK_cmd_B)
	inc	b

	ld	c,96	
	ld	a,32
	sub	b
_wspw_loop_h:
	ld	(hl),c
	inc	hl
	djnz	_wspw_loop_h
	
	and	a
	jp	z,_pcAY_commandEND
	
	ld	c,-96
	ld	b,a
_wspw_loop_l:
	ld	(hl),c
	inc	hl
	djnz	_wspw_loop_l

	jp	_pcAY_commandEND
	
_pcAY_cmd22:
	;=================
	; Waveform Cut
	;=================

	res	3,(ix+TRACK_Flags)	; reset command
	res	6,(ix+TRACK_Flags)	; reset normal wave update

	;get the waveform	start	in [DE]
	ld	de,_0x9800
	ld	a,iyh		;ixh contains chan#
	rrca			; a mac value is 4 so
	rrca			; 3 times rrca is	X32
	rrca			; max	result is 128.
	add	a,e
	ld	e,a
	jp	nc,99f
	inc	d
99:
	ld	a,(ix+TRACK_Waveform)
	add	a,a
	add	a,a
	add	a,a	

	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
		
	ld	  bc,_WAVESSCC
	add	  hl,bc

	ld	a,(ix+TRACK_cmd_B)
	inc	a
	add	a
	ld	c,a
	ld	b,0
	ldir
	
	sub	32
	neg	
	jp	z,_pcAY_commandEND	
	
	ld	b,a
	xor	a
_wsc_l:
	ld	(de),a
	inc	de
	djnz	_wsc_l
	
	jp	_pcAY_commandEND
	
_pcAY_cmd23:
_pcAY_cmd24:	
_pcAY_cmd25:
	jp	_pcAY_commandEND	


	



	
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
	jp	z,99f

;	ld	a,(psgmode)
;	and	a
;	jp	nz,e_psg

;msx_psg:
;	; set PSG
;	ld	a,$d
;	out	($a0),a
;	ld	a,1
;	out	($a1),a
;
	;--- Apply the mixer.
	ld	a,(MainMixer)
	ld	b,a
	xor	a
	bit	5,b
	jp	nz,0f
	;-- chan 1 off
	ld	(AY_regVOLA),a
0:	
	bit	6,b
	jp	nz,0f
	;-- chan 2 off
	ld	(AY_regVOLB),a
0:
	bit	7,b
	jp	nz,0f
	;-- chan 3 off
	ld	(AY_regVOLC),a
0:
99:
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

	
	
;e_psg:
;	; set PSG BANK A
;	ld	a,$d
;	out	($a0),a
;	ld	a,10100000b
;	out	($a1),a
;
;	;--- Apply the mixer.
;	ld	a,(MainMixer)
;	ld	b,a
;	xor	a
;	bit	5,b
;	jp	nz,0f
;	;-- chan 1 off
;	ld	(AY_regVOLA),a
;0:	
;	bit	6,b
;	jp	nz,0f
;	;-- chan 2 off
;	ld	(AY_regVOLB),a
;0:
;	bit	7,b
;	jp	nz,0f
;	;-- chan 3 off
;	ld	(AY_regVOLC),a
;0:
;99:
;	ld	bc,(AY_regToneA)
;	ld	a,0
;	out	($a0),a
;	ld	a,c
;	out	($a1),a
;	ld	a,1
;	out	($a0),a
;	ld	a,b
;	out	($a1),a
;	ld	bc,(AY_regToneB)
;	ld	a,2
;	out	($a0),a
;	ld	a,c
;	out	($a1),a
;	ld	a,3
;	out	($a0),a
;	ld	a,b
;	out	($a1),a
;	ld	bc,(AY_regToneC)
;	ld	a,4
;	out	($a0),a
;	ld	a,c
;	out	($a1),a
;	ld	a,5
;	out	($a0),a
;	ld	a,b
;	out	($a1),a
;	
;	ld	a,6
;	out	($a0),a
;	ld	a,(AY_regNOISE)
;	out	($a1),a
;	ld	a,7
;	out	($a0),a
;	ld	a,(AY_regMIXER)
;	out	($a1),a
;
;	ld	a,8
;	out	($a0),a
;	ld	a,(AY_regVOLA)
;	rla	
;	out	($a1),a
;	ld	a,9
;	out	($a0),a
;	ld	a,(AY_regVOLB)
;	rla	
;	out	($a1),a	
;	ld	a,$a
;	out	($a0),a
;	ld	a,(AY_regVOLC)
;	rla	
;	out	($a1),a	
;
;
;	;BANK B
;	ld	a,$d
;	out	($a0),a
;	ld	a,10110000b
;	out	($a1),a
;	
;	
;	ld	a,(AY_duty1)
;	ld	d,a
;	and	a
;	jp	z,99f
;	ld	a,6
;	out	($a0),a
;	ld	a,d
;	out	($a1),a	
;99:
;	ld	a,(AY_duty1)
;	ld	d,a
;	and	a
;	jp	z,99f
;	ld	a,6
;	out	($a0),a
;	ld	a,d
;	out	($a1),a	
;99:
;	ld	a,(AY_duty2)
;	ld	d,a
;	and	a
;	jp	z,99f
;
;	ld	a,7
;	out	($a0),a
;	ld	a,d
;	out	($a1),a	
;99:
;	ld	a,(AY_duty3)
;	ld	d,a
;	and	a
;	jp	z,99f
;	
;	ld	a,8
;	out	($a0),a
;	ld	a,d
;	out	($a1),a	
;99:
;	ld	a,(AY_NoiseOR)
;	ld	d,a
;	and	a
;	jp	z,99f
;	
;	ld	a,$a
;	out	($a0),a
;	ld	a,d
;	out	($a1),a	
;	xor	a
;	ld	(AY_NoiseOR),a
;99:
;	ld	a,(AY_NoiseAND)
;	ld	d,a
;	and	a
;	jp	z,99f
;	
;	ld	a,$9
;	out	($a0),a
;	ld	a,d
;	out	($a1),a	
;	xor	a
;	ld	(AY_NoiseAND),a
;99:



;	;--- Push values to AY HW
;	ld	b,0
;	ld	c,0xa0
;	ld	hl,AY_registers
;_comp_loop:	
;	out	(c),b
;	ld	a,(hl)
;	add	1
;	out	(0xa1),a
;	inc	hl
;	ld	a,(hl)
;	adc	a,0
;	inc	b
;	out	(c),b	
;	inc	hl
;	out	(0xa1),a	
;	inc	b
;	ld	a,6
;	cp	b
;	jp	nz,_comp_loop
;	
;	ld	a,b	
;	
;	
;_ptAY_loop:
;	out	(c),a
;	inc	c
;	outi
;	dec	c
;	inc	a
;	cp	13
;	jr	nz,_ptAY_loop
;
;	ld	b,a
;	ld	a,(hl)
;	and	a
;	jp	z,_ptAY_noEnv
;	out	(c),b
;	inc	c
;	out 	(c),a
;	ld	(hl),0	;reset the envwrite
	
		
	
scc_route:
	
;--------------
; S C	C 
;--------------
	;--- Apply the mixer.
	ld	hl,SCC_regMIXER
	;--- do not	apply	mmainmixer when in  mode 2
;	ld	a,(keyjazz)
;	and	a
;	jp	nz,99f
	ld	a,(replay_mode)
	cp	2
	jp	z,99f
	ld	a,(MainMixer)
	and	(hl)	; set	to 0 to silence
	ld	(hl),a
99:
	;--- Set the waveforms
	ld	hl,TRACK_Chan4+TRACK_Flags
	bit	6,(hl)
	jp	z,0f
	;--- set wave form
	res	6,(hl)
	ld	a,(TRACK_Chan4+TRACK_Waveform)
	ld	de,_0x9800
	call	_write_SCC_wave
0:
	ld	hl,TRACK_Chan5+TRACK_Flags
	bit	6,(hl)
	jp	z,0f
	;--- set wave form
	res	6,(hl)
	ld	a,(TRACK_Chan5+TRACK_Waveform)
	ld	de,_0x9820
	call	_write_SCC_wave
0:
	ld	hl,TRACK_Chan6+TRACK_Flags
	bit	6,(hl)
	jp	z,0f
	;--- set wave form
	res	6,(hl)
	ld	a,(TRACK_Chan6+TRACK_Waveform)
	ld	de,_0x9840
	call	_write_SCC_wave
0:
	ld	hl,TRACK_Chan7+TRACK_Flags
	bit	6,(hl)
	jp	z,0f
	;--- set wave form
	res	6,(hl)
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
;	bit	4,(hl)
;	jp	nz,_write_SCC_special
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
;	bit	7,a
;	jp	nz,_write_SCC_PW_wave
;	bit	6,a
;	jp	nz,_write_SCC_cut
;	ret


	
	
	





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
	jp	z,99f
	set	6,(hl)
99:
	add	hl,de
	djnz	10b	
	
	
	;---- timer ended.
	inc	a
	jp	nz,_rpm_next_step		; if status was !=255 then skip init

	;---- calculate offset
	inc	a		
	ld	(replay_morph_active),a		; set status to 1
;	ld	(replay_morph_update),a		; after this update the waveforms of the SCC

	ld	a,(replay_morph_speed)
	ld	(replay_morph_timer),a
	

	;--- calculate the delta's
	ld	de,replay_morph_buffer
	ld	hl,_WAVESSCC
	ld	a,(replay_morph_waveform)
	add	a
	jp	nc,99f
	inc	h
99:	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:	
	;---- start calculating
	ld	b,32		; 32 values
_rpm_loop:	
	inc	de
	ld	a,(de)
	dec	de
	add	a,128
	ld	c,a
	ld	a,(hl)
	add	a,128
	cp	c
	jp	c,_rpm_smaller		; dest is smaller

	
_rpm_larger:
	sub	c
	rrca
	rrca
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
	jp	nz,99f
	;--- end morph
	ld	(replay_morph_active),a

99:
	dec c
	ld	hl,replay_morph_buffer
	ld	b,32
_rpm_ns_loop:	
	ld	a,(hl)
	bit 	4,a
	jp	z,_rmp_ns_add
_rmp_ns_sub:
	;--- handle corection
	and	$ef
	cp	c		; correction < counteR?
	jp	c,99f
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
	jp	c,99f
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