MIN_SONG_SEGSIZE	equ 6					; minimal segment size of a song.
MAX_SONG_SEGSIZE	equ 32				; maximun segment size of a song
SONG_PATLNSIZE	equ (4*8);(5*8)+2			; size of a pattern line
SONG_PATSIZE	equ ((SONG_PATLNSIZE)*64)	; patternsize in RAM
SONG_PATINSEG	equ (16*1024)/SONG_PATSIZE	; the number of patterns in a segment
SONG_PATINSONG	equ (10*1024)/SONG_PATSIZE	; The number of total pattern pages not usable as it contains song data. 
;SONG_MAXPAT	equ (SONG_PATINSEG*(SONG_SEGSIZE-2))+SONG_PATINSONG; Max number of pattterns in memory
SONG_SEQSIZE	equ 200;128				; size of the order list
INSTRUMENT_LEN	equ 32				; max lines of data for macro
INSTRUMENT_SIZE	equ (INSTRUMENT_LEN*4)+3	; size of 1 instrument macro
MAX_WAVEFORM	equ 192+1;-16			; max number of voice.
MAX_DRUMS		equ 20				; max number of drum macros
DRUMMACRO_SIZE	equ (7*16)+1			; size 1 drum macro.

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
PATTERN_WIN		equ 0			; pattern edit window

_base equ	16			; to move the FM part.

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
song_cur_drum		#1
song_instrument_offset	#1
song_empty_string		#16
song_instrument_list	#16*31
instrument_offset		#1	; for use in menu.
drum_macro_offset		#0
instrument_macro_offset	#1	; for use in macro		
drum_len			#0
instrument_len		#1	
instrument_waveform	#1

instrument_loop		#1
instrument_macros		#(INSTRUMENT_SIZE)*32
;psg_sample_line:	
drum_line			#0
instrument_line		#1

waveform_datasize	#1	;# of waveforms (16,32,48 or 64 waveforms)

; 2nd part contains MOAM waveforms

cpu_type:			#1


; --- edit modes
editmode:		#1	; 0=pattern,1=psg samp,2= ornaments, 3=scc samples, 4=scc waves, 5=file load, 6=file save
editsubmode:	#1	; specific areas in the edit modes.
_pkv_mod_total_COL	#1

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


_VOICES:		#8*MAX_WAVEFORM
drum_macros:	#DRUMMACRO_SIZE*MAX_DRUMS
song_drum_list:	#MAX_DRUMS*16	
_SONGDATA_END:	#0
; DONT PLACE DATA BEYOND THIS ALL fREE SPACE ISFOR cursor stack




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

;org_stack:	#2	; used to recover from an error.



;CHIP_Chan1:			#CHIP_REC_SIZE
;CHIP_Chan2:			#CHIP_REC_SIZE
;CHIP_Chan3:			#CHIP_REC_SIZE
;CHIP_Chan4:			#CHIP_REC_SIZE
;CHIP_Chan5:			#CHIP_REC_SIZE
;CHIP_Chan6:			#CHIP_REC_SIZE
;CHIP_Chan7:			#CHIP_REC_SIZE
;CHIP_Chan8:			#CHIP_REC_SIZE

_KEYJAZZ_LINE:	#4	;db	0,0,0,0
_KJ_PSG:		#4	;db	0,0,0,0
_KJ_PSG2:		#4	;db	0,0,0,0
_KJ_SCC:		#2	;db	0,0
_KJ_DRM1:		#4	;db	0,0
				;db	0,0
_KJ_DRM2:		#14	;db	0,0
				;db	0,0,0,0
				;db	0,0,0,0
				;db	0,0,0,0


FM_Registers: 	#0	; contains the registers values to write and value previously written
FM_regToneA 	#2	; Tone A freq low (8bit)			; Tone A freq high (1bit)
FM_regToneAb 	#2	; Tone A freq low (8bit)			; Tone A freq high (1bit)
FM_regVOLA		#1	; Chan A volume
FM_regVOLAb		#1	; Chan A volume
FM_regToneB 	#2	; Tone B freq low					; Tone B freq high
FM_regToneBb 	#2	; Tone B freq low					; Tone B freq high
FM_regVOLB		#1	; Chan B volume
FM_regVOLBb		#1	; Chan B volume
FM_regToneC 	#2	; Tone C freq low					; Tone C freq high
FM_regToneCb 	#2	; Tone C freq low					; Tone C freq high
FM_regVOLC	 	#1	; Chan C volume
FM_regVOLCb	 	#1	; Chan C volume
FM_regToneD 	#2	; Tone D freq low					; Tone D freq high
FM_regToneDb 	#2	; Tone D freq low					; Tone D freq high
FM_regVOLD		#1	; Chan D volume
FM_regVOLDb		#1	; Chan D volume
FM_regToneE 	#2	; Tone E freq low					; Tone E freq high
FM_regToneEb 	#2	; Tone E freq low					; Tone E freq high
FM_regVOLE	  	#1	; Chan E volume
FM_regVOLEb	  	#1	; Chan E volume
FM_regToneF 	#2	; Tone E freq low					; Tone F freq high
FM_regToneFb 	#2	; Tone E freq low					; Tone F freq high
FM_regVOLF	  	#1	; Chan F volume
FM_regVOLFb	  	#1	; Chan F volume

DRUM_regToneBD	#2
DRUM_regToneBDb	#2
DRUM_regVolBD	#1
DRUM_regVolBDb	#1
DRUM_regToneSH	#2
DRUM_regToneSHb	#2
DRUM_regVolSH	#1
DRUM_regVolSHb	#1
DRUM_regToneCT	#2
DRUM_regToneCTb	#2
DRUM_regVolCT	#1
DRUM_regVolCTb	#1
FM_DRUM		#1	; Percussion bits



MainMixer:				#1
DrumMixer:				#1
mainPSGvol:				#1
mainSCCvol:				#1
_REPLAY_START:			#0
;---------- REPLAYER VARS
_SP_Storage				#2			; to store the SP

replay_key				#1			; key to test for stopping sound
replay_line				#1			; local playing line to sync visual playback
replay_speed 			#1 ;2			; speed to replay (get from song)
replay_speed_subtimer 		#1			; counter for finer speed
replay_speed_timer 		#1 			; counter for speed
replay_mode: 			#1			; Replayer status
; mode 0  = no sound output
; mode 1  = replay song 
; mode 2  = instrument key jazz
; mode 4  = pattern keyjazz
; mode 5  = replay song step based  
replay_chan_setup			#1			; 0 = 2 psg+ 6 fm, 1 = 3psg + 5 fm
replay_arp_speed			#1			; counter for arp speed

replay_patpointer 		#2			; pointer to the data
replay_patpage 			#1 			; the current page
replay_previous_note		#1			; previousnote played
replay_mainvol			#1			; the volume correction.



; key pressed
keyboardtype	#1
fkey:			#1
skey:			#1
keyjazz:		#1
keyjazz_chip:	#1

;-- Music module keyboard
music_key			#1
music_buf_key		#1
music_buf_key_old		#1
music_key_on		#1


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
copy_transparent:		#1

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

_VU_UPDATE:		#1
_VU_VALUES:		#8	;"xxxxxxxx"
_VU_LABEL:		#8	;"xxxxxxxx"




; general buffer
drum_select_status
instrument_select_status:	#1
waveform_select_status:		#1
instrument_buffer:		#(INSTRUMENT_SIZE)
waveform_buffer:			#32
pat_buffer:				#SONG_PATSIZE+2	 ; full uncompressed pattern	
drum_buffer:
buffer:				#2048+64
THE_END:	#0