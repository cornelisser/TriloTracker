	

;===========================================================
; --- draw_configbox
; Display the configuration menu.  Without actual values 
; 
;===========================================================
draw_configbox:
	; box around macro lines
	ld	hl,(80*9)+0
	ld	de,(80*256) + 17
	call	draw_box



	ld	hl,0x0009
	ld	de,0x5012
	call	draw_colorbox

	ld	hl,0x010a
	ld	de,0x250e
	call	erase_colorbox
	ld	hl,0x290a
	ld	de,0x250e
	call	erase_colorbox
	ld	hl,0x0219
	ld	de,0x4c01
	call	erase_colorbox


	ld	hl,(80*11)+2
	ld	de,_LABEL_CONFIG_KEY_1
	call	draw_label	
	ld	hl,(80*12)+2
	ld	de,_LABEL_CONFIG_KEY_2
	call	draw_label
	ld	hl,(80*13)+2
	ld	de,_LABEL_CONFIG_KEY_3
	call	draw_label

	ld	hl,(80*15)+2
	ld	de,_LABEL_CONFIG_EDIT_SPD
	call	draw_label	
	ld	hl,(80*16)+2
	ld	de,_LABEL_CONFIG_EDIT_STP
	call	draw_label
	ld	hl,(80*17)+2
	ld	de,_LABEL_CONFIG_EDIT_ADD
	call	draw_label


	ld	hl,(80*19)+2
	ld	de,_LABEL_CONFIG_COLOR_1
	call	draw_label	
	ld	hl,(80*20)+2
	ld	de,_LABEL_CONFIG_COLOR_2
	call	draw_label
	ld	hl,(80*21)+2
	ld	de,_LABEL_CONFIG_COLOR_3
	call	draw_label
	ld	hl,(80*22)+2
	ld	de,_LABEL_CONFIG_COLOR_4
	call	draw_label


	ld	hl,(80*11)+2+40
	ld	de,_LABEL_CONFIG_PSG_PORT
	call	draw_label

IFDEF TTSCC
	
	ld	hl,(80*12)+2+40
	ld	de,_LABEL_CONFIG_SCC_1
	call	draw_label
ELSE
	ld	hl,(80*12)+2+40
	ld	de,_LABEL_CHAN_SETUP
	call	draw_label	
ENDIF
	
	ld	hl,(80*13)+2+40
	ld	de,_LABEL_CONFIG_VDP_FREQ
	call	draw_label
	ld	hl,(80*14)+2+40
	ld	de,_LABEL_CONFIG_VDP_EQU
	call	draw_label
	ld	hl,(80*15)+2+40
	ld	de,_LABEL_CONFIG_VOLUME
	call	draw_label



	ld	hl,(80*16)+2+40
	ld	de,_LABEL_CONFIG_AUDIT
	call	draw_label
	ld	hl,(80*17)+2+40
	ld	de,_LABEL_CONFIG_DEBUG
	call	draw_label
	ld	hl,(80*20)+2+40
	ld	de,_LABEL_CONFIG_INSDEFAULT
	call	draw_label

	ld	hl,(80*18)+2+40
	ld	de,_LABEL_CONFIG_VU
	call	draw_label
;	ld	hl,(80*20)+2+40
;	ld	de,_LABEL_CONFIG_PLUGIN_2
;	call	draw_label
;	ld	hl,(80*21)+2+40
;	ld	de,_LABEL_CONFIG_PLUGIN_3
;	call	draw_label
	ld	hl,(80*22)+2+40
	ld	de,_LABEL_CONFIG_SAVE
	call	draw_label

	;-- get location of TT.COM
;debug:	ld	c,$6b
;	ld	hl,_ENV_PROGRAM
;	ld	de,buffer
;	ld	b,255
;	call	DOS		; < 255-[B] is length value string returned.
;
;	;--- get full path+filename length
;	ld	a,255
;	sub	b
;	ld	b,a
;	
;	;--- set extension .CFG
;	sub	4
;	ld	hl,buffer
;	add	a,l
;	ld	l,a
;	jr.	nc,99f
;	inc	h
	call	reset_hook
	call	get_program_path

	ld	hl,_DEFAULT_CFG
	ld	bc,_DEFAULT_CFGLEN
	ldir	
	
	;--- display config path+name
	ld	hl,(80*25)+2
	ld	de,buffer+256
;	ld	b,40
	call	draw_label;_fast

	call	set_hook


	call	update_config_selection
	call	update_configeditor

	ret

IFDEF TTSCC
_LABEL_CONFIG_SCC_1:
	db "SCC slot",0
ELSE
_LABEL_CHAN_SETUP:
	db "Channel setup",0
ENDIF
	
_LABEL_CONFIG_AUDIT:
	db "Note audition",0	
_LABEL_CONFIG_DEBUG:
	db "Register debug",0	
_LABEL_CONFIG_INSDEFAULT:
	db "Default instruments",0	

_LABEL_CONFIG_KEY_1:
	db "Keyboard type",0
_LABEL_CONFIG_KEY_2:
	db "Key click",0
_LABEL_CONFIG_KEY_3:
	db "Keyjazz default",0

_LABEL_CONFIG_EDIT_SPD:
	db "Speed default",0
_LABEL_CONFIG_EDIT_STP:
	db "Step default",0
_LABEL_CONFIG_EDIT_ADD:
	db "Add default",0

_LABEL_CONFIG_COLOR_1:
	db "Color theme",0	
_LABEL_CONFIG_COLOR_2:
	db "Text color",0	
_LABEL_CONFIG_COLOR_3:
	db "Higlight color",0	
