;===========================================================
; --- set_songpage
;
; Sets the song page in bank 2. This contains songs vars
; (not pattern data)
;
; Input: A contains the song name
;===========================================================
set_songpage:
	ld	a,(song_list)
	call	PUT_P2
	ret

;===========================================================
; --- set_songpage_safe
;
; Sets the song page in bank 2. This contains songs vars
; (not pattern data)
; Special is that all registers are restored. Used in replayer
;
;
;===========================================================
set_songpage_safe:
	push	af
	push	hl
	push	de

	ld	a,(song_list)
	call	PUT_P2
	
	pop	de
	pop	hl
	pop	af
	
	ret
	
;===========================================================
; --- set_patternpage
;
; Sets the song pattern in bank 2. In hl the start is returned
; 
;
; Input: b contains the patternname
;
; Changed af,de,hl
;===========================================================
set_patternpage:	
	;- debug test to prefent going beyond highest pattern
	ld	hl,max_pattern
	ld	a,b
	cp	(hl)
	jr.	c,0f
	ld	a,(max_pattern)
	dec	a
	ld	b,a
0:
	ld	hl,song_list
2:
	; calculate the page and offset in the page
;	ld	a,b
	add	SONG_PATINSONG
	ld	b,a
	cp	SONG_PATINSEG
	jp	c,0f

	rrca	
	rrca	
	rrca	
	
	and	$1f
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	hl
99:
;	add	a,SONG_PATINSEG	
0:
;	push	af		; a contains the rest value

	; --- set the correct page
	ld	a,(hl)
	call	PUT_P2	

;	pop	af
	ld	a,b
	and	$07
	ld	hl,0x8000	; start of page
	and	a
	ret	z		; rest was 0
	
	ld	de,SONG_PATSIZE
2:
	add	hl,de
	dec	a
	jr.	nz,2b
	
	ret
	
;===========================================================
; --- set_patternpage_safe
;
; Sets the song pattern in bank 2. In hl the start is returned
; All registers are unchanged. Used in replayer.
;
; Input: none
;
; Changed af,de,hl
;===========================================================
set_patternpage_safe:
	push	af
	push	bc
	push	de
	push	hl
	
	ld	a,(song_pattern)
	ld	b,a
	call	set_patternpage
	
	pop	hl
	pop	de
	pop	bc
	pop	af
	
	ret