	; --- start_init
	;
	; Initialisation of the program.
	; Checks are done and this part may be overwritten after init.
start_init:
	di
	call	check_extendedBIOS	; exteded BIOS is needed

	ld	a,($FFE8)	; get mirror of VDP reg# 9
	and	2
	jp	z,99f
	ld	a,-1
99:
	inc	a	
	ld	(_FOUND_VDP),a		;1=60hz

	call	init_mapper		; check and init mapper RAM space	

	call	init_vdp		; set the vdp registers (mouse/colors/width80)
	call	init_font		; set the new font

;	call	setpalette		; loads the custom palette colors.


;	xor	a
;	ld	(current_song),a

	;--- init the window pnt's
;	call	set_vdpwindow
	call	clear_screen


	;--- copy window messages to VRAM
	; do this before initing SONG variables as the code to be loaded to VRAM is a tsame RAM address.
	ld	de,SWAP_WIN_VRAMSTART
	ld	hl,SWAP_WIN_START
	ld	bc,SWAP_WIN_END-SWAP_WIN_START
	call	swap_loadvram 


	;--- copy swapcode to VRAM
	; do this before initing SONG variables as the code to be loaded to VRAM is a tsame RAM address.
	;-- REPLAYER and imports code
	ld	de,SWAP_VRAMSTART
	ld	hl,SWAP_INIT_START
	ld    bc,0+(SWAP_FILE_END-SWAP_INIT_START)
	call	swap_loadvram

	
	ld	a,0
	ld	(cursor_y),a
;	ld	a,0
	ld	(cursor_x),a
;	ld	a,0
	ld	(cursor_type),a	
	ld	(keyjazz),a	
	ld	(mainPSGvol),a
	ld	(mainSCCvol),a
	ld	(instrument_select_status),a	
	ld	(waveform_select_status),a
	


	inc	a
	ld	(DrumMixer),a	; FM drums on	
	ld	a,11111111b	; all channels active.
	ld	(MainMixer),a

	ld	a,3
	ld	(keyjazz_chip),a	
		
	call	clear_clipboard	
	call	reset_selection	
	
;	xor	a
;	call	swap_loadblock

;	call	init_hook
	call	init_keyboard

;	ld	iy,(EXPTBL-1)       ;BIOS slot in iyh
 ;     ld	ix,$005F             ;address of BIOS routine
;	ld	a,0
 ;     call	CALSLT              ;interslot call	
;	jp	0



	ld	c,_DEFER
	ld	de,disk_error_handler
	call	DOS
	ld	c,_DEFAB
	ld	de,disk_abort_handler
	call	DOS	

	
;	ld	hl,insert_disk_handler
;	ld	a,0xc3
;	ld	(0xF24F),a
;	ld	(0xF250),hl	
	



	; -- now all prequisites are met

	;call 	init_isr
;	xor	a
;	call	window

	
	;--- load the note labels to RAM ($c000-$ffff)
	ld	de,_LABEL_NOTES
	ld	hl,_LABEL_NOTES_START
	ld	bc,_LABEL_NOTES_END-_LABEL_NOTES_START
	ldir

	;--- load the note to key translation to RAM ($c000-$ffff)
	ld	de,_KEY_NOTE_TABLE
	ld	hl,_KEY_NOTE_TABLE_START
	ld	bc,_KEY_NOTE_TABLE_END-_KEY_NOTE_TABLE_START
	ldir


config:


	;---- configuration loading
	call	init_config
	call	load_config
	call	set_vsf

	


	call	set_textcolor		; Adjust the colors to the current song.



	
	
	
	ret



	; --- check_extendedBIOS
	;
	; Checks if the extended BIOS hook is available.
	; returns to MSX-DOS when not found.
check_extendedBIOS:
	; check if there is an extended BIOS
	ld	a,(HOKVLD)
	and	1
	ret	nz
	
	ld	de,_NO_EXTBIO_S
	ld	c,_STROUT
	call	5
	ld	c,_TERM0
	jr.	5	