_LABEL_CONFIG_COLOR_4:
	db "Text highlight color",0	

_LABEL_CONFIG_VDP_FREQ:
	db "VDP frequency",0
_LABEL_CONFIG_VDP_EQU:
	db "Speed equalization",0

_LABEL_CONFIG_VOLUME:
	db "Volume limit",0

_LABEL_CONFIG_VU:
	db "VU meter",0

_LABEL_CONFIG_PERDIOD:
	db "Period table",0

_;LABEL_CONFIG_PLUGIN_2:
;	db "Plug-in #2",0
;_LABEL_CONFIG_PLUGIN_3:
;	db "Plug-in #3",0

_LABEL_CONFIG_PSG_PORT:	
	db "PSG port",0



_LABEL_CONFIG_SAVE:
	db "Save configuration  [ENTER] to save.",0




;_LABEL_CONFIG_EXIT:
;	db "[EXIT]",0	
;_LABEL_CONFIG_SAVE:
;	db "[SAVE]",0	



;===========================================================
; --- update_macrobox
; Display the values
; 
;===========================================================
update_configbox:
	;-------------------
	; PSG port
	;-------------------
	ld	hl,(80*11)+2+20+40
	ld	de,_LABEL_CONFIG_A010
	call	draw_label	
	ld	a,(_CONFIG_PSGPORT)
IFDEF TTSMS
	sub	$3f
ELSE
	sub	$a0
ENDIF
	and	a
	jr.	z,99f
	ld	a,7
99:
	add	0x3e
	ld	h,a
	ld	l,11
	ld	de,0x0601
	call	draw_colorbox	

IFDEF TTSCC
	;-----------------
	;	SCC SLOT
	;-----------------
	ld	a,(_CONFIG_SLOT)
	cp	255				; check if config is set to auto
	jr.	nz,99f
	ld	de,_LABEL_CONFIG_SCCSLOT_AUTO
	jr.	88f
99:
	ld	de,_LABEL_CONFIG_SCCSLOT	
88:	
	;--- translate the SLOT# to text
	;	ExxxSSPP
	ld	a,(SCC_slot)
	; first the slot
	ld	h,d
	ld	l,e
	ld	bc,7
	add	hl,bc			; set the pointer to the slot
	
	ld	b,a
	and 	00000011b
	add	48
99:
	ld	(hl),a
	
	; next subslot
	inc	hl
	inc	hl
	ld	a,b
	bit	7,a
	jr.	nz,_cfg_exp
	ld	a,"X"
	jr.	99f
_cfg_exp:
	rra	
	rra
	and	3
	add	48
99:
	ld	(hl),a	
	
	
	;--- display the result.
	ld	hl,(80*12)+2+20+40
	call	draw_label	
		
0:
ELSE
	;-------------------
	; CHannel setup
	;-------------------
	ld	hl,(80*12)+2+20+40
	ld	de,_LABEL_CONFIG_CHAN_SETUP
	call	draw_label	
	ld	a,(replay_chan_setup)
	and 	$01
	jr.	z,99f
	ld	a,7
99:
	add	0x3e
	ld	h,a
	ld	l,12
	ld	de,0x0601
	call	draw_colorbox



ENDIF
	;-----------------
	;    VDP FREQ
	;-----------------
	ld	hl,(80*13)+2+20+40
	ld	de,_LABEL_CONFIG_VDP_FRQ
	call	draw_label
	
	ld	hl,0x3f0d
	ld	de,0x0c01
	call	erase_colorbox	
	ld	d,4
	
	ld	a,(_CONFIG_VDP);(vsf)
	cp	255
	jr.	nz,88f

	ld	hl,0x470d
	ld	e,$01
	call	draw_colorbox	
	ld	d,1

	ld	a,(_FOUND_VDP)
88:	and	a
	ld	a,4
	jr.	nz,99f	; PAL
	ld	a,0
99:
	ld	hl,0x3f0d
	ld	e,0x01
	add	a,h
	ld	h,a
	call	draw_colorbox	
	
	;-------------------
	; SPEED equalisation
	;-------------------
	ld	hl,(80*14)+2+20+40
	ld	de,_LABEL_CONFIG_ONOFF
	call	draw_label	
	ld	a,(_CONFIG_EQU)
	cp	0
	jr.	nz,99f
	ld	a,7
99:
	add	0x3e
	ld	h,a
	ld	l,14
	ld	de,0x0601
	call	draw_colorbox	



	;-------------------
	; Volume limit
	;-------------------
	ld	hl,(80*15)+2+20+40
	ld	de,_LABEL_CONFIG_01
	call	draw_label	
	ld	a,(_CONFIG_VOL)
	cp	0
	jr.	z,99f
	ld	a,6
99:
	add	0x3f
	ld	h,a
	ld	l,15
	ld	de,0x0601
	call	draw_colorbox	




	;-------------------
	; Note audition
	;-------------------
	ld	hl,(80*16)+2+20+40
	ld	de,_LABEL_CONFIG_ONOFF
	call	draw_label	
	ld	a,(_CONFIG_AUDIT)
	cp	0
	jr.	z,99f
	ld	a,6
99:
	add	0x3f
	ld	h,a
	ld	l,16
	ld	de,0x0601
	call	draw_colorbox	

	;-------------------
	; Register debug
	;-------------------
	ld	hl,(80*17)+2+20+40
	ld	de,_LABEL_CONFIG_ONOFF
	call	draw_label	
	ld	a,(_CONFIG_DEBUG)
	cp	0
	jr.	z,99f
	ld	a,6
