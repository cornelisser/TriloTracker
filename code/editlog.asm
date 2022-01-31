_undo_pointer:		dw	0	; Pointer to last edit change
;redo_pointer:		dw	0	; Pointer to last undone change
_undo_start_pointer:	dw	0	; Pointer to the last possible undo.
_undo_end_pointer:	dw	0	; Pointer to the last possible redo end.

; keep variables below in this order!
_log_cursor_pos_y:		db	0	; values of the cursor pointer
_log_cursor_pos_x:		db	0
_log_cursor_type:			db	0
_log_cursor_input:		db	0; type of input
_log_cursor_column:		db	0
_log_song_pattern:		db	0
_log_song_pattern_offset:	db	0	; offset to draw
_log_song_pattern_line:		db	0		; line to edit


_LOG_WRAP_MASK			equ	0xbf


;_LABEL_ADR:	
;	db	"    ",0

;log_debug:
;	ld	hl,(_undo_start_pointer)
;	call	log_debug_sub
;	ld	de,_LABEL_ADR
;	ld	hl,(80*1)+44+4
;	call	draw_label	
;	ld	hl,(_undo_pointer)
;	call	log_debug_sub
;	ld	de,_LABEL_ADR
;	ld	hl,(80*2)+44+4
;	call	draw_label	
;	ld	hl,(_undo_end_pointer)
;	call	log_debug_sub
;	ld	de,_LABEL_ADR
;	ld	hl,(80*3)+44+4
;	call	draw_label
;	ret
		
;log_debug_sub:	
;	ld	de,_LABEL_ADR
;	ld	a,h
;	call	draw_hex2
;	ld	a,l
;	call	draw_hex2
;	
;	ret





;===========================================================
; --- init_undoredo
;
;  Initialises the undo and redo memory area
;
; Input: none 
;===========================================================
init_undoredo:
	ld	hl,0x8000	; start of the undo page
	ld	(_undo_pointer),hl
	ld	(_undo_start_pointer),hl	
	ld	(_undo_end_pointer),hl
	ret



	
;===========================================================
; --- store_log_byte
;
;  Logs 1 byte change. Storing page, cursor pos and old/new value
;
; Input: a contains value
;	 hl contains address

;===========================================================	
store_log_byte:
	push	bc		;--- store to be sure
	push	de		;--- store to be sure
	push	af		;--- Save new value
	push	hl		;--- Store the destination	

	ld	d,(hl)		;--- Get the old value
	cp	d
	jr.	z,_store_log_byte_NOCHANGE
	ld	(hl),a		;--- Update the new value in the pattern

	call	getCursorInfo	; get current cursor pos

	; -- get and set the current page where the data is.
	call	GET_P2
	ld	e,a
	ex	af,af'	;'

	call set_undo_page	
	
	ld	hl,(_undo_pointer)
	;--- Store the type of undo logging
	ld	(hl),1			; 1 = one byte undo log
	call	incrementHL

	;--- Store the page the where the value is at
	ld	(hl),e
	call	incrementHL
	
	;--- Store the cursor position
	call	storeCursorInfo	
		
	;--- Store the address the values is at
	pop	bc
	ld	(hl),c
	call	incrementHL
	ld	(hl),b
	call	incrementHL
	
	;--- Store the old value (for undo)
	ld	(hl),d
	call	incrementHL
	
	;--- Store the new value (for redo)
	pop	af
	ld	(hl),a
	call	incrementHL
	
	;--- Store the beginning of the logging action
	ld	de,(_undo_pointer)
	ld	(hl),e
	call	incrementHL
	ld	(hl),d
	call	incrementHL	
	
	;--- Store the new end and undo pointer
	ld	(_undo_end_pointer),hl
	ld	(_undo_pointer),hl
	
	;--- Restore the original page
	ex	af,af'	;'
	call	PUT_P2
	
	pop	de
	pop	bc	

	ret
	
_store_log_byte_NOCHANGE:
	pop	hl
	pop	af		
	pop	de
	pop	bc
	ret

