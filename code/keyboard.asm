_KEY_LEFT:	equ 29
_KEY_RIGHT:	equ 28	
_KEY_DOWN:	equ 31
_KEY_UP:	equ 30	
_KEY_ENTER:	equ 13
_KEY_CTRL:	equ 6
_KEY_TAB:	equ 9

_CTRL_A:	equ "a"+128	;0x01
_CTRL_B:	equ "b"+128	;0x02
_CTRL_C:	equ "c"+128	;0x03
_CTRL_D:	equ "d"+128	;0x04
_CTRL_E:	equ "e"+128	;0x05
_CTRL_F:	equ "f"+128	;0x06
_CTRL_G:	equ "g"+128	;0x07
_CTRL_I:	equ "i"+128	;0x09
_CTRL_J:	equ "j"+128	;0x0a
_CTRL_K:	equ "k"+128	;0x0b
_CTRL_L:	equ "l"+128	;0x0c
_CTRL_M:	equ "m"+128	;0x0d
_CTRL_N:	equ "n"+128	;0x0e
_CTRL_O:	equ "o"+128	;0x0f
_CTRL_P:	equ "p"+128	;0x10
_CTRL_Q:	equ "q"+128	;0x11
_CTRL_R:	equ "r"+128	;0x12
_CTRL_S:	equ "s"+128	;0x13
_CTRL_T:	equ "t"+128	;0x14
_CTRL_V:	equ "v"+128	;0x16
_CTRL_W:	equ "w"+128	;0x17
_CTRL_X:	equ "x"+128	;0x18
_CTRL_Y:	equ "y"+128	;0x19
_CTRL_Z:	equ "z"+128	;0x1a


_ESC:		equ 0x1B
_INS:		equ 0x12
_DEL:		equ 0x7f
_ENTER:	equ 0x0D
_BACKSPACE:	equ 0x08
_SPACE:	equ 0x20




;===========================================================
; --- detect_keyboardtype
;
; inits
;===========================================================
detect_keyboardtype:
	; --- Read 0x002c from MSX BIOS
;	ld	a,0x80
;	ld	hl,0x2c
	;--- execute MSX BIOS call
;	rst	0x30
;	db	0x80
;	dw	0x000c 	;RDSLT

	ld	a,0x80
	ld	hl,0x002c
	call	0x000c
	and $0f
	
	;-- Set French to International
	cp	2
	jp	nz, 99f
	ld 	a,1
	;-- Set UK to International
	cp	3
	jp	nz, 99f
	ld 	a,1	
	;--- Set German to 2 = German mapping
	cp	4
	jp	nz,99f
	ld 	a,2
99:
	ld	(keyboardtype),a

	
	ret
	
;===========================================================
; --- create_keyboardtype_mapping
;
; inits
;===========================================================	
create_keyboardtype_mapping:
	ld	hl,KH_map_jap
	
	ld	a,(_CONFIG_KB)
	cp	3
	jp	c,99f
	ld	a,(keyboardtype)
99:
	and	a
	jr.	z,.matrixupdate
	;--- Update the note table for int and german keyboards
	ld 	hl,_KEY_NOTE_TABLE+$2e		;location of Y int, Z german
	dec	a
	jp	z,.setQWERTY
; --- German keyboard
.setQWERTZ:
	ld	(hl),0+1
	inc	hl
	ld 	(hl),9+12+1
	jp	0f
	
; --- International keyboard 	
.setQWERTY:
	ld	(hl),9+12+1
	inc	hl
	ld 	(hl),0+1
0:	
	ld	hl,KH_map_int
	
.matrixupdate:
	;--- copy the data to the keyboard mapping area
	;-- row 1 and 2
	ld	de,KH_mapping+8		;row1
	ld	bc,16
	ldir
	
	;-- row 11,0+shift, and 1+shift
	ld	de,KH_mapping+88		;row11
	ld	bc,24
	ldir		

	ret



	ret	
	