99:
	add	0x3f
	ld	h,a
	ld	l,17
	ld	de,0x0601
	call	draw_colorbox

	;-------------------
	; VU
	;-------------------
	ld	hl,(80*18)+2+20+40
	ld	de,_LABEL_CONFIG_ONOFF
	call	draw_label	
	ld	a,(_CONFIG_VU)
	cp	0
	jr.	z,99f
	ld	a,6
99:
	add	0x3f
	ld	h,a
	ld	l,18
	ld	de,0x0601
	call	draw_colorbox

	;--------------------
	; Period table
	;----------------------
	ld	hl,(80*19)+2+40
	ld	de,_LABEL_CONFIG_PERDIOD
	call	draw_label



	ld	a,(replay_period)
	add	a
	add	a
	add	a
	add	a

	ld	de,_LABEL_PERIOD_TABLE
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	hl,(80*19)+2+20+40
	call	draw_label	



	;-------------------
	; Default ins
	;-------------------
	ld	hl,(80*20)+2+20+40
	ld	de,_LABEL_CONFIG_ONOFF
	call	draw_label	
	ld	a,(_CONFIG_INS)
	cp	0
	jr.	z,99f
	ld	a,6
99:
	add	0x3f
	ld	h,a
	ld	l,20
	ld	de,0x0601
	call	draw_colorbox







	;--------------------
	; KEYBOARD type
	;--------------------
	ld	a,(_CONFIG_KB)
	add	a
	add	a
	add	a
	add	a
	ld	de,_LABEL_CONFIG_KEYBOARD
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	hl,(80*11)+2+20
	call	draw_label
	
	
	;--------------------
	; KEYCLICK
	;--------------------	
	ld	de,_LABEL_CONFIG_ONOFF
	ld	hl,(80*12)+2+20
	call	draw_label
		
	ld	a,(KH_CLICK)
	and	a
	jr.	z,99f
	ld	a,6
99:
	add	23
	ld	h,a
	ld	l,12
	ld	de,0x0601
	call	draw_colorbox	


	;---------------------
	; KEYJAZZ default
	;---------------------
	ld	de,_LABEL_CONFIG_ONOFF
	ld	hl,(80*13)+2+20
	call	draw_label
	ld	a,(_CONFIG_KEYJAZZ)
	and	a
	jr.	z,99f
	ld	a,6
99:
	add	23
	ld	h,a
	ld	l,13
	ld	de,0x0601
	call	draw_colorbox	


	;----------------------
	; SPEED default
	;----------------------
	ld	a,(_CONFIG_SPEED)	
	ld	de,_LABEL_CONFIG_NUMBER+2
	call	draw_decimal

	ld	de,_LABEL_CONFIG_NUMBER
	ld	hl,(80*15)+2+20
	call	draw_label

	;----------------------
	; STEP default
	;----------------------
	ld	a,(_CONFIG_STEP)	
	ld	de,_LABEL_CONFIG_NUMBER+2
	call	draw_decimal

	ld	de,_LABEL_CONFIG_NUMBER
	ld	hl,(80*16)+2+20
	call	draw_label	
	
	;----------------------
	; ADD default
	;----------------------
	ld	a,(_CONFIG_ADD)	
	ld	de,_LABEL_CONFIG_NUMBER+2
	call	draw_decimal

	ld	de,_LABEL_CONFIG_NUMBER
	ld	hl,(80*17)+2+20
	call	draw_label		
	
	;--------------------
	; Theme
	;--------------------
	ld	a,(_CONFIG_THEME)
	add	a
	add	a
	add	a
	add	a
	ld	de,_LABEL_CONFIG_THEME
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	hl,(80*19)+2+20
	call	draw_label


	;--------------------
	; Theme colors
	;--------------------
	ld	hl,TABLE_COLOR_THEMES
	ld	a,(_CONFIG_THEME)
	add	a
	add	a
	add	a
;	add	a
	add	2
	add	a,l
	ld	l,a
	jr. 	nc,99f
	inc 	h
99:
	;-- Text color
	call	_ucb_rgb
	push	hl
	ld	de,_LABEL_CONFIG_RGB
	ld	a,(editsubmode)
	cp	7
	call	z,_config_set_color_cursor
	ld	hl,(80*20)+4+20
	ld	b,9
	call	draw_label_fast	
	pop	hl
	;-- Highlight text color
	call	_ucb_rgb
	push	hl
	ld	de,_LABEL_CONFIG_RGB
	ld	a,(editsubmode)
	cp	8
	call	z,_config_set_color_cursor
	ld	hl,(80*21)+4+20
	ld	b,9
	call	draw_label_fast	
	pop	hl	
	;-- Highlight color
	call	_ucb_rgb
	push	hl
	ld	de,_LABEL_CONFIG_RGB
	ld	a,(editsubmode)
	cp	9
	call	z,_config_set_color_cursor
	ld	hl,(80*22)+4+20
	ld	b,9
	call	draw_label_fast	
	pop	hl
		

	ret

_config_set_color_cursor	
	ld	a,(cursor_input)
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	a,(de)
	sub	"0"
	ld	(de),a
	ld	de,_LABEL_CONFIG_RGB
	ret	
	
_ucb_rgb:	
	ld	a,(hl)
	inc	hl
	ld	de,_LABEL_CONFIG_RGB
	call	draw_hex2
	ld	a,(hl)
	inc	hl
	call	draw_hex
	ret	
	
_LABEL_CONFIG_RGB:
	db	"    [RBG]",0	

IFDEF TTSCC
_LABEL_CONFIG_SCCSLOT_AUTO:
	db	_ARROWLEFT," AUTO X-X  ",_ARROWRIGHT,0
