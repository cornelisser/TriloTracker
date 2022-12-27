;0000-03FE+      Window
;2000           PNT
;2a00           CNT
;2c00-3bff      instruments
;3c00-8fff      <free>
;9000-9800      PGT
;9800-0a00	    PGT backup

;a000-ebdd+     swap code

;--- sets the speed equalisation
set_vsf:
	xor	a
	ld	(equalization_flag),a

	ld	a,(_CONFIG_EQU)
	and	a
	jr.	nz,_sv_off
	
	ld	a,($FFE8)
	and	2
	jr.	nz,_sv_off
	
	ld	a,1
	ld	(vsf),a
	
	ld	a,6
	ld	(cnt),a
	
	ret
	
	
_sv_off:
	xor	a
	ld	(vsf),a
	ret

;--- These two funcitons are to switch the same font. But the backup can be 
;	used for drawing SCCwaveform (or other things)
set_font_org:
	di
	ld	a,00010010b ; Reg#4 [ 0 ][ 0 ][A16][A15][A14][A13][A12][A11]  - Pattern generator table
	jp	_set_font_cont

set_font_backup:
	ld	a,00010011b ; Reg#4 [ 0 ][ 0 ][A16][A15][A14][A13][A12][A11]  - Pattern generator table
_set_font_cont:
	out	(0x99),a
	ld	a,4+128
	out	(0x99),a	
	ei
	ret	


	
	; --- set_vdpwrite
	; sets up the vdp address in HL to write to
	; disables ISR and changes a

set_vdpwrite:
	xor	a
	rlc	h
	rla
	rlc	h
	rla
	srl	h
	srl	h
	di
	out	(#99),a
	ld	a,14+128
	out	(#99),a
	ld	a,l
	nop
	out	(#99),a
	ld	a,h
	or	64
;	ei
	out	(#99),a
	ret





	; --- set_vdpread
	; sets up the vdp address in HL to read from
	; enables ISR and changes a

set_vdpread:
	xor	a
	rlc	h
	rla
	rlc	h
	rla
	srl	h
	srl	h
	di
	out	(#99),a
	ld	a,14+128
	out	(#99),a
	ld	a,l
	nop
	out	(#99),a
	ld	a,h
	out	(#99),a
	ei
	ret



; ================================================
; --- set_textcolor
;
; Set the color corresponfing to the active song
;
; IN: [A] the type 1=keyjazz, 0=normal.
; ================================================
set_textcolor:
;	ld	a,(keyjazz)
	ld	hl,TABLE_COLOR_THEMES
;	rlca
;	rlca
;	rlca
;	add	a,l
;	ld	l,a
;	jr.	nc,99f
;	inc	h
99:
	ld	a,(_CONFIG_THEME)
	add	a
	add	a
	add	a
;	add	a
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:
	ld	a,(keyjazz)
	and	a
	jr.	z,99f
	ld	a,$32
99:
	ld	(hl),a
	

	xor	a
	call	_write_pallete
;	ld	a,b
	ld	a,$f
	call	_write_pallete
	

	ld	a,1;$E1;($FFEA)		; get blink colors TTTTBBBB
;	ld	b,a
;	and	$0f
;	srl	b
;	srl	b
;	srl	b
;	srl	b
	
	call	_write_pallete
;	ld	a,b
	ld	a,$e
	call	_write_pallete

	ei
	ret

; [A] = color# to write.
_write_pallete:
	;add	a		; 2 per color
	out 	($99),a
	ld 	a,16+128
	out	($99),a
	ld	a,(hl)
	inc	hl
	out	($9a),a
	ld	a,(hl)
	inc	hl
	out	($9a),a
	ret	
TABLE_COLOR_THEMES:
;	;  	RB   G
_theme1a:
	db 	$00,$0		;backgrnd
	db 	$77,$7		;text
	db	$23,$3		; back blink
	db	$67,$7
_theme2a:
	db 	$00,$0		;backgrnd
	db 	$77,$7		;text
	db	$14,$2		; back blink
	db	$67,$6
_theme3a:
	db 	$00,$0		;backgrnd
	db 	$77,$7		;text
	db	$42,$4		; back blink
	db	$76,$7
_theme4a:
	db 	$00,$0		;backgrnd
	db 	$77,$7		;text
	db	$07,$1		; back blink
	db	$00,$0
_theme5a:
	db 	$00,$0		;backgrnd
	db 	$67,$7		;text
	db	$02,$1		; back blink
	db	$37,$7		
_theme6a:
	db 	$00,$0		;backgrnd
	db 	$75,$6		;text
	db	$51,$2		; back blink
	db	$75,$6
_theme7a:
	db 	$00,$0		;backgrnd
	db 	$77,$7		;text
	db	$12,$3		; back blink
	db	$56,$7
_theme8a:
	db 	$00,$0		;backgrnd
	db 	$77,$7		;text
	db	$32,$1		; back blink
	db	$76,$5
_theme9a:
	db 	$01,$0		;backgrnd
	db 	$57,$5		;text
	db	$53,$0		; back blink
	db	$77,$7	
_theme10a:
	db 	$00,$0		;backgrnd
	db 	$77,$7		;text
	db	$33,$3		; back blink
	db	$66,$6	