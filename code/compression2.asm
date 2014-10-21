;====================================
; decompress_pattern
; in b the pattern nr
; out hl = length of data -> length 20 (0x14) is empty pattern
;------------------------------------
decompress_pattern:
	call	set_patternpage	
	ld	de,pat_buffer		; perhaps this needs to be a param?
	
_dp_loop:	
	ld	a,(de)
	inc	de
	and	a
	jr.	nz,_dp_value
_dp_explode:
	ld	a,(de)
	inc	de
	and	a
	ret	z	; if 0,0 then end of pat data	
	
	ld	b,a
	xor	a
_dp_explode_loop:
	ld	(hl),a
	inc	hl
	;--- check memory range
	push	af
	ld	a,h;$c0
	cp	$c0
	jr.	c,99f
	
	pop	af
	ret	
;	ld	a,WIN_FILE_CORRUPT
;	call	catch_diskerror
99:
	pop	af	
	djnz	_dp_explode_loop	
	jr.	_dp_loop

_dp_value:
	ld	(hl),a
	inc	hl
	jr.	_dp_loop	


;====================================
; compress_pattern
; in b the pattern nr
; out hl = length of data -> length 20 (0x14) is empty pattern
;------------------------------------
compress_pattern:
	call	set_patternpage
	ld	de,pat_buffer
	
	ex	de,hl

	ld	bc,(8*4)*64	;--- process full pattern
	xor	a
	ex	af,af'	;'
_cp_loop:
	push	bc
	
	ld	a,(de)
	inc	de
	;--- test if it is a zero
	and	a
	jr.	z,_cp_loop_zero

	;-- did we find previous zeros?
	ex	af,af'		;'
	and	a
	jr.	z,99f
	;--- store the # found 
	ld	(hl),0
	inc	hl
	ld	(hl),a
	inc	hl
	xor	a
99:
	ex	af,af'		;'
	;--- store the normal value	
	ld	(hl),a
	inc	hl
	jr.	_cp_loop_END
	
_cp_loop_zero:
	ex	af,af'	;'
	inc	a
	cp	255
	jr.	nz,99f
	;--- reached the max
	ld	(hl),0
	inc	hl
	ld	(hl),a
	inc	hl
	inc	a
99:
	ex	af,af'		;'
		
_cp_loop_END:
	
	pop	bc
	dec	c
	jr.	nz,_cp_loop
	djnz	_cp_loop

	;-- did we find previous zeros?
	ex	af,af'		;'
	and	a
	jr.	z,99f
	;--- store the # found 
	ld	(hl),0
	inc	hl
	ld	(hl),a
	inc	hl
99:	;--- Delimiter !!!
	ld	(hl),0
	inc	hl
	ld	(hl),0
	inc	hl

	;-- calculate the REAL length
	ld	a,l
	sub	low (pat_buffer)
	ld	l,a
	ld	a,h
	sbc	high (pat_buffer)
	ld	h,a



	ret		
	