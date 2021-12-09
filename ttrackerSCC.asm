; Trilo-Tracker v0.2
define VERSION "v0.11.4b SCC"
define YEAR "2021"
define CHIPSET_CODE $00

DEFINE TTSCC
 
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
	call	start_init		; this calls function that is overwritten after call
					; the space can be used by the songs 

	; locate available SCC
	ld	a,1
	ld	(scc_type_check),a
	call	find_SCC		;find SCC+

	cp	255
	jr.	nz,99f
	
	xor	a
	ld	(scc_type_check),a
	call	find_SCC		; find SCC
99:	

	;--- init correct period tabel from config
	ld	a,(_CONFIG_PERIOD)
	ld	(replay_period),a
	call	set_period_table



	; new that we have the memory reserved. Switch to slot of song data
	ld	a,(mapper_slot)			; get mapper slot
	ld	h,0x80
	call enaslt	
	
	
	call	init_hook
	xor	a
	call	swap_loadblock		


	xor	a
	call	new_song
	call	set_songpage

	call	cursorstack_init

	ld	a,(SCC_slot_found)
	inc	a
	jp	nz,99f
	ld	a,WIN_NOSCC
	call	window
	
	
	
99:

	;--- should we load default instruments?
	ld	a,(_CONFIG_INS)
	and	a
	call	nz,load_instruments


	ld	a,10
	ld	(editmode),a
	call	init_patterneditor

	;--- Set the SCC slot according to config
	ld	a,(_CONFIG_SLOT)
	cp	255				; check if config is set to auto
	jp	nz,99f
	ld	a,(SCC_slot_found)

99:
	ld	(SCC_slot),a	
	
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
	db	136,160,161,164,185,188,189,186,187	; psg1
	db	136,160,161,165,185,188,189,186,187	; psg2
	db	136,160,161,166,185,188,189,186,187	; psg3
	db	137,162,163,164,185,188,189,186,187	; scc1	
	db	136,162,163,165,185,188,189,186,187	; scc2
	db	136,162,163,166,185,188,189,186,187	; scc3	
	db	136,162,163,167,185,188,189,186,187	; scc4	
	db	136,162,163,168,185,188,189,186,187	; scc5
	db	136,32,32,32,0
;	include	".\code\elements\trackbox.asm"
	include	".\code\elements\trackboxRAM.asm"
	include	".\code\elements\sequencebox.asm"
	include	".\code\elements\songbox.asm"	
	include 	".\code\elements\patterneditor.asm"
	include 	".\code\elements\filedialogRAM.asm"
	include 	".\code\elements\sccwavebox.asm"
	include 	".\code\sound\sccdetect.asm"
	include 	".\code\elements\keyjazz.asm"
	include	".\code\elements\instrumentbox.asm"
	include	".\code\elements\vu.asm"
	include 	".\code\loadinstruments.asm"		
	include 	".\code\editlog.asm"
	include    ".\code\elements\filedialog.asm"
SWAP_ELEMENTSTART:
font_data:
	incbin 	".\data\fontpatSCC.bin"
	include	".\code\startup.asm"
	include	".\code\elements\keynotetable.asm"

			
	; --- PAGE 1
	;
	; Main code (can be swapped)
	;
	;
	; --------------------------------------------------
	page 1
	include 	".\code\cursor.asm"
	include 	".\code\vdp.asm"
	include 	".\code\screen.asm"
	include 	".\code\register_debug.asm"	
	include 	".\code\clipboard.asm"
	include 	".\code\song.asm"		
	include	".\code\volumetable.asm"
	include 	".\code\keyboard.asm"	
	include	".\code\musickeyboard.asm"
	include 	".\code\isr.asm"	; This cannot be before this address!!!!
;	include ".\code\replayerFM.asm"
;	include ".\code\sound\AY.asm"	;AY3-8910.asm"
;	include ".\code\sound\SCC.asm"
	include 	".\code\mapper.asm"
;	include	".\code\slotselect.asm"	
	include	".\code\disk.asm"


;	include 	".\code\import\import.asm"	
	include 	".\code\compression2.asm"

	include	".\code\vram_swapper.asm"
	include	".\code\replayerSCCRAM.asm"	
	include 	".\code\window.asm"
;	include 	".\code\configuration.asm"


	; --- PAGE 2
	;
	; Data page  (music data)
	;
	;
	; --------------------------------------------------	
;	page 2
	; temporary start up code and data!!! Will be over written after init
	



SWAP_INIT_START:
	org	SWAP_RAMSTART
	; Replayer swappable code block
	; --------------------------------------------------
SWAP_REPLAY:
	include ".\code\replayerSCC.asm" ;replayer.asm"
SWAP_REPLAY_END:	
	
	; Sample editor
	; --------------------------------------------------
	org	SWAP_ELEMENTSTART
SWAP_SAMPLE:
	include ".\code\elements\sampleeditor.asm"
	include ".\code\elements\samplebox.asm"
SWAP_SAMPLE_END:		

	; XM importer swappable code block
	; --------------------------------------------------
	org	SWAP_RAMSTART
SWAP_SAMFILE:	
	include	".\code\elements\filesamdialog.asm"
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
	include 	".\code\elements\macrobox.asm"
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
SWAP_TRACK:
SWAP_FILE:
	db	"trackbox swap"
	include	".\code\elements\trackbox.asm"
SWAP_TRACK_END:
SWAP_FILE_END:
 
 	db	"End of swap data"
SWAP_INIT_END:
	
	
	
	include ".\code\variablesSCC.asm"