;===========================================================
; --- init_keyboard
;
; inits
;===========================================================
init_keyboard:
	; --- Clear the function key values
	ld	hl,0xf87f
	ld	(hl),0
	ld	de,0xf880
	ld	bc,160-1
	ldir
	
	;--- disable standard MSX keyclick
	xor	a
	ld	($F3DB),a		;CLIKSW

	call	detect_keyboardtype
	call	create_keyboardtype_mapping
	
	ret


;===========================================================
; --- read_key
;
; Reads the key pressed using the DOS function 
;===========================================================
read_key:
	ld	bc,(KH_buffer_writepos)	; C = writepos B= readpos

	ld	a,b
	cp	c
	jr.	z,_rk_nokey			; no key in buffer




	;--- calucalate read address
	ld	hl,KH_buffer
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	c,(hl)
	ld	a,16
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	b,(hl)
	
	ld	(KH_key),bc
	
	ld	a,(KH_buffer_readpos)
	inc	a
	and	15
	ld	(KH_buffer_readpos),a
	
;	ld	a,$0f
;	ld	($FBD9),a; CLIKFL	
	;- click
	ld	a,(KH_CLICK)
	and	a
	ret	z
	di
	ld	a,$0f
	out	($ab),a
	ld	a,$0a
0:	dec	a
	jr	nz,0b
	ld	a,$0e
	out	($ab),a
	ei


	ret

_rk_nokey:
	ld	bc,0
	ld	(KH_key),bc
	ret

;===========================================================
; --- read_functionkeys
;
; Reads the function keys. 
;===========================================================
read_functionkeys:
	xor	a
	ld	(fkey),a
	
	ld	a,(KH_matrix+6)
	ld	b,a
	
	ld	a,(KH_matrix+8)
	ld	d,a
	
	ld	a,6
	bit	1,b		; CTRL		
	jr.	z,_rfkEND	
	inc	a
	bit	2,b		; GRAPH		
	jr.	z,_rfkEND	
		
	xor	a		; no functional key found
_rfkEND:	
	ld	(fkey),a

	ld	a,1
	bit	0,b		; SHIFT
	jr.	z,_rfk2END	
	inc	a
	bit	1,d		; HOME
	jr.	z,_rfk2END		
	xor	a


_rfk2END:
	ld	(skey),a	
	
	
	ret
	


;==========================================
; key_handler
;
; customer keyboard handler
;
; changes: [A][BC][DE][HL][IX]
;
;
;==========================================
key_handler:
	;--- get the full keyboard matrix read-out and detect changes
	xor	a
	
;	ld	($fbd9),a
	
	ex	af,af'			;' keypress indicator

	ld	de,KH_matrix
	ld	hl,KH_matrix_old
	ld	b,0x0b			; number of rows to read
	in	a,(0xaa)
	and	0xf0
	ld	c,a


_kh_read_loop:
	ld	a,c
	out	(0xaa),a
	in	a,(0xa9)

	ld	(de),a
	;--- need to set timer to long on keychange?
	cp	(hl)				; Value has not changed?
	jr.	z,99f				; Jmp if not
				
	ld	a,KH_WAIT			; set long wait before repeat
	ld	(KH_timer),a	
99:
	;---- is there a key pressed
	cp	0xff
	jr.	z,99f
	ex	af,af'	;'
	inc	a
	ex	af,af'	;'
99:
	inc	hl
	inc	de
	inc	c
	djnz	_kh_read_loop

	;--- key pressed?
	ex	af,af'		;'
	and	a
	jr.	nz,99f
	
	ld	a,(KH_buffer_writepos)
	ld	(KH_buffer_readpos),a
