;===========================================================
; --- draw_samplebox
; Display the  area.  Without actual values 
; 
;===========================================================
draw_macrobox:

	;--- Display the keyjazz chip
	ld	hl,_LABEL_keyjazz
	ld	a,(keyjazz_chip)

		dec	a
		jr.	nz,44f
		;-- psg
		ld	(hl),160
		inc	hl
		ld	(hl),161
		jr.	99f
44:
		dec	a
		jr.	nz,44f	
		;-- scc
		ld	(hl),162+8
		inc	hl
		ld	(hl),163+8	
		jr.	99f

44:
		;-- psg+scc
		ld	(hl),158
		inc	hl
		ld	(hl),159
		jr.	99f
99:

	; box around number, length, restart etc
	ld	hl,(80*6)+8
	ld	de,(49*256) + 3
	call	draw_box
	
	; box around macro lines
	ld	hl,(80*9)+0
	ld	de,((31+_base)*256) + 17
	call	draw_box	
	
	;box around FM voice
	ld	hl,(80*9)+30+_base
	ld	de,(34*256) + 17
	call	draw_box	
	;box around waveform data
;	ld	hl,(80*17)+32
;	ld	de,(15*256) + 9
	

	ld	hl,(80*6)+1+8
	ld	de,_LABEL_SAMPLEBOX
	call	draw_label
	
	ld	hl,(80*7)+2+8
	ld	de,_LABEL_SAMPLETEXT
	call	draw_label
	ld	hl,(80*8)+2+8
	ld	de,_LABEL_SAMPLETEXT2
	call	draw_label


	ld	hl,(80*9)+1
	ld	de,_LABEL_SAMPPLEMACRO
	call	draw_label

	;--- FM voice stuff
	ld	hl,(80*9)+1+28+2+_base
	ld	de,_LABEL_SAMPPLEFORM
	call	draw_label
	ld	hl,(80*12)+1+28+16+6+_base
	ld	de,_LABEL_VOICE_EDIT_HEADER
	call	draw_label

	; editor labels
	ld	hl,(80*13)+2+28+2+_base
	ld	de,_LABEL_VOICE_EDIT
	ld	ixh, 13
66:
	push	hl
	call	draw_label
	inc	de
	pop	hl
	ld	bc,80
	add	hl,bc
	dec	ixh
	jr.	nz,66b
	
				
	; instrument edit box
	ld	hl,0x0806
	ld	de,0x3103	
	call	draw_colorbox	
	;ld	hl,0x0a08
	;ld	de,0x0501	
	;call	erase_colorbox	
	ld	hl,0x0f08
	ld	de,0x0401	
	call	erase_colorbox		
	ld	hl,0x1408
	ld	de,0x0401	
	call	erase_colorbox
	ld	hl,0x1908
	ld	de,0x0401	
	call	erase_colorbox

	ld	hl,0x1e08
	ld	de,0x1001	
	call	erase_colorbox
	ld	hl,0x2f08
	ld	de,0x0401	
	call	erase_colorbox
	ld	hl,0x3408
	ld	de,0x0401	
	call	erase_colorbox

	; under the info top area
	ld	hl,0x0009
	ld	de,0x5012	
	call	draw_colorbox

	; R column of mnacro?
	ld	hl,0x010a
	ld	de,0x0110	
	call	erase_colorbox	

	; macro data
	ld	hl,0x040a
	ld	de,0x1a10+(_base*256)	
	call	erase_colorbox	

	; voice values
	ld	hl,0x330d+(_base*256)
	ld	de,0x040d	
	call	erase_colorbox
	ld	hl,0x3a0d+(_base*256)
	ld	de,0x0406	
	call	erase_colorbox
	ld	hl,0x3a14+(_base*256)
	ld	de,0x0401	
	call	erase_colorbox
	ld	hl,0x3a16+(_base*256)
	ld	de,0x0404	
	call	erase_colorbox	
	
	; voice name
	ld	hl,0x240a+(_base*256)
	ld	de,0x1401	
	call	erase_colorbox
	

	ret
	
_LABEL_SAMPLEBOX:
	db	"instrument edit:",0
_LABEL_SAMPPLEMACRO:
	db	"Macro:",_HORIZONTAL,"freq",_HORIZONTAL,_HORIZONTAL,_HORIZONTAL,_HORIZONTAL,_HORIZONTAL,_HORIZONTAL,"vol",_HORIZONTAL,_HORIZONTAL,_HORIZONTAL,_HORIZONTAL,_HORIZONTAL,_HORIZONTAL,"noi",_HORIZONTAL,"fmv",0
_LABEL_SAMPPLEFORM:
	db	"Fm voice:",0
_LABEL_SAMPLETEXT:
	db	"Ins: Len: Rst: Wav: Description:     Oct: Tst:",0
_LABEL_SAMPLETEXT2:	
	db	_ARROWLEFT," x",_ARROWRIGHT,32
	db	_ARROWLEFT,"xx",_ARROWRIGHT,32
	db	_ARROWLEFT,"xx",_ARROWRIGHT,32
	db	_ARROWLEFT,"xx",_ARROWRIGHT
_LABEL_SAMPLETEXT2SUB:
	db	"                  "
	db	_ARROWLEFT,"xx",_ARROWRIGHT,32		
	db	_ARROWLEFT
_LABEL_keyjazz:
	db	"  ",_ARROWRIGHT,0
_PSG_SAMPLESTRING:
	db	"tnv+000 [000]                                 "
;	db	" xxTN _xxx _xx _x **************** ***** *****",0
;	db	"           [000]        X****   "

_NOISE_0:
	db	"[pHi]"
_NOISE_1:
	db	"[pMe]"
_NOISE_2:
	db	"[pLo]"
_NOISE_3:
	db	"[pCh]"
_NOISE_4:
	db	"[wHi]"
_NOISE_5:
	db	"[wMe]"
_NOISE_6:
	db	"[wLo]"
_NOISE_7:
	db	"[wCh]"



_LABEL_VOICE_EDIT_HEADER:
	db	"Mod.   Car.",0
	
_LABEL_VOICE_EDIT:
	db	"Amp Modulation",0
	db	"Freq Vibration",0
	db	"Envelope Type(D/S)",0
	db	"Key Scale Rate",0
	db	"Modulation Level",0
	db	"Key Scale Level",0
	db	"Mod Total Level",0
	db	"Waveform",0
	db	"Feedback",0
	db	"Attack",0
	db	"Decay",0
	db	"Sustain",0
	db	"Release",0



_ups_pntpos:	dw	0
;_ups_tone:		dw	0
;_ups_noise:		db	0
;_ups_volume:	db	0


