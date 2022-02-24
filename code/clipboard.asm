
; =========================================================	
; --- copy_to_buffer
; 
; Copies the current selection to the buffer. 
; If there is no selection then nothing is
; placed in the buffer.
; ==========================================================	
copy_to_buffer:
	call	set_songpage

	ld	a,(selection_status)
	and	a
	ret	z

	ld	a,1
	ld	(clipb_status),a
	;---Set the source pattern
	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage

	;--- Switch X1 and X2 if needed
	ld	a,(selection_x2)
	ld	b,a
	ld	a,(selection_x1)
	cp	b
	jr.	c,_ctb_no_Xswap
	
	; swap X1 and X2
	ld	a,(selection_type2)	; load X2 vals
	ld	c,a
	ld	a,(selection_column2)
	ld	d,a
	
	ld	a,(selection_x1)		; write X1 vals in X2
	ld	(selection_x2),a
	ld	a,(selection_type1)
	ld	(selection_type2),a
	ld	a,(selection_column1)
	ld	(selection_column2),a
	
	ld	a,b				; write X2 vals into X1
	ld	(selection_x1),a
	ld	a,c
	ld	(selection_type1),a
	ld	a,d
	ld	(selection_column1),a	

_ctb_no_Xswap:
	;--- switch Y1 and Y2 if needed
	ld	a,(selection_y2)
	ld	b,a
	ld	a,(selection_y1)
	cp	b
	jr.	c,_ctb_no_Yswap

	ld	(selection_y2),a		; swap Y values
	ld	a,b
	ld	(selection_y1),a	

_ctb_no_Yswap:

	;--- Get the source address of the selection
	ld	a,(selection_x1)
	ld	b,a
	ld	a,(selection_column1)
	ld	c,a
	ld	a,(selection_y1)
	call	get_chanrecord_location_ctb
	ld	(clipb_src_address),hl

	
	;--- Get the # bytes to copy
	ld	a,(selection_x2)
	ld	b,a
	ld	a,(selection_column2)
	ld	c,a
	ld	a,(selection_y1)
	call	get_chanrecord_location_ctb
	ld	de,(clipb_src_address)
	inc	hl
	xor	a		; remove carry flag
	sbc	hl,de
	ld	a,l		; this should contain the number of bytes to copy
	ld	(clipb_bytes),a
	
	;--- Get the # rows to copy
	ld	a,(selection_y1)
	ld	b,a
	ld	a,(selection_y2)
	sub	b
	inc	a
	ld	(clipb_rows),a 
	
	;--- Get the start and ending column input type (needed for combined bytes)
	ld	a,(selection_column1)
	ld	(clipb_column_start),a
	ld	a,(selection_column2)
	ld	(clipb_column_end),a

	;--- Now copy the data into the clipboard
	ld	hl,(clipb_src_address)
	ld	de,pat_buffer
	ld	a,(clipb_rows)
	ld	c,a
_ctb_row_loop:
		ld	a,(clipb_bytes)
		ld	b,a
	
		push	hl
_ctb_byte_loop:
			ld	a,(hl)
			ld	(de),a
			inc	hl
			inc	de
			djnz	_ctb_byte_loop

		; set the next row
		pop	hl
		ld	a,SONG_PATLNSIZE
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
	
		; still need to copy?
		dec	c
		jr.	nz,_ctb_row_loop

;	ld	a,(current_song)
	call	set_songpage

	ret


; ==========================================================	
; --- clear_clipboard
; 
; Clears the clipboard; 
; ==========================================================	
clear_clipboard:
	xor	a
	ld	(clipb_status),a
	ret

; ==========================================================	
; --- erase_clipboard
; 
; Erased the current selection area; 
; ==========================================================	
erase_selection:

	;---Set the source pattern
	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage
	call	init_log_block		; make local copy of pattern

	;--- Switch X1 and X2 if needed
	ld	a,(selection_x2)
	ld	b,a
	ld	a,(selection_x1)
	cp	b
	jr.	c,_es_no_Xswap
	
	; swap X1 and X2
	ld	a,(selection_type2)	; load X2 vals
	ld	c,a
	ld	a,(selection_column2)
	ld	d,a
	
	ld	a,(selection_x1)		; write X1 vals in X2
	ld	(selection_x2),a
	ld	a,(selection_type1)
	ld	(selection_type2),a
	ld	a,(selection_column1)
	ld	(selection_column2),a
	
	ld	a,b				; write X2 vals into X1
	ld	(selection_x1),a
	ld	a,c
	ld	(selection_type1),a
	ld	a,d
	ld	(selection_column1),a	

