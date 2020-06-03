	

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

_LABEL_CONFIG_VU:
	db "VU meter",0
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
; --- update_psgsamplebox
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
	jp	nz,99f
	ld	de,_LABEL_CONFIG_SCCSLOT_AUTO
	jp	88f
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
	jp	nz,_cfg_exp
	ld	a,"X"
	jp	99f
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
	cp	0
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
	jp 	nc,99f
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
	jp	nc,99f
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

_LABEL_CONFIG_NUMBER:
	db	_ARROWLEFT," 00 ",_ARROWRIGHT,0

_LABEL_CONFIG_THEME:
	db	_ARROWLEFT,"TriloTracker ",_ARROWRIGHT,0
	db	_ARROWLEFT,"MSX blues    ",_ARROWRIGHT,0
	db	_ARROWLEFT,"SchismTracker",_ARROWRIGHT,0
	db	_ARROWLEFT,"ZX Spectrum  ",_ARROWRIGHT,0
	db	_ARROWLEFT,"MSX-Musixx   ",_ARROWRIGHT,0
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
	db	0x10
	db	0x11
	db	0x12			
	db	0x14
;	db	0x15
	db	0x16
;	db	0x18			
	db	0x1a
	; H = x pos
	; L = y pos
	; D = width
	; E = height	


;===========================================================
; --- process_key_psgsamplebox
;
; Process the input for the PSG sample. 
; 
; 
;===========================================================
process_key_configbox:
	
	ld	a,(key)
	and	a
	ret	z

0:
	cp	_ENTER
	jp	z,.save
	cp	_SPACE
	jp	nz,0f
4:
	ld	a,(editsubmode)
	cp	19
	jp	nz,0f
.save	
	;--- save data
	call	reset_hook
	call	get_program_path


	ld	hl,_DEFAULT_CFG
	ld	bc,9
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
	ld	hl,16
	call	write_file

	call	close_file
	call	set_hook
	
	ld	a,WIN_CFGSAV
	call	window
	jp	draw_configbox
	
	
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
	cp	19
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
	ld	a,18
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
	; check if we are on color options
	ld	a,(editsubmode)
	cp	7
	jp	c,0f
	cp	10
	jp	nc,0f

	;----- for input colors
	; number?
	ld	a,(key)
	cp	"0"
	jp	c,0f
	cp	"7"+1
	jp	nc,0f

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
	jp 	nc,99f
	inc 	h
99:
	;-- add the color we are editing
	ld	a,(editsubmode)
	sub	6
	add	a
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	ld	a,(cursor_input)
	ld	c,a
	inc	a
	cp	3
	jp	c,99f
	xor	a
99:	ld	(cursor_input),a
	ld	a,c
	and	a
	jp	z,_pkcb_ch
	
	; edit second byte of color?
	cp	2
	jp	nz,99f
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
	dw	pk_config_audition
	dw	pk_config_debug
	dw	pk_config_vu
	dw	pk_config_instruments
	dw	_pk_config_END
	dw	_pk_config_END
	dw	_pk_config_END

;====================================
; change keyboard
;====================================
pk_config_keyboard:
	ld	a,(key)
	cp	_KEY_RIGHT
	ld	a,(_CONFIG_KB)
	jp	nz,0f

	; -- Right
	inc	a
	cp	4
	jp	c,99f
	xor	a
99:	jp	88f
	
0:	;-- lEFT
	and 	a
	jp	z,99f
	dec	a
	jp	88f
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
	jp	nz,1f
	ld	a,1
	ld	(_CONFIG_VDP),a
	jp	99f
1:	; 60
	cp	1
	jr.	nz,update_configbox
	xor	a
	ld	(_CONFIG_VDP),a
	jp	99f	

_pcv_r:
	ld	a,(_CONFIG_VDP)
	cp	255
	jr.	z,update_configbox
	and	a
	jr.	nz,1f
	;-- 0
	inc	a
	ld	(_CONFIG_VDP),a
	jp	99f
1:	;---1
	ld	a,255
	ld	(_CONFIG_VDP),a
	ld	a,(_FOUND_VDP)

99:
	
	ld	b,2
	and	a
	jp	z,99f
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
	jp	z,0f
	ld	b,-1
0:
	ld	a,(_CONFIG_SPEED)
	add	a,b
	cp	64
	jp	c,99f
	ld	a,63
99:
	cp	2
	jp	nc,99f
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
	jp	z,0f
	ld	b,-1
0:
	ld	a,(_CONFIG_STEP)
	add	a,b
	cp	33
	jp	c,99f
	ld	a,32
99:
	cp	2
	jp	nc,99f
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
	jp	z,0f
	ld	b,-1
0:
	ld	a,(_CONFIG_ADD)
	add	a,b
	cp	17
	jp	nz,99f
	ld	a,16
99:
	cp	255
	jp	nz,99f
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
	jp	z,0f
	ld	a,(_CONFIG_THEME)
	inc	a
	cp	nr_of_themes
	jp	c,1f
	xor	a
	jp	1f
0:
	cp	_KEY_LEFT
	ret	z
	ld	a,(_CONFIG_THEME)
	dec	a
	cp	$ff
	jp	nz,1f
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
	jp	z,1f
	
	ld	a,$3f				; MMM
	jp	2f
1:	
	ld	a,$49				; Franky
ELSE
	cp	$a0
	jp	z,1f
	
	ld	a,$a0
	jp	2f
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
	jp	nz,0f
	
	ld	a,c
	inc	c
	cp	3
	jp	nz,pk_config_scc_END	
	inc	b
	jr.	pk_config_scc_END	


0:	
	cp	_KEY_LEFT
	jp	nz,update_configbox
	
	ld	a,c
	dec	c
	and	a
	jp	nz,pk_config_scc_END
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
	jp	nz,99f		;-- check if we are NOT back at found slot
	
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
; --- reset_cursor_psgsamplebox
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