_PSG_VOL0:	db  32, 32, 32, 32, 32
_PSG_VOL1:	db 247, 32, 32, 32, 32
_PSG_VOL2:	db 246, 32, 32, 32, 32
_PSG_VOL3:	db 245, 32, 32, 32, 32
_PSG_VOL4:	db 245,247, 32, 32, 32
_PSG_VOL5:	db 245,246, 32, 32, 32
_PSG_VOL6:	db 245,245, 32, 32, 32
_PSG_VOL7:	db 245,245,247, 32, 32
_PSG_VOL8:	db 245,245,246, 32, 32
_PSG_VOL9:	db 245,245,245, 32, 32
_PSG_VOLA:	db 245,245,245,247, 32
_PSG_VOLB:	db 245,245,245,246, 32
_PSG_VOLC:	db 245,245,245,245, 32
_PSG_VOLD:	db 245,245,245,245,247
_PSG_VOLE:	db 245,245,245,245,246
_PSG_VOLF:	db 245,245,245,245,245

;===========================================================
; --- update_macrobox
; Display the values
; 
;===========================================================
update_macrobox:
	;--- Make sure the cursor is inside the macro
	ld	a,(instrument_len)
	ld	b,a
;	ld	a,(instrument_macro_offset)
;	ld	c,a
	ld	a,(instrument_line)
;	add	c
	cp	b
	jr.	c,99f
	call	reset_cursor_macrobox	
99:
	;--- Make sure the cursor is on Noise/Voicelink only if
	;    active




	;--- Get the current sample
	ld	a,(instrument_macro_offset)
	ld	c,a			; contains the line#
	ld	b,16		
	; add offset here somewhere
	
	
	; -- Init and store the display pos in PNT
	ld	hl,(80*9)+1			; start position
	ld	(_ups_pntpos),hl	
	
	
	;--- Calculate the position in RAM of current sample	
	call	_get_instrument_start
	
	ld	a,(hl)
	ld	(instrument_len),a
	inc	hl
	ld	a,(hl)
	ld	(instrument_loop),a
	inc	hl
	ld	a,(hl)
	ld	(instrument_waveform),a
	inc	hl
	
	ld	a,c
	and	a
	jr.	z,4f
	ld	de,4
3:
	add	hl,de
	dec	a
	jr.	nz,3b	
	
4:	
	
	
_ups_lineloop:	
	;each line
	ld	de,_PSG_SAMPLESTRING	
	
	;	check if we are at the end.
	ld	a,(instrument_len)
	dec	a
	cp	c
	jr.	nc,0f
	; --- YES draw empty line
		inc	c				; increase line number
		push	bc				; store line+len	
		ld	a," "
		ld	b,23+6+8+7
10:		ld	(de),a
		inc	de
		djnz	10b
		jr.	_ups_draw
	;-- YES draw data!!!
0:	
	;--- Check if we are at loop pos
	ld	a,(instrument_loop)
	cp	c
	jr.	c,2f
	jr.	nz,1f
	ld	a,_LOOPSIGN
	jr.	3f
	
1:	ld	a," "
	jr.	3f	
2:	;--- looping area
	ld	a,191
3:	ld	(de),a
	inc	de
	
	; draw the line number
	ld	a,c
	call	draw_hex2			; draw hex line number

	inc	c				; increase line number
	push	bc				; store line+len

	; --- continue
	; get info bytes
	ld	b,(hl)			; store byte2 in b
	inc	hl
	ld	c,(hl)			; store byte3 in c
	inc	hl
	
	;--- tone indicator
	ld	a,_TONE_ON_SIGN
	bit	7,c				; 1 = Tone on.
	jr.	nz,1f	
	dec	a
1:
	ld	(de),a
	inc	de
	
	;--- noise indicator
	ld	a,_NOISE_ON_SIGN
	bit	7,b				; 1 = Noise on.
	jr.	nz,1f	
	dec	a
1:
	ld	(de),a
;	inc	de	
	
	;--- voice link indicator
	inc	hl
	ld	a,(hl)
	dec	hl
	and	128			;bit 	7,a
	ld	a,_NOISE_ON_SIGN+4
	jr. 	z,1f
	ld	a,_NOISE_ON_SIGN-1
	ld	(de),a
	add	6	

1:	
	inc	de
	ld	(de),a	
	inc	de

	;---- tone deviation
	ld	a,"+";
1:	;- acc
	bit	6,c
	jr.	z,99f			; 0 = add
	;--- min
	ld	a,"-"			; 1 = subtract
99:	;--- add
	ld	(de),a	
	inc	de

	; the tone deviation values	
	ld	a,(hl)
	ex	af,af'	;'
	inc	hl
	ld	a,(hl)
	inc	hl

	call	draw_hex
	ex	af,af'		;'
	call	draw_hex2

	; the tone accumulation (for John)
	inc	de
	ld	a,"["
	ld	(de),a

	inc	de
	inc	de
	inc	de
	inc	de
	ld	a,"]"
	ld	(de),a
	inc	de
	inc	de

_vol_update:
	push	bc
	;--- Volume	
	ld	a,c
	and	00110000b
	jp	z,_ups_base
	cp	00100000b
	jp	z,_ups_add
	cp	00110000b
	jp	z,_ups_sub

IFDEF TTFM
_ups_env:
	;- Envelope
	ld	a,"^"
	ld	(de),a
	inc	de

	ld	a,c
	and	0x0f
	call	draw_hex

	push	hl
	ld	a,c
	and	0x0f
	jp	z,.env_no
	cp	4
	jp	c,.env_0
	cp	8
	jp	c,.env_4
	jp	z,.env_8
	cp	$a
	jp	c,.env_0
	jp	z,.env_a
	cp	$c
	jp	c,.env_b
	jp	z,.env_c
	cp	$e
	jp	c,.env_d
	jp	z,.env_e
.env_4:
	ld	hl,ENVELOPE_4567F
	jp	.print
.env_0:
	ld	hl,ENVELOPE_01239
	jp	.print
.env_8:
	ld	hl,ENVELOPE_8
	jp	.print
.env_a:
	ld	hl,ENVELOPE_A
	jp	.print
.env_b:
	ld	hl,ENVELOPE_B
	jp	.print
.env_c:
	ld	hl,ENVELOPE_C
	jp	.print
.env_d:
	ld	hl,ENVELOPE_D
	jp	.print
.env_no:
	ld	hl,ENVELOPE_NO
	jp	.print
.env_e:
	ld	hl,ENVELOPE_E
.print	
	inc	de
	ld	bc,4
	ldir
	pop	hl
	inc	de
	jp	55f

ENVELOPE_NO:
	db	'    '
ENVELOPE_01239:
	db	$b3,$b5,$b5,$b5			;'\___'
ENVELOPE_4567F:	
	db	$b2,$b5,$b5,$b5			;'/___'
ENVELOPE_8:
	db	$b3,$b3,$b3,$b3			;'\\\\'
ENVELOPE_A:
	db	$b3,$b2,$b3,$b2			;'\/\/'
ENVELOPE_B:
	db	$b3,$b4,$b4,$b4			;'\"""'
ENVELOPE_C:
	db	$b2,$b2,$b2,$b2			;'////'
ENVELOPE_D:
	db	$b2,$b4,$b4,$b4			;'/"""'
