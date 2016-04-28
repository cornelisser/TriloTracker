VM_X	equ	14
VM_Y	equ	4



;===========================================================
; --- draw_voicemanager
;
; Display the voicemanager window.  Without actual values 
; 
;===========================================================
draw_voicemanager:

	;draw the window
	ld	hl,(80*VM_Y)+VM_X
	ld	de,(52*256) + 16+6
	call	draw_box
	;draw the pattern area
	ld	hl,(80*(VM_Y+3))+VM_X
	ld	de,(52*256) + 1
	call	draw_box
	
	ld	hl,VM_Y+(256*VM_X)
	ld	de,0x3416	
	call	draw_colorbox
;	;-- category area
;	ld	hl,VM_Y+4+(256*(VM_X+1))
;	ld	de,0x1611	
;	call	erase_colorbox	
	;-- voice area
	ld	hl,VM_Y+2+(256*(VM_X+1+24))
	ld	de,0x1a13	
	call	erase_colorbox		
	
	;--- draw title	
	ld	hl,(80*(VM_Y))+VM_X+16
	ld	de,_LABEL_VMANAGER
	call	draw_label	

	; draw all categories
	ld	hl,(80*(VM_Y+4))+VM_X+2
	ld	de,_LABEL_VCATEGORIES
	ld	a,16
_dvm_cat_loop: 
	push 	af
	push 	hl
	call	draw_label
	inc	de			; skip the 0
	pop	hl
	ld	bc,80
	add	hl,bc
	pop	af
	dec	a
	jp	nz,_dvm_cat_loop

	
	call	update_voicemanager	
	ret
	
_LABEL_VMANAGER:
	db	"[ FMvoice  Selection ]",0	
	


	

;===========================================================
; --- update_voicemanager_selection
;
; Display the voice manager slection. 
; 
;===========================================================
update_voicemanager_selection:

	ld	hl,VM_Y+4+ (256*((VM_X+26)))
	ld	de,0x1811	
	call	erase_colorbox
	ld	a,(vm_selection)
	add	VM_Y+4
	ld	l,a
	ld	h,(VM_X+26)
	ld	de,0x1801	
	call	draw_colorbox	

	ret


;===========================================================
; --- update_voicemanager
;
; Display the voice manager values. 
; 
;===========================================================
update_voicemanager:

	;; Decolor the current category
	ld	hl,VM_Y+4+ (256*((VM_X+1)))
	ld	de,0x1811	
	call	draw_colorbox
	ld	a,(editsubmode)
	add	VM_Y+4
	ld	l,a
	ld	h,(VM_X+1)
	ld	de,0x1801	
	call	erase_colorbox


	;== Erase cat name first
	ld	de,_LABEL_VEMPTY
	ld	hl,(80*(VM_Y+2))+VM_X+2+16+8
	call	draw_label		

	;-=== Show current category name
	ld	hl,_LABEL_VCATEGORIES_OFFSET
	ld	a,(editsubmode)
	ld	b,0
	ld	c,a
	add	hl,bc
	ld	a,(hl)
	ld	hl,_LABEL_VCATEGORIES
	ld	c,a
	add	hl,bc
	ex	de,hl
	ld	hl,(80*(VM_Y+2))+VM_X+2+16+8
	call	draw_label		
	
	;--- Show category voices.
	ld	a,(editsubmode)
	ld	hl,_category_voiceoffset
	ld	b,0
	ld	c,a
	add	hl,bc
	ld	b,(hl)		; start number
	inc	hl
	ld	c,(hl)		; start number of next category
	
	ld	hl,(80*(VM_Y+4))+VM_X+7+16+8
	ld	de,_LABEL_VOICENAME+2
	push	bc
	
	
_uvm_voice_loop:		
	push	bc
;	push	de
	push	hl
	ld	a,b
	call	get_voicename
	pop	hl
	push	hl
	ld	b,16
	call	draw_label_fast
	
	pop	hl
	ld	bc,80
	add	hl,bc
	ld	de,_LABEL_VOICENAME+2
	pop	bc
	inc	b
	ld	a,c
	cp	b
	jp	nz,_uvm_voice_loop

	pop	bc
	push	bc
	;--- draw the numbers
	ld	hl,(80*(VM_Y+4))+VM_X+2+16+8

_uvm_num_loop:
	push	bc
	push	hl
	ld	de,_VNUM
	ld	a,b
	call	draw_decimal_3
	
	pop	hl
	push	hl
	ld	de,_VNUM
	ld	b,4
	call	draw_label_fast
	pop	hl
	ld	bc,80
	add	hl,bc
	pop	bc
	inc	b
	ld	a,c
	cp	b
	jp	nz,_uvm_num_loop	
	
	pop	bc
	;--- erase the remaining lines
	ld	a,c
	sub	b
	ld	b,a
	ld	a,17
	sub	b
	jr.	z,0f	

_uvm_clear_loop:
	push	af
	push	hl
	ld	de,_LABEL_VEMPTY
	call	draw_label
	pop	hl
	ld	bc,80
	add	hl,bc
	pop	af
	dec	a
	jp	nz,_uvm_clear_loop
		
	