_es_no_Xswap:
	;--- switch Y1 and Y2 if needed
	ld	a,(selection_y2)
	ld	b,a
	ld	a,(selection_y1)
	cp	b
	jr.	c,_es_no_Yswap

	ld	(selection_y2),a		; swap Y values
	ld	a,b
	ld	(selection_y1),a	

_es_no_Yswap:

	;--- Get the source address of the selection
	ld	a,(selection_x1)
	ld	b,a
	ld	a,(selection_column1)
	ld	c,a
	ld	a,(selection_y1)
	call	get_chanrecord_location_ctb
	ld	(clipb_clr_address),hl
	push	hl
	
	;--- PLACE  UNDO/READO logging here
	
	
	
	;--- Get the # bytes to copy
	ld	a,(selection_x2)
	ld	b,a
	ld	a,(selection_column2)
	ld	c,a
	ld	a,(selection_y1)
	call	get_chanrecord_location_ctb
	pop	de
	inc	hl
	xor	a		; remove carry flag
	sbc	hl,de
	ld	a,l		; this should contain the number of bytes to copy
;	ld	b,a
	ld	d,a		; [D] contains bytes
	
	;--- Get the # rows to copy
	ld	a,(selection_y1)
	ld	b,a
	ld	a,(selection_y2)
	sub	b
	inc	a
	ld	c,a		; [C] contains rows
	
	;--- Now erase the data in the pattern
	ld	hl,(clipb_clr_address)
_es_row_loop:
		ld	a,d
		ld	b,a
	
		push	hl
		
		;--- single value?
		cp	1
		jr.	nz,_es_byte_loop
		call	_es_erase_single_value
		jr.	99f
		
		
_es_byte_loop:
		call _es_erase_value
		djnz	_es_byte_loop	


99:		; set the next row
		pop	hl
		ld	a,SONG_PATLNSIZE
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
	
		; still need to copy?
		dec	c
		jr.	nz,_es_row_loop

;	ld	a,(current_song)
	call	set_songpage

	call	store_log_block


	ret




_es_erase_value:
	push	bc
	
	;---Test if we are at the start/middle/end of a row
	ld	a,b
	cp	d
	jr.	z,_essv_start	; copying first byte
	cp	1
	jr.	z,_essv_ending		; copying last byte
	jr.	_essv_byte		; copy in the middle
	
_essv_start:
	ld	a,(selection_column1)
	cp	3		; cmd
	jr.	z,_essv_low
	cp	5		; par y
	jr.	z,_essv_low
	jr.	_essv_byte	; all others

_essv_ending:
	ld	a,(selection_column2)
	cp	2		; volume
	jr.	z,_essv_high
	cp	4		; par y
	jr.	z,_essv_high
	jr.	_essv_byte	; all others
	
	
_es_erase_single_value:
	push	bc	
	
	ld	a,(selection_column1)
	cp	2
	jr.	c,_essv_byte	; 0 and instr. are full bytes
	jr.	z,_essv_high	; 1 volume
	cp	3			; cmd
	jr.	z,_essv_low
	cp	4			
	jr.	z,_essv_high	; par x
	jr.	_essv_high		; par y
	
	
_essv_low:
	ld	a,(hl)
	and	0xf0
	ld	(hl),a
	jr.	_essv_end
		
_essv_high:
	ld	a,(hl)
	and	0x0f
	ld	(hl),a
	jr.	_essv_end
	
_essv_byte:
	ld	(hl),0
	jr.	_essv_end
	
_essv_end:
	pop	bc
	inc	hl
	ret	
; ==========================================================	
; --- copy_to_pattern
; 
; Copies the current clipboard selection to the current 
; position in the current pattern. 
; 
; ==========================================================	
copy_to_pattern:
	;--- Is there data on the clipboard?
	ld	a,(clipb_status)
	and	a
	ret	z
	