ENVELOPE_E:
	db	$b2,$b3,$b2,$b3			;'/\/\'
ENDIF

_ups_base:
	ld	a,"_"
	jp	0f
_ups_add:
	;- add
	ld	a,"+"
	jp	0f
_ups_sub:
	ld	a,"-"
0:
	ld	(de),a
	inc	de

	ld	a,c
	and	0x0f
	call	draw_hex

	ld	a,c
	and	0x0f
1:
	inc	de
	call	draw_volumebar
55:
	inc	de
	pop	bc
	
_noise_dev:
	; noise deviation
IFDEF TTFM
	ld	a,(_PSG_SAMPLESTRING+5)
	cp	_NOISE_ON_SIGN+5
	jr.	z,88f

	ld	a,"_";151
	bit	6,b
	jr.	z,99f
	;-not base	
	ld	a,"-"		;	add	a,2
0:
	bit	5,b
	jr.	nz,99f
	;- add
	ld	a,"+"		;	inc	a
99:	

	ld	(de),a
	inc	de

	ld	a,b
	and	0x1f	
	
	call	draw_hex2
	inc	de
	jp	2f
88:	;--- draw empty
	ld	a," "	; space
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	inc	de
	
	
2:	
ELSE	; TTSMS

	ld	a,(_PSG_SAMPLESTRING+5)
	cp	_NOISE_ON_SIGN+5
	jr.	nz,88f
	
	push	hl
	ex	de,hl
	ld	a,15
0:	ld	(hl),32
	inc	hl
	dec	a
	jp	nz,0b
	
	ex	de,hl
	pop	hl
	jp	2f
	
88:
	push	hl
	ld	a,b		; Draw noise value
	and	01110000b
	srl 	a
	srl	a
	ld	l,a
	rr	a
	rr	a
	
	push	af
	call	draw_hex
	pop	af
	
	add	a,l

	ld	hl,_NOISE_0
	add	a,l
	ld	l,a
	jp	nc,99f
	inc	h
99:
	push	bc
	ld	bc,5
	ldir
	pop	bc
	inc	de
	
	; Draw Volume
	ld	a,"_"
	ld	(de),a
	inc	de	
	
	ld	a,b
	and	0x0f	
	push	af
	call	draw_hex
	inc	de
	pop	af
	call	draw_volumebar	
	pop	hl
2:


	
ENDIF
;	inc	de
	ld	a,(_PSG_SAMPLESTRING+5)
	cp	_NOISE_ON_SIGN+5
	jr.	z,88f

	ld	a,0
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de	
	ld	(de),a
	inc	de
	jp	55f
88:
;// voice link active
	ld	a,"v"
	ld	(de),a
	inc	de
	ld	a,b	
	and	00001111b
	call	draw_hex2
;	jp	55f





_ups_draw:
55:	; end of line making,,,,,
	push	hl			; store data pointer
	ld	hl,(_ups_pntpos)	; get pnt pointer
	ld	de,80
	add	hl,de			; store new position
	ld	(_ups_pntpos),hl
	

	ld	de,_PSG_SAMPLESTRING	; draw the string
	ld	b,45
	call	draw_label_fast	
	
	pop	hl
	pop	bc	
	
	dec	b
	jr.	nz,_ups_lineloop


	ld	de,_LABEL_SAMPLETEXT2+2
	ld	a,(song_cur_instrument)
	call	draw_fake_hex_sp

	ld	de,_LABEL_SAMPLETEXT2+5+1
	ld	a,(instrument_len)
	call	draw_decimal
	
	ld	de,_LABEL_SAMPLETEXT2+11
	ld	a,(instrument_loop)
	call	draw_decimal
		
	ld	de,_LABEL_SAMPLETEXT2+16
	ld	a,(instrument_waveform)
	call	draw_hex2		
	
	ld	de,_LABEL_SAMPLETEXT2+16+22
	ld	a,(song_octave)
	call	draw_decimal

	;--- set the instrument name
	ld	a,(song_cur_instrument)
	ld	l,a
	xor	a		; [a] to catch carry bit
	sla	l		; offset  *16
	sla	l
	sla	l
	sla	l
	adc	a,0		; only the 4th shift can cause carry
	ld	h,a
	ld	de,song_instrument_list-16
	add	hl,de	
	ld	bc,16
	ld	de,_LABEL_SAMPLETEXT2SUB+1
	ldir


	ld	hl,(80*8)+2+8+1
	ld	de,_LABEL_SAMPLETEXT2+1
	ld	b,25+13+6
	call	draw_label_fast

	
	call	update_tonecum
	ret

draw_volumebar:
	; volume bar
	push	hl
	push	bc
	ld	hl,_PSG_VOL0
	ld	bc,5
	and	0x0f
	jr.	z,1f
0:
	add	hl,bc
	dec	a
	jr.	nz,0b
1:	
	ld	bc,5
	ldir	
	pop	bc
	pop 	hl
	ret



update_tonecum:
	; -- Init and store the display pos in PNT
	ld	hl,(80*9)+13			; start position
	ld	(_ups_pntpos),hl	



	;--- init the cummulative tone deviation
	ld	de,0
	;--- there is an offset. calculate what we don't show
	;--- Calculate the position in RAM of current sample	
	call	_get_instrument_start
	
	ld	a,(hl)
	dec	a
	ld	ixh,a
	ld	bc,4
	add	hl,bc		; now we point at deviation type byte
	
	ld	bc,0	
_upsb_loop:
	push	bc
	ld	bc,0
	ld	a,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ex	de,hl
	and	64
	jr.	z,_upsb_add
	;-- sub
	xor	a
	sbc	hl,bc
	jr.	44f
_upsb_add:
	add	hl,bc
	
44:	
	ex	de,hl
	inc	hl
	inc	hl
	pop	bc
	ld	a,(instrument_macro_offset)
	inc	c
	cp	c
	jr.	nc,3f		; skip display
	;--- display the value
	push	de
	push	hl
	push	bc
	ex	de,hl
	ld	de,_PSG_SAMPLESTRING+12
	ld	a,h
	call	draw_hex
	ld	a,l
	call	draw_hex2
	
	ld	hl,(_ups_pntpos)
	ld	bc,80
	add	hl,bc
	ld	(_ups_pntpos),hl
	ld	de,_PSG_SAMPLESTRING+12
	ld	b,3
	call	draw_label_fast

	pop	bc
	pop	hl
	pop	de
	inc	b	
3:	
;	inc	c
	ld	a,ixh
	cp	c
	ret	c

	ld	a,15
	cp	b
	jr.	nc,_upsb_loop

	ret

;--- Move macro data 1 line down (delete row)
; in: [A] is the line to move down/delete
;
; need to preserve [A]
;_move_macrolinedown:
;	push	af
;	;-- set hl to start macro data of current instrument
;	call	_get_instrument_start
;	dec	hl
;	dec 	hl
;	;-- jump to line ( input)
;	pop	bc
;	push	bc
;	inc	b
;	ld	de,4
;.loop:
;	add	hl,de
;	djnz	.loop
;
;	;--- copy the data to next line
;	ld	d,h	
;	ld	e,l
;	ld	a,4
;	add	a,l
;	ld	l,a
;	jr.	nc,.skip
;	inc	l
;.skip:
;	ldi
;	ldi
;	ldi
;	ldi
;	
;	;--- restore and return 	
;	pop	af
;	ret
	