99:

	;--- Changes detected?
	ld	a,(KH_timer)
	cp	KH_WAIT
	call	z,_kh_process_keys	; skip key process if no change
	

	;--- timer to start repeating the keys in the buffer
	ld	hl,KH_timer
	dec	(hl)
	ret	nz			; timer != 0



	;--- start repeating
	ld	(hl),KH_REPEAT		; short repeat time
	ld	hl,KH_matrix_old	; erase old matrix values
	ld	de,KH_matrix_old+1
	ld	bc,0x0a		
	ld	(hl),0xff
	ldir
	call	_kh_process_keys	; put new chars in th ringbuffer	

	ret

;------------------
; Process the matrix changes
;-------------------
_kh_process_keys:
	;---- get ctrl and shift additions values
	ld	ix,0
	ld	a,(KH_matrix+6)
	bit	0,a		; shift pressed?
	jr.	nz,99f
	ld	ixl,88
99:	
	bit	1,a		; control pressed?
	jr.	nz,99f
	ld	ixh,128
99:
	
	;--- Process the pressed keys (if any)
	ld	de,KH_matrix
	ld	hl,KH_matrix_old
	ld	b,0x0b
_kh_pk_loop:
	ld	a,(de)		; get new value
	ld	c,a
	xor	(hl)			; erase non changed bits
	and	(hl)			; erase key release transistions
	ld	(hl),c	
	call	nz,_kh_pk_getkey	; if a new key is pressed
	inc	de
	inc	hl
	djnz	_kh_pk_loop

	ret


;----
; Process the matrix value to get the key(s) and place 
; the result in the ring buffer.
;----
_kh_pk_getkey:
	push	hl			; save KH_matrix_old pointer
	push	de			; save KH_matrix pointer
	push	bc			; save row counter
	push	af			; save pressed bit(s)

	;--- calculate the base (number) of the key
	ld	a,0x0b
	sub	b			; calculate the row this key is on
	add	a,a
	add	a,a
	add	a,a			; *8
	ld	c,a			; store base in [c]
	
	ld	b,8			; test 8 bits
	pop	af			; restore pressed bit(s)
	
_kh_pk_gk_loop:
	rra				; rotate bit0 to carry flag
	call	c,_kh_pk_gk_found	; a bit is found put in buffer	
	inc	c			; increase base value
	djnz	_kh_pk_gk_loop
	
	pop	bc			; restore values
	pop	de
	pop	hl
	ret




	
;----
; Translate the key number
;
; in:
;	[C] contains key number.
;
; changes:
;	none
;----	
_kh_pk_gk_found:	
	push	hl
	push	bc			; save key value
	push	af			; save pressed bit(s)

	
	ld	a,c			; get key value
	cp	48		
	jr.	c,_kh_pk_gk_f_txt	; normal text keys
	cp	72		
	jr.	c,_kh_pk_gk_f_spc	; 'special' keys
	jr.	_kh_pk_gk_f_num	; num pad keys
	
_kh_pk_gk_f_end:
	pop	af
	pop	bc
	pop	hl
	ret
		

_kh_pk_gk_f_txt:

	ld	hl,KH_mapping	; address of the mapping table

	ld	a,c			; get key value
	add	a,ixl			; add shift offset
;	add	a,ixh			; add	control offset
;	cp	110			; CTRL+<capital character>?
;	jr.	c,99f
;	sub	ixl			; remove capital
;99:
	ld	c,a
	add	a,l			
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	and	a			; someting to put in buffer?
	jr.	z,_kh_pk_gk_f_end

	cp	ixh			; is control set (128)
	jr.	nc,99f			; no

	ld	b,a
	ld	a,c
	cp	110
	ld	a,b
	jr.	c,88f
	add	32
88:	add	ixh
99:	
	call	put_keybuffer	
	jr.	_kh_pk_gk_f_end	; return
	
	
	
	
_kh_pk_gk_f_num:
	ld	hl,KH_mapping	; address of the mapping table

	ld	a,c			; get key value
	add	a,ixh			; add	control offset

	add	a,l			
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	and	a			; someting to put in buffer?
	call	nz,put_keybuffer	
	jr.	_kh_pk_gk_f_end	; return
	
	