_LABEL_CONFIG_SCCSLOT:
	db	_ARROWLEFT," SLOT X-X  ",_ARROWRIGHT,0
ELSE
_LABEL_CONFIG_CHAN_SETUP:
	db	"[ 2-6    3-5 ]",0
ENDIF
	
_LABEL_CONFIG_A010:
IFDEF TTSMS
	db	"[ $3F    $49 ]",0
ELSE
	db	"[ $A0    $10 ]",0
ENDIF

_LABEL_CONFIG_KEYBOARD:
	db	_ARROWLEFT,"Japanese     ",_ARROWRIGHT,0
	db	_ARROWLEFT,"International",_ARROWRIGHT,0
	db	_ARROWLEFT,"German       ",_ARROWRIGHT,0
	db	_ARROWLEFT,"Autodetect   ",_ARROWRIGHT,0
_LABEL_CONFIG_ONOFF:
	db	"[ OFF    ON  ]",0
_LABEL_CONFIG_VDP_FRQ:
	db	"[ 50  60 AUTO]",0
_LABEL_CONFIG_01:
	db	"[  0      1  ]",0
_LABEL_CONFIG_NUMBER:
	db	_ARROWLEFT," 00 ",_ARROWRIGHT,0

_LABEL_CONFIG_THEME:
	db	_ARROWLEFT,"TriloTracker ",_ARROWRIGHT,0
	db	_ARROWLEFT,"MSX blues    ",_ARROWRIGHT,0
	db	_ARROWLEFT,"SchismTracker",_ARROWRIGHT,0
	db	_ARROWLEFT,"ZX Spectrum  ",_ARROWRIGHT,0
	db	_ARROWLEFT,"Icy dark     ",_ARROWRIGHT,0
	db	_ARROWLEFT,"Beatrix      ",_ARROWRIGHT,0
	db	_ARROWLEFT,"Jungle       ",_ARROWRIGHT,0	
	db	_ARROWLEFT,"Purple Haze  ",_ARROWRIGHT,0
	db	_ARROWLEFT,"CottonTracker",_ARROWRIGHT,0
	db	_ARROWLEFT,"Custom theme ",_ARROWRIGHT,0

;===========================================================
; --- update selection
;
;
;
;===========================================================
update_config_selection:

	;erase any existing selection
	ld	hl,0x020a
	ld	de,0x130e
	call	erase_colorbox
	ld	hl,0x2a0a
	ld	de,0x130e
	call	erase_colorbox
	ld	hl,0x2a19
	ld	de,0x1301
	call	erase_colorbox



	ld	a,(editsubmode)
;	add	a
	ld	hl,_CONFIG_MENU_XY
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	l,(hl)
	ld	h,2
	ld	a,(editsubmode)
	cp	10
	jr.	c,99f
	ld	h,42
99:
	ld	de,0x1301
	call	draw_colorbox
	ret	

_CONFIG_MENU_XY:
	db	0x0b
	db	0x0c
	db	0x0d	
	db	0x0f
	db	0x10
	db	0x11			
	db	0x13
	db	0x14
	db	0x15
	db	0x16	
	db	0x0b	
	db	0x0c
	db	0x0d
	db	0x0e	
	db	0x0f
	db	0x10
	db	0x11
	db	0x12
	db	0x13			
	db	0x14
;	db	0x15
	db	0x16
;	db	0x18			
	db	0x1a
	; H = x pos
	; L = y pos
	; D = width
	; E = height	


_LABEL_PERIOD_TABLE:
	db	_ARROWLEFT,"A440 Modern  ",_ARROWRIGHT,0
	db	_ARROWLEFT,"A445 Konami  ",_ARROWRIGHT,0
	db	_ARROWLEFT,"A448         ",_ARROWRIGHT,0
	db	_ARROWLEFT,"A432 Earth   ",_ARROWRIGHT,0





PERIOD_TABLES_PSG:
	dw	PSG_A440_Modern
	dw	PSG_A445_Konami
	dw	PSG_A448
	dw	PSG_A432_Earth


PSG_A432_Earth:
      dw      $0D9C, $0CD8, $0C20, $0B72, $0ACD, $0A32, $099F, $0915, $0893, $0817, $07A3, $0735
      dw      $06CE, $066C, $0610, $05B9, $0567, $0519, $04D0, $048B, $0449, $040C, $03D2, $039B
      dw      $0367, $0336, $0308, $02DC, $02B3, $028C, $0268, $0245, $0225, $0206, $01E9, $01CD
      dw      $01B3, $019B, $0184, $016E, $015A, $0146, $0134, $0123, $0112, $0103, $00F4, $00E7
      dw      $00DA, $00CE, $00C2, $00B7, $00AD, $00A3, $009A, $0091, $0089, $0081, $007A, $0073
      dw      $006D, $0067, $0061, $005C, $0056, $0052, $004D, $0049, $0045, $0041, $003D, $003A
      dw      $0036, $0033, $0030, $002E, $002B, $0029, $0026, $0024, $0022, $0020, $001F, $001D
      dw      $001B, $001A, $0018, $0017, $0016, $0014, $0013, $0012, $0011, $0010, $000F, $000E
 ;     dw      $000E, $000D, $000C, $000B, $000B, $000A, $000A, $0009, $0009, $0008, $0008, $0007
  ;    dw      $0007, $0006, $0006, $0006, $0005, $0005, $0005, $0005, $0004, $0004, $0004, $0004