_NO_EXTBIO_S:
	db	"[ERROR]: No External bios found",13,10,"$"	








	; --- init_mapper
	;
	; Checks if the MSX-DOS mapper is available.
	; If available check the availble space, determine
	; the max # of simultanious songs in RAM. And
	; reserve the needed segments (build a segmentlist for each song)
init_mapper:	
	; add EXTBIO call met parameters A=0,DE=$0401
	; HL -> start addres van mapper vars.
	; HL+8 -> entries for other mapper slots. if 0 there are none.
	
	ld	de,$0401
	call	EXTBIO				; in HL the pointer to the mapper info.

	and	a
	jp	nz,99f
	ld 	de,_NO_DOS
	ld	c,_STROUT
	call	5
	jr. _TERM0
	
99:	ld	a,(hl)			; store primary slot.
	ld	(prim_slot),a

	;--- now see which mapper has most free segments.
	ld	b,(hl)		; B = slot 
	inc	hl
	inc	hl
	ld	c,(hl)		; C = free segments.
	
	ld	e,MAX_SONG_SEGSIZE
	
0:
	;--- check if primary is enough for max patterns.
	ld	a,c
	cp	e
	jp	nc,0f			; this mapper has max free segs.
	
	ld	e,MAX_SONG_SEGSIZE+1  ; if we are here the next check should include the undpo page.
4:	
	ld	a,8-2			; jump to next mapper entry
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:		
	ld	a,(hl)		; get slot addr
	and	a
	jp	z,0f			; if slot is 0 then there is no mapper
;	or	$82
	ld	d,a
	inc	hl
	inc	hl
	ld	a,(hl)		; get free segs
	cp	c			
	jp	c,4b			; if not loop
	jp	z,4b			; if equal loop
	
	ld	c,a			; store new free segs
	ld	a,d
	ld	b,a			; store new slot
	
	jp	4b
	

0:
	;--- check if there is minimal room.
	ld	a,c
	and	a
	jp	nz,0f

	ld de,_NOT_ENOUGH_FREE_S
	ld	c,_STROUT
	call	5
	jr. _TERM0

	
0:
	dec	a
	add	a
	add	a
	add	a
	sub	SONG_PATINSONG	; (4 patterns lost for song data)
	ld	(max_pattern),a

	;--- Store mapper for song data
	ld	a,b
	ld	(mapper_slot),a
	
99:
	push	bc

	;--- copy jump table to RAM for mapper access		
	xor	a
	ld	de,$0402
	call	EXTBIO			; in HL the pointer to the mapper info.
	
	ld	de,ALL_SEG
	ld	bc,15*3
	ldir
	
	;--- Store the orignal BANK 2 page 
	;    to prevent a DOS2 bug. As the original
	;    page is not restored on exit
	call	GET_P2
	ld	(org_page),a	
	
	
	
	
	
	;--- init the undo segment
	ld	a,(prim_slot)
	ld	b,a
	ld	a,(mapper_slot)
	cp	b
	jp	z,0f			; jump if mapper and primary mapper are the same.
	
	;----- If mapper is external then undo is in external mapper.
	ld	a,(mapper_slot)
	ld	b,a
	
	xor	a
	call	ALL_SEG
	jr.	33f
0:
	call	GET_P2
33:	ld	(undo_page),a	
	
	pop	bc			; B slot, C #segments
	dec	c
	call	_alloc_songRAM
	ret
	
	; subroutine fot allocating the RAM for a song	
_alloc_songRAM:	
	ld 	hl,song_list
0:	
	push	bc
	; init	ALL_SEG params

	; [b] contains slot
	xor	a
	call	ALL_SEG
	
	jr.	c,_ALLOCATION_ERROR
	
	ld	(hl),a		; store page
	inc	hl

	pop	bc
	dec	c	
	jr.	nz,0b
	ret
	
		
_ALLOCATION_ERROR	
	pop	bc
	ld	de,_NOT_ENOUGH_FREE_S
	ld	c,_STROUT
	call	5
	jr. _TERM0	


_NOT_ENOUGH_FREE_S:
	db	"[ERROR]: Not enough free memory found",0,13,10,"$"

_NO_DOS:
	db	"[ERROR]: This program needs MSX-DOS2.",0,13,10,"$"





	; --- init_font
	;
	; Init the font in the PGT.