;	ld	a,(current_song)
	call	set_songpage	
	
	
	
	;--- Does the destination input type match?
	ld	a,(cursor_input)
	ld	b,a
	ld	a,(clipb_column_start)
	cp	b
	ret	nz

;	ld	a,(song_pattern)
;	ld	b,a
;	call	set_patternpage

	
	;--- get the destination address
	
;	- a = Y pos
;	- b = X pos
;	- c = input column	
	
	ld	a,(cursor_input)
	ld	c,a
	ld	a,(cursor_x)
	ld	b,a
	ld	a,(cursor_y)
	ld	e,a
	ld	a,(song_pattern_offset)
	add	e
	
	call	get_chanrecord_location_ctb
	call	init_log_block		; make local copy of pattern
;	and	a
;	jr.	z,88f		;--- it was a note
;	inc	hl
;	cp	1
;	jr.	z,88f		;--- it was an instrument
;	inc	hl
;	cp	4		;--- it was a volume or cmd
;	jr.	c,88f
;	inc	hl		;--- it was a parameter (x or y)
;88:
	ld	(clipb_dst_address),hl
	
	;--- PLACE UNDO/REDO logging here


	;--- Copy the data to the pattern
	ld	de,(clipb_dst_address)	; destination
	ld	hl,pat_buffer		; source
	ld	a,(clipb_rows)
	ld	c,a				; store # rows in c
_ctp_row_loop:
		push	de
		ld	a,(clipb_column_start)
		ld	iyl,a			; store input type for transparent copy
		ld	a,(clipb_bytes)
		ld	b,a			; store the # of bytes to copy

		;--- single  value?
		cp	1
		jr.	nz,_ctp_byte_loop
		call	_ctp_store_single_value
		call	_ctp_pattern_end
		jr.	55f
		
_ctp_byte_loop:
		call	_ctp_store_value
		call	_ctp_next_inputtype	; Set the next type to copy
		call	_ctp_pattern_end
		djnz	_ctp_byte_loop

55:
		pop	de
		ld	a,SONG_PATLNSIZE
		add	a,e
		ld	e,a
		jr.	nc,99f
		inc	d
		;-- check if we crossed pattern
		ld	a,d	
		and	0x07		; check if low 3 bits are 0
		jr.	nz,99f
		ld	a,e
		cp	SONG_PATLNSIZE	; check if e < linesize
		jr.	nc,99f
		ld	bc,$0101
99:
		dec	c
		jr.	nz,_ctp_row_loop
		
;	ld	a,(current_song)
	call	set_songpage		
	
	call	store_log_block
		
	ret	
	
	
_ctp_next_inputtype:
	ld	a,iyl
	inc	a
	cp	3		; command is already copied -> set 4 Xy
	jr.	nz,99f
	inc	a
	jr.	0f
99:
	cp	5		; y is already copied -> set 0 note
	jr.	nz,99f
	inc	a
	jr.	0f
99:

0:	ld	iyl,a
	ret
	
	
	
	
	
;----------------
; _ctp_pattern_end
; sets b and c to 0 if the end of pattern is reached.
; end is when last 11 bits are 0 
;----------------
_ctp_pattern_end:
	ld	a,e
	and	a
	ret	nz
	ld	a,d
	and	$07
	ret	nz
	ld	bc,$0101	; bytes to copy + rows
	
	ret
	
	
;-----------------------
; Stores a value
; 
; Input: 	HL = source
; 		DE = destination
;		B = number of bytes to copy
;		IYH = input type
;
; Output:	HL++
;		DE++
;-----------------------
_ctp_store_value:
	push	bc

	;--- Test if we are at the start/middle/end of a row
	ld	a,(clipb_bytes)
	cp	b			; copying first byte
	jr.	z,_ctpsv_start
	ld	a,b
	cp	1			; copying last byte
	jr.	z,_ctpsv_end	
	jr.	_ctpssv_byte	; copying in the middle
	
_ctpsv_start:
	ld	a,(clipb_column_start)
	cp	3			; cmd
	jr.	z,_ctpssv_low
	cp	5			; par x
	jr.	z,_ctpssv_low	
	jr.	_ctpssv_byte	; all others