;--- Move macro data 1 line up (insert row)
; in: [A] is the line to move up
;
; need to preserve [A]
;_move_macrolineup:
;	push	af
;	;-- set hl to start macro data of current instrument
;	call	_get_instrument_start
;	inc	hl
;	inc 	hl
;	inc	hl
;	;-- jump to line ( input)
;	ex	af,af
;	add	a	; x2
;	add	a	; x4
;	add	a,l
;	ld	l,a
;	jp	nc,99f
;	inc	h
;99:
;
;	;--- copy the data to next line
;	ld	d,h	
;	ld	e,l
;	ld	a,4
;	add	a,e
;	ld	e,a
;	jr.	nc,.skip
;	inc	d
;.skip:
;	ldi
;	ldi
;	ldi
;	ldi
;	;--- restore and return 	
;	pop	af
;	ret
	
	


;--- Get instrument start
; return in HL that start of the instrument data
;
_get_instrument_start:
	push	bc
	ld	hl,instrument_macros
	ld	a,(song_cur_instrument)
	and	a
	jr.	z,99f
	ld	bc,INSTRUMENT_SIZE
88:
	add	hl,bc
	dec	a
	jr.	nz,88b
99:
	pop	bc
	ret
	
	
;===========================================================
; --- process_key_macrobox_musickb
;
; Process the input for the pattern. 
; There are 2 version for compact and full view
; 
;===========================================================
process_key_macrobox_musickb:
	ld	a,(music_key)
	and	a
	ret	z				; stop if no key found

	;--- check for keyjazz
	;ex	af,af'	
;	ld	a,(keyjazz)
;	and	a
;	jr.	nz,process_key_keyjazz
;	ret
	jr.	process_key_keyjazz
;===========================================================
; --- process_key_macrobox
;
; Process the input for the PSG sample. 
; 
; 
;===========================================================
process_key_macrobox:

	call	process_key_macrobox_musickb
	
	ld	a,(key)
	and	a
	ret	z


	;--- INS key to insert macro line
	cp	_INS
	jr.	nz,0f
	ld	a,(instrument_line)
	cp	31			; check if we are at last line
	jr.	nc,process_key_macrobox_END
	;--- increase len
	
	;--- get the location in RAM
	call	_get_instrument_start	
	;inc	hl
	ld	a,(hl)
	cp	32
	jr.	nc,99f
	inc	a
	ld	(hl),a
	ld	(instrument_len),a
99:

	;--- move data 1 line down
	ld	de,(30*4)+3+3		
	add	hl,de
	ld	d,h
	ld	e,l
	inc	de
	inc	de
	inc	de 
	inc	de
	
	ld	a,(instrument_line)
	ld	b,a
	ld	a,31
	sub	a,b
	add	a	;x2
	add	a	;x4
	ld	c,a
	ld	b,0
	
	lddr
;	
;	ld	a,(instrument_line)
;	ld	ixh,a
;	ld	a,30		; start from end to current line
;.line_loop:
;	call	_move_macrolineup
;	and	a
;	jr.	z,88f
;	dec	a
;	cp	ixh
;	jr.	nc,.line_loop
;88:	
	call	update_macrobox
	jr.	process_key_macrobox_END	

0:	
	;--- DEL key to delete macro line
	cp	_BACKSPACE
	jr.	nz,0f

	ld	a,(instrument_line)
	inc	a
	ld	b,a
	ld	a,(instrument_len)
	cp	b			; check if we are at last line
	jr.	nz,1f
	
	cp	1	
	jr.	z,process_key_macrobox_END
	
	call	_get_instrument_start
	ld	a,(hl)
	dec	a
	ld	(hl),a
	dec	a
	ld	(instrument_line),a
	;-- restart move
	inc	hl		
	ld	b,a
	ld	a,(hl)
	and	a
	jr.	z,99f
	cp	b
	jr.	c,99f
	dec	(hl)
99:	
	;--- update screen
	call	flush_cursor
	ld	a,(cursor_y)
	dec	a
	ld	(cursor_y),a
	
	
	call	update_macrobox
	jr.	process_key_macrobox_END	
	
	;--- decrease len
1:	
	;--- get the location in RAM
	call	_get_instrument_start	
	;inc	hl
	ld	a,(hl)
	cp	1
	jr.	z,99f
	dec	a
	ld	(hl),a
	ld	(instrument_len),a

99:	
	;--- check for moving restart
	ld	b,(hl)
	inc	hl
	ld	a,(hl)
	cp	b
	jr.	c,99f
	dec	b
	ld	(hl),b
99:
	inc	hl	; set HL to start of first line of data
	inc	hl
	;-- Get address of current line
	ld	a,(instrument_line)
	cp	31
	jp	nc,88f
	add	a	;x2
	add	a	;x4
	add	a,l
	ld	l,a
	jp	nc,99f
	inc 	h
99:
	ld	d,h	; store in DE
	ld	e,l
	
	inc	hl	; point hl to next line
	inc	hl	
	inc	hl
	inc	hl
	
	;calculate how many bytes to move here.
	ld	a,(instrument_line)
	ld	b,a
	ld	a,31
	sub	b
	add	a
	add	a
	ld	c,a
	ld	b,0
	
	ldir
	
;	
;
;	;--- move data 1 line down
;	ld	a,(instrument_line)
;;	ld	ixh,a
;;	ld	a,30		; start from end to current line
;.line_loopdel:
;	call	_move_macrolinedown
;	inc	a
;	cp	31
;	jr.	z,88f
;	jr.	.line_loopdel
88:	
	call	update_macrobox
	jr.	process_key_macrobox_END	
	
				
0:	
	;--- key left
	cp	_KEY_LEFT
	jr.	nz,0f
	; column left
	ld	hl,_COLTAB_MACRO
	ld	a,(cursor_column)
	add	a
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h	
99:
	; check if we are at the end?
	dec	hl
	ld	a,(hl)
	cp	255
	jr.	z,process_key_macrobox_END
	
	; get the displacement)
	ld	b,a
	call	flush_cursor
	ld	a,(cursor_x)
	sub	b
	ld	(cursor_x),a
	
	;set the new input type and cursor.
	dec	hl
	ld	a,(hl)
	ld	(cursor_input),a
	ld	hl,cursor_column
	dec	(hl)
	
	jr.	process_key_macrobox_END			
0:		
	;--- key right
	cp	_KEY_RIGHT
	jr.	nz,0f
	; column right