0:	
	call	update_voicemanager_selection


	ret
	

	
_LABEL_VCATEGORIES_OFFSET:
	db	_VC1-_LABEL_VCATEGORIES
	db	_VC2-_LABEL_VCATEGORIES
	db	_VC3-_LABEL_VCATEGORIES
	db	_VC4-_LABEL_VCATEGORIES
	db	_VC5-_LABEL_VCATEGORIES
	db	_VC6-_LABEL_VCATEGORIES
	db	_VC7-_LABEL_VCATEGORIES
	db	_VC8-_LABEL_VCATEGORIES
	db	_VC9-_LABEL_VCATEGORIES
	db	_VC10-_LABEL_VCATEGORIES
	db	_VC11-_LABEL_VCATEGORIES
	db	_VC12-_LABEL_VCATEGORIES
	db	_VC13-_LABEL_VCATEGORIES
	db	_VC14-_LABEL_VCATEGORIES
	db	_VC15-_LABEL_VCATEGORIES
	db	_VC16-_LABEL_VCATEGORIES
;	db	_VC17-_LABEL_VCATEGORIES
			
_category_voiceoffset:
	db	0		;- Cat 1 start at 0				
	db	16		;- Cat 2 start at 16
cat1_start	equ	16	
	db	31
	db	47
	db	53
	db	66
	db	82
	db	92
	db	105
	db	111
	db	118
	db	128
	db	139
	db	145
	db	161
	db	177
	db	193
;	db	208		; this can go if we drop the CRAP category
last_voice	equ	193-1

			
_LABEL_VCATEGORIES:
_VC1:		db	"Hardware Voices",0
_VC2:		db	"Keys",0
_VC3:		db	"Chromatic Percussion",0
_VC4:		db	"Organ",0
_VC5:		db	"Guitar",0
_VC6:		db	"Bass",0
_VC7:		db	"Strings",0
_VC8:		db	"Brass",0
_VC9:		db	"Reed",0
_VC10:	db	"Pipe",0
_VC11:	db	"Synth Lead",0
_VC12:	db	"Synth Pad",0
_VC13:	db	"Ethnic",0
_VC14:	db	"Percussive",0
_VC15:	db	"Other",0
_VC16:	db	"Custom Voices",0
;_VC17:	db	"Crap!",0
;===========================================================
; --- init_voicemanager
;
; initialise the voice manager window
; 
;===========================================================	
init_voicemanager:
	ld	a,(editmode)
	cp	7
	ret	z

;	call	save_cursor

	; --- init mode
	ld	a,7
	ld	(editmode),a
;	ld	a,0				; category
;	ld	(editsubmode),a	

	;--- get current instrument
	call	set_songpage
	ld	a,(instrument_waveform)
	ld	(vm_voice),a
	
	call	translate_voice_to_selection

	call	set_cursor_voicemanager
	

	; --- show the screen
	call	draw_voicemanager
;	call	update_voicemanager
	
	ret	
	
	
;===========================================================
; --- processkey_voicemanager
; Specific controls 
; 
;===========================================================	
processkey_voicemanager:
	call	set_songpage
	
	ld	a,(key)
	and	a
	ret	z

	cp	_ESC
	jr.	nz,0f

22:	;call	update_psgsampleeditor
	;jr.	restore_instrumenteditor
	jr. restore_psgsampleeditor

0:		
	cp	_SPACE
	jr.	nz,0f
		ld	a,(keyjazz)
		xor 	1
		ld	(keyjazz),a
		jr.	set_textcolor		

0:
	cp	_ENTER
	jp	nz,0f
	
	ld	a,(song_cur_instrument)
	ld	hl,instrument_macros+2
	ld	de,$83
;	ld	a,(vm_voice)
	and	a
	jp	z,99f

55:	add	hl,de
	dec	a
	jp	nz,55b
99:	
	ld	a,(vm_voice)
	ld	(hl),a
	ld	(instrument_waveform),a
	
	jr.	22b


0:
	;--- next category
	cp	_KEY_RIGHT
	jr.	nz,0f
		
	ld	a,(editsubmode)
	cp	15	;(max cat nr)
	jr.	nc,processkey_voicemanager_END
	
	ld	hl,_category_voiceoffset
	inc	a
	ld	c,a
	ld	b,0
	add	hl,bc

	ld	b,(hl)		; get the start voice # in this cat
	inc	hl
	ld	c,(hl)		; get the start voice# of the next cat
	ld	a,(vm_selection)
	add	b			; get new voice# at same selection pos.
	cp	c
	jp	c,44f
	ld	a,c
	dec	a
	jp	44f

0:
	;--- next pattern
	cp	_KEY_LEFT
	jr.	nz,0f
		
	ld	a,(editsubmode)
	and	a
	jr.	z,processkey_voicemanager_END
	
	ld	hl,_category_voiceoffset
	dec	a
	ld	c,a
	ld	b,0
	add	hl,bc

	ld	b,(hl)		; get the start voice # in this cat
	inc	hl
	ld	c,(hl)		; get the start voice# of the next cat
	ld	a,(vm_selection)
	add	b			; get new voice# at same selection pos.
	cp	c
	jp	c,44f
	ld	a,c
	dec	a
