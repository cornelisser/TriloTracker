

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

	;--- Determine the channel setup
	ld	a,(replay_chan_setup)
	and	a
	jp	z,.setup26
.setup35:
	ld	de,_VU_VALUES+3
	ld	hl,FM_regToneB+2	; points to key on
	ld	b, 5	
	jp	.loop

.setup26:
	ld	de,_VU_VALUES+2
	ld	hl,FM_regToneA+2	; points to key on
	ld	b, 6
	
.loop:	
	bit 	4,(hl)		; keyon
	jp	z,.off
		
	ld	a,(de)
	ld	c,a
	ld	a,15
	sub	c
	ld	(de),a	
	
.loop_end:	
	inc	de
	ld	a,6
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	djnz .loop

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

.off:
	xor	a
	ld	(de),a
	jp	.loop_end




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