_psgsamright:
	ld	hl,_COLTAB_MACRO
	ld	a,(cursor_column)
	add	a
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h	
99:
	; check if we are at the end?
	inc	hl
	ld	a,(hl)
	cp	255
	jr.	z,44f
	
	; get the displacement)
	ld	b,a
	call	flush_cursor
	ld	a,(cursor_x)
	add	b
	ld	(cursor_x),a
	
	;set the new input type and cursor.
	inc	hl
	ld	a,(hl)
	ld	(cursor_input),a
	and	a
	ld	a,1
	jr.	nz,99f
	ld	a,3	
99:	
	ld	(cursor_type),a
	ld	hl,cursor_column
	inc	(hl)
44:	
	call	update_macrobox
	jr.	process_key_macrobox_END			
0:		

	;--- key down
	cp	_KEY_DOWN
	jr.	nz,0f
	; row down
	ld	a,(instrument_len)
	ld	b,a
	ld	a,(instrument_line)
	inc	a
	cp	b
	jr.	nc,process_key_macrobox_END
	
	ld	(instrument_line),a
	call	flush_cursor
	ld	a,(cursor_y)
	inc	a
	cp	26
	jr.	z,88f
	ld	(cursor_y),a
	jr.	77f			
88:	ld	a,(instrument_macro_offset)
	inc	a
	ld	(instrument_macro_offset),a
77:	call	update_macrobox
	jr.	process_key_macrobox_END		
99:	;-- see if we need to go to the next column
	ld	a,(instrument_line)	
	cp	16
	jr.	nz,88f
	ld	a,(cursor_y)
	sub	15
	ld	(cursor_y),a
	ld	a,(cursor_x)
	add 	40
	ld	(cursor_x),a
88:	call	update_macrobox
	jr.	process_key_macrobox_END	
	
0:		
	;--- key up
	cp	_KEY_UP
	jr.	nz,0f
	; row up
	ld	a,(instrument_line)
	and	a
	jr.	z,process_key_macrobox_END
	
	dec	a
	ld	(instrument_line),a
	call	flush_cursor
	ld	a,(cursor_y)
	dec	a
	cp	9
	jr.	z,88f
	ld	(cursor_y),a
	jr.	77f			
88:	ld	a,(instrument_macro_offset)
	dec	a
	ld	(instrument_macro_offset),a
77:	call	update_macrobox
	jr.	process_key_macrobox_END						
99:	;-- see if we need to go to the next column
	ld	a,(instrument_line)	
	cp	15
	jr.	nz,88f
	ld	a,(cursor_y)
	add	15
	ld	(cursor_y),a
	ld	a,(cursor_x)
	sub 	40
	ld	(cursor_x),a
88:	call	update_macrobox
	jr.	process_key_macrobox_END		



0:
	;--- check for keyjazz
	ld	b,a
	ld	a,(keyjazz)
	and	a
	jr.	nz,process_key_keyjazz	
	ld	a,b	


	;--- Loop
	cp	"r"
	jr.	z,88f
	cp	"R"
	jr.	nz,0f
88:
	;--- get the location in RAM
	call	_get_instrument_start
	inc	hl

	ld	a,(instrument_line)
	ld	(hl),a
	call	update_macrobox
	jr.	process_key_macrobox_END		
0:


	;===================
	;
	; T O N E ena/dis 
	;
	;===================
	;--- Check if the key pressed is t or T
	cp	"t"	
	jr.	z,1f
	cp	"T"
	jr.	nz,0f
	;--- get the location in RAM
1:	call	get_macro_location
	
	inc	hl		; 2nd byte has T
	ld	a,(hl)
	xor	128
	ld	(hl),a
	and 	128		; check if need to reset voice link
	jr	z,99f
	;-- Reset the voice link flag
	inc	hl
	inc	hl
	res	7,(hl)
99:
	call	update_macrobox
	jr.	process_key_macrobox_END

0:	
	;===================
	;
	; N O I S E ena/dis 
	;
	;===================
	;--- Check if the key pressed is n or N
	cp	"n"	
	jr.	z,1f
	cp	"N"
	jr.	nz,0f
	;--- get the location in RAM
1:	call	get_macro_location	
	
			; 1st byte has N
	ld	a,(hl)
	xor	128
	ld	(hl),a
	; reset Voicelink if needed.
	bit 	7,a
	jp	z,99f
	inc	hl
	inc	hl
	inc	hl
	res	7,(hl)
	call	update_macrobox
	jr.	process_key_macrobox_END



0:
	;===================
	;
	; V O I C E ena/dis 
	;
	;===================
	;--- Check if the key pressed is n or N
	cp	"v"	
	jr.	z,1f
	cp	"V"
	jr.	nz,0f
	;--- get the location in RAM
1:	call	get_macro_location	
	
			; 1st byte has N
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	xor	128
	ld	(hl),a
	and	128
	jp	z,99f
	;-- reset the noise bit
	dec	hl
	dec	hl
	dec	hl
	res	7,(hl)
99:
	call	update_macrobox
	jr.	process_key_macrobox_END



0:
	;=====================
	;
	; Addition deviation
	;
	;=====================
IFDEF TTFM
	cp	'^'
	jr.	z,_pkp_env
	cp	'\'
	jr.	z,_pkp_env		
ENDIF
	cp	"+"
	jr.	z,1f
	cp	"-"
	jr.	z,1f
	cp	"_"
	jr.	z,1f
	cp	"="
	jr.	nz,0f
	ld	a,"_"
	jr	1f

_pkp_env:
	;--- Check if we are editing volume
	ld	a,(cursor_input)
	cp	13
	jp	nz,update_macrobox
	call	get_macro_location
	inc	hl
	ld	a,(hl)
	and	11001111b
	or	00010000b 	
;	set	4,e
;	res	5,e
	ld	(hl),a
	jr.	update_macrobox


	; save the key
1:	ld	d,a
	call	get_macro_location
	;--- what are we editing
	ld	a,(cursor_input)
	cp	9
	jr.	c,_pkp_freq
	cp	13
IFDEF TTFM
	jr.	nz,_pkp_noise
ELSE
	jr.	nz,process_key_macrobox_END
ENDIF

	;-- set volume deviation
_pkp_vol:
	inc	hl
	ld	e,(hl)
;	ld	e,a
	
	ld	a,d
	cp	"+"
	jr.	nz,1f
	;- Add
	set	5,e
	res	4,e
	jr.	2f
1:
	cp	"-"
	jr.	nz,1f
	;--- Subtract
	set	5,e
	set	4,e
	jr.	2f	

1:	
	;--- Base
	res	5,e
	res	4,e
2:
	ld	(hl),e

	jr.	update_macrobox
	;end
	
	;-- set freq deviation	
_pkp_freq:
	inc	hl
	ld	e,(hl)
	
	ld	a,d
	cp	"-"
	jr.	z,1f
	res	6,e	
	jr.	3f
1:	
	set	6,e
	jr.	3f
		
	
_pkp_noise:
	ld	a,(hl)
	and	0x9f
	ld	e,a
	
	ld	a,d
	cp	"+"
	jr.	nz,1f
	ld	a,64
	jr.	2f