PSG_A440_Modern:
      dw      $0D5C, $0C9D, $0BE7, $0B3C, $0A9B, $0A02, $0973, $08EB, $086B, $07F2, $0780, $0714
      dw      $06AE, $064E, $05F4, $059E, $054D, $0501, $04B9, $0475, $0435, $03F9, $03C0, $038A
      dw      $0357, $0327, $02FA, $02CF, $02A7, $0281, $025D, $023B, $021B, $01FC, $01E0, $01C5
      dw      $01AC, $0194, $017D, $0168, $0153, $0140, $012E, $011D, $010D, $00FE, $00F0, $00E2
      dw      $00D6, $00CA, $00BE, $00B4, $00AA, $00A0, $0097, $008F, $0087, $007F, $0078, $0071
      dw      $006B, $0065, $005F, $005A, $0055, $0050, $004C, $0047, $0043, $0040, $003C, $0039
      dw      $0035, $0032, $0030, $002D, $002A, $0028, $0026, $0024, $0022, $0020, $001E, $001C
      dw      $001B, $0019, $0018, $0016, $0015, $0014, $0013, $0012, $0011, $0010, $000F, $000E
;      dw      $000D, $000D, $000C, $000B, $000B, $000A, $0009, $0009, $0008, $0008, $0007, $0007
;      dw      $0007, $0006, $0006, $0006, $0005, $0005, $0005, $0004, $0004, $0004, $0004, $0004

PSG_A445_Konami:
      dw      $0D36, $0C78, $0BC5, $0B1C, $0A7C, $09E6, $0957, $08D1, $0853, $07DB, $076A, $0700
      dw      $069B, $063C, $05E3, $058E, $053E, $04F3, $04AC, $0469, $0429, $03ED, $03B5, $0380
      dw      $034E, $031E, $02F1, $02C7, $029F, $0279, $0256, $0234, $0215, $01F7, $01DB, $01C0
      dw      $01A7, $018F, $0179, $0163, $0150, $013D, $012B, $011A, $010A, $00FB, $00ED, $00E0
      dw      $00D3, $00C8, $00BC, $00B2, $00A8, $009E, $0095, $008D, $0085, $007E, $0077, $0070
      dw      $006A, $0064, $005E, $0059, $0054, $004F, $004B, $0047, $0043, $003F, $003B, $0038
      dw      $0035, $0032, $002F, $002C, $002A, $0028, $0025, $0023, $0021, $001F, $001E, $001C
      dw      $001A, $0019, $0018, $0016, $0015, $0014, $0013, $0012, $0011, $0010, $000F, $000E
;      dw      $000D, $000C, $000C, $000B, $000A, $000A, $0009, $0009, $0008, $0008, $0007, $0007
;      dw      $0007, $0006, $0006, $0006, $0005, $0005, $0005, $0004, $0004, $0004, $0004, $0003

PSG_A448:
      dw      $0D1F, $0C63, $0BB1, $0B09, $0A6A, $09D5, $0947, $08C2, $0844, $07CE, $075D, $06F4
      dw      $0690, $0631, $05D8, $0584, $0535, $04EA, $04A4, $0461, $0422, $03E7, $03AF, $037A
      dw      $0348, $0319, $02EC, $02C2, $029B, $0275, $0252, $0231, $0211, $01F3, $01D7, $01BD
      dw      $01A4, $018C, $0176, $0161, $014D, $013B, $0129, $0118, $0109, $00FA, $00EC, $00DE
      dw      $00D2, $00C6, $00BB, $00B1, $00A7, $009D, $0094, $008C, $0084, $007D, $0076, $006F
      dw      $0069, $0063, $005E, $0058, $0053, $004F, $004A, $0046, $0042, $003E, $003B, $0038
      dw      $0034, $0032, $002F, $002C, $002A, $0027, $0025, $0023, $0021, $001F, $001D, $001C
      dw      $001A, $0019, $0017, $0016, $0015, $0014, $0013, $0012, $0011, $0010, $000F, $000E
 
IFDEF TTSCC 
ELSE

PERIOD_TABLES_FM:
	dw	FM_A440_Modern
	dw	FM_A445_Konami
	dw	FM_A448
	dw	FM_A432_Earth


FM_A432_Earth:
      dw      $00A8, $00B2, $00BC, $00C8, $00D4, $00E0, $00EE, $00FC, $010B, $011B, $012B, $013D

FM_A440_Modern:
      dw      $00AB, $00B5, $00C0, $00CB, $00D8, $00E4, $00F2, $0100, $0110, $0120, $0131, $0143

FM_A448
      dw      $00AE, $00B8, $00C3, $00CF, $00DB, $00E9, $00F6, $0105, $0115, $0125, $0137, $0149

FM_A445_Konami:
      dw      $00AD, $00B7, $00C2, $00CE, $00DA, $00E7, $00F5, $0103, $0113, $0123, $0134, $0147


ENDIF
;===========================================================
; --- process_key_macrobox
;
; Process the input for the PSG sample. 
; 
; 
;===========================================================
process_key_configbox:
	

	call	process_key_numpad
	jr. 	c,update_configeditor

	ld	a,(key)
	and	a
	ret	z

0:
	cp	_ENTER
	jr.	z,.save
	cp	_SPACE
	jr.	nz,0f
4:
	ld	a,(editsubmode)
	cp	19
	jr.	nz,0f
.save	
	;--- save data
	call	reset_hook
	call	get_program_path


	ld	hl,_DEFAULT_CFG
	ld	bc,9
	ldir


	;--- Copy the custom theme to config vars
	ld	hl,_theme10a
	ld	de,_CONFIG_CUSTOMTHEME
	ld	bc,8
	ldir
	
	;--- open the file
	ld	de,buffer+256 	; +2 to skip drive name
	ld	a,00000000b		; NO write
	ld	b,00000000b		; b7=0 -> overwrite