_ctpsv_end:
	ld	a,(clipb_column_end)
	cp	2			; volume
	jr.	z,_ctpssv_high
	cp	4			; par y
	jr.	z,_ctpssv_high	
	jr.	_ctpssv_byte	; all others
	
	
	
	
;-----------------------
; Stores a single value
; 
; Input: 	HL = source
; 		DE = destination
;
; Output:	HL++
;		DE++
;-----------------------
_ctp_store_single_value:
	push	bc

	ld	a,(clipb_column_start)
	ld	iyl,a		; used by _ctpssv_byte
	cp	2			
	jr.	c,_ctpssv_byte	; 0 (note) and 1(instr) are full bytes
	jr.	z,_ctpssv_high	; 1 (volume) 	
	cp	3
	jr.	z,_ctpssv_low	; 2 (command)
	cp	4
	jr.	z,_ctpssv_high	; 3 (parameter x)
					; 4 (parameter y) otherwise	

_ctpssv_low:
	ld	a,(copy_transparent)
	and	a
	jr.	z,0f	
;	ld	a,(de)		; don't overwrite destination 	
;	and	$f0
	ld	a,(hl)		; don't overwrite with empty		
	and	$0f
;	jr.	nz,_ctpssv_end	; don't overwrite destination
	jr.	z,_ctpssv_end	; ; don't overwrite with empty
0:	
	ld	a,(hl)
	and	0x0f			; keep only the x value
	ld	b,a
	ld	a,(de)
	and	0xf0			; erase the x value
	or	b			; add the x value
	ld	(de),a
	jr.	_ctpssv_end

_ctpssv_high:
	ld	a,(copy_transparent)
	and	a
	jr.	z,0f	
;	ld	a,(de)		; don't overwrite destination 
;	and	$0f
	ld	a,(hl)		; don't overwrite with empty	
	and	$f0
;	jr.	nz,_ctpssv_end	; don't overwrite destination
	jr.	z,_ctpssv_end	; ; don't overwrite with empty
0:
	ld	a,(hl)
	and	0xf0			; keep only the y value
	ld	b,a
	ld	a,(de)
	and	0x0f			; erase the y value
	or	b			; add the y value
	ld	(de),a
	jr.	_ctpssv_end

_ctpssv_byte:
	ld	a,(copy_transparent)
	and	a
	jr.	z,0f	
	ld	a,iyl
	cp	2
	jr.	z,_ctpssv_hilo
	
;	ld	a,(de)		; don't overwrite destination 
	ld	a,(hl)		; don't overwrite with empty	
	and	a
;	jr.	nz,_ctpssv_end	; don't overwrite destination
	jr.	z,_ctpssv_end	; ; don't overwrite with empty
0:
	ld	a,(hl)
	ld	(de),a
	jr.	_ctpssv_end

;-- transparent copy volume and effect 
_ctpssv_hilo:
	ld	a,(hl)
	and	0xf0	
	jr.	z,1f	; is there a value
	ld	b,a
	ld	a,(de)
	and	0x0f
	or	b
	ld	(de),a
1:
	ld	a,(hl)
	and	0x0f	
	jr.	z,1f	; is there a value
	ld	b,a
	ld	a,(de)
	and	0xf0
	or	b
	ld	(de),a
1:
	; continue below
_ctpssv_end
	pop	bc
	inc	hl
	inc	de
	ret


;============================================================
; --- selection_to_bottom
;
; Selects all date below current selection_show
;
;============================================================
selection_to_bottom:
	;--- Start new selection?
	ld	a,(selection_status)
	and	a
	jr.	nz,.extend
	
	;--- Init the new selection
	ld	a,1
	ld	(selection_status),a
	
	;--- Set the x2 and y2 of the selection window
.new:
	ld	a,(song_pattern_offset)
	ld	b,a
	ld	a,(cursor_x)
	ld	(selection_x1),a	
	ld	(selection_x2),a
	ld	a,(cursor_y)
	add	b
	ld	(selection_y1),a	
	ld	(selection_y2),a	
	ld	a,(cursor_type)
	dec	a
	ld	(selection_type1),a	
	ld	(selection_type2),a
	ld	a,(cursor_input)
	ld	(selection_column1),a
	ld	(selection_column2),a