;===========================================================
; --- store_log_note
;
;  Logs 2 byte change (note+instrument). Storing page, cursor pos, location and old/new value
;
; Input: a contains value
;	 hl contains address

;===========================================================	
store_log_note:
	push	ix		;--- Store to be sure
	push	bc		;--- store to be sure
	push	de		;--- store to be sure
	push	af		;--- Save new value
	push	hl		;--- Store the destination	
	ld	d,(hl)	;--- Get the old NOTE value
	cp	d
;	jr.	z,_store_log_note_NOCHANGE
	jr.	nz,0f

	;-- is instrument changed?
	ld	d,a
	inc	hl
	ld	a,(tmp_cur_instrument)
	cp	(hl)
	dec	hl
	jr.	z,_store_log_note_NOCHANGE	
	ld	a,d
	
	
0:	
	ld	(hl),a		;--- Update the new value in the pattern

	; set the instrument to 0 when there is no note
	and	a
	jr.	nz,45f
	xor	a
	jr.	46f
45:
	cp 	97 	;< also no instrument for rest
	ld	a,(tmp_cur_instrument)

	jr.	c,46f
	xor	a
46:

	ld	ixh,a

	inc	hl
	ld	a,(hl)
	ld	ixl,a
	ld	a,ixh
	ld	(hl),a
	dec 	hl
	
	call	getCursorInfo	; init the custor info localy
	
	
	; -- get and set the current page where the data is.
	call	GET_P2
	ld	e,a		; store page for undo info
	ex	af,af'	;'

	
	call set_undo_page	
	
	ld	hl,(_undo_pointer)
	;--- Store the type of undo logging
	ld	(hl),2			; 2 = 2 byte undo log
	call	incrementHL

	;--- Store the page the where the value is at
	ld	(hl),e
	call	incrementHL

	;--- Store the cursor position
	call	storeCursorInfo
	
	;--- Store the address the values is at
	pop	bc
	ld	(hl),c
	call	incrementHL
	ld	(hl),b
	call	incrementHL
	
	;--- Store the old note value (for undo)
	ld	(hl),d
	call	incrementHL
	
	;--- Store the new note value (for redo)
	pop	af
	ld	(hl),a
	call	incrementHL
	
	;--- Store the old instrument value (for undo)
	ld	a,ixl
	ld	(hl),a
	call	incrementHL
	
	;--- Store the new instrument value (for redo)
	ld	a,ixh
	ld	(hl),a
	call	incrementHL
	
	;--- Store the beginning of the logging action
	ld	de,(_undo_pointer)
	ld	(hl),e
	call	incrementHL
	ld	(hl),d
	call	incrementHL	
	
	;--- Store the new end and undo pointer
	ld	(_undo_end_pointer),hl
	ld	(_undo_pointer),hl
	
	;--- Restore the original page
	ex	af,af'	;'	
	call	PUT_P2
	
	pop	de
	pop	bc	
	pop	ix

	ret
	
_store_log_note_NOCHANGE:
	pop	ix
	pop	hl
	pop	af		
	pop	de
	pop	bc
	ret



;===========================================================
; --- undo
;
;  Undoes the latest action in the list

; Input: none
;	 
; Changes HL,DE,BC,A
;===========================================================
undo:
	;--- get _undo_pointer
	ld	hl,(_undo_pointer)
	
	;--- no undo's left?
	ld	de,(_undo_start_pointer)
	ld	a,e
	cp	l
	jr.	nz,_undo_start
	ld	a,d
	cp	h
	jr.	nz,_undo_start
	
	;--- Undo and undo_base are the same. There is no undo left
	ret

_undo_start:
	;--- save current page
	call	GET_P2
	push af

	call	set_undo_page

	ld	hl,(_undo_pointer)
	;--- Go back to the start of the undoaction	
	call	decrementHL
	ld	d,(hl)
	call	decrementHL
	ld	e,(hl)
	ex	de,hl	; HL now points to the start of the undo
	
	;--- Store the new undo pointer
	ld	(_undo_pointer),hl
	
	;--- get the type
	ld	a,(hl)
	cp	1			; type 1 is one byte
	jr.	z,sub_undo1
	cp	2			; type 2 is two byte (note+instrument)
	jr.	z,sub_undo2
	cp	3
	jr.	z,sub_undo3		; type 3 is block action
	
	pop	af
	ret