;	ld	de,buffer
	ld	c,(_CREATE)
	call	DOS
	and	a	
	jr	nz,_lsav_error
	
	
	;--- file is found.
	ld	a,b
	ld	(disk_handle),a


	;--- Read type
	ld	de,_CONFIG_SLOT
	ld	hl,18+8
	call	write_file


	call	close_file
	call	set_hook
	
	ld	a,WIN_CFGSAV
	call	window
	jr.	draw_configbox
	
	
_lsav_error:
	call	set_hook
	ret	
	

0:	
	; - ESCAPE
	cp	_ESC
	jr.	nz,0f
	; escape 
;	ld	a,(editsubmode)
;	and	a
;	jr.	nz,0f
		jr.	restore_patterneditor
	
0:	
	;---- Move selection down
	cp	_KEY_DOWN
	jr.	nz,0f
	;-selection down
	xor	a
	ld 	(cursor_input),a		; reset colorinput
	ld	a,(editsubmode)
	inc	a
	cp	20
	jr.	c,99f
	xor	a
99:	ld	(editsubmode),a
	jr.	update_config_selection
0:	
	;---- Move selection up
	cp	_KEY_UP
	jr.	nz,0f
	;-selection down
	xor	a
	ld 	(cursor_input),a		; reset colorinput	
	ld	a,(editsubmode)
	dec	a
	cp	0xff
	jr.	nz,99f
	ld	a,19
99:	ld	(editsubmode),a
	jr.	update_config_selection
	
0:	
	;---- Change selection
	cp	_KEY_RIGHT
	jr.	z,1f
	cp	_KEY_LEFT
	jr.	nz,0f
	;-selection right/left
1:
	ld	a,(editsubmode)
	add	a
	ld	hl,_CONFIG_MENU_JMP
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	jp	hl
0:
	;-------------------
	; color input 
	;-------------------
	;-- only for custom theme
	ld	a,(_CONFIG_THEME)
	cp	9
	jr.	nz,0f

	; check if we are on color options
	ld	a,(editsubmode)
	cp	7
	jr.	c,0f
	cp	10
	jr.	nc,0f

	;----- for input colors
	; number?
	ld	a,(key)
	cp	"0"
	jr.	c,0f
	cp	"7"+1
	jr.	nc,0f

	;--- 	
	sub	'0'
	ld	d,a		; save value
	
	;--- get current theme start pos
	ld	hl,TABLE_COLOR_THEMES
	ld	a,(_CONFIG_THEME)
	add	a
	add	a
	add	a
;	add	a
	add	a,l
	ld	l,a
	jr. 	nc,99f
	inc 	h
99:
	;-- add the color we are editing
	ld	a,(editsubmode)
	sub	6
	add	a
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(cursor_input)
	ld	c,a
	inc	a
	cp	3
	jr.	c,99f
	xor	a
99:	ld	(cursor_input),a
	ld	a,c
	and	a
	jr.	z,_pkcb_ch
	
	; edit second byte of color?
	cp	2
	jr.	nz,99f
	inc	hl
99:
	
	
	;input low byte
_pkcb_cl:
	ld	a,(hl)
	and	$f0
	or	d	
	ld	(hl),a
	call	set_textcolor
	call	update_configbox
	ret
_pkcb_ch:
	ld	a,(hl)
	and	$0F
	
	sla	d
	sla	d
	sla	d
	sla	d
	or	d	
	ld	(hl),a
	call	set_textcolor
	call	update_configbox
	ret


0:
_pk_config_END:
	ret

	
_CONFIG_MENU_JMP:
	dw	pk_config_keyboard
	dw	pk_config_keyclick
	dw	pk_config_keyjazz
	dw	pk_config_speed
	dw	pk_config_step
	dw	pk_config_add
	dw	pk_config_theme
	dw	_pk_config_END
	dw	_pk_config_END
	dw	_pk_config_END
	dw	pk_config_psg
IFDEF TTSCC
	dw	pk_config_scc
ELSE
	dw	pk_config_chan_setup
ENDIF	
	dw	pk_config_vdp
	dw	pk_config_equalisation
	dw	pk_config_volume
	dw	pk_config_audition
	dw	pk_config_debug
	dw	pk_config_vu
	dw	pk_config_period
	dw	pk_config_instruments
	dw	_pk_config_END
	dw	_pk_config_END

;====================================
; change keyboard
;====================================
pk_config_keyboard:
	ld	a,(key)
	cp	_KEY_RIGHT
	ld	a,(_CONFIG_KB)
	jr.	nz,0f

	; -- Right
	inc	a
	cp	4
	jr.	c,99f
	xor	a
99:	jr.	88f
	
0:	;-- lEFT
	and 	a
	jr.	z,99f
	dec	a
	jr.	88f
99:	ld	a,3
88:
	ld	(_CONFIG_KB),a
	call	create_keyboardtype_mapping
	jr.	update_configbox


;====================================
; change keyclick
;====================================
pk_config_keyclick:
	ld	a,(KH_CLICK)
	inc	a
	and	1
	ld	(KH_CLICK),a
	
	ld	hl,0x160c
	ld	de,0x0d01
	call	erase_colorbox
	
	jr.	update_configbox


;====================================
; change defalut keyjazz
;====================================
pk_config_keyjazz:
	ld	a,(_CONFIG_KEYJAZZ)
	inc	a
	and	1
	ld	(_CONFIG_KEYJAZZ),a
	
	ld	hl,0x160d
	ld	de,0x0d01
	call	erase_colorbox
	
	jr.	update_configbox
;====================================
; change vdp frequency
;====================================
pk_config_vdp:
	ld	a,(key)
	cp	_KEY_RIGHT
	jr.	z,_pcv_r
