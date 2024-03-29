

draw_vu_empty:
	ld	a,(_CONFIG_VU)
	and	a
	ret	z


	ld	hl,_VU_VALUES
	ld	de,_VU_VALUES+1
	ld	(hl),0
[7]	ldi
	jr.	1f
	


;---------- VU meter
draw_vu:
	ld	a,(_CONFIG_VU)
	and	a
	ret	z

	ld	a,(_VU_UPDATE)
	and	a
	ret	z
	dec	a
	ld	(_VU_UPDATE),a


	;--- Determine the channel setup
	ld	a,(replay_chan_setup)
	and	$01
	jr.	z,.setup26
.setup35:
	ld	de,_VU_VALUES+3
	ld	hl,CHIP_Chan4+CHIP_Flags   
	ld	b, 5	
	jr.	.loop

.setup26:
	ld	de,_VU_VALUES+2
	ld	hl,CHIP_Chan3+CHIP_Flags  	
	ld	b, 6
	
.loop:	
	bit 	1,(hl)		; keyon
	jr.	z,.off
		
	ld	a,(de)
	ld	c,a
	ld	a,15
	sub	c
	ld	(de),a	
	
.loop_end:	
	inc	de
	ld	a,CHIP_REC_SIZE
	add	a,l
	ld	l,a
	jr.	nc,99f
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
	jr.	.loop_end




_vu_line_calc:
	ld	hl,_VU_VALUES
	ld	b,$08
	ld	de,_VU_LABEL

_vu_track_loop:
	ld	a,(hl)
	cp	4
	jr.	c,88f
	;--- >= 4
	sub	4
	ld	(hl),a
	ld	a,143+4
	ld	(de),a
	jr.	77f
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
