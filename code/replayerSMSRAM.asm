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

replay_patpointer 		dw 0			; pointer to the data
replay_patpage 			db 0 			; the current page
replay_previous_note		db 0			; previousnote played
replay_mainvol			db 0			; the volume correction.

replay_vib_table:			dw 0			; pointer to the vibrato table
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
CHIP_cmd_4_depth		equ 23
CHIP_cmd_4_step		equ 24
;CHIP_cmd_6			equ 26
CHIP_cmd_detune		equ 25

CHIP_cmd_9			equ 27
CHIP_cmd_A			equ 28		
CHIP_cmd_B			equ 29		
CHIP_cmd_E			equ 30
;CHIP_cmd_F			equ 31
CHIP_Timer			equ 31		; used for timing by all cmd's
CHIP_Step			equ 32		; only for VIBRATO???

CHIP_REC_SIZE		equ 33

CHIP_Chan1			ds	CHIP_REC_SIZE
CHIP_Chan2			ds	CHIP_REC_SIZE
CHIP_Chan3			ds	CHIP_REC_SIZE
CHIP_Chan4			ds	CHIP_REC_SIZE
CHIP_Chan5			ds	CHIP_REC_SIZE
CHIP_Chan6			ds	CHIP_REC_SIZE
CHIP_Chan7			ds	CHIP_REC_SIZE
CHIP_Chan8			ds	CHIP_REC_SIZE



;--- AY SPECIFIC
AY_registers 
AY_regToneA 	dw	0	; Tone A freq low (8bit)
					; Tone A freq high (4bit)
AY_regToneB 	dw	0	; Tone B freq low
					; Tone B freq high
AY_regToneC 	dw	0	; Tone C freq low
					; Tone C freq high
AY_regNOISE 	db	0	; Noise freq (5bit)
AY_regNOISEVOL
AY_regMIXER 	db	0x38	;x3f	; Mixer control (1 = off, 0 = on)
AY_regVOLA 		db	0	; Chan A volume
AY_regVOLB 		db	0	; Chan B volume
AY_regVOLC  	db	0	; Chan C volume
AY_regEnvL 		db	1	; Volume Env Freq low (8bit)	
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

FM_DRUM		db	0
FM_DRUM_Flags	db	0	; 0,1,2 = volume, 5,6,7 = freq
FM_volreg1		db	0	; Drum (low)
FM_volreg2		db	0	; Snare(low) Hihat(High)
FM_volreg3		db	0	; Cymbal(low) TomTom (High)
FM_freqreg1		dw	0	; Base drum
FM_freqreg2		dw	0	; Snare + HiHat
FM_freqreg3		dw	0	; Cymbal + TomTom

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
	db	0adh,000h,0b7h,000h,0c2h,000h,0cdh,000h,0d9h,000h,0e6h,000h
      db	0f4h,000h,003h,001h,012h,001h,022h,001h,034h,001h,046h,001h
      db    0adh,002h,0b7h,002h,0c2h,002h,0cdh,002h,0d9h,002h,0e6h,002h
      db    0f4h,002h,003h,003h,012h,003h,022h,003h,034h,003h,046h,003h
      db    0adh,004h,0b7h,004h,0c2h,004h,0cdh,004h,0d9h,004h,0e6h,004h
      db    0f4h,004h,003h,005h,012h,005h,022h,005h,034h,005h,046h,005h
      db    0adh,006h,0b7h,006h,0c2h,006h,0cdh,006h,0d9h,006h,0e6h,006h
      db    0f4h,006h,003h,007h,012h,007h,022h,007h,034h,007h,046h,007h
      db    0adh,008h,0b7h,008h,0c2h,008h,0cdh,008h,0d9h,008h,0e6h,008h
      db    0f4h,008h,003h,009h,012h,009h,022h,009h,034h,009h,046h,009h
      db    0adh,00ah,0b7h,00ah,0c2h,00ah,0cdh,00ah,0d9h,00ah,0e6h,00ah
      db    0f4h,00ah,003h,00bh,012h,00bh,022h,00bh,034h,00bh,046h,00bh
      db    0adh,00ch,0b7h,00ch,0c2h,00ch,0cdh,00ch,0d9h,00ch,0e6h,00ch
      db    0f4h,00ch,003h,00dh,012h,00dh,022h,00dh,034h,00dh,046h,00dh
      db    0adh,00eh,0b7h,00eh,0c2h,00eh,0cdh,00eh,0d9h,00eh,0e6h,00eh
      db    0f4h,00eh,003h,00fh,012h,00fh,022h,00fh,034h,00fh,046h,00fh
;_FM_drumfreqtable:
;	dw	$4000
;	dw	$4002
;	dw	$4004
;	dw	$4006
;	dw	$4008
;	dw	$400a
;	dw	$400c
;	dw	$400e
;	dw	$0006
;	dw	$2006
;	dw	$4006
;	dw	$6006
;	dw	$8006
;	dw	$a006
;	dw	$c006
;	dw	$e006

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
	
_WAVESSCC			
_FM_drumfreqtable:	ds	32	; the drum frequency values
_FM_drumfreqedit:		ds	32 	; the values use din the drumfreq editor		

_rest_WAVESCC:		ds	32*30	
	