1:
	cp	"-"
	jr.	nz,1f
	ld	a,64+32
	jr.	2f	

3:
1:	xor	a
2:
	or	e
	ld	(hl),a

	jr.	update_macrobox
	;end
0:
	;===================
	; INPUT is FREQ high
	;
	; FREQ	high
	;
	;===================
	;--- Check if we are in a envelope ena/dis column
	ld	b,a
	ld	a,(cursor_input)
	cp	4
	ld	a,b
	jr.	nz,0f
		
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	22f
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	22f
99:	
	cp	'A'
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
;	ld	d,a
22:	
	ld	d,a	

	; get the location in RAM
	call	get_macro_location
	inc	hl
	inc	hl
	ld	c,(hl)	
	inc	hl
	ld	b,(hl)		; bc now contains the freq value

	;--- set the new high value
	ld	a,b
	and	0xf0
	or	d	

44:	

	ld	(hl),a
	jr.	_psgsamright
	call	update_macrobox
	jr.	process_key_macrobox_END		

	
0:

	;===================
	; INPUT is FREQ mid
	;
	; FREQ	mid
	;
	;===================
	;--- Check if we are in a envelope ena/dis column
	ld	b,a
	ld	a,(cursor_input)
	cp	5
	ld	a,b
	jr.	nz,0f
	
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	22f
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	22f
99:	
	cp	'A'
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
	
22:	
	rlca
	rlca
	rlca
	rlca
	ld	d,a	

	; get the location in RAM
	call	get_macro_location
	inc	hl
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)		; bc now contains the freq value
	
	;--- set the new high value
	ld	a,c
	and	0x0f
	or	d	

44:	
	dec	hl
	ld	(hl),a
	jr.	_psgsamright
	call	update_macrobox
	jr.	process_key_macrobox_END			
	
	
	
0:
	;===================
	; INPUT is FREQ low
	;
	; FREQ	low
	;
	;===================
	;--- Check if we are in a envelope ena/dis column
	ld	b,a
	ld	a,(cursor_input)
	cp	6
	ld	a,b
	jr.	nz,0f
		
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	22f
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	22f
99:	
	cp	'A'
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
	ld	d,a
22:	
	ld	d,a	

	; get the location in RAM
	call	get_macro_location
	inc	hl
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)		; bc now contains the freq value
	
	;--- set the new high value
	ld	a,c
	and	0xf0
	or	d	

44:	
	dec	hl
	ld	(hl),a
;	jr.	_psgsamright
	call	update_macrobox
	jr.	process_key_macrobox_END			
	
	
	

0:
IFDEF TTFM
	;===================
	; INPUT is Noise high
	;
	; N O I S E high
	;
	;===================
	;--- Check if we are in a noise high column
	ld	b,a
	ld	a,(cursor_input)
	cp	9
	ld	a,b
	jr.	nz,0f

	ld	d,a
	call	get_macro_location
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	0x80
	ld	a,d
	jr.	z,_pk_psg_noise
_pk_psg_voice:
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	22f
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	22f
99:	
	cp	'A'
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
22:	
	rlca
	rlca
	rlca
	rlca
	ld	d,a	

	; get the location in RAM
	call	get_macro_location
	ld	a,(hl)
	and	0x0f
	or	d

	ld	(hl),a
99:	jr.	_psgsamright
	call	update_macrobox
	jr.	process_key_macrobox_END			


_pk_psg_noise	
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'1'+1	; smaller than 1?
	jr.	c,1f
	cp	'9'+1	; number but out of range?
	jr.	nc,0f
	ld	a,"1" ; 1 is max value for high byte
1:
	sub	33
	and	0x10
	ld	d,a	

	; get the location in RAM
	call	get_macro_location

	ld	a,(hl)
	and	0xef
	or	d

	ld	(hl),a
99:	jr.	_psgsamright
	call	update_macrobox
	jr.	process_key_macrobox_END			
	
0:
	;===================
	; INPUT is NOISE low
	;
	; NOISE	low
	;
	;===================
	;--- Check if we are in a noiselow column
	ld	b,a
	ld	a,(cursor_input)
	cp	10
	ld	a,b
	jr.	nz,0f
		
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	22f
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	22f
99:	
	cp	'A'
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
;	ld	d,a
22:	
	ld	d,a	

	; get the location in RAM
	call	get_macro_location

	ld	a,(hl)
	and	0xf0
	or	d
	ld	(hl),a
;	jr.	_psgsamright
	call	update_macrobox
	jr.	process_key_macrobox_END			
	
	
	

0:	
	;===================
	; INPUT is Volume
	;
	; V O L U M E
	;
	;===================
	;--- Check if we are in an volume column
	ld	a,(cursor_input)
	cp	13			; 4 = volume type
	ld	a,b
	jr.	nz,0f
	cp	_DEL
	jr.	nz,99f
	ld	a,'0'	
	
99:	
	;--- Check if the key pressed is in the envelope range
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	_psgvolfound
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	_psgvolfound
99:	
	cp	'A'
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
	ld	d,a
_psgvolfound:	
	ld	d,a
	
	;--- get the location in RAM
	call	get_macro_location

	inc	hl		;(2nd byte)
	ld	a,(hl)
	and	0xf0
	or	d
	ld	(hl),a
	call	update_macrobox
	jr.	process_key_macrobox_END
	
0:
	;===================
	; INPUT is volume addition
	;
	; VOLUME addition
	;
	;===================
	;--- Check if we are in a volume add type column
	ld	b,a
	ld	a,(cursor_input)
	cp	13
	ld	a,b
	jr.	nz,0f
	
	;--- check for space.
	cp	_ENTER
	jr.	nz,0f
	
	;--- get the location in RAM
	call	get_macro_location
	
	inc	hl
	ld	a,(hl)
	and	16+8
	jr.	nz,12f
	add	8
12:
	add	8
	and	16+8
	ld	b,a
	ld	a,(hl)
	and	0xe7	
	or	b
	ld	(hl),a
	call	update_macrobox
	jr.	process_key_macrobox_END	
0:

process_key_macrobox_END:
	ret

ELSE

	;===================
	; INPUT is SN Noise register
	;
	; N O I S E high
	;
	;===================
	;--- Check if we are in a noise high column
	ld	b,a
	ld	a,(cursor_input)
	cp	9
	ld	a,b
	jr.	nz,0f

	ld	d,a
	call	get_macro_location
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	0x80
	ld	a,d
	jr.	z,_pk_psg_noise
_pk_psg_voice:
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	22f
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	22f
99:	
	cp	'A'
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
22:	
	rlca
	rlca
	rlca
	rlca
	ld	d,a	

	; get the location in RAM
	call	get_macro_location
	ld	a,(hl)
	and	0x0f
	or	d

	ld	(hl),a
99:	;jr.	_psgsamright
	call	update_macrobox
	jr.	process_key_macrobox_END			


_pk_psg_noise	
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'8'+1	; smaller than 8?
	jr.	c,1f
	jr.	0f
