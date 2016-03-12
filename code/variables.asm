
MIN_SONG_SEGSIZE	equ 6			; minimal segment size of a song.
MAX_SONG_SEGSIZE	equ 32		; maximum segment size of a song
SONG_PATLNSIZE	equ (4*8);(5*8)+2		; size of a pattern line
SONG_PATSIZE	equ ((SONG_PATLNSIZE)*64);+1	; patternsize in RAM
SONG_PATINSEG	equ (16*1024)/SONG_PATSIZE; the number of patterns in a segment
SONG_PATINSONG	equ (10*1024)/SONG_PATSIZE; number of pats that fit IN song data
;SONG_MAXPAT		equ (SONG_PATINSEG*(SONG_SEGSIZE-2))+SONG_PATINSONG; Max number of pattterns in memory
SONG_SEQSIZE	equ 200;128			; size of the order list
INSTRUMENT_LEN	equ 32		; max lines of data for macro
INSTRUMENT_SIZE	equ (INSTRUMENT_LEN*4)+3		; size of 1 instrument macro
MAX_WAVEFORM	equ	32


DOS			equ 5			; DOS function call entrance
HOKVLD		equ 0xFB20		; External BIOS hook valid
EXTBIO		equ 0xFFCA		; External BIOS hook.
_TERM0		equ 0x00		; Jump adres to quit and return to DOS
_STROUT		equ 0x09		; String Output
_DIRIO		equ 0x06		; get pressed key
_CURDRV		equ 0x19		; get current drive
_GETCD		equ 0x59		; get current directory
_FFIRST		equ 0x40		; find first entry
_FNEXT		equ 0x41		; find next entry
_OPEN			equ 0x43		; open a file handle
_READ			equ 0x48		; read x bytes from file 
_WRITE		equ 0x49		; write x bytes to file
_CLOSE		equ 0x45		; close the file
_LOGIN		equ 0x18		; get the available drives
_CHDIR		equ 0x5a		; change the directory
_SELDSK		equ 0x0e		; set the diskdrive
_DELETE		equ 0x4d		; delete a file
_RENAME		equ 0x4e		; rename a file
_CREATE		equ 0x44		; create a file handle
_EXPLAIN		equ 0x66		; get explaination string for error 
_ASSIGN		equ 0x6a		; get/set LOGICAL DRIVE ASSIGNMENT
_DEFER		equ 0x64		; set the error handler.
_DEFAB		equ 0x63		; set the abort handler.
_FLUSH		equ 0x5f		; flush buffers

PATTERN_WIN	equ 0			; pattern edit window

_PNT		equ	0x2000		; pnt
_CNT		equ	0x2a00		; cnt


	; --- Song Variables
	;
	;
	map 0x8000
	
; --- global track info
song_name				#32
song_by				#32
song_version			#1
song_order_loop			#1
song_order_len			#1
song_order				#SONG_SEQSIZE
song_order_pos_old		#1
song_order_pos			#1
song_order_offset			#1
song_order_update			#1
	
;-- track
song_pattern		#1
song_pattern_offset	#1		; offset to draw
song_pattern_line		#1		; line to edit

; track column ????
song_octave			#1
song_step			#1
song_add			#1
;song_inc_mode:		#1
song_speed			#1

;Instrument/Macro:	
song_active_instrument	#1	; -> 	instrument in instrument selection
					;	and is added to the note
song_cur_instrument	#1
song_instrument_offset	#1
song_empty_string		#16
song_instrument_list	#16*31
instrument_offset		#1	; for use in menu.
instrument_macro_offset	#1	; for use in macro		
instrument_len		#1	
instrument_waveform	#1
instrument_loop		#1
instrument_macros		#(INSTRUMENT_SIZE)*32
;psg_sample_line:	
instrument_line:		#1

waveform_datasize:	#1	;# of waveforms (16,32,48 or 64 waveforms)

; 2nd part contains MOAM waveforms


; --- edit modes
editmode:		#1	; 0=pattern,1=psg samp,2= ornaments, 3=scc samples, 4=scc waves, 5=file load, 6=file save
editsubmode:	#1	; specific areas in the edit modes.