; =========================================================
; ONE BYTE UNDO
; =========================================================	
sub_undo1:
	;--- Get the destination page
	call	incrementHL
	ld	c,(hl)	
	
	;--- Set the undo cursor pos
	call	incrementHL
	call	loadCursorInfo
	
	;--- Get the destinaion address
	ld	e,(hl)
	call	incrementHL
	ld	d,(hl)
	
	;--- Get the old value
	call	incrementHL
	ld	b,(hl)
	
	;--- Calculate the original pattern and cursor position
	
	;--- restore the value
	ld	a,c
	call	PUT_P2
	ld	a,b
	ld	(de),a
	
	call	putCursorInfo
		
	;restore original page
	pop	af
	call	PUT_P2
	
	;--- Update the screen
	call	update_patterneditor

	ret

; =========================================================
; Note (2 byte) BYTE UNDO
; =========================================================	
sub_undo2:
	;--- Get the destination page
	call	incrementHL
	ld	c,(hl)	

	;--- Set the undo cursor pos
	call	incrementHL
	call	loadCursorInfo

	;--- Get the destinaion address
	ld	e,(hl)
	call	incrementHL
	ld	d,(hl)
	
	;--- Get the old note value
	call	incrementHL
	ld	b,(hl)


	;--- Get the old instrument value
	call	incrementHL
	call	incrementHL
	ld	a,(hl)
	ld	ixl,a

	;--- Calculate the original pattern and cursor position
	
	;--- restore the values
	ld	a,c
	call	PUT_P2
	ld	a,b
	ld	(de),a
	inc	de
	ld	a,ixl
	ld	(de),a

	call	putCursorInfo
		
	;restore original page
	pop	af
	call	PUT_P2
	
	;--- Update the screen
	call	update_patterneditor

	ret

; =========================================================
; Pattern diff undo (Block actions)
; =========================================================	
sub_undo3:
	call	GET_P2
	ld	(log_undopage),a

	;--- Get the destination page
	call	incrementHL
	ld	a,(hl)	
	ld	(log_patpage),a
	
	;--- Set the undo cursor pos
	call	incrementHL
	call	loadCursorInfo


_su3_loop:
	;--- Get the destination address
	ld	e,(hl)
	call	incrementHL
	ld	d,(hl)

	;--- check if we are at the end	
	xor	a
	cp	d
	jr.	z,_su3_end
	
	;--- Get the number of bytes to proces in sequence
	call	incrementHL
	ld	b,(hl)
	call	incrementHL

_su3_subloop:
	;--- Get the old instrument value
;	call	incrementHL
	ld	c,(hl)
	call	incrementHL
	call	incrementHL
	;--- restore the values
	ld	a,(log_patpage)
	call	PUT_P2
	ld	a,c
	ld	(de),a
	inc	de

	ld	a,(log_undopage)
	call	PUT_P2
	
	djnz	_su3_subloop
	jr.	_su3_loop
_su3_end:
	call	putCursorInfo
		
	;restore original page
	pop	af
	call	PUT_P2
	
	;--- Update the screen
	call	update_patterneditor
	call	update_orderbox
	ret

	

;===========================================================
; --- redo
;
;  Redoes the last undo action in the list

; Input: none
;	 
; Changes HL,DE,BC,A
;===========================================================
redo:
	;--- get _undo_pointer
	ld	hl,(_undo_pointer)
	
	;--- no redo's left?
	ld	de,(_undo_end_pointer)
	ld	a,e
	cp	l
	jr.	nz,_redo_start
	ld	a,d
	cp	h
	jr.	nz,_redo_start
	
	;--- Undo and undo_end are the same. There is no redo left
	ret

