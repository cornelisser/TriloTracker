;-----------------------------------------
; [A] = limit type. 0 = min volume is 0,
;       1 = min volume is 1
;-----------------------------------------
set_volumetable:
      and   a
      jp    nz,.limit1

;----- update PSG volumes
.limit0:
	ld	bc,0x1000
	jr.	.limit_cont

.limit1:
	ld	bc,0x1701
.limit_cont:
	ld	de,16
	ld	hl,AY_VOLUME_TABLE
	call	.limit_write
	ld	b,0x04
	call	.limit_write
	ld	b,0x03
	call	.limit_write
	ld	b,0x02
	call	.limit_write
	ld	b,0x02
	call	.limit_write
	ld	b,0x02
	call	.limit_write
	ld	b,0x02
	call	.limit_write
	ld	b,0x01
	call	.limit_write
	ld	b,0x01
	call	.limit_write
	ld	b,0x01
	call	.limit_write
	ld	b,0x01
	call	.limit_write
	ld	b,0x01
	call	.limit_write
	ld	b,0x01
	call	.limit_write
	ld	b,0x01
	call	.limit_write
	ld	b,0x01
	call	.limit_write

;---- update FM/SCC volume linmit
	ld	a,(_CONFIG_VOL)
	and	a
IFDEF TTSCC
	ld	c,0
	jr.	z,.start
	ld	c,1
ELSE
	ld	c,0x0f
	jp	z,.start
	ld	c,$0e
	
ENDIF

.start:
	ld	hl,SCC_VOLUME_TABLE
	ld	a,16
.loop:
	ld	b,a
	call	.limit_write
	dec	a
	jp	nz,.loop

      ret

;	[HL] = address to write
;	[B] = number of writes
;	[C] = value to write
.limit_write:
	push	hl
0:
	ld	(hl),c
	inc	hl
	djnz	0b
	pop	hl
	ld	de,16
	add	hl,de
	ret
