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
replay_chan_setup			db 1			; 0 = 2 psg+ 6 fm, 1 = 3psg + 5 fm

replay_patpointer 		dw 0			; pointer to the data
replay_patpage 			db 0 			; the current page
replay_previous_note		db 0			; previousnote played
replay_mainvol			db 0			; the volume correction.

;replay_vib_table:			dw 0			; pointer to the vibrato table
replay_Tonetable:			dw CHIP_ToneTable

CHIP_Instrument		equ 0	
CHIP_Voice			equ 1
CHIP_Waveform		equ 1
CHIP_Command		equ 2
CHIP_MacroPointer		equ 3	
CHIP_Note			equ 5	
CHIP_Volume			equ 6	
CHIP_Flags			equ 7	
	; 0 = note trigger
	; 1 = note active
	; 2 = 
	; 3 = command trigger
	; 4 = key trigger		; for fm note trigger	;'command tone add
	; 5 = sustain		; for fm note sustain	;'instrument trigger
	; 6 = custom voice trigger
	; 7 = PSG/SCC
CHIP_MacroStep		equ 8			; reset after note set
CHIP_ToneAdd		equ 9			; reset after note set
CHIP_VolumeAdd		equ 11		; reset after note set
CHIP_Noise			equ 12		; reset after note set


CHIP_cmd_ToneSlideAdd	equ 13		; reset after note set
;CHIP_cmd_VolumeSlideAdd	equ 15		; reset after note set
CHIP_cmd_NoteAdd		equ 15		; reset after note set
CHIP_cmd_ToneAdd		equ 16		; reset after note set
CHIP_cmd_VolumeAdd	equ 18		; reset after note set
CHIP_cmd_0			equ 19
CHIP_cmd_1			equ 20
CHIP_cmd_2			equ 21
CHIP_cmd_3			equ 22
CHIP_cmd_4_depth		equ 23	; pointer to the sine table
CHIP_cmd_4_step		equ 25
;CHIP_cmd_6			equ 26
CHIP_cmd_detune		equ 26

CHIP_cmd_9			equ 28
CHIP_cmd_A			equ 29		
CHIP_cmd_B			equ 30		
CHIP_cmd_E			equ 31
;CHIP_cmd_F			equ 31
CHIP_Timer			equ 32		; used for timing by all cmd's
CHIP_Step			equ 33		; only for VIBRATO???

CHIP_REC_SIZE		equ 34

; Moved to RAM > $c000 to free space for replayer code.
;CHIP_Chan1			ds	CHIP_REC_SIZE
;CHIP_Chan2			ds	CHIP_REC_SIZE
;CHIP_Chan3			ds	CHIP_REC_SIZE
;CHIP_Chan4			ds	CHIP_REC_SIZE
;CHIP_Chan5			ds	CHIP_REC_SIZE
;CHIP_Chan6			ds	CHIP_REC_SIZE
;CHIP_Chan7			ds	CHIP_REC_SIZE
;CHIP_Chan8			ds	CHIP_REC_SIZE


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
AY_regVOLC		db	0	; Chan C volume

IFDEF TTSMS
;--- Values are used to be able to mute noise when chan is muted,
SN_regVOLNA	db	0
SN_regVOLNB	db 	0

ENDIF

SN_regVOLN
AY_regEnvL 		db	0	; Volume Env Freq low (8bit)
SN_regNOISEold	
AY_regEnvH 		db	0	; Volume Env Freq high (4bit)
AY_regEnvShape 	db	0	; Volume Env Shape (4bit)
AY_VOLUME_TABLE   
	incbin "..\data\voltable.bin"	


;--- SCC SPECIFIC
SCC_registers
FM_registers 
FM_regToneA
SCC_regToneA 	dw	0	; Tone A freq low (8bit)					; Tone A freq high (1bit)
;FM_regKeyA		db	0
FM_regToneB
SCC_regToneB 	dw	0	; Tone B freq low					; Tone B freq high
;FM_regKeyB		db	0
FM_regToneC
SCC_regToneC 	dw	0	; Tone C freq low					; Tone C freq high
;FM_regKeyC		db	0
FM_regToneD
SCC_regToneD 	dw	0	; Tone D freq low					; Tone D freq high
;FM_regKeyD		db	0
FM_regToneE
SCC_regToneE 	dw	0	; Tone E freq low					; Tone E freq high
;FM_regKeyE		db	0
FM_regToneF
SCC_regToneF 	dw	0	; Tone E freq low					; Tone E freq high

FM_regVOLA
SCC_regVOLA 	db	0	; Chan B volume
FM_regVOLB
SCC_regVOLB 	db	0	; Chan B volume
FM_regVOLC
SCC_regVOLC  	db	0	; Chan C volume
FM_regVOLD
SCC_regVOLD 	db	0	; Chan D volume
FM_regVOLE
SCC_regVOLE  	db	0	; Chan E volume
FM_regVOLF
SCC_regVOLF  	db	0	; Chan E volume