_pcv_l:
	ld	a,(_CONFIG_VDP)
	cp	255
	; auto
	jr.	nz,1f
	ld	a,1
	ld	(_CONFIG_VDP),a
	jr.	99f
1:	; 60
	cp	1
	jr.	nz,update_configbox
	xor	a
	ld	(_CONFIG_VDP),a
	jr.	99f	

_pcv_r:
	ld	a,(_CONFIG_VDP)
	cp	255
	jr.	z,update_configbox
	and	a
	jr.	nz,1f
	;-- 0
	inc	a
	ld	(_CONFIG_VDP),a
	jr.	99f
1:	;---1
	ld	a,255
	ld	(_CONFIG_VDP),a
	ld	a,(_FOUND_VDP)

99:
	
	ld	b,2
	and	a
	jr.	z,99f
	ld	b,0
99:	
	ld	a,($FFE8)	; get mirror of VDP reg# 9
	and	11111101b
	or	b
	ld	($FFE8),a

	di
	or	10000000b ; Reg#9 [LN ][ 0 ][S1 ][S0 ][IL ][EO ][NT ][DC ]
	out	(0x99),a
	ld	a,9+128
	out	(0x99),a	
	ei
	call	set_vsf
	jr.	update_configbox	
	


;====================================
; change speed
;====================================
pk_config_speed:
	ld	b,1
	ld	a,(key)
	cp	_KEY_RIGHT
	jr.	z,0f
	ld	b,-1
0:
	ld	a,(_CONFIG_SPEED)
	add	a,b
	cp	64
	jr.	c,99f
	ld	a,63
99:
	cp	2
	jr.	nc,99f
	ld	a,2
99:
	ld	(_CONFIG_SPEED),a

	jr.	update_configbox	

;====================================
; change step
;====================================
pk_config_step:
	ld	b,1
	ld	a,(key)
	cp	_KEY_RIGHT
	jr.	z,0f
	ld	b,-1
0:
	ld	a,(_CONFIG_STEP)
	add	a,b
	cp	33
	jr.	c,99f
	ld	a,32
99:
	cp	2
	jr.	nc,99f
	ld	a,2
99:
	ld	(_CONFIG_STEP),a
	ld	(song_step),a
	jr.	update_configbox	

;====================================
; change add
;====================================
pk_config_add:
	ld	b,1
	ld	a,(key)
	cp	_KEY_RIGHT
	jr.	z,0f
	ld	b,-1
0:
	ld	a,(_CONFIG_ADD)
	add	a,b
	cp	17
	jr.	nz,99f
	ld	a,16
99:
	cp	255
	jr.	nz,99f
	ld	a,0
99:
	ld	(_CONFIG_ADD),a
	ld	(song_add),a	
	jr.	update_configbox	


nr_of_themes	equ 	10		; number of themes
;====================================
; change theme
;====================================
pk_config_theme:

	ld	a,(key)
	cp	_KEY_RIGHT
	jr.	z,0f
	ld	a,(_CONFIG_THEME)
	inc	a
	cp	nr_of_themes
	jr.	c,1f
	xor	a
	jr.	1f
0:
	cp	_KEY_LEFT
	ret	z
	ld	a,(_CONFIG_THEME)
	dec	a
	cp	$ff
	jr.	nz,1f
	ld	a,nr_of_themes-1

1:	ld	(_CONFIG_THEME),a
	call	set_textcolor
	jr.	update_configbox	


;====================================
; change vdp port
;====================================
pk_config_psg:
	ld	a,(_CONFIG_PSGPORT)
	
IFDEF TTSMS
	cp	$3f				; MMM?
	jr.	z,1f
	
	ld	a,$3f				; MMM
	jr.	2f
1:	
	ld	a,$49				; Franky
ELSE
	cp	$a0
	jr.	z,1f
	
	ld	a,$a0
	jr.	2f
1:	
	ld	a,$10
ENDIF

2:
	ld	(_CONFIG_PSGPORT),a
	ld	(psgport),a

	ld	hl,0x3f0b
	ld	de,0x0d01
	call	erase_colorbox
	
	jr.	update_configbox	

IFDEF	TTSCC	
;====================================
; change SCC slot
;====================================
pk_config_scc:
	; translate slot to prim and sub in BC
	ld	a,(SCC_slot)
	ld	b,a
	rra
	rra	
	and	3
	ld	c,a
	ld	a,b
	and	3
	ld	b,a


;	ld	b,a
	ld	a,(key)
	cp	_KEY_RIGHT
	jr.	nz,0f
	
	ld	a,c
	inc	c
	cp	3
	jr.	nz,pk_config_scc_END	
	inc	b
	jr.	pk_config_scc_END	


0:	
	cp	_KEY_LEFT
	jr.	nz,update_configbox
	
	ld	a,c
	dec	c
	and	a
	jr.	nz,pk_config_scc_END
	dec	b
pk_config_scc_END:	
	ld	a,(SCC_slot_found)
	and	00001111b
	ld	d,a
	
	ld	d,a
	ld	a,c
	rla
	rla
	and	00001100b
	ld	c,a
	ld	a,b
	and	3
	or	c
	
	cp	d
	jr.	nz,99f		;-- check if we are NOT back at found slot
	
	or	0x80
	ld	(SCC_slot),a	
	ld	a,255
	ld	(_CONFIG_SLOT),a
	jr.	update_configbox		
	
99:	
	or	0x80
	ld	(SCC_slot),a
	ld	(_CONFIG_SLOT),a
	jr.	update_configbox	