.extend:	
	ld	a,73
	ld	(selection_y1),a
	ret






; ==========================================================	
; --- selection_process
; 
; Processes the input cursor into a selection area 
;
; ==========================================================	
selection_process:

	;--- Check if shift is pressed
	ld	a,(skey)
	cp	1	
	jr.	nz,reset_selection
	
	;--- Start new selection?
	ld	a,(selection_status)
	and	a
	jr.	nz,_sp_setselection_xy2
	
	;--- Init the new selection
	ld	a,1
	ld	(selection_status),a
	
	;--- Set the x2 and y2 of the selection window
_sp_setselection_xy2	
	ld	a,(song_pattern_offset)
	ld	b,a
	ld	a,(cursor_x)
	ld	(selection_x2),a
	ld	a,(cursor_y)
	add	b
	ld	(selection_y2),a	
	ld	a,(cursor_type)
	dec	a
	ld	(selection_type2),a
	ld	a,(cursor_input)
	ld	(selection_column2),a
	ret

reset_selection:
	ld	a,(song_pattern_offset)
	ld	b,a
	ld	a,(cursor_x)
	ld	(selection_x1),a
	ld	a,(cursor_y)
	add	b
	ld	(selection_y1),a
	ld	a,(cursor_type)
	dec	a
	ld	(selection_type1),a
	
	ld	a,(cursor_input)
	ld	(selection_column1),a	
	xor	a
	ld	(selection_status),a
	ret

; ==========================================================	
; --- selection_show
; 
; Shows	the selection in the screen. 
;
; ==========================================================	
selection_show:

	; --- erase_colorbox
	; 
	; Draw box 
	; H = x pos
	; L = y pos
	; D = width
	; E = height

	ld	hl,0x020a
	ld	de,0x4c10
	call	erase_colorbox

	; is there a selection to draw?
	ld	a,(selection_status)
	and	a
	ret	z

	ld 	hl,(selection_y1)	; l= y1 h= x1


	
	;--- set the X window
	ld 	a,(selection_x2)
	cp	h
	jr.	nc,99f

	;--- X1 >= X2
	ld	h,a
	ld	a,(selection_type1)
	ld	b,a	
	ld 	a,(selection_x1)
	jr.	88f
99:	
	;--- X1 < X2
	ld	a,(selection_type2)
	ld	b,a		
	ld 	a,(selection_x2)
88:
	sub	h
	add	b
	ld	d,a

	;--- set the Y window
	ld	a,(selection_y2)
	cp	l
	jr.	nc,99f

	;--- Y1 >= Y2
	ld	l,a
	ld	a,(selection_y1)
99:	
	;--- Y1 < Y2
	sub	l
	ld	e,a	
	
	inc	d
	inc	e

	;--- calculate the offset 
	ld	a,(song_pattern_offset)
	ld	b,a
	
	cp	-8
	jr.	nc,99f
	
	ld	a,l
	sub	10
	cp	b
	
	jr.	nc,99f		;- JMP if the start line is in visible area
	
	;--- Top is outside visible area
	sub	b
	add	e
	ld	e,a
	ld	l,0x0a
	jr.	88f
99:	
	ld	a,l
	sub	b
	ld	l,a
88:	
	call	draw_colorbox
	
	ret
	
	

;===========================================================
; --- get_chanrecord_location_ctb
;
; Returns the location of the start of the chanrecord of the
; selection in RAM (hl). Starting at the column input type
; 
; input:
;	- a = Y pos
;	- b = X pos
;	- c = input column
; The function swaps pattern data in.
;===========================================================
get_chanrecord_location_ctb:
	push	bc		; save the input column

	sub	10	; pattern start at
	ld	hl,0	
	and	a
	jr.	z,0f
	ld	de,SONG_PATLNSIZE

	;--- Set patternline offset
_gcll_ctb_loop:
	add	hl,de
	dec	a	
	jr.	nz,_gcll_ctb_loop
0:
	;--- Get channel number
	ld	a,b
	sub	4 		; first chan starts at 4

	dec	hl
	dec	hl
	dec	hl
	dec	hl
	dec	hl		; only go 3 pos back as first 2 are not chan record.
	ld	bc,4
	
