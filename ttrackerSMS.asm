; Trilo-Tracker v0.2
define VERSION "v0.11.0b SMS"
define YEAR "2021"
define CHIPSET_CODE $30

DEFINE TTSMS 

enaslt:          equ #0024


	defpage	0,0x0100, 0x3f00	; page 0 contains main code + far call routines
	defpage 	1,0x4000, 0x8000	; page 1 contains code (last 5kb should be empty)
;	defpage	2,0x8000, 0x4000	; NPC/titlescreen/gameinit code/swap code blocks


	; --- PAGE 0
	;
	; Global code (will never be swapped)
	;
	;
	; --------------------------------------------------
	page 0
	org	0x0100
MAIN:
	; initialisation
	call	reset_hook
	call	get_drives
	call	init_workdir
	
	;--- load the voicenames into VRAM
	;    from a seperate TTFM.DAT file
	call	load_voicenames
	
	
	call	start_init		; this calls function that is overwritten after call
					; the space can be used by the songs 

	;-- Find and enable if any MMM is inserted. 
	ld	b,16
	ld	h,0x40
	call mmm_srch	; This routine will find and activate SN if found
	call	MSXMusic_Detect

	; new that we have the memory reserved. Switch to slot of song data
	ld	a,(mapper_slot)			; get mapper slot
	ld	h,0x80
	call enaslt	
	
	call	set_songpage
	;-- now copy the voices data to songpage:
	ld	hl,_VOICES_data
	ld	de,_VOICES
	ld	bc,MAX_WAVEFORM*8
	ldir
	
	xor	a
	call	swap_loadblock	
	
	
	
	call	init_hook

	xor	a
	call	new_song
	call	set_songpage

	call	cursorstack_init


;	call	MSXMusic_Detect
;	jp	c,99f
;	ld	a,WIN_NOSCC
;	call	window	
;99:

;	cp	$ff
;	jp	nz,99f
;	ld	a,WIN_NOSCC
;	call	window	
;99:


;	ld	a,WIN_CFGSAV
;	call	window
	
	;--- should we load default instruments?
	ld	a,(_CONFIG_INS)
	and	a
	call	nz,load_instruments
	
	ld	a,10
	ld	(editmode),a
	call	init_patterneditor

	; --- main loop
	;call	set_hook
	
	include	".\code\main.asm"	
	include	".\code\configurationRAM.asm"

	
	
END:
;	jp	_TERM0
	
	include	".\code\elements\patternbox.asm"
_LABEL_PATTERNHEADER:
	;db	32,129,171,172,175,129			; envelope column
	db	32,32,32
	db	136,160,161,164,185,188,189,186,187	; psg2
	db	136,160,161,165,185,188,189,186,187	; psg3
	db	137,170,171,164,185,188,189,186,187	; scc1	
	db	136,170,171,165,185,188,189,186,187	; scc2
	db	136,170,171,166,185,188,189,186,187	; scc3	
	db	136,170,171,167,185,188,189,186,187	; scc4	
	db	136,170,171,168,185,188,189,186,187	; scc5
	db	136,170,171,169,185,188,189,186,187	; scc6
	db	136,151,152,153,154,0	
_LABEL_PATTERNHEADER2:
	;db	32,129,171,172,175,129			; envelope column
	db	32,32,32
	db	136,160,161,164,185,188,189,186,187	; psg1
	db	136,160,161,165,185,188,189,186,187	; psg2
	db	136,160,161,166,185,188,189,186,187	; psg3
	db	137,170,171,165,185,188,189,186,187	; scc1	
	db	136,170,171,166,185,188,189,186,187	; scc2
	db	136,170,171,167,185,188,189,186,187	; scc3	
	db	136,170,171,168,185,188,189,186,187	; scc4	
	db	136,170,171,169,185,188,189,186,187	; scc5
	db	136,151,152,153,154,0
	include	".\code\elements\trackbox.asm"
	include	".\code\elements\sequencebox.asm"
	include	".\code\elements\songbox.asm"	
	include 	".\code\elements\patterneditor.asm"
	include 	".\code\elements\filedialogRAM.asm"