;--- cursor
cursor_type:	#1	; large or small cursor
cursor_input:	#1	; type of input
cursor_column:	#1	; column# we are in (to caclulate the data adress to write. en next pos

cursor_y:	#1
cursor_x:	#1
cursor_buffer:	#3

cursor_sp:	#2
cursor_stack:	#4*6	; room for 6 stacks?


;tmp_cursor_type:	#1	; large or small cursor
;tmp_cursor_input:	#1	; type of input
;tmp_cursor_column:	#1	; column# we are in (to caclulate the data adress to write. en next pos

;tmp_cursor_y:	#1
;tmp_cursor_x:	#1
;tmp_editsubmode:	#1

; DONT PLACE DATA BEYOND THIS ALL fREE SPACE ISFOR cursor stack

_SONGDATA_END:	#0





	; --- Global Variables
	;
	;
	map 0xc000
	
; MSX-DOS2 memory mapper function jump table	
ALL_SEG:		#3
FRE_SEG:		#3
RD_SEG:		#3
WR_SEG:		#3
CAL_SEG:		#3
CALLS:		#3
PUT_PH:		#3
GET_PH:		#3
PUT_P0:		#3
GET_P0:		#3
PUT_P1:		#3
GET_P1:		#3
PUT_P2:		#3
GET_P2:		#3
PUT_P3:		#3

org_page:		#1
prim_slot:		#1
mapper_slot		#1
SCC_slot:		#1	;scc slot

vsf:		#1	; vdp type for correct playback on 60hz
cnt:		#1	; tic timer for correct playback on 60hz
equalization_flag:	#1	; flag indicating if only instruments need to be processed.

MainMixer:				#1
mainPSGvol:				#1
mainSCCvol:				#1
_REPLAY_START:			#0
;---------- REPLAYER VARS
;replay_key				#1			; key	to test for	stopping sound
;replay_line				#1			; local playing line to	sync visual	playback
;replay_speed			#1			; speed to replay	(get from song)
;replay_speed_subtimer		#1			; counter for finer speed
;replay_speed_timer		#1			; counter for speed
;replay_mode				#1			; Replayer status
;; mode 0  =	no sound output
;; mode 1  =	replay song	

;replay_patpointer			#2			; pointer to the data
;replay_patpage			#1			; the	current page
;replay_previous_note		#1			; previousnote played
;replay_mainvol			#1			; the	volume correction.

;replay_vib_table:			#2			; pointer to the vibrato table

;CHIP_Chan1				#CHIP_REC_SIZE
;CHIP_Chan2				#CHIP_REC_SIZE
;CHIP_Chan3				#CHIP_REC_SIZE
;CHIP_Chan4				#CHIP_REC_SIZE
;CHIP_Chan5				#CHIP_REC_SIZE
;CHIP_Chan6				#CHIP_REC_SIZE
;CHIP_Chan7				#CHIP_REC_SIZE
;CHIP_Chan8				#CHIP_REC_SIZE
;--- AY SPECIFIC
;AY_registers: 		#0
;AY_regToneA:		#2	; Tone A freq low	(8bit)
					; Tone A freq high (4bit)
;AY_regToneB:		#2	; Tone B freq low
					; Tone B freq high
;AY_regToneC:		#2	; Tone C freq low
					; Tone C freq high
;AY_regNOISE:		#1	; Noise freq (5bit)
;AY_regMIXER:		#1	;x3f	; Mixer control (1 = off, 0 =	on)
;AY_regVOLA:		#1	; Chan A volume
;AY_regVOLB:		#1	; Chan B volume
;AY_regVOLC:		#1	; Chan C volume
;AY_regEnv:		#1	; Volume Env Freq	low (8bit)	
;AY_regC:		#1	; Volume Env Freq	high (4bit)
;AY_regENVSHAPE:	#1	; Volume Env Shape (4bit)
;--- SCC SPECIFIC
;SCC_registers 
;SCC_regToneA	#2	; Tone A freq low	(8bit)
					; Tone A freq high (4bit)
;SCC_regToneB	#2	; Tone B freq low
					; Tone B freq high
;SCC_regToneC	#2	; Tone C freq low
					; Tone C freq high
;SCC_regToneD	#2	; Tone D freq low
					; Tone D freq high
