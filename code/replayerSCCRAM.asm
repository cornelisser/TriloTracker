;================================
; The new replayer.
;
; Persistent RAM unswappable
;
;================================
_SP_Storage	dw	0	; to store the SP

replay_key				db 0			; key to test for stopping sound
replay_line				db 0			; local playing line to sync visual playback
replay_speed 			db 2			; speed to replay (get from song)
replay_speed_subtimer 		db 0			; counter for finer speed
replay_speed_timer 		db 0 			; counter for speed
replay_mode 			db 0			; Replayer status
; mode 0  = no sound output
; mode 1  = replay song 
; mode 2  = instrument key jazz
; mode 4  = pattern keyjazz
; mode 5  = replay song step based  


replay_patpointer 		dw 0			; pointer to the data
replay_patpage 			db 0 			; the current page
replay_previous_note		db 0			; previousnote played
replay_mainvol			db 0			; the volume correction.

;replay_vib_table			dw 0			; pointer to the vibrato table
replay_Tonetable			dw TRACK_ToneTable

replay_morph_active		db 0			; flag to indicate morphing is active
replay_morph_type			db 0			; 0 = from start from currenr waveform. 1= continue from waveform in SCC Register
replay_morph_timer		db 0			; step timer between morphs
replay_morph_speed		db 0 
replay_morph_counter		db 0			; counter till end morph
replay_morph_buffer		ds 64,0		; interleaved buffer with morphed waveform and morph delta values
replay_morph_waveform		db 0 			; waveform we are morphin to.
replay_arp_speed			db 0			; counter for arp speed

replay_period:			db	0			; Pitch table for playback

;auto_env_times			db	0
;auto_env_divide			db	0
envelope_ratiotype		db	0 
envelope_ratio			db	0 
envelope_correction		dw	0 
envelope_period			dw	0 


;replay_sample_num		db 0 			; Current sample deeing played 
;replay_sample_active		db 0			; 0 = inactive, 1 update, -1 init
;replay_sample_waveoffset	db 0			; Offset for the waveform beeing used.
;replay_sample_period		dw 0			; Pointer to the period data
;replay_sample_data		dw 0			; Pointer to the waveform data

TRACK_Instrument		equ 0	
TRACK_Waveform		equ 1

TRACK_Command		equ 2
TRACK_MacroPointer	equ 3	
TRACK_Note			equ 5	
TRACK_Volume		equ 6	
TRACK_Flags			equ 7	
_TRG_NOT:		equ	0		; 0 = note trigger
_ACT_NOT:		equ	1		; 1 = note active
	; 2 = morph active		;-< for SCC when 1 then waveform is followin morph buffer
_TRG_CMD:		equ	3	; 3 = command trigger
_ACT_MOR:		equ 	4		; 4 = Morph follow active
	; 5 = instrument trigger
_TRG_WAV:		equ	6		; 6 = waveform trigger
_PSG_SCC:		equ   7		; 7 = PSG/SCC
TRACK_MacroStep		equ 8			; reset after note set
TRACK_ToneAdd		equ 9			; reset after note set
TRACK_VolumeAdd		equ 11		; reset after note set
TRACK_Noise			equ 12		; reset after note set

TRACK_cmd_ToneSlideAdd	equ 13		; reset after note set
;TRACK_cmd_VolumeSlideAdd	equ 15		; reset after note set
TRACK_cmd_NoteAdd		equ 15		; reset after note set
TRACK_cmd_ToneAdd		equ 16		; reset after note set
TRACK_cmd_VolumeAdd	equ 18		; reset after note set
TRACK_cmd_0			equ 19
TRACK_cmd_1			equ 20
TRACK_cmd_2			equ 21
TRACK_cmd_3			equ 22
TRACK_cmd_4_depth		equ 23
TRACK_cmd_4_step		equ 25
;TRACK_cmd_6			equ 26
TRACK_cmd_detune		equ 26

TRACK_cmd_9			equ 28
TRACK_cmd_A			equ 29		
TRACK_cmd_B			equ 30		
TRACK_cmd_E			equ 31
;TRACK_cmd_F		equ 31
TRACK_Timer			equ 32		; used for timing by all cmd's
TRACK_Step			equ 33		; only for VIBRATO???

TRACK_REC_SIZE		equ 34