99:	;--- Calculate the channel
	add	hl,bc
	sub	9		; each channel is 9 chars wide
	jp	p,99b

	;--- Set HL to the patten data
	ex	de,hl
	call	set_songpage_safe
	ld	a,(song_pattern)
	ld	b,a
	push	de
	call	set_patternpage
	pop	de
	inc	hl		;dirst pos is the pat length
	add	hl,de
	
	;--- add the column offset
	pop	bc
	ld	a,c
	
	and	a		; is it a note?
	jr.	z,gcrlc_end	
	
	inc	hl
	cp	1		; is it an instrument?
	jr.	z,gcrlc_end	
	
	inc	hl
	cp	4		; is it a volume or command?
	jr.	c,gcrlc_end	
	
	inc	hl		; only left is a parameter x and y.
		
gcrlc_end:			
	ret


;===========================================================
; --- selection_volume_up
;
; Sets all volumes in the current selection one higher
; if possible. Only run if 1 column is selected.
; 
; No changes are made to the clipboard status and contents
;===========================================================
selection_volume_up:
	;--- One final check to be sure only 1 column is selected
	ld	a,(selection_x2)
	ld	b,a
	ld	a,(selection_x1)
	cp	b
	ret	nz


	;--- Now copy the data into the clipboard
	ld	hl,(clipb_tmp_address)
	ld	a,(clipb_tmp_rows)
	ld	b,a

.loop:	
	;--- Update volume
	ld	a,(hl)
	cp	$10			; no volume (0)
	jr.	c,22f		
	cp	$f0			; Volume < 15
	jr.	nc,22f
	add	$10
	ld	(hl),a
22:

	ld	a,SONG_PATLNSIZE
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	; still need to copy?
	djnz .loop

;	ld	a,(current_song)
	call	set_songpage

	call	store_log_block
	ret

;===========================================================
; --- selection_volume_down
;
; Sets all volumes in the current selection one lower
; if possible. Only run if 1 column is selected.
; 
; No changes are made to the clipboard status and contents
;===========================================================
selection_volume_down:
	;--- One final check to be sure only 1 column is selected
	ld	a,(selection_x2)
	ld	b,a
	ld	a,(selection_x1)
	cp	b
	ret	nz


	;--- Now copy the data into the clipboard
	ld	hl,(clipb_tmp_address)
	ld	a,(clipb_tmp_rows)
	ld	b,a

.loop:	

	;--- Update volume
	ld	a,(hl)
	cp	$20		; volume > 1 (do not erase volume)
	jr.	c,22f
	sub	$10
	ld	(hl),a
22:
	ld	a,SONG_PATLNSIZE
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	; still need to copy?
	djnz .loop

;	ld	a,(current_song)
	call	set_songpage

	call	store_log_block
	ret

;===========================================================
; --- selection_octave_up
;
; Sets all notes in the current selection one octave higher
; if possible
; 
; No changes are made to the clipboard status and contents
;===========================================================
selection_octave_up:
	;--- setup all the needed values
	call	_common_selection_change

	;--- Check if we have a single column selection over the volume
	ld	a,(selection_column1)
	cp	2
	jr.	nz,.skip
	ld	a,(clipb_tmp_bytes)
	cp	1
	jr.	z,selection_volume_up

.skip:
	;--- Now copy the data into the clipboard
	ld	hl,(clipb_tmp_address)
	ld	a,(clipb_tmp_rows)
	ld	c,a


_sou_row_loop:
		ld	a,(clipb_tmp_bytes)
		ld	b,a
		ld	a,(selection_column1)
		ld	d,a			; column type
	
		push	hl
_sou_byte_loop:
		;--- are we at a note column
		ld	a,d
		and	a
		jr.	nz,44f
		;-- note
			ld	a,(hl)
			and	a
			jr.	z,22f
			add	12
			cp	97
			jr.	nc,22f
			ld	(hl),a
22:
44:			inc	hl

		ld	a,d
		inc	a
		cp	4
		jr.	c,55f
		xor	a