_redo_start:
	;--- save current page
	call	GET_P2
	push af

	call set_undo_page

	ld	hl,(_undo_pointer)
	;--- get the type
	ld	a,(hl)
	cp	1			; type 1 is 1 byte redo
	jr.	z,sub_redo1
	cp	2			; type 2 is note redo (2bytes)
	jr.	z,sub_redo2	
	cp	3
	jr.	z,sub_redo3		; type 3 is block action
	
	
	pop	af	
	ret

; =========================================================
; ONE BYTE REDO
; =========================================================	
sub_redo1:
	;--- Get the destination page
	call	incrementHL
	ld	c,(hl)	

	;--- Set the undo cursor pos
	call	incrementHL
	call	loadCursorInfo
		
	;--- Get the destinaion address
	ld	e,(hl)
	call	incrementHL
	ld	d,(hl)
	
	;--- Get the new value
	call	incrementHL
	call	incrementHL
	ld	b,(hl)
	
	;--- Set the new undo pointer
	call	incrementHL
	call	incrementHL
	call	incrementHL		
	ld	(_undo_pointer),hl

	;--- Calculate the original pattern and cursor position
	
	
	
	;--- restore the value
	ld	a,c
	call	PUT_P2
	ld	a,b
	ld	(de),a
	
	call	putCursorInfo
	
	;restore original page
	pop	af
	call	PUT_P2
	
	;--- Update the screen
	call	update_patterneditor

	ret

; =========================================================
; two BYTE NOTE REDO
; =========================================================	
sub_redo2:
	;--- Get the destination page
	call	incrementHL
	ld	c,(hl)	

	;--- Set the undo cursor pos
	call	incrementHL
	call	loadCursorInfo
	
	;--- Get the destinaion address
	ld	e,(hl)
	call	incrementHL
	ld	d,(hl)
	
	;--- Get the new note value
	call	incrementHL
	call	incrementHL
	ld	b,(hl)

	;--- Get the new instrument value
	call	incrementHL
	call	incrementHL
	ld	a,(hl)
	ld	ixl,a

	
	;--- Set the new undo pointer
	call	incrementHL
	call	incrementHL
	call	incrementHL		
	ld	(_undo_pointer),hl

	;--- restore the value
	ld	a,c
	call	PUT_P2
	ld	a,b
	ld	(de),a
	inc	de
	ld	a,ixl
	ld	(de),a

	call	putCursorInfo
	
	;restore original page
	pop	af
	call	PUT_P2
	
	;--- Update the screen
	call	update_patterneditor

	ret
; =========================================================
; Pattern diff undo (Block actions)
; =========================================================	
sub_redo3:
	call	GET_P2
	ld	(log_undopage),a

	;--- Get the destination page
	call	incrementHL
	ld	a,(hl)	
	ld	(log_patpage),a
	;--- Set the undo cursor pos
	call	incrementHL
	call	loadCursorInfo


_sr3_loop:
	;--- Get the destination address
	ld	e,(hl)
	call	incrementHL
	ld	d,(hl)

	;--- check if we are at the end	
	xor	a
	cp	d
	jr.	z,_sr3_end
	
	;--- Get the number of bytes to proces in sequence
	call	incrementHL
	ld	b,(hl)
	call	incrementHL

_sr3_subloop:
	;--- Get the old instrument value
	call	incrementHL
	ld	c,(hl)
	call	incrementHL


	;--- restore the values
	ld	a,(log_patpage)
	call	PUT_P2
	ld	a,c
	ld	(de),a
	inc	de

	ld	a,(log_undopage)
	call	PUT_P2
	
	djnz	_sr3_subloop
	jr.	_sr3_loop
_sr3_end:
	

	;--- Set the new undo pointer
	call	incrementHL
	call	incrementHL
	call	incrementHL		
	ld	(_undo_pointer),hl

	call	putCursorInfo		
	;restore original page
	pop	af
	call	PUT_P2
	
	;--- Update the screen
	call	update_patterneditor
	call	update_orderbox
	ret









;===========================================================
; --- set_undo_page
;
;  Sets the undo page of the current song