init_font:

	di
	; relocate the PGT (old is at 0x1000)
	; new is at 0x9000
;	ld	a,00010010b
;	out	(0x99),a
;	ld	a,128+4	
;	out	(0x99),a

	ld	hl,0x9000
	call	set_vdpwrite
	
	di
	ld a,8		; loop 8 times
	ld c,0x98

	ld hl,font_data

_fontloop:
		ld b,255		; subloop 255 times
		otir
	dec a
	jr. nz,_fontloop
	
	ei
	ret









init_config:
	call	set_vsf



	;-- get location of TT.COM
;	ld	c,$6b
;	ld	hl,_ENV_PROGRAM
;	ld	de,buffer
;	ld	b,255
;	call	DOS

	;-load the config file
	
	
	
	;--- process the config values
	
	;-- Speed equalisation
;	ld	a,(_FOUND_VDP)
;	and	a
;	jr.	z,1f		; if 60hz
;	
;	;--- on 50Hz always disable speed equalization
;	ld	(vsf),a
;	jp	0f
;
;	;--- on 60hz equalization is optional	
;1:
;	ld	a,(_CONFIG_EQU)
;	ld	(vsf),a
;
;
;0:
	ret


load_config:
	call	get_program_path

	ld	hl,_DEFAULT_CFG
	ld	bc,_DEFAULT_CFGLEN
	ldir

	call	reset_hook
	
	;--- open the file
	ld	de,buffer+256 	; +2 to skip drive name
	ld	a,00000001b		; NO write
;	ld	de,buffer
	ld	c,(_OPEN)
	call	DOS
	and	a	
	jr	nz,_lcfg_error
	
	
	;--- file is found.
	ld	a,b
	ld	(disk_handle),a
	
	;--- Read type
	ld	de,_CONFIG_SLOT
	ld	hl,16
	call	read_file

	call	close_file

_lcfg_error:
	ld	a,(_CONFIG_PSGPORT)		; copy port value as this is not available in ISR
	cp	$a0				; standard MSX
	jp	z,99f
	cp	$10				; SCC flash
	jp	z,99f
	ld	a,$a0				; change to default of no valid value
	ld	(_CONFIG_PSGPORT),a
99:	
	ld	(psgport),a
	ret	



	; --- init_vdp
	; 
	; Initial init of the vdp
init_vdp:
	di
	ld	a,00000100b ; Reg#0 [ 0 ][DG ][IE2][IE1][M5 ][M4 ][M3 ][ 0 ]
	out	(0x99),a
	ld	a,0+128
	out	(0x99),a

	ld	a,01110000b ; Reg#1 [ 0 ][BL ][IE0][M1 ][M2 ][ 0 ][SIZ][MAG]

	out	(0x99),a
	ld	a,1+128
	out	(0x99),a	

	ld	a,00001011b ; REG#2[ 0 ][A16][A15][A14][A13][A12][ 1 ][ 1 ]  - Pattern layout table

	out	(0x99),a
	ld	a,2+128
	out	(0x99),a	

	ld	a,10101111b ; Reg#3 [A13][A12][A11][A10][A09][ 1 ][ 1 ][ 1 ]  - Color table  [HIGH]

	out	(0x99),a
	ld	a,3+128
	out	(0x99),a	
	
	ld	a,00010010b ; Reg#4 [ 0 ][ 0 ][A16][A15][A14][A13][A12][A11]  - Pattern generator table

	out	(0x99),a
	ld	a,4+128
	out	(0x99),a	
	
	ld	a,($FFE8)
	or	10000000b ; Reg#9 [LN ][ 0 ][S1 ][S0 ][IL ][EO ][NT ][DC ]
	out	(0x99),a
	ld	a,9+128
	out	(0x99),a	


	ld	a,$f0
	out	(0x99),a
	ld	a,7+128
	out	(0x99),a
	ld	a,$e1
	out	(0x99),a
	ld	a,12+128
	out	(0x99),a
	ld	a,0xF0	;reg#13
	out	(0x99),a
	ld	a,13+128
	out	(0x99),a		
	
	
	ei
	ret	