1:
	sub	48
	rlca
	rlca
	rlca
	rlca
	and	0x70	
	ld	d,a	

	; get the location in RAM
	call	get_macro_location

	ld	a,(hl)
	and	0x8f
	or	d

	ld	(hl),a
99:	;jr.	_psgsamright
	call	update_macrobox
	jr.	process_key_macrobox_END			
	
0:
	;===================
	; INPUT is NOISE vol
	;
	; NOISE	vol
	;
	;===================
	;--- Check if we are in a noisevol column
	ld	b,a
	ld	a,(cursor_input)
	cp	10
	ld	a,b
	jr.	nz,0f
		
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	22f
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	22f
99:	
	cp	'A'
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
;	ld	d,a
22:	
	ld	d,a	

	; get the location in RAM
	call	get_macro_location

	ld	a,(hl)
	and	0xf0
	or	d
	ld	(hl),a
;	jr.	_psgsamright
	call	update_macrobox
	jr.	process_key_macrobox_END			
	
	
	

0:	
	;===================
	; INPUT is Volume
	;
	; V O L U M E
	;
	;===================
	;--- Check if we are in an volume column
	ld	a,(cursor_input)
	cp	13			; 4 = volume type
	ld	a,b
	jr.	nz,0f
	cp	_DEL
	jr.	nz,99f
	ld	a,'0'	
	
99:	
	;--- Check if the key pressed is in the envelope range
	; is it a number?
	cp	'0'	; bigger than 0 
	jr.	c,99f	
	cp	'9'+1	; smaller than 9?
	jr.	nc,99f
	sub 	'0'
	jr.	_psgvolfound
99:	
	cp	'a'
	jr.	c,99f
	cp	'f'+1
	jr.	nc,99f
	sub	'a'-10
	jr.	_psgvolfound
99:	
	cp	'A'
	jr.	c,0f
	cp	'F'+1
	jr.	nc,0f
	sub	'A'-10
	ld	d,a
_psgvolfound:	
	ld	d,a
	
	;--- get the location in RAM
	call	get_macro_location

	inc	hl		;(2nd byte)
	ld	a,(hl)
	and	0xf0
	or	d
	ld	(hl),a
	call	update_macrobox
	jr.	process_key_macrobox_END
	
0:
	;===================
	; INPUT is volume addition
	;
	; VOLUME addition
	;
	;===================
	;--- Check if we are in a volume add type column
	ld	b,a
	ld	a,(cursor_input)
	cp	13
	ld	a,b
	jr.	nz,0f
	
	;--- check for space.
	cp	_ENTER
	jr.	nz,0f
	
	;--- get the location in RAM
	call	get_macro_location
	
	inc	hl
	ld	a,(hl)
	and	16+8
	jr.	nz,12f
	add	8
12:
	add	8
	and	16+8
	ld	b,a
	ld	a,(hl)
	and	0xe7	
	or	b
	ld	(hl),a
	call	update_macrobox
	jr.	process_key_macrobox_END	
0:




process_key_macrobox_END:
	ret

ENDIF


;===========================================================
; --- get_macro_location:
;
; returns in hl the start ofthe current sample line.
; Changes: A, HL and BC
;===========================================================
get_macro_location:
	;--- get the location in RAM
	call	_get_instrument_start
	inc	hl
	inc	hl
	inc	hl	
	
	;--- add the current line to the start of the sample
	ld	a,(instrument_line)
	and	a
	ret	z
	ld	bc,4		; b is 0
88:
	add	hl,bc
	dec	a
	jr.	nz,88b
	
	ret




;===========================================================
; --- process_key_macrobox_waveform
;
;
;===========================================================
process_key_macrobox_waveform:
	;--- get the location in RAM
	call	_get_instrument_start	
	inc	hl
	inc	hl
	
	ld	a,(instrument_waveform)
	ld	c,a
	ld	a,(key)

	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		jr.	restore_cursor
	
0:	
	cp	_KEY_LEFT
	jr.	nz,0f
	;--- sample nr down
		ld	a,c
		and	a
		ret	z
		dec	a
		ld	(instrument_waveform),a
		ld	(hl),a
		jr.	update_macrobox
0:
	cp	_KEY_RIGHT
	jr.	nz,0f
	;--- sample nr up
		ld	a,c
		cp	16
		ret	nc
		inc	a
		ld	(hl),a
		ld	(instrument_waveform),a
		jr.	update_macrobox

0:	ret


;===========================================================
; --- process_key_macrobox_octave
;
;
;===========================================================
process_key_macrobox_octave:
	ld	a,(song_octave)
	ld	c,a
	ld	a,(key)

	;--- Check if edit is ended.
	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		call	restore_cursor
		;call	reset_cursor_trackbox
		jr.	process_key_macrobox_octave_END
0:		
	;--- Key_up - Pattern down	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
44:		dec	c
		ld	a,c
		jr.	z,process_key_macrobox_octave_END
88:		ld	(song_octave),a
		call	update_macrobox
		jr.	process_key_macrobox_octave_END	
0:
	;--- Key_down - Pattern up	
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
44:		ld	a,c
		cp	7
		jr.	nc,process_key_macrobox_octave_END
		inc	a
		jr.	88b	
0:
	;---- number key
	cp	"1"
	jr.	c,0f
	cp	"8"
	jr.	nc,0f

		sub	48
		ld	(song_octave),a
		call	restore_cursor
		call	update_macrobox
		jr.	process_key_macrobox_octave_END
		
	

0:	
process_key_macrobox_octave_END:
	ret






;===========================================================
; --- process_key_macrobox_len
;
;
;===========================================================
process_key_macrobox_len:
	;--- get the location in RAM
	call	_get_instrument_start
	
	ld	a,(instrument_loop)
	inc	a
	ld	b,a
	ld	a,(instrument_len)
	ld	c,a


	ld	a,(key)

	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		
	call	restore_cursor
	jr.	update_macrobox
	
0:	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
	;--- len down
44:		ld	a,c
		cp	1
		ret	z
		dec	a
		ld	(hl),a
		cp	b
		jr.	nc,update_macrobox
		dec	a
		inc	hl
		ld	(hl),a
		jr.	update_macrobox		
		
0:
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
	;--- sample nr up
44:		ld	a,c
		cp	32
		ret	nc
		inc	a
		ld	(hl),a
		jr.	update_macrobox

0:	ret

;===========================================================
; --- process_key_macrobox_loop
;
;
;===========================================================
process_key_macrobox_loop:
	;--- get the location in RAM
	call	_get_instrument_start
	
	inc	hl

	ld	a,(instrument_len)
	ld	b,a
	ld	a,(instrument_loop)
	ld	c,a
	ld	a,(key)

	cp	_ENTER
	jr.	z,44f
	cp	_ESC
	jr.	nz,0f
44:		jr.	restore_cursor
	
0:	
	cp	_KEY_DOWN
	jr.	z,44f
	cp	_KEY_LEFT
	jr.	nz,0f
	;--- sample nr down