; Input: none
;	 
; Changes HL,A,bc
;===========================================================
set_undo_page:
	ld	a,(undo_page)
	call	PUT_P2

	ret
	
;===========================================================
; --- incrementHL
;
;  Increments HL with 1. Automaticly wraps around the 16kb
;  page (0x8000 - 0xbfff). Also checks if _undo_end_pointer
;  goes past the _undo_start_pointer. If so the  oldest undo 
;  is deleted (overwritten).

; Input: hl
;	 
; Changes HL,
;===========================================================
incrementHL:
	push	af
	inc	hl
		ld	a,h
		and	_LOG_WRAP_MASK		; auto wrap to beginning of the page
		ld	h,a
		
	;--- NEED TO ADD UNDO LOG WRAPING!!!!!
	push	de
	
	ld	de,(_undo_start_pointer)
	ld	a,e
	cp	l
	jr.	nz,incrementHL_END
	ld	a,d
	cp	h
	jr.	nz,incrementHL_END
	
	;--- overlap in the undo list. remove the oldest undo.
	ex	de,hl
	ld	h,d
	ld	l,e
	
	;--- Get the type
	ld	a,(hl)
	dec	a
	jr.	z,_incHL_type1
	dec	a
	jr.	z,_incHL_type2
	jr.	_incHL_type3
	
	
incrementHL_END:	
	pop	de
	pop	af
	ret

;===============================
; MOVE start undo type 1
;===============================	
_incHL_type1:
	ld	a,16	; (type+page+cursorinfo+address+old+new+prevundoaddress)
	add	l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,h
	and	_LOG_WRAP_MASK		; auto wrap to beginning of the page
	ld	h,a

	ld	(_undo_start_pointer),hl
	ex	de,hl
	jr.	incrementHL_END
;===============================
; MOVE start undo type 2
;===============================	
_incHL_type2:
	ld	a,18	; (type+page+cursorinfo+address+old(2)+new(2)+prevundoaddress)
	add	l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,h
	and	_LOG_WRAP_MASK		; auto wrap to beginning of the page
	ld	h,a

	ld	(_undo_start_pointer),hl
	ex	de,hl
	jr.	incrementHL_END
;===============================
; MOVE start undo type 3
;===============================	
_incHL_type3:
	ld	a,10	; (type+page+cursorinfo)
	add	l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,h
	and	_LOG_WRAP_MASK;0xbf		; auto wrap to beginning of the page
	ld	h,a

0:	;-- process sequences
	call	_incHL_type3_inc
;	call	_incHL_type3_inc
	ld	a,(hl)
	and	a
	jr.	z,2f		;--- end of all sequences

	;--- read # bytes in sequence.	
	call	_incHL_type3_inc
	ld	b,(hl)
	call	_incHL_type3_inc

1:	;-- skip sequence
	call	_incHL_type3_inc
	call	_incHL_type3_inc
	djnz	1b
		
	jr.	0b

2:
	call	_incHL_type3_inc
	call	_incHL_type3_inc	
	call	_incHL_type3_inc
	ld	(_undo_start_pointer),hl
	ex	de,hl
	jr.	incrementHL_END

	
_incHL_type3_inc:
	ex	af,af'	;'
	inc	hl
	ld	a,h
	and	_LOG_WRAP_MASK		; auto wrap to beginning of the page
	ld	h,a
	ex	af,af'	;'
	ret	
;===========================================================
; --- decrementHL
;
;  decrements HL with 1. Automaticly wraps around the 16kb
;  page (0x8000 - 0xbfff).

; Input: hl
;	 
; Changes HL,A
;===========================================================
decrementHL:
	dec	hl
		ld	a,h
		and	0x3f		; auto wrap to end of the page
		or	0x80
		ld	h,a

	
	ret
	
	
	
;===========================================================
; --- getCursorInfo
;
;  Stores the current (cursor) position locally to be
;  stored in the undo/redo log.
;
; Input: none
;	 
; Changes: af' 
;===========================================================
getCursorInfo:
	;--- store registers
	push	af
	push	bc
	push	de
		
	call	GET_P2	; get the current page
	ex	af,af'	;'	
	
	;--- now get the info!