55:
		ld	d,a
		djnz	_sou_byte_loop

		; set the next row
		pop	hl
		ld	a,SONG_PATLNSIZE
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
	
		; still need to copy?
		dec	c
		jr.	nz,_sou_row_loop

;	ld	a,(current_song)
	call	set_songpage

	call	store_log_block
	ret
	

;===========================================================
; --- selection_octave_down
;
; Sets all notes in the current selection one octave lower
; if possible
; 
; No changes are made to the clipboard status and contents
;===========================================================
selection_octave_down:
	;--- setup all the needed values
	call	_common_selection_change

	;--- Check if we have a single column selection over the volume
	ld	a,(selection_column1)
	cp	2
	jr.	nz,.skip
	ld	a,(clipb_tmp_bytes)
	cp	1
	jr.	z,selection_volume_down

.skip:
	;--- Now copy the data into the clipboard
	ld	hl,(clipb_tmp_address)
	ld	a,(clipb_tmp_rows)
	ld	c,a

_sod_row_loop:
		ld	a,(clipb_tmp_bytes)
		ld	b,a
		ld	a,(selection_column1)
		ld	d,a			; column type
	
		push	hl
_sod_byte_loop:
		;--- are we at a note column
		ld	a,d
		and	a
		jr.	nz,44f
		;-- note
			ld	a,(hl)
			cp	97
			jr.	nc,22f
			cp	13
			jr.	c,22f
			sub	12
			ld	(hl),a
22:
44:			inc	hl

		ld	a,d
		inc	a
		cp	4
		jr.	c,55f
		xor	a
55:
		ld	d,a
		djnz	_sod_byte_loop

		; set the next row
		pop	hl
		ld	a,SONG_PATLNSIZE
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
	
		; still need to copy?
		dec	c
		jr.	nz,_sod_row_loop

;	ld	a,(current_song)
	call	set_songpage
	
	call	store_log_block
	ret
	
;===========================================================
; --- selection_note_up
;
; Sets all notes in the current selection one (halve)note
; higher if possible
; 
; No changes are made to the clipboard status and contents
;===========================================================
selection_note_up:
	;--- setup all the needed values
	call	_common_selection_change

	;--- Check if we have a single column selection over the volume
	ld	a,(selection_column1)
	cp	2
	jr.	nz,.skip
	ld	a,(clipb_tmp_bytes)
	cp	1
	jr.	z,selection_volume_up

.skip:
	;--- Now copy the data into the clipboard
	ld	hl,(clipb_tmp_address)
	ld	a,(clipb_tmp_rows)
	ld	c,a

_snu_row_loop:
		ld	a,(clipb_tmp_bytes)
		ld	b,a
		ld	a,(selection_column1)
		ld	d,a			; column type
	
		push	hl
_snu_byte_loop:
		;--- are we at a note column
		ld	a,d
		and	a
		jr.	nz,44f
		;-- note
			ld	a,(hl)
			and	a
			jr.	z,22f
			inc	a
			cp	97
			jr.	nc,22f
			ld	(hl),a
22:
44:			inc	hl

		ld	a,d
		inc	a
		cp	4
		jr.	c,55f
		xor	a
55:
		ld	d,a
		djnz	_snu_byte_loop

		; set the next row
		pop	hl
		ld	a,SONG_PATLNSIZE
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
	
		; still need to copy?
		dec	c
		jr.	nz,_snu_row_loop

;	ld	a,(current_song)
	call	set_songpage

	call	store_log_block
	ret






;===========================================================
; --- selection_note_down
;
; Sets all notes in the current selection one (halve)note
; lower if possible
; 
; No changes are made to the clipboard status and contents
;===========================================================
selection_note_down:
	;--- setup all the needed values
	call	_common_selection_change

	;--- Check if we have a single column selection over the volume
	ld	a,(selection_column1)
	cp	2
	jr.	nz,.skip
	ld	a,(clipb_tmp_bytes)
	cp	1
	jr.	z,selection_volume_down

.skip:
	;--- Now copy the data into the clipboard
	ld	hl,(clipb_tmp_address)
	ld	a,(clipb_tmp_rows)
	ld	c,a

_snd_row_loop:
		ld	a,(clipb_tmp_bytes)
		ld	b,a
		ld	a,(selection_column1)
		ld	d,a			; column type
	
		push	hl
