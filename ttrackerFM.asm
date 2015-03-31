; Trilo-Tracker v0.2
define VERSION "v0.8.0 MSX-Music   "
define YEAR "2014"
define CHIPSET_CODE $10

DEFINE TTFM 

enaslt:          equ #0024


	defpage	0,0x0100, 0x3f00	; page 0 contains main code + far call routines
	defpage 	1,0x4000, 0x4000	; page 1 contains code (last 5kb should be empty)
	defpage	2,0x8000, 0x4000	; NPC/titlescreen/gameinit code/swap code blocks


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

	ld	a,WIN_STARTUP
	call	window
	
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
	db	136,160,161,164,185,188,189,186,187	; psg1
	db	136,160,161,165,185,188,189,186,187	; psg2

	db	137,170,171,164,185,188,189,186,187	; scc1	
	db	136,170,171,165,185,188,189,186,187	; scc2
	db	136,170,171,166,185,188,189,186,187	; scc3	
	db	136,170,171,167,185,188,189,186,187	; scc4	
	db	136,170,171,168,185,188,189,186,187	; scc5
	db	136,170,171,169,185,188,189,186,187	; psg3
	db	136,32,32,32,0
	
	include	".\code\elements\trackboxFM.asm"
	include	".\code\elements\sequencebox.asm"
	include	".\code\elements\songbox.asm"	
	include 	".\code\elements\patterneditor.asm"
	include 	".\code\elements\filedialog.asm"
	include 	".\code\elements\psgsampleeditor.asm"
	include 	".\code\elements\psgsampleboxFM.asm"
	include 	".\code\elements\sccwaveboxFM.asm"
	include 	".\code\elements\voicemanager.asm"
	include 	".\code\elements\keyjazzFM.asm"
	include	".\code\elements\instrumentbox.asm"
	include	".\code\elements\vuFM.asm"
	include 	".\code\loadinstruments.asm"	

			
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
	include 	".\code\clipboard.asm"
	include 	".\code\song.asm"		

	include 	".\code\keyboard.asm"	
	include 	".\code\isr.asm"	; This cannot be before this address!!!!
	include 	".\code\mapper.asm"	
	include 	".\code\disk.asm"
	include 	".\code\import\import.asm"	
	include 	".\code\compression2.asm"
	include 	".\code\editlog.asm"
	include	".\code\vram_swapper.asm"
	include 	".\code\window.asm"
	include 	".\code\replayerFMRAM.asm"	

_VOICES_data:
	include ".\code\Voices_Light.asm"

	
	; --- PAGE 2
	;
	; Data page  (music data)
	;
	;
	; --------------------------------------------------	
	page 2
	; temporary start up code and data!!! Will be over written after init
	
	include ".\code\startup.asm"
	include ".\code\loadvoicenamesFM.asm"
	include ".\code\elements\keynotetable.asm"

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
SWAP_MBM_IMP:
	include ".\code\import\importMBM.asm"
SWAP_MBM_IMP_END:		

	; XM importer swappable code block
	; --------------------------------------------------
	org	SWAP_RAMSTART
SWAP_XM_IMP:	
;	include ".\code\import\importXM.asm"
_XM_WILDCARD:
	db	0
open_xmfile:
	ret


SWAP_XM_IMP_END:	
	

	; XM importer swappable code block
	; --------------------------------------------------
	org	SWAP_RAMSTART
SWAP_CONFIG:

	include	".\code\elements\configeditor.asm"
	include	".\code\elements\configbox.asm"
SWAP_CONFIG_END:


	; Track manager swappable code block
	; --------------------------------------------------
	org	SWAP_RAMSTART
SWAP_TRACK:

	include	".\code\elements\trackmanager.asm"
SWAP_TRACK_END:

	; Instrument file dialog swappable code block
	; --------------------------------------------------
	org	SWAP_RAMSTART
SWAP_INSFILE:

	include	".\code\elements\fileinsdialog.asm"
SWAP_INSFILE_END:



		
	include ".\code\variablesFM.asm"	


	