_kh_pk_gk_f_spc:
	ld	hl,KH_mapping	; address of the mapping table

	ld	a,c			; get key value

	add	a,l			
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(hl)
	and	a			; someting to put in buffer?
	call	nz,put_keybuffer	
	jr.	_kh_pk_gk_f_end	; return		




;----
; Put the key in the ring buffer
;
; in:
;	[C] contains key number.
;	[A] containts the translated value
;
; changes:
;	[A][B][HL]
;----	
put_keybuffer:
	ld	b,a
	
	ld	hl,KH_buffer
	ld	a,(KH_buffer_writepos)
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	(hl),b		; write translated value
	ld	a,16			
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	(hl),c		; write key value
	
	;--- set new buffer pointer
	ld	a,(KH_buffer_writepos)
	inc	a
	and	15
	ld	(KH_buffer_writepos),a

	ret


KH_CLICK			equ	_CONFIG_CLK		;db	1		; 0 = off, 1 = on
KH_WAIT			equ	32		; timer valueto wait for repeat
KH_REPEAT			equ	2		;repeat timer value
KH_timer			db	1		; timer to repeat key
;KH_timer_value:		db	0		; contains the timer to set.

KH_matrix			ds	11,255	; matrix read-out
KH_matrix_old		ds	11,255	; matrix read-out copy
KH_buffer_writepos	db	0		; fill pos
KH_buffer_readpos		db	0		; read pos
KH_buffer			ds	16,0		; contains the key characters
KH_buffer_values		ds	16,0		; contains original key values
key
KH_key			db	0
key_value
KH_key_value		db	0



;KH_fkey:			db	0		; fkeys, graph and ctrl
;KH_skey:			db	0		; shift and home

KH_mapping:		;[INTERNATIONAL]
	db	"0","1","2","3","4","5","6","7"
	db	"8","9","-","=","\\","[","]",";"
	db	"'","`",",",".","/",  0,"a","b"
	db	"c","d","e","f","g","h","i","j"
	db	"k","l","m","n","o","p","q","r"
	db	"s","t","u","v","w","x"
;KH_mapping_yl:	
	db	"y","z"	
	db	  0,  0,  0,  0,  0,  1,  2,  3
	db	  4,  5, 27,  9,  0,  8,  0, 13
	db	" ", 11, 18,127, 29, 30, 31, 28
	db	"*","+","/","0","1","2","3","4"
	db	"5","6","7","8","9","-",",","."

	db	")","!","@","#","$","%","^","&"
	db	"*","(","_","+","|","{","}",":"
	db	"\"","~","<",">","?", 0,"A","B"
	db	"C","D","E","F","G","H","I","J"
	db	"K","L","M","N","O","P","Q","R"
	db	"S","T","U","V","W","X"
;KH_mapping_yc:
	db	"Y","Z"	

;KH_keyboard-mappings:
;KH_map_jap:;
;	 db	255,5,6,255,255,255,255,255,255,255,255,7,8,9,255,255
;KH_map_int:
;	 db	255,0,1,255,255,255,255,255,255,255,255,2,3,4,255,255



;GLOBAL MAPPING:
KH_map_int:
	;int delta
	db	"8","9","-","=","\\","[","]",";"
	db	"'","`",",",".","/",  0,"a","b"
	db	")","!","@","#","$","%","^","&"
	db	"*","(","_","+","|","{","}",":"
	db	"\"","~","<",">","?", 0,"A","B"
KH_map_jap:	; jap delta
	db	"8","9","-","^","\\","@","[",";"
	db	":","]",",",".","/","_","a","b"	
	db	0  ,"!","\"","#","$","%","&","'"
	db	"(",")","=","~","|","`","{","+"
	db	"*","}","<",">","?",  0,"A","B"
	