FM_DRUM		db	0	; Percussion bits
FM_DRUM_Flags	db	0	; 7, percusion, 6,4,2 = tone update, 5,3,1 = vol update
FM_freqreg1		dw	0	; Base drum
FM_volreg1		db	0	; Drum (low)
FM_freqreg2		dw	0	; Snare + HiHat
FM_volreg2		db	0	; Snare(low) Hihat(High)
FM_freqreg3		dw	0	; Cymbal + TomTom
FM_volreg3		db	0	; Cymbal(low) TomTom (High)

FM_DRUM_LEN		db	0	; Length of drum macro
FM_DRUM_MACRO	dw	0	; Pointer to drum macro data

FM_softvoice_req	db	0	; Software voice requested
FM_softvoice_set 	db	0	; Software voice currently loaded



;FM_DRUM1_LEN	db	0
;FM_DRUM1		dw	0	; pointer to BDrum macro
;FM_DRUM2_LEN	db	0
;FM_DRUM2		dw	0 	; pointer to SN+HHat macro
;FM_DRUM3_LEN	db	0
;FM_DRUM3		dw	0	; pointer to CYm_Tom macro


SCC_regMIXER 	db	0	; x3f	; Mixer control (1 = off, 0 = on)

_AUDITION_LINE:
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
psgport:	db	0
		
CHIP_FM_ToneTable:
	db   	0,0
	db	0adh,000h,0b7h,000h,0c2h,000h,0cdh,000h,0d9h,000h,0e6h,000h	; Oct 1
      db	0f4h,000h,003h,001h,012h,001h,022h,001h,034h,001h,046h,001h
      db    0adh,002h,0b7h,002h,0c2h,002h,0cdh,002h,0d9h,002h,0e6h,002h ; Oct 2
      db    0f4h,002h,003h,003h,012h,003h,022h,003h,034h,003h,046h,003h
      db    0adh,004h,0b7h,004h,0c2h,004h,0cdh,004h,0d9h,004h,0e6h,004h ; Oct 3
      db    0f4h,004h,003h,005h,012h,005h,022h,005h,034h,005h,046h,005h
      db    0adh,006h,0b7h,006h,0c2h,006h,0cdh,006h,0d9h,006h,0e6h,006h ; Oct 4
      db    0f4h,006h,003h,007h,012h,007h,022h,007h,034h,007h,046h,007h
      db    0adh,008h,0b7h,008h,0c2h,008h,0cdh,008h,0d9h,008h,0e6h,008h ; Oct 5
      db    0f4h,008h,003h,009h,012h,009h,022h,009h,034h,009h,046h,009h
      db    0adh,00ah,0b7h,00ah,0c2h,00ah,0cdh,00ah,0d9h,00ah,0e6h,00ah ; Oct 6
      db    0f4h,00ah,003h,00bh,012h,00bh,022h,00bh,034h,00bh,046h,00bh
      db    0adh,00ch,0b7h,00ch,0c2h,00ch,0cdh,00ch,0d9h,00ch,0e6h,00ch ; Oct 7
      db    0f4h,00ch,003h,00dh,012h,00dh,022h,00dh,034h,00dh,046h,00dh
      db    0adh,00eh,0b7h,00eh,0c2h,00eh,0cdh,00eh,0d9h,00eh,0e6h,00eh ; Oct 8
      db    0f4h,00eh,003h,00fh,012h,00fh,022h,00fh,034h,00fh,046h,00fh