;SCC_regToneE	#2	; Tone E freq low
					; Tone E freq high
;SCC_regVOLA		#1	; Chan A volume
;SCC_regVOLB		#1	; Chan B volume
;SCC_regVOLC		#1	; Chan C volume
;SCC_regVOLD		#1	; Chan D volume
;SCC_regVOLE		#1	; Chan E volume
;SCC_regMIXER	#1	; x3f	; Mixer control (1 = off, 0 =	on)

;AY_VOLUME_TABLE:	#256
;SCC_VOLUME_TABLE:	#256
;
;CHIP_ToneTable:		#CHIP_ToneTable_END-CHIP_ToneTable_START
;CHIP_Vibrato_sine:	#CHIP_Vibrato_sine_END-CHIP_Vibrato_sine_START
;CHIP_Vibrato_triangle:	#CHIP_Vibrato_triangle_END-CHIP_Vibrato_triangle_START
;CHIP_Vibrato_pulse:	#CHIP_Vibrato_pulse_END-CHIP_Vibrato_pulse_START
;
;_REPLAY_END:	#0



; key pressed
keyboardtype	#1
fkey:			#1
skey:			#1
keyjazz:		#1
keyjazz_chip:	#1

; clipboard variables:
clipb_status:		#1	; 0 = nothing here,1= copy, 2=cut
clipb_column_start:	#1	; first column input type to copy
clipb_column_end:		#1	; ending input type
clipb_bytes:		#1	; screen char columns of selection
clipb_rows:			#1
;clipb_start:		#1	; start of the channel

clipb_src_address:	#2	; source address
clipb_dst_address:	#2	; destination address
clipb_clr_address:	#2	; address used for erasing selection
clipb_tmp_address:	#2	; address used for stransponation
clipb_tmp_bytes:		#2	; used for transponation
clipb_tmp_rows:		#2	; "


; selection variables
selection_y1:		#1
selection_x1:		#1
selection_type1:		#1
selection_column1:	#1
selection_y2:		#1
selection_x2:		#1
selection_type2:		#1
selection_column2:	#1
selection_status:		#1

tmp_cur_instrument:	#1		; local copy of the current instrument.
						; be sure to copy this when switching songs.






; menu vars
menu_selection:	#1		; to keep track of the selection cursor
file_selection:	#1	


;current_song:	#1
;current_screen:	#1
;current_pnt:	#2
;current_cnt:	#2
current_mode:	#1
current_submode:	#1


;max_songs:		#1		; Number of possible simultanious songs in RAM
undo_page:		#1		; page for the undo
max_pattern:	#1		; Numer of patterns available
song_list:		#MAX_SONG_SEGSIZE	; All segments in list for song x
;song2_list:		#SONG_SEGSIZE
;song3_list:		#SONG_SEGSIZE
;song4_list:		#SONG_SEGSIZE

;scc_waves:		#32*16		; waves are stored in RAM

; --- Mouse vars
;mousey:		#1
;mousex:		#1
;mouse_pntoffset:	#2		; cnt offset written to
;mouse_oldpnt:	#1		; contains the original cnt value

; --- Colorbox function variables
cb_maskleft:	#1
cb_maskright:	#1
cb_fullbytes:	#1
cb_status:		#1

cursor_timer:	#1	; for blinking.


; --- Vars for track manager
tm_src_start:	#1	; start pattern of selection
tm_src_end:		#1
tm_src_chan:	#1	; source channel
tm_dst_start:	#1
tm_dst_end:		#1
tm_dst_chan:	#1	; dest channel
tm_pattern:		#1	; current pattern in window
tm_status:		#1	; status to keep track actions

; ----- Note display
_LABEL_NOTES:	#_LABEL_NOTES_END - _LABEL_NOTES_START
; ----- Key to note mapping 
_KEY_NOTE_TABLE:	#_KEY_NOTE_TABLE_END - _KEY_NOTE_TABLE_START



; general buffer
instrument_select_status:	#1
waveform_select_status:		#1
instrument_buffer:		#(INSTRUMENT_SIZE)
waveform_buffer:			#32
pat_buffer:				#SONG_PATSIZE+2	 ; full uncompressed pattern	
buffer:				#2048+64




THE_END:	#0