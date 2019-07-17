

_IMP_chan_man_labels:		; channel 'names'
	db	0,0,0,0,0,0,0,0
_IMP_chan_man_order:
	db	0,0,0,0,0,0,0,0	; the channel order

_IMP_LABEL_title:
	db	"[ CHANNEL MANAGER ]"	
_IMP_LABEL_channels:
	db	"[ x - x - x - x - x - x - x - x ]"
_IMP_LABEL_text0:
	db	"[ch1-ch2-ch3-ch4-ch5-ch6-ch7-ch8]"
_IMP_LABEL_text1:
	db	"Change the channel order below",0
_IMP_LABEL_text2:
	db	"using the cursor keys. Confirm with",0
_IMP_LABEL_text3:
	db	"[ENTER] or cancel using [ESC].",0	
;===========================================================
; --- channel_manager
;
; relocate channel data.
; input:	[HL] contains the address of the channel names
;
;===========================================================	
channel_manager:
	ld	de,_IMP_chan_man_labels
	ld	bc,8
	ldir

;	;--- determin labels using a
;	dec	a
;	jr.	z,_cm_init_xm
;	dec	a
;	jr.	z,_cm_init_mbm
;
;_cm_init_normal:
;_cm_init_xm:
;	ld	a,49
;	ld	hl,_IMP_chan_man_labels
;	ld	b,8
;88:
;	ld	(hl),a
;	inc	a
;	inc	hl
;	djnz	88b
;	
;	jr.	_cm_dialog
;
;_cm_init_mbm:
;	ld	a,49
;	ld	hl,_IMP_chan_man_labels
;	ld	(hl),"D"
;	ld	b,6
;	inc	hl
;88:	
;	ld	(hl),a
;	inc	a
;	inc	hl
;	djnz	88b
;	
;	ld	(hl),"X"
;	
	;--- now display the manager dialog.
;_cm_dialog:
	;--- init the channels
	xor	a
	ld	b,8
	ld	hl,_IMP_chan_man_order
99:
	ld	(hl),a
	inc	hl
	inc	a
	djnz	99b

	ld	hl,8*80+20
	ld	de,(256*39)+(10)
	call	draw_box

	ld	hl,(20*256)+(8)
	ld	de,(256*39)+(10)
	call	draw_colorbox

	ld	hl,(23*256)+(15)
	ld	de,(256*33)+(1)
	call	erase_colorbox


	ld	hl,8*80+30
	ld	de,_IMP_LABEL_title
	ld	b,19
	call	draw_label_fast		

;	ld	hl,13*80+24
;	ld	de,_IMP_LABEL_channels
;	ld	b,33
;	call	draw_label_fast		

	ld	hl,14*80+23
	ld	de,_IMP_LABEL_text0
	ld	b,33
	call	draw_label_fast		

	ld	hl,10*80+22
	ld	de,_IMP_LABEL_text1
	call	draw_label
	ld	hl,11*80+22
	ld	de,_IMP_LABEL_text2
	call	draw_label
	ld	hl,12*80+22
	ld	de,_IMP_LABEL_text3
	call	draw_label

	call	reset_cursor_channel_manager

_cm_display_loop:
	;--- but first set the channel labels
	ld	a,8
	ld	bc,_IMP_chan_man_order
	ld	de,_IMP_LABEL_channels+2
0:	ld	hl,_IMP_chan_man_labels
	ex	af,af'	;'
	ld	a,(bc)
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	ld	(de),a
	inc	de
	inc	de
	inc	de
	inc	de
	inc	bc
	ex	af,af'	;'
	dec	a
	jr.	nz,0b
			
	ld	hl,15*80+23
	ld	de,_IMP_LABEL_channels
	ld	b,33
	call	draw_label_fast		

_cm_input_loop:
	halt
	call	show_cursor
	call	read_key
	
	ld	a,(key)	

	;--- Escape do nothing
	cp	_ESC
	ret	z
	
	;--- Apply the changes?
	cp	_ENTER
	jr.	z,channel_manager_process
	
	
	;--- move cursor 1 channel right
	cp	_KEY_RIGHT
	jr.	nz,0f
	
		ld	a,(cursor_x)
		cp	24+25
		jr.	nc,_cm_input_loop
		
		add	4
		call	flush_cursor
		ld	(cursor_x),a
		jr.	_cm_input_loop
	
0:
	;--- move cursor 1 channel left
	cp	_KEY_LEFT
	jr.	nz,0f
	
		ld	a,(cursor_x)
		cp	25
		jr.	c,_cm_input_loop
		
	
		sub	4
		call	flush_cursor
		ld	(cursor_x),a
		jr.	_cm_input_loop
		
0:
	;--- change value up
	cp	_KEY_UP
	jr.	nz,0f
	
		ld	a,(cursor_x)
		sub	24
		sra	a
		sra	a
		ld	hl,_IMP_chan_man_order
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
		ld	a,(hl)
		inc	a
		and	$07
		ld	(hl),a
		jr.	_cm_display_loop
		
0:
	;--- change value up
	cp	_KEY_DOWN
	jr.	nz,0f
	
		ld	a,(cursor_x)
		sub	24
		sra	a
		sra	a
		ld	hl,_IMP_chan_man_order
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
		ld	a,(hl)
		dec	a
		and	$07
		ld	(hl),a
		jr.	_cm_display_loop
		
0:


	jr.	_cm_input_loop




;===========================================================
; --- channel_manager_process
;
; relocate channel data.
;===========================================================	
channel_manager_process:
	ld	a,(max_pattern)
	ld	ixh,a
;	ld	ixh,SONG_MAXPAT
	
_cmp_loop:
	ld	b,ixh
	dec	b
	call	set_patternpage
	ld	ixl,64
	
_cmp_lineloop:
	ld	iyh,8
	push	hl		
	;--- get the line
	ld	bc,32
	ld	de,buffer+100
	ldir
	
	pop	hl
	ld	bc,_IMP_chan_man_order

_cmp_chanloop:
	;--- now reinsert the data in the new order. 

	ld	de,buffer+100
	ld	a,(bc)		; get the chan# to read
	inc	bc
	add	a			; x4
	add	a
	add	a,e
	ld	e,a
	jr.	nc,99f
	inc	d
99:
	ld	iyl,4
_cmp_byteloop:
	ld	a,(de)		; get byte
	ld	(hl),a
	inc	de
	inc	hl	
	dec	iyl
	jr.	nz,_cmp_byteloop

	dec	iyh
	jr.	nz,_cmp_chanloop
	
	dec	ixl
	jr.	nz,_cmp_lineloop
	
	dec	ixh
	jr.	nz,_cmp_loop

	ret
	










;===========================================================
; --- reset_cursor_channel_manager
;
; Reset the cursor to the top left of the channel_manager.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_channel_manager:
	call	flush_cursor
	ld	a,15
	ld	(cursor_y),a
	ld	a,3
	ld	(cursor_type),a		
	ld	a,24
	ld	(cursor_x),a
	ret