;	include 	".\code\elements\macroeditor.asm"
;	include 	".\code\elements\macroboxFM.asm"
	include    ".\code\elements\voicemanager.asm"
      include 	".\code\elements\FMvoicebox.asm"
	include 	".\code\elements\voicemanagerRAM.asm"
	include 	".\code\elements\keyjazz.asm"
	include	".\code\elements\instrumentbox.asm"
	include	".\code\elements\vuFM.asm"
	include 	".\code\loadinstruments.asm"
	include 	".\code\cursor.asm"
	include    ".\code\elements\filedialog.asm"
	
SWAP_ELEMENTSTART:		
	; temporary start up code and data!!! Will be over written after init
	include	".\code\sound\mmmdetect.asm"
	include	".\code\sound\fmdetect.asm"
	
font_data:
	incbin  ".\data\fontpat.bin"
	include ".\code\startup.asm"
	include ".\code\loadvoicenamesFM.asm"
	include ".\code\elements\keynotetable.asm"







	; --- PAGE 1
	;
	; Main code (can be swapped)
	;
	;
	; --------------------------------------------------
	page 1

	include 	".\code\vdp.asm"
	include 	".\code\screen.asm"	
	include 	".\code\clipboard.asm"
	include 	".\code\song.asm"		
	include 	".\code\keyboard.asm"
	include	".\code\musickeyboard.asm"	
	include 	".\code\isr.asm"	; This cannot be before this address!!!!
	include 	".\code\mapper.asm"	
	include 	".\code\disk.asm"
;	include 	".\code\import\import.asm"	
	include 	".\code\compression2.asm"
	include 	".\code\editlog.asm"
	include	".\code\vram_swapper.asm"
	include 	".\code\window.asm"
	include 	".\code\replayerFMRAM.asm"	

	
	
	; --- PAGE 2
	;
	; Data page  (music data)
	;
	;
	; --------------------------------------------------	
;	page 2

_VOICES_data:
	include ".\code\Voices_Light.asm"			

;	include ".\code\startup.asm"
;	include ".\code\loadvoicenamesFM.asm"
;	include ".\code\elements\keynotetable.asm"

SWAP_INIT_START:
	org	SWAP_RAMSTART
	; Replayer swappable code block
	; --------------------------------------------------
SWAP_REPLAY:
	include ".\code\replayerFM.asm" ;replayer.asm"
SWAP_REPLAY_END:	
	
	; MBM import swappable code block
	; --------------------------------------------------
	org	SWAP_RAMSTART
SWAP_SAMPLE:
;	include ".\code\import\importMBM.asm"
SWAP_SAMPLE_END:		

	; XM importer swappable code block
	; --------------------------------------------------
	org	SWAP_RAMSTART
SWAP_SAMFILE:	


SWAP_SAMFILE_END:	
	

	; XM importer swappable code block
	; --------------------------------------------------
	org	SWAP_RAMSTART
SWAP_CONFIG:

	include	".\code\elements\configeditor.asm"
	include	".\code\elements\configbox.asm"
SWAP_CONFIG_END:


	; Macro editor swappable code block
	; --------------------------------------------------
	org	SWAP_ELEMENTSTART
SWAP_MACRO:
	include 	".\code\elements\macroeditor.asm"
	include 	".\code\elements\macroboxFM.asm"

SWAP_MACRO_END:

	; Instrument file dialog swappable code block
	; --------------------------------------------------
	org	SWAP_RAMSTART
SWAP_INSFILE:

	include	".\code\elements\fileinsdialog.asm"
SWAP_INSFILE_END:

     ; Song file dialog swappable code block
     ; --------------------------------------------------
     org    SWAP_ELEMENTSTART
SWAP_FILE:
 
  ;   include    ".\code\elements\filedialog.asm"
SWAP_FILE_END:
 
     ; Voice manager swappable code block
     ; --------------------------------------------------
     org    SWAP_ELEMENTSTART
SWAP_VOICEMAN:

SWAP_VOICEMAN_END:

     ; Voice manager swappable code block
     ; --------------------------------------------------
     org    SWAP_ELEMENTSTART
SWAP_DRUM:
	include	".\code\elements\drumeditor.asm"
	include	".\code\elements\drumeditbox.asm"	
SWAP_DRUM_END:

		
	include ".\code\variablesFM.asm"	