44:
	ld	(vm_voice),a
	call	translate_voice_to_selection
	jr.	update_voicemanager;_selection

0:
	;--- next voice
	cp	_KEY_UP
	jr.	nz,0f
		
	ld	a,(vm_voice)
	and	a
	jr.	z,processkey_voicemanager_END
	dec	a
	ld	(vm_voice),a
	call	translate_voice_to_selection
	jr.	update_voicemanager;_selection

0:
	;--- next pattern
	cp	_KEY_DOWN
	jr.	nz,0f
		
	ld	a,(vm_voice)
	cp	last_voice
	jr.	nc,processkey_voicemanager_END
	inc	a
	ld	(vm_voice),a
	call	translate_voice_to_selection
	jr.	update_voicemanager;_selection

0:	
0:
	
	;--- Special numkey check for setting octave.
;	call	read_numkeys
	ld	a,(key_value)
	 
	cp	0x4b
	jr.	c,0f
	cp	0x55
	jr.	nc,0f
		
	;--- set octave
	sub	0x4b
	ld	(song_octave),a
	call	update_voicemanager
	jr.	process_key_patternbox_octave_END
		
	

0:




















;	ld	a,(keyjazz)
;	and	a
;	jr.	z,processkey_voicemanager_END
	
	ld	a,(song_cur_instrument)
	ld	hl,instrument_macros+2
	ld	de,$83
	and	a
	jp	z,99f

55:	add	hl,de
	dec	a
	jp	nz,55b
99:	
	ld	a,(vm_voice)
	ld	b,(hl)
	ld	(hl),a
	push	bc
	push	hl
	
	call	process_key_keyjazz
	
	call	set_songpage
	pop	hl
	pop	bc
	ld	(hl),b

	
	
processkey_voicemanager_END:
	ret
	




;===========================================================
; --- processkey_voicemanager_ctrl
; Specific controls 
; 
;===========================================================	
processkey_voicemanager_ctrl:	
;	ld	a,(key)
;
;
;	;-- set clipboard
;	cp	_CTRL_C
;	jr.	nz,0f
;
;	ld	bc,(VM_dst_start)
;	;--- swap if needed
;	ld	a,b
;	cp	c
;	jr.	nc,99f
;	push	af
;	ld	a,c
;	ld	b,a
;	pop	af
;	ld	c,a
;99:	
;	
;	ld	(VM_src_start),bc	
;	ld	a,(VM_dst_chan)
;	ld	(VM_src_chan),a
;	ld	a,3
;	ld	(VM_status),a
;	call	update_voicemanager
;
;0:	;-- paste selection
;	cp	_CTRL_V
;	jr.	nz,0f
;	
;	;-- check if there is data to paste
;	ld	a,(VM_status)
;	and	2
;	ret	z
;	
;	call	VM_paste
;	
;
;	ret
;	
;0:	;--- swap selection
;	cp	_CTRL_S
;	jr.	nz,0f
;
;	;-- check if there is data to swap.
;	ld	a,(VM_status)
;	and	2
;	ret	z
;
;	call	VM_swap
;	
;	ret
;
;0:
;	cp	_KEY_LEFT
;	jr.	nz,0f
;
;	ld	a,(VM_dst_chan)
;	and	a
;	jr.	z,_processkey_voicemanager_chans_end
;	dec	a
;	ld	(VM_dst_chan),a
;	jr.	update_voicemanager
;
;0:	
;	cp	_KEY_RIGHT
;	jr.	nz,0f
;
;	ld	a,(VM_dst_chan)
;	cp	7
;	jr.	z,_processkey_voicemanager_chans_end
;	inc	a
;	ld	(VM_dst_chan),a
;	jr.	update_voicemanager
;
;0:	
_processkey_voicemanager_chans_end:
	ret	
	
;===========================================================
; --- set_cursor_trachmanager
; Translate thecurrent pattern to a cursor pos.
; 
;===========================================================	
set_cursor_voicemanager:	
	call	flush_cursor

	ld	a,(vm_selection)
	add	VM_Y+4
	ld	(cursor_y),a
	ld	a,TM_X+28+7
	ld	(cursor_x),a
	ld	a,3
	ld	(cursor_type),a
	ret

; translates current instrument to the selection position
translate_voice_to_selection:
	ld	a,(vm_voice)
	ld	b,a		; voice #
	ld	c,-1		; cat#
	
	;--- calculate the category if the voice
	ld	hl,_category_voiceoffset
0:	
	inc	hl
	ld	a,(hl)
	dec	a
	inc	c
	cp	b	
	jp	c,0b
	
	;--- Store the category
	ld	a,c
	ld	(editsubmode),a
	
	;--- Store the selection offset in the category
	dec	hl
	ld	c,(hl)
	ld	a,b
	sub	c
	ld	(vm_selection),a
	
	call set_cursor_voicemanager
	ret
