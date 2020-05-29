_VU_VALUES:
	db	"xxxxxxxx"
_VU_LABEL:
	db	"xxxxxxxx"

draw_vu_empty:
	ld	a,(_CONFIG_VU)
	and	a
	ret	z


	ld	hl,_VU_VALUES
	ld	de,_VU_VALUES+1
	ld	(hl),0
[7]	ldi
	jp	1f
	


;---------- VU meter
draw_vu:
	ld	a,(_CONFIG_VU)
	and	a
	ret	z

	ld	a,(replay_chan_setup)
	and	a
	jp	z,26f
35:
	;--- copy values
	ld	de,_VU_VALUES
	ld	hl,AY_regVOLA
[3]	ldi
	ld	hl,SCC_regVOLB	
	; copy and invert value
	ld	b,5
_dv_invert1:
	ld	c,(hl)
	ld	a,15
	sub	c
	ld	(de),a
	inc	de
	inc	hl
	djnz	_dv_invert1
	JP	1f
26:
	;--- copy values
	ld	de,_VU_VALUES
	ld	hl,AY_regVOLA
[2]	ldi
	ld	hl,SCC_regVOLA	
	; copy and invert value
	ld	b,6
_dv_invert2:
	ld	c,(hl)
	ld	a,15
	sub	c
	ld	(de),a
	inc	de
	inc	hl
	djnz	_dv_invert2




1:	call	_vu_line_calc
	ld	hl,(80*5)+48
	call	draw_label_fast

	call	_vu_line_calc
	ld	hl,(80*4)+48
	call	draw_label_fast

	call	_vu_line_calc
	ld	hl,(80*3)+48
	call	draw_label_fast

	call	_vu_line_calc
	ld	hl,(80*2)+48
	call	draw_label_fast

	ret



_vu_line_calc:
	ld	hl,_VU_VALUES
	ld	b,$08
	ld	de,_VU_LABEL

_vu_track_loop:
	ld	a,(hl)
	cp	4
	jp	c,88f
	;--- >= 4
	sub	4
	ld	(hl),a
	ld	a,143+4
	ld	(de),a
	jp	77f
	;---- < 4
88:	
	add	143
	ld	(de),a
	ld	(hl),0

77:
	inc	hl
	inc	de
	djnz	_vu_track_loop

	ld	de,_VU_LABEL
	ld	b,8
	ret