;	ld	a,(current_song)		; set the page
	call	set_songpage

	ld	de,_log_cursor_pos_y

	ld	a,(cursor_y)
	ld	(de),a
	inc	de
	ld	a,(cursor_x)
	ld	(de),a
	inc	de
	ld	a,(cursor_type)
	ld	(de),a
	inc	de
	ld	a,(cursor_input)
	ld	(de),a
	inc	de
	ld	a,(cursor_column)
	ld	(de),a
	inc	de
	ld	a,(song_pattern)
	ld	(de),a
	inc	de
	ld	a,(song_pattern_offset)
	ld	(de),a
	inc	de
	ld	a,(song_pattern_line)
	ld	(de),a
	
	
	;--- restore the original page
	ex	af,af'	;'
	call	PUT_P2
	
	
	;--- restore registers
	pop	de
	pop	bc
	pop	af
	
	ret	
	
;===========================================================
; --- putCursorInfo
;
;  Stores the current local (cursor) position into be
;  global stored position.
;
; Input: none
;	 
; Changes: af' 
;===========================================================
putCursorInfo:
	;--- store registers
	push	af
	push	bc
	push	de
		
	call	GET_P2	; get the current page
	ex	af,af'	;'	
	
	;--- now get the info!
;	ld	a,(current_song)		; set the page
	call	set_songpage

	call	flush_cursor		; be sure to clear current cursor

	ld	de,_log_cursor_pos_y

	ld	a,(de)
	ld	(cursor_y),a
	inc	de	
	ld	a,(de)
	ld	(cursor_x),a
	inc	de	
	ld	a,(de)
	ld	(cursor_type),a
	inc	de	
	ld	a,(de)
	ld	(cursor_input),a
	inc	de	
	ld	a,(de)
	ld	(cursor_column),a
	inc	de	
	ld	a,(de)
	ld	(song_pattern),a
	inc	de	
	ld	a,(de)
	ld	(song_pattern_offset),a
	inc	de	
	ld	a,(de)
	ld	(song_pattern_line),a

	;--- restore the original page
	ex	af,af'	;'
	call	PUT_P2
	
	;--- restore registers
	pop	de
	pop	bc
	pop	af
	
	ret	

;===========================================================
; --- storeCursorInfo
;
;  Stores the current local (cursor) position into the
;  undo page.
;
; Input: none
;	 
; Changes: 
;===========================================================
storeCursorInfo:
	;--- store registers
	push	af
	push	de
	
	ld	de,_log_cursor_pos_y
	ld	b,8
	
_scf_loop:	
	ld	a,(de)
	inc	de
	ld	(hl),a
	call	incrementHL
		
	djnz	_scf_loop

	;--- restore registers
	pop	de
	pop	af
	ret
	
;===========================================================
; --- loadCursorInfo
;
;  Loads the cursor infor mation from the undo page into the
;  local variables.
;
; Input: none
;	 
; Changes: 
;===========================================================
loadCursorInfo:
	;--- store registers
	push	af
	push	de
	
	ld	de,_log_cursor_pos_y
	ld	b,8
	
_lcf_loop:	
	ld	a,(hl)
	ld	(de),a
	inc	de
	call	incrementHL
		
	djnz	_lcf_loop

	;--- restore registers
	pop	de
	pop	af
	ret	
	
;=========
; Make a local copy of the changeing pattern
;
; Expects hl to point to pattern start 
; leaves HL unchanged
;=============
init_log_block:
	push	hl
	push	de
	push	bc
	
;	ld	a,(current_song)
	call	set_songpage
	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage
	ld	de,buffer
	ld	bc,2048
	ldir	
	
	pop	bc
	pop	de
	pop	hl
	ret
	
	
	
log_undopage:	db	0
log_patpage:	db	0
log_bytes:		db	0
log_byte_addr:	dw	0
	
	
	
;===========
; store_log_block
;
;============
store_log_block:
	;--- Init the undo action undo header