IFDEF TTSMS
CHIP_ToneTable:	
	dw	0	;	Dummy value (note 0)
	dw $0001	     ; C1			
	dw $0001	     ; C#1			
	dw $0001	     ; D1			
	dw $0001	     ; D#1			
	dw $0001	     ; E1			
	dw $0001	     ; F1			
	dw $0001	     ; F#1			
	dw $0001	     ; G1
	dw $0001	     ; G#1	
	dw $0001         ; A1
	dw $0001         ; A#1/Bb1 
	dw $0001         ; B1	
	dw $0001	     ; C2			
	dw $0001	     ; C#2			
	dw $0001	     ; D2			
	dw $0001	     ; D#2			
	dw $0001	     ; E2			
	dw $0001	     ; F2			
	dw $0001	     ; F#2			
	dw $0001	     ; G2
	dw $0001	     ; G#2			
   
	dw $03F9      ;A2
	dw $03C0      ; A#2/Bb2 
	dw $038A      ;B2
	dw $0357      ;C3
	dw $0327      ; C#3/Db3 
	dw $02FA      ;D3
	dw $02CF      ; D#3/Eb3 
	dw $02A7      ;E3
	dw $0281      ;F3
	dw $025D      ; F#3/Gb3 
	dw $023B      ;G3
	dw $021B      ; G#3/Ab3 
	dw $01FC      ;A3
	dw $01E0      ; A#3/Bb3 
	dw $01C5      ;B3
	dw $01AC      ;C4
	dw $0194      ; C#4/Db4 
	dw $017D      ;D4
	dw $0168      ; D#4/Eb4 
	dw $0153      ;E4
	dw $0140      ;F4
	dw $012E      ; F#4/Gb4 
	dw $011D      ;G4
	dw $010D      ; G#4/Ab4 
	dw $00FE      ;A4
	dw $00F0      ; A#4/Bb4 
	dw $00E2      ;B4
	dw $00D6      ;C5
	dw $00CA      ; C#5/Db5 
	dw $00BE      ;D5
	dw $00B4      ; D#5/Eb5 
	dw $00AA      ;E5
	dw $00A0      ;F5
	dw $0097      ; F#5/Gb5 
	dw $008F      ;G5
	dw $0087      ; G#5/Ab5 
	dw $007F      ;A5
	dw $0078      ; A#5/Bb5 
	dw $0071      ;B5
	dw $006B      ;C6
	dw $0065      ; C#6/Db6 
	dw $005F      ;D6
	dw $005A      ; D#6/Eb6 
	dw $0055      ;E6
	dw $0050      ;F6
	dw $004C      ; F#6/Gb6 
	dw $0047      ;G6
	dw $0043      ; G#6/Ab6 
	dw $0040      ;A6
	dw $003C      ; A#6/Bb6 
	dw $0039      ;B6
	dw $0035      ;C7
	dw $0032      ; C#7/Db7 
	dw $0030      ;D7
	dw $002D      ; D#7/Eb7 
	dw $002A      ;E7
	dw $0028      ;F7
	dw $0026      ; F#7/Gb7 
	dw $0024      ;G7
	dw $0022      ; G#7/Ab7 
	dw $0020      ;A7
	dw $001E      ; A#7/Bb7 
	dw $001C      ;B7
	dw $001B      ;C8
	dw $0019      ; C#8/Db8 
	dw $0018      ;D8
	dw $0016      ; D#8/Eb8 
	dw $0015      ;E8
	dw $0014      ;F8
	dw $0013      ; F#8/Gb8 
	dw $0012      ;G8
	dw $0011      ; G#8/Ab8 
	dw $0010      ;A8
	dw $000F      ; A#8/Bb8 
	dw $000E      ;B8


	

	
	
ELSE	
CHIP_ToneTable:	
	dw	0
	dw C_PER/1	,C1_PER/1  ,D_PER/1  ,D1_PER/1  ,E_PER/1	,F_PER/1  ,F1_PER/1  ,G_PER/1	 ,G1_PER/1	,A_PER/1  ,A1_PER/1  ,B_PER/1
	dw C_PER/2	,C1_PER/2  ,D_PER/2  ,D1_PER/2  ,E_PER/2	,F_PER/2  ,F1_PER/2  ,G_PER/2	 ,G1_PER/2	,A_PER/2  ,A1_PER/2  ,B_PER/2
	dw C_PER/4	,C1_PER/4  ,D_PER/4  ,D1_PER/4  ,E_PER/4	,F_PER/4  ,F1_PER/4  ,G_PER/4	 ,G1_PER/4	,A_PER/4  ,A1_PER/4  ,B_PER/4
	dw C_PER/8	,C1_PER/8  ,D_PER/8  ,D1_PER/8  ,E_PER/8	,F_PER/8  ,F1_PER/8  ,G_PER/8	 ,G1_PER/8	,A_PER/8  ,A1_PER/8  ,B_PER/8
	dw C_PER/16	,C1_PER/16 ,D_PER/16 ,D1_PER/16 ,E_PER/16	,F_PER/16 ,F1_PER/16 ,G_PER/16 ,G1_PER/16	,A_PER/16 ,A1_PER/16 ,B_PER/16
	dw C_PER/32	,C1_PER/32 ,D_PER/32 ,D1_PER/32 ,E_PER/32	,F_PER/32 ,F1_PER/32 ,G_PER/32 ,G1_PER/32	,A_PER/32 ,A1_PER/32 ,B_PER/32
	dw C_PER/64	,C1_PER/64 ,D_PER/64 ,D1_PER/64 ,E_PER/64	,F_PER/64 ,F1_PER/64 ,G_PER/64 ,G1_PER/64	,A_PER/64 ,A1_PER/64 ,B_PER/64
	dw C_PER/128,C1_PER/128,D_PER/128,D1_PER/128,E_PER/128,F_PER/128,F1_PER/128,G_PER/128,G1_PER/128,A_PER/128,A1_PER/128,B_PER/128
	dw C_PER/256,C1_PER/256,D_PER/256,D1_PER/256,E_PER/256,F_PER/256,F1_PER/256,G_PER/256,G1_PER/256,A_PER/256,A1_PER/256,B_PER/256

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

ENDIF




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
	jp	z,replay_init_cont	; loaded; continue to loaded code.
	
	xor	a
	call	swap_loadblock
	
	jp	replay_init_cont				
	
;_WAVESSCC			
;_FM_drumfreqtable:	ds	32	; the drum frequency values
;_FM_drumfreqedit:		ds	32 	; the values use din the drumfreq editor		

;_rest_WAVESCC:	;	ds	32*30	