ELSE
pk_config_chan_setup:
	ld	a,(replay_chan_setup)
	inc	a
	and	1
	ld	(replay_chan_setup),a
	ld	(_CONFIG_SLOT),a

	ld	hl,0x3f0c
	ld	de,0x0d01
	call	erase_colorbox

	ld	hl,_KJ_PSG
	ld	b,8
22:
	ld	(hl),0
	djnz	22b

	jr.	update_configbox
	
ENDIF
	
;====================================
; change equalisation
;====================================
pk_config_equalisation:

	ld	a,(_CONFIG_EQU)
	inc	a
	and	1
	ld	(_CONFIG_EQU),a

;	jr.	nz,99f		;-> equalisation off
;	ld	a,(_FOUND_VDP)
;	and	a
;	jr.	nz,88f
;	ld	a,1	
;88:	ld	(vsf),a	
	call	set_vsf
	
	ld	hl,0x3f0e
	ld	de,0x0d01
	call	erase_colorbox
	
	jr.	update_configbox




;====================================
; change volume limit
;====================================
pk_config_volume:
	ld	a,(_CONFIG_VOL)
	inc	a
	and	$01
	ld	(_CONFIG_VOL),a

	call	set_volumetable

	ld	hl,0x3f0f
	ld	de,0x0d01
	call	erase_colorbox

	jr. 	update_configbox
	ret



;====================================
; change note audition
;====================================
pk_config_audition:
	ld	a,(_CONFIG_AUDIT)
	inc	a
	and	1
	ld	(_CONFIG_AUDIT),a

	ld	hl,0x3f10
	ld	de,0x0d01
	call	erase_colorbox
	
	jr.	update_configbox

;====================================
; change debug info
;====================================
pk_config_debug:
	ld	a,(_CONFIG_DEBUG)
	inc	a
	and	1
	ld	(_CONFIG_DEBUG),a

	ld	hl,0x3f11
	ld	de,0x0d01
	call	erase_colorbox
	
	jr.	update_configbox



;====================================
; change vu meter
;====================================
pk_config_vu:
	ld	a,(_CONFIG_VU)
	inc	a
	and	1
	ld	(_CONFIG_VU),a

	ld	hl,0x3f12
	ld	de,0x0d01
	call	erase_colorbox
	
	jr.	update_configbox

;====================================
; change period table(s)
;====================================
pk_config_period:

	ld	a,(replay_period)
	inc	a
	and	3
	ld	(_CONFIG_PERIOD),a
	ld	(replay_period),a

	call	set_period_PSG
	ld	a,(replay_period)
	call	set_period_FM

	;-- Higlight current line
	ld	hl,0x3f13
	ld	de,0x0d01
	call	erase_colorbox
	
	jr.	update_configbox


set_period_PSG:
	;---- PSG Values
IFDEF TTSMS
	;--- copy period table(s) to RAM
	add	a
	ld	de,TRACK_ToneTable+2
	ld	bc,12*8*2
	ld	hl,PERIOD_TABLES_PSG
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
.loop:
	;-- filter out any value out of SN7 range
	ldi
	ld	a,(hl)
	cp	$04
	jr.	c,99f
	ld	(hl),0
	dec	de
	ld	a,1
	ld	(de),a
	inc	de
99:
	ldi
	inc	c
	dec	c
	jr.	nz,.loop

ELSE
	;--- copy period table(s) to RAM
	add	a
	ld	de,TRACK_ToneTable+2
	ld	bc,12*8*2
	ld	hl,PERIOD_TABLES_PSG
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a

	ldir

ENDIF
	ret


set_period_FM:
IFDEF	TTSCC
ELSE
	;---- FM values
	;--- copy period table(s) to RAM
	add	a
	ld	de,CHIP_FM_ToneTable+2
	ld	bc,12*8*2
	ld	hl,PERIOD_TABLES_FM
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a

	ld	c,0		; octave
.loopfm:	
	ld	b,12		; notes
.loopfmsub:
	ld	a,(hl)
	ld	(de),a
	inc	hl
	inc 	de
	ld	a,(hl)
	add	c	; add octave
	ld	(de),a
	inc	hl
	inc 	de
	djnz	.loopfmsub

	;-- back to start note values
	ld	a,l
	sub	24
	ld	l,a
	jr.	nc,99f
	dec	h
99:
	;-- increase octave
	ld	a,2
	add	c
	ld	c,a
	cp	12
	jr.	nz,.loopfm	


ENDIF
	ret








;====================================
; change default instruments
;====================================
pk_config_instruments:
	ld	a,(_CONFIG_INS)
	inc	a
	and	1
	ld	(_CONFIG_INS),a

	ld	hl,0x3f14
	ld	de,0x0d01
	call	erase_colorbox
	
	jr.	update_configbox
	
	
	
;====================================
; change keyclick
;====================================
;pk_config_keyclick:
;	ld	a,(KH_CLICK)
;	inc	a
;	and	1
;	ld	(KH_CLICK),a
;	
;	ld	hl,0x160c
;	ld	de,0x0d01
;	call	erase_colorbox
;	
;	jr.	update_configbox
	



;===========================================================
; --- reset_cursor_macrobox
;
; Reset the cursor to the top left of the pattern.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_configbox:
	call	flush_cursor
	
;	ld	a,(editsubmode)
;	add	a
;	ld	hl,_CONFIG_MENU_XY
;	add	a,l
;	ld	l,a
;	jr.	nc,99f
;	inc	h
;99:
;	ld	a,(hl)
;	ld	(cursor_y),a
;	ld	a,20
;	ld	(cursor_x),a
	ld	a,0
	ld	(cursor_type),a
	
	ret