;	ld	a,(current_song)
	call	set_songpage
	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage
	push	hl
	call	GET_P2
	ld	(log_patpage),a
	
	call	getCursorInfo	; get current cursor pos

;	ex	af,af'		;'

	call set_undo_page
	call	GET_P2	
	ld	(log_undopage),a
	
	
	ld	hl,(_undo_pointer)
	;--- Store the type of undo logging
	ld	(hl),3			; 1 = block action undo log
	call	incrementHL
	
	;--- store the pattern page (dst page)
;	ex	af,af'		;'
	ld	a,(log_patpage)
	ld	(hl),a
;	ex	af,af'		;'
	call	incrementHL
	
	;--- Store the cursor position
	call	storeCursorInfo	

	
	;--- set up the diff check values
	xor	a
	ld	(log_bytes),a
	ld	(log_byte_addr),hl


	;--- save the registers
	exx

	;--- set the pattern data
	ld	a,(log_patpage)
	call	PUT_P2
	ld	de,buffer		; here is the original pattern
	pop	hl
	
_slb_loop:
	ld	a,(de)
	cp	(hl)
	jr.	nz,_slb_match
	ld	a,(log_bytes)
	and	a
	call	nz,slb_endsequence
_slb_continue:	
	inc	hl
	inc	de
	ld	a,e
	cp	low (buffer+SONG_PATSIZE)
	jr.	nz,_slb_loop
	ld	a,d
	cp	high (buffer+SONG_PATSIZE)	
	jr.	nz,_slb_loop
	
	ld	a,(log_bytes)
	and	a
	jr.	z,99f

	;-- store the # bytes in the last sequence
	ld	bc,(log_byte_addr)
	ld	a,(log_bytes)
	ld	(bc),a
	
99:	
	;--- end here the log entry	
	call	set_undo_page
	exx

	xor	a
	ld	(hl),a
	call	incrementHL
	ld	(hl),a
	call	incrementHL

	ld	de,(_undo_pointer)	; reference to start of undo entry
	ld	(hl),e
	call	incrementHL
	ld	(hl),d
	call	incrementHL
	
	;--- Store the new end and undo pointer
	ld	(_undo_end_pointer),hl
	ld	(_undo_pointer),hl
	
;	ld	a,(current_song)
	call	set_songpage

	ret

_slb_match:
	;--- need to write address?
	ld	a,(log_bytes)
	and	a
	jr.	nz,99f
	;--- write addres to undopage
	call	_slb_write_addr

99:	
	ld	a,(de)
	call	_slb_write_byte		; old value
	ld	a,(hl)
	call	_slb_write_byte		; new value
		
	ld	a,(log_bytes)
	inc	a
	ld	(log_bytes),a	
	call	z,slb_endsequence	 	;255 entries!!!	
	jr.	_slb_continue		
		
		
;--- write hl as address and store undo pointer for #bytes update later	
_slb_write_addr:
	;-- set undo page
	ld	a,(log_undopage)
	call	PUT_P2

	push	hl			; safe the address
	exx				; swap registers
	pop	bc
	ld	(hl),c
	call	incrementHL
	ld	(hl),b
	call	incrementHL
	ld	(log_byte_addr),hl
	call	incrementHL

	;--- set pat page
	ld	a,(log_patpage)
	call	PUT_P2
	exx
	
	ret	
	
_slb_write_byte:
	ex	af,af'			;'
	;-- set undo page
	ld	a,(log_undopage)
	call	PUT_P2

	exx				; swap registers
	ex	af,af'			;'
	ld	(hl),a
	call	incrementHL

	;--- set pat page
	ld	a,(log_patpage)
	call	PUT_P2
	exx
	
	ret			

slb_endsequence:
	;-- set undo page
	ld	a,(log_undopage)
	call	PUT_P2

	exx				; swap registers
	ld	bc,(log_byte_addr)
	ld	a,(log_bytes)
	ld	(bc),a
	xor	a
	ld	(log_bytes),a
	
	;--- set pat page
	ld	a,(log_patpage)
	call	PUT_P2
	exx
		
	ret			
	
	