TRACK_Chan1			ds	TRACK_REC_SIZE
TRACK_Chan2			ds	TRACK_REC_SIZE
TRACK_Chan3			ds	TRACK_REC_SIZE
TRACK_Chan4			ds	TRACK_REC_SIZE
TRACK_Chan5			ds	TRACK_REC_SIZE
TRACK_Chan6			ds	TRACK_REC_SIZE
TRACK_Chan7			ds	TRACK_REC_SIZE
TRACK_Chan8			ds	TRACK_REC_SIZE

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
      dw      $0D5C, $0C9D, $0BE7, $0B3C, $0A9B, $0A02, $0973, $08EB, $086B, $07F2, $0780, $0714
      dw      $06AE, $064E, $05F4, $059E, $054D, $0501, $04B9, $0475, $0435, $03F9, $03C0, $038A
      dw      $0357, $0327, $02FA, $02CF, $02A7, $0281, $025D, $023B, $021B, $01FC, $01E0, $01C5
      dw      $01AC, $0194, $017D, $0168, $0153, $0140, $012E, $011D, $010D, $00FE, $00F0, $00E2
      dw      $00D6, $00CA, $00BE, $00B4, $00AA, $00A0, $0097, $008F, $0087, $007F, $0078, $0071
      dw      $006B, $0065, $005F, $005A, $0055, $0050, $004C, $0047, $0043, $0040, $003C, $0039
      dw      $0035, $0032, $0030, $002D, $002A, $0028, $0026, $0024, $0022, $0020, $001E, $001C
      dw      $001B, $0019, $0018, $0016, $0015, $0014, $0013, $0012, $0011, $0010, $000F, $000E
;	dw	0	;	Dummy value (note 0)
;	dw C_PER/1	,C1_PER/1  ,D_PER/1  ,D1_PER/1  ,E_PER/1	,F_PER/1  ,F1_PER/1  ,G_PER/1	 ,G1_PER/1	,A_PER/1  ,A1_PER/1  ,B_PER/1
;	dw C_PER/2	,C1_PER/2  ,D_PER/2  ,D1_PER/2  ,E_PER/2	,F_PER/2  ,F1_PER/2  ,G_PER/2	 ,G1_PER/2	,A_PER/2  ,A1_PER/2  ,B_PER/2
;	dw C_PER/4	,C1_PER/4  ,D_PER/4  ,D1_PER/4  ,E_PER/4	,F_PER/4  ,F1_PER/4  ,G_PER/4	 ,G1_PER/4	,A_PER/4  ,A1_PER/4  ,B_PER/4
;	dw C_PER/8	,C1_PER/8  ,D_PER/8  ,D1_PER/8  ,E_PER/8	,F_PER/8  ,F1_PER/8  ,G_PER/8	 ,G1_PER/8	,A_PER/8  ,A1_PER/8  ,B_PER/8
;	dw C_PER/16	,C1_PER/16 ,D_PER/16 ,D1_PER/16 ,E_PER/16	,F_PER/16 ,F1_PER/16 ,G_PER/16 ,G1_PER/16	,A_PER/16 ,A1_PER/16 ,B_PER/16
;	dw C_PER/32	,C1_PER/32 ,D_PER/32 ,D1_PER/32 ,E_PER/32	,F_PER/32 ,F1_PER/32 ,G_PER/32 ,G1_PER/32	,A_PER/32 ,A1_PER/32 ,B_PER/32
;	dw C_PER/64	,C1_PER/64 ,D_PER/64 ,D1_PER/64 ,E_PER/64	,F_PER/64 ,F1_PER/64 ,G_PER/64 ,G1_PER/64	,A_PER/64 ,A1_PER/64 ,B_PER/64
;	dw C_PER/128,C1_PER/128,D_PER/128,D1_PER/128,E_PER/128,F_PER/128,F1_PER/128,G_PER/128,G1_PER/128,A_PER/128,A1_PER/128,B_PER/128
;	dw C_PER/256,C1_PER/256,D_PER/256,D1_PER/256,E_PER/256,F_PER/256,F1_PER/256,G_PER/256,G1_PER/256,A_PER/256,A1_PER/256,B_PER/256
;	dw C_PER/512,C1_PER/512,D_PER/512,D1_PER/512,E_PER/512,F_PER/512,F1_PER/512,G_PER/512,G1_PER/512,A_PER/512,A1_PER/512,B_PER/512

AY_VOLUME_TABLE: 
	; No tail
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00   
	db $00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01   
	db $00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02   
	db $00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03   
	db $00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04   
	db $00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05   
	db $00,$00,$01,$01,$02,$02,$02,$03,$03,$04,$04,$04,$05,$05,$06,$06
	db $00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07
	db $00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07,$08
	db $00,$01,$01,$02,$02,$03,$04,$04,$05,$05,$06,$07,$07,$08,$08,$09
	db $00,$01,$01,$02,$03,$03,$04,$05,$05,$06,$07,$07,$08,$09,$09,$0A
	db $00,$01,$01,$02,$03,$04,$04,$05,$06,$07,$07,$08,$09,$0A,$0A,$0B
	db $00,$01,$02,$02,$03,$04,$05,$06,$06,$07,$08,$09,$0A,$0A,$0B,$0C
	db $00,$01,$02,$03,$03,$04,$05,$06,$07,$08,$09,$0A,$0A,$0B,$0C,$0D
	db $00,$01,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
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