_snd_byte_loop:
		;--- are we at a note column
		ld	a,d
		and	a
		jr.	nz,44f
		;-- note
			ld	a,(hl)
			cp	97
			jr.	nc,22f
			cp	2
			jr.	c,22f
			dec	a
			ld	(hl),a
22:
44:			inc	hl

		ld	a,d
		inc	a
		cp	4
		jr.	c,55f
		xor	a
55:
		ld	d,a
		djnz	_snd_byte_loop

		; set the next row
		pop	hl
		ld	a,SONG_PATLNSIZE
		add	a,l
		ld	l,a
		jr.	nc,99f
		inc	h
99:
	
		; still need to copy?
		dec	c
		jr.	nz,_snd_row_loop

;	ld	a,(current_song)
	call	set_songpage

	call	store_log_block

	ret
	
	
;-------------------------------------------------------	
; sets the data needed to transpose data in selection
;-------------------------------------------------------
_common_selection_change:
	;be sure to get the right info from song page
;	ld	a,(current_song)
	call	set_songpage


	ld	a,(selection_status)
	and	a
	jr.	nz,1f

	;--- single char copy
	inc	a
	ld	(selection_status),a
	
	
	ld	a,(cursor_x)
	ld	(selection_x1),a
	ld	(selection_x2),a
	ld	a,(song_pattern_offset)
	ld	b,a
	ld	a,(cursor_y)
	add	b
	ld	(selection_y1),a
	ld	(selection_y2),a
	ld	a,(cursor_type)
	dec	a
	ld	(selection_type1),a
	ld	(selection_type2),a
	ld	a,(cursor_input)
	ld	(selection_column1),a
	ld	(selection_column2),a
	
	call	selection_show

1:
	;---Set the source pattern
	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage
	call	init_log_block		; make local copy of pattern

	;--- Switch X1 and X2 if needed
	ld	a,(selection_x2)
	ld	b,a
	ld	a,(selection_x1)
	cp	b
	jr.	c,_ctt_no_Xswap
	
	; swap X1 and X2
	ld	a,(selection_type2)	; load X2 vals
	ld	c,a
	ld	a,(selection_column2)
	ld	d,a
	
	ld	a,(selection_x1)		; write X1 vals in X2
	ld	(selection_x2),a
	ld	a,(selection_type1)
	ld	(selection_type2),a
	ld	a,(selection_column1)
	ld	(selection_column2),a
	
	ld	a,b				; write X2 vals into X1
	ld	(selection_x1),a
	ld	a,c
	ld	(selection_type1),a
	ld	a,d
	ld	(selection_column1),a	

_ctt_no_Xswap:
	;--- switch Y1 and Y2 if needed
	ld	a,(selection_y2)
	ld	b,a
	ld	a,(selection_y1)
	cp	b
	jr.	c,_ctt_no_Yswap

	ld	(selection_y2),a		; swap Y values
	ld	a,b
	ld	(selection_y1),a	

_ctt_no_Yswap:

	;--- Get the source address of the selection
	ld	a,(selection_x1)
	ld	b,a
	ld	a,(selection_column1)
	ld	c,a
	ld	a,(selection_y1)
	call	get_chanrecord_location_ctb
	ld	(clipb_tmp_address),hl

	
	;--- Get the # bytes to copy
	ld	a,(selection_x2)
	ld	b,a
	ld	a,(selection_column2)
	ld	c,a
	ld	a,(selection_y1)
	call	get_chanrecord_location_ctb
	ld	de,(clipb_tmp_address)
	inc	hl
	xor	a		; remove carry flag
	sbc	hl,de
	ld	a,l		; this should contain the number of bytes to copy
	ld	(clipb_tmp_bytes),a
	
	;--- Get the # rows to copy
	ld	a,(selection_y1)
	ld	b,a
	ld	a,(selection_y2)
	sub	b
	inc	a
	ld	(clipb_tmp_rows),a 
	
	;--- Get the start and ending column input type (needed for combined bytes)
	ld	a,(selection_column1)
	ld	(clipb_column_start),a
	ld	a,(selection_column2)
	ld	(clipb_column_end),a

	ret		