44:		ld	a,c
		and	a
		ret	z
		dec	a
		cp	c
		ld	(hl),a
		jr.	update_macrobox
0:
	cp	_KEY_UP
	jr.	z,44f
	cp	_KEY_RIGHT
	jr.	nz,0f
	;--- sample nr up
44:		ld	a,c
		cp	32
		ret	nc
		inc	a
		cp	b
		jr.	nc,0f
		ld	(hl),a
		jr.	update_macrobox

0:	ret

;===========================================================
; --- process_key_description
;
; Process the song name input
; 
;===========================================================
process_key_macrobox_description:
	
	;--- Set the start of the instrument name.
	ld	a,(song_cur_instrument)
	ld	l,a
	xor	a		; [a] to catch carry bit
	sla	l		; offset  *16
	sla	l
	sla	l
	sla	l
	adc	a,0		; only the 4th shift can cause carry
	ld	h,a
	ld	de,song_instrument_list-16
	add	hl,de	
0:	
		
	ld	a,(key)
	;--- Check if edit is ended.
	cp	_ESC
	jr.	z,44f
	cp	_ENTER
	jr.	nz,0f	
44:		;ld	a,0
		;ld	(editsubmode),a
		call	restore_cursor
		;call	reset_cursor_macrobox
		jr.	process_key_macrobox_description_END

0:
	;--- Check for RIGHT
	cp	_KEY_RIGHT
	jr.	nz,99f
		ld	a,(cursor_x)
		cp	30+15
		jr.	nc,process_key_macrobox_description_END
		call	flush_cursor
		inc	a
		ld	(cursor_x),a
		jr.	process_key_macrobox_description_END			
99:	
	
	;--- Check for LEFT
	cp	_KEY_LEFT
	jr.	nz,99f
		ld	a,(cursor_x)
		cp	31
		jr.	c,process_key_macrobox_description_END
		call	flush_cursor
		dec	a
		ld	(cursor_x),a
		jr.	process_key_macrobox_description_END
99:
	;--- Backspace
	cp	_BACKSPACE
	jr.	nz,99f
		; get location in RAM
		ld	b,a
		ld	a,(cursor_x)
		sub	30
		add	a,l
		ld	l,a
		jr.	nc,88f
		inc	h
88:
		; move cursor (if possible)
		ld	a,(cursor_x)
		cp	31
		jr.	c,77f		
		dec	a
		ld	(cursor_x),a
77:		
		ld	(hl),32
		call	update_macrobox
		jr.	process_key_macrobox_description_END

99:
	;--- Delete
	cp	_DEL
	jr.	nz,99f
		ld	a,(cursor_x)
		sub	30
		add	a,l
		ld	l,a
		jr.	nc,88f
		inc	h	
88:	
		ld	(hl)," "
		call	update_macrobox
		jr.	process_key_macrobox_description_END	

99:
	;--- All other (normal) keys
	cp	32
	jr.	c,process_key_macrobox_description_END
	cp	128
	jr.	nc,process_key_macrobox_description_END
	
	ld	b,a
	ld	a,(cursor_x)
	sub	30
	add	a,l
	ld	l,a
	jr.	nc,88f
	inc	h
88:
		ld	a,(cursor_x)
		cp	30+15
		jr.	nc,99f
		call	flush_cursor
		inc	a
		ld	(cursor_x),a
99:	ld	(hl),b
	call	update_macrobox
	jr.	process_key_macrobox_description_END
		
			
process_key_macrobox_description_END
	call	build_instrument_list
	ret





;===========================================================
; --- reset_cursor_macrobox
;
; Reset the cursor to the top left of the pattern.
; To be used when switching patterns, after loadinging and etc
;===========================================================
reset_cursor_macrobox:
	call	flush_cursor
	
	ld	a,(editsubmode)
	and	a
	jr.	nz,0f	
	;--- Sample edit
		ld	a,1
		ld	(cursor_type),a
		ld	a,10
		ld	(cursor_y),a
IFDEF TTSMS
		ld	a,8+15+3-7
ELSE
		ld	a,8+15-4
ENDIF
		ld	(cursor_x),a
		xor	a
		ld	(instrument_line),a
		ld	(instrument_macro_offset),a
		inc	a 
		ld	(cursor_type),a	
		ld	a,13		; get volume type value
		ld	(cursor_input),a
		xor	a
		ld	(instrument_line),a
		ld	a,3
		ld	(cursor_column),a
		ret
0:
	dec	a
	jr.	nz,0f
	;--- Waveform.
		ld	a,3+5+6+9+3
		ld	(cursor_x),a
		ld	a,2
		ld	(cursor_type),a	
		jr.	99f	
0:
	dec	a
	jr.	nz,0f
	;--- Sample length
		ld	a,3+5+8
		ld	(cursor_x),a
		ld	a,2
		ld	(cursor_type),a	
		jr.	99f		
0:
	dec	a
	jr.	nz,0f
	;--- Sample loop
		ld	a,3+5+6+7
		ld	(cursor_x),a	
		ld	a,2
		ld	(cursor_type),a	
		jr.	99f	
0:	
	dec	a
	jr.	nz,0f
	;--- OCtave 
		ld	a,3+5+6+9+6+19
		ld	(cursor_x),a	
		ld	a,2
		ld	(cursor_type),a	
		jr.	99f	
0:	
	dec	a
	jr.	nz,0f
	;--- Wave form editor
		ld	a,2
		ld	(cursor_type),a
;		dec	a
		ld	a,(_scc_waveform_col)
		jr.	_set_voice_cursor


0:
	dec	a
	jr.	nz,0f
	;--- Instrument description 
		ld	a,3+5+6+7+9
		ld	(cursor_x),a	
		ld	a,1
		ld	(cursor_type),a	
		jr.	99f		
0:
99:	ld	a,8
88:	ld	(cursor_y),a
	ret

	db	255	;end
_COLTAB_MACRO:
IFDEF TTSMS
	db	4,1	; 4 = freq deviation high
	db	5,1	; 5 = freq deviation mid
	db	6,9	; 6 = freq deviation low
	db	13,8;1	; 12= volume
	db	9,8	; 9 = noise deviation high
	db	10,8	; 6 = noise deviation low
	db	10,255	;

ELSE
	db	4,1	; 4 = freq deviation high
	db	5,1	; 5 = freq deviation mid
	db	6,3+6	; 6 = freq deviation low
	db	13,9	; 12= volume
	;db	7,2	; 7 = freq deviation add type
;	db	8,1	; 8 = pos/neg noise deviation
	db	9,1	; 9 = noise deviation high
	db	10,4	; 6 = noise deviation low
;	db	11,2	; 11= noise deviation add type
	db	10,255;1	; 12= volume
;	db	12,255	; 13= volume add type
ENDIF

restore_instrumenteditor:
	ld	a,(editmode)
	cp	1
	ret	z


	ld	a,1
	ld	(editmode),a	
		
	call	restore_cursor
	
	call	draw_macrobox
	call	update_macrobox
	
	ret