SCC_VOLUME_TABLE 
	; Tail mode off
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07
	db $00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08
	db $00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09
	db $00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A
	db $00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B
	db $00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C
	db $00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D
	db $00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
	; Tail mode ON
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07
;	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08
;	db $01,$01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09
;	db $01,$01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A
;	db $01,$01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B
;	db $01,$01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C
;	db $01,$01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D
;	db $01,$01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
;	db $01,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F	







;AY_duty1		db	0
;AY_duty2		db	0
;AY_duty3		db	0
;psgmode		db	0
;AY_NoiseOR		db	0
;AY_NoiseAND		db	0


DrumMixer

;--- AY SPECIFIC
AY_registers 
AY_regToneA 	dw	0	; Tone A freq low (8bit)
					; Tone A freq high (4bit)
AY_regToneB 	dw	0	; Tone B freq low
					; Tone B freq high
AY_regToneC 	dw	0	; Tone C freq low
					; Tone C freq high
AY_regNOISE 	db	0	; Noise freq (5bit)
AY_regMIXER 	db	0x38	;x3f	; Mixer control (1 = off, 0 = on)
AY_regVOLA 		db	0	; Chan A volume
AY_regVOLB 		db	0	; Chan B volume
AY_regVOLC  	db	0	; Chan C volume
AY_regEnvL 		db	1	; Volume Env Freq low (8bit)	
AY_regEnvH 		db	0	; Volume Env Freq high (4bit)
AY_regEnvShape 	db	0	; Volume Env Shape (4bit)

;--- SCC SPECIFIC
SCC_registers 
SCC_regToneA 	dw	0	; Tone A freq low (8bit)
					; Tone A freq high (4bit)
SCC_regToneB 	dw	0	; Tone B freq low
					; Tone B freq high
SCC_regToneC 	dw	0	; Tone C freq low
					; Tone C freq high
SCC_regToneD 	dw	0	; Tone D freq low
					; Tone D freq high
SCC_regToneE 	dw	0	; Tone E freq low
					; Tone E freq high
SCC_regVOLA 	db	0	; Chan A volume
SCC_regVOLB 	db	0	; Chan B volume
SCC_regVOLC  	db	0	; Chan C volume
SCC_regVOLD 	db	0	; Chan D volume
SCC_regVOLE  	db	0	; Chan E volume
SCC_regMIXER 	db	0	; x3f	; Mixer control (1 = off, 0 = on)

_WAVESSCC: 			ds	32*MAX_WAVEFORM

_AUDITION_LINE:
		db	0,0,8,0           ; default envelope freq $400
		db	0,0,9,4
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
_PRE_INIT_LINE:
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0		

psgport:	db	0
;-- SCC registers
oldregs:	ds	32*4+3*5+1,255	; a way to int the SCC
newregs:
_0x9800:	ds	32
_0x9820:	ds	32
_0x9840:	ds	32
_0x9860:	ds	32
_0x9880:	ds	5*2
		ds	5*1
		ds	1

;===========================================================
; ---	replay_play
; Plays the	data according to	the current	replay_mode
; 
;
;===========================================================
replay_play:
	ld	a,(replay_mode)
	and	a
	ret	z	; Replay mode = 0	is silent
	
	dec	a
	jr.	z,replay_mode1	; play music normal
	dec	a
	jr.	z,replay_mode2	; keyjazz
	dec	a
	jr.	z,replay_mode3	; note audition
	dec	a
	jr.	z,replay_mode4	; [ENTER] looped play
	dec	a
	jr.	z,replay_mode5	;  Stepped playback
	;--- DEBUG
	XOR	A
	LD	(replay_mode),A
	ret
	
;===========================================================
; ---	replay_init
; Initialize all data for playback
; 
; 
;===========================================================
replay_init:
	; fail save. Check if the replayer is loaded in RAM

	ld	a,(swap_block)
	and	a
	jr.	z,replay_init_cont	; loaded; continue to loaded code.
	
	xor	a
	call	swap_loadblock
	
	jr.	replay_init_cont
	
	
;===========================================================
; ---	replay_stop
; Silence all channels
; 
; 
;===========================================================
replay_stop:
	xor	a
	ld	(replay_mode),a	
	
	;--- Silence the SCC chip
	ld	(SCC_regMIXER),a

	;--- Silence the AY3 PSG chip
	ld	a,0x3f
	ld	(AY_regMIXER),a

	; Remove envelope
	; Envelope could continue
	ld	a,(AY_regVOLA)
	and	$0f
	ld	(AY_regVOLA),a
	ld	a,(AY_regVOLB)
	and	$0f
	ld	(AY_regVOLB),a
	ld	a,(AY_regVOLC)
	and	$0f
	ld	(AY_regVOLC),a

      call  replay_route
      ei                      ;--- As replay_route does slot select. 
	ret	
	