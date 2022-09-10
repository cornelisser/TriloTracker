_rd_tonevalue:
	ld	a,(hl)
	ld	b,a
      inc   hl
	ld	a,(hl)
	call	draw_hex
	ld	a,b
	call	draw_hex2
      inc   hl
      ret

    

IFDEF TTFM
_TEMPVALUES:	db $a,"XXX",$b,"XXX",$c,"XXX ",$17,"XX ",$16,"XX ",$e,"XXXX ",$a,"X",$b,"X",$c,"X          ",$a,"XXX",$b,"XXX",$c,"XXX",$d,"XXX",$e,"XXX",$f,"XXX ",$a,"X",$b,"X",$c,"X",$d,"X",$e,"X",$f,"X"

draw_register_debug:	
      ld    de,_TEMPVALUES+1
	ld	hl,AY_registers
      ;-- tone A
      call  _rd_tonevalue
	inc	de
      ;-- tone B
      call  _rd_tonevalue
	inc	de
      ;-- tone B
      call  _rd_tonevalue
	inc	de
      inc   de
      ;-- Noise
      ld    a,(hl)
      inc   hl
      call  draw_hex2
      inc   de
      inc   de
      ;-- Mixer
      ld    a,(hl)
      inc   hl
      call  draw_hex2
      inc   de
      inc   de
      ;--- Envelope
      ld    a,(AY_regEnvH)
      call  draw_hex2     
      ld    a,(AY_regEnvL)
      call  draw_hex2  
      inc   de
      inc   de
      ;--- Volume A
	ld	a,(hl)
	inc	hl
	call	draw_hex
	inc	de
      ;--- Volume B
	ld	a,(hl)
	inc	hl
	call	draw_hex
	inc	de
      ;--- Volume C
	ld	a,(hl)
	inc	hl
	call	draw_hex
	inc	de

      ;--- Skip to FM
      ld    a,10
      add   a,e
      ld    e,a
      jr.    nc,99f
      inc   d
99:

 
      ;-- tone A
      ld    hl,FM_regToneA
      call  _rd_tonevalue
      inc   de
      ;-- tone B
      ld    hl,FM_regToneB
      call  _rd_tonevalue
      inc   de
      ;-- tone C
      ld    hl,FM_regToneC
      call  _rd_tonevalue
      inc   de
      ;-- tone D
      ld    hl,FM_regToneD
      call  _rd_tonevalue
      inc   de
      ;-- tone E
      ld    hl,FM_regToneE
      call  _rd_tonevalue
      inc   de
      ;-- tone F
      ld    hl,FM_regToneF
      call  _rd_tonevalue
      inc   de
      inc   de

      ;--- Vol a
      ld    a,(FM_regVOLA)
      xor   $ff
      call  draw_hex
      inc   de
      ;--- Vol B
      ld    a,(FM_regVOLB)
      xor   $ff
      call  draw_hex
      inc   de
      ;--- Vol c
      ld    a,(FM_regVOLC)
      xor   $ff
      call  draw_hex
      inc   de
      ;--- Vol D
      ld    a,(FM_regVOLD)
      xor   $ff
      call  draw_hex
      inc   de
      ;--- Vol E
      ld    a,(FM_regVOLE)
      xor   $ff
      call  draw_hex
      inc   de
      ;--- Vol F
      ld    a,(FM_regVOLF)
      xor   $ff
      call  draw_hex
      inc   de

 

      ;--- PLOT the values
	ld	hl,0
	ld	de,_TEMPVALUES
	ld	b,80
	call	draw_label_fast
	ret				
ENDIF
IFDEF TTSCC
_TEMPVALUES:	db $a,"XXX",$b,"XXX",$c,"XXX ",$17,"XX ",$16,"XX ",$e,"XXXX ",$a,"X",$b,"X",$c,"X            ",$a,"XXX",$b,"XXX",$c,"XXX",$d,"XXX",$e,"XXX ",$16,"XX ",$a,"X",$b,"X",$c,"X",$d,"X",$e,"X"
      db "koe"
draw_register_debug:	
      ld    de,_TEMPVALUES+1
	ld	hl,AY_registers
      ;-- tone A
      call  _rd_tonevalue
	inc	de
      ;-- tone B
      call  _rd_tonevalue
	inc	de
      ;-- tone B
      call  _rd_tonevalue
	inc	de
      inc   de
      ;-- Noise
      ld    a,(hl)
      inc   hl
      call  draw_hex2
      inc   de
      inc   de
      ;-- Mixer
      ld    a,(hl)
      inc   hl
      call  draw_hex2
      inc   de
      inc   de
      ;--- Envelope
      ld    a,(AY_regEnvH)
      call  draw_hex2     
      ld    a,(AY_regEnvL)
      call  draw_hex2  
      inc   de
      inc   de
      ;--- Volume A
	ld	a,(hl)
	inc	hl
	call	draw_hex
	inc	de
      ;--- Volume B
	ld	a,(hl)
	inc	hl
	call	draw_hex
	inc	de
      ;--- Volume C
	ld	a,(hl)
	inc	hl
	call	draw_hex
	inc	de

      ;--- Skip to FM
      ld    a,12
      add   a,e
      ld    e,a
      jr.    nc,99f
      inc   d
99:

      ld    hl,SCC_registers
      ;-- tone A
      call  _rd_tonevalue
      inc   de
      ;-- tone B
      call  _rd_tonevalue
      inc   de
      ;-- tone C
      call  _rd_tonevalue
      inc   de
      ;-- tone D
      call  _rd_tonevalue
      inc   de
      ;-- tone E
      call  _rd_tonevalue
      inc   de
      inc   de
      ;--- Mixer
      ld    a,(SCC_regMIXER)
      call  draw_hex2

      inc   de
      inc   de
      ;--- Vol a
      ld    a,(hl)
      call  draw_hex
      inc   hl
      inc   de
      ;--- Vol B
      ld    a,(hl)
      call  draw_hex
      inc   hl
      inc   de
      ;--- Vol c
      ld    a,(hl)
      call  draw_hex
      inc   hl
      inc   de
      ;--- Vol D
      ld    a,(hl)
      call  draw_hex
      inc   hl
      inc   de
      ;--- Vol E
      ld    a,(hl)
      call  draw_hex
      inc   hl
      inc   de


 

      ;--- PLOT the values
	ld	hl,0
	ld	de,_TEMPVALUES
	ld	b,80
	call	draw_label_fast
	ret				
ENDIF

IFDEF TTSMS
_TEMPVALUES:	db $a,"XXX",$b,"XXX",$c,"XXX ",$17,"X ",$a,"X",$b,"X",$c,"X",$17,"X                   ",$a,"XXX",$b,"XXX",$c,"XXX",$d,"XXX",$e,"XXX",$f,"XXX ",$a,"X",$b,"X",$c,"X",$d,"X",$e,"X",$f,"X"
      db "koe"
draw_register_debug:	
      ld    de,_TEMPVALUES+1
	ld	hl,AY_registers
      ;-- tone A
      call  _rd_tonevalue
	inc	de
      ;-- tone B
      call  _rd_tonevalue
	inc	de
      ;-- tone B
      call  _rd_tonevalue
	inc	de
      inc   de
      ;-- Noise
      ld    a,(hl)
      inc   hl
      call  draw_hex
      inc   de
      inc   de
 
      ld    hl,AY_regVOLA
      ;--- Volume A
	ld	a,(hl)
	inc	hl
	call	draw_hex
	inc	de
      ;--- Volume B
	ld	a,(hl)
	inc	hl
	call	draw_hex
	inc	de
      ;--- Volume C
	ld	a,(hl)
	inc	hl
	call	draw_hex
	inc	de

      ld    hl,SN_regVOLN
      ;--- Volume Noise
	ld	a,(hl)
	inc	hl
	call	draw_hex
	inc	de

      ;--- Skip to FM
      ld    a,19
      add   a,e
      ld    e,a
      jr.    nc,99f
      inc   d
99:

      ;-- tone A
      ld    hl,FM_regToneA
      call  _rd_tonevalue
      inc   de
      ;-- tone B
      ld    hl,FM_regToneB
      call  _rd_tonevalue
      inc   de
      ;-- tone C
      ld    hl,FM_regToneC
      call  _rd_tonevalue
      inc   de
      ;-- tone D
      ld    hl,FM_regToneD
      call  _rd_tonevalue
      inc   de
      ;-- tone E
      ld    hl,FM_regToneE
      call  _rd_tonevalue
      inc   de
      ;-- tone F
      ld    hl,FM_regToneF
      call  _rd_tonevalue
      inc   de
      inc   de

      ;--- Vol a
      ld    a,(FM_regVOLA)
      xor   $ff
      call  draw_hex
      inc   de
      ;--- Vol B
      ld    a,(FM_regVOLB)
      xor   $ff
      call  draw_hex
      inc   de
      ;--- Vol c
      ld    a,(FM_regVOLC)
      xor   $ff
      call  draw_hex
      inc   de
      ;--- Vol D
      ld    a,(FM_regVOLD)
      xor   $ff
      call  draw_hex
      inc   de
      ;--- Vol E
      ld    a,(FM_regVOLE)
      xor   $ff
      call  draw_hex
      inc   de
      ;--- Vol F
      ld    a,(FM_regVOLF)
      xor   $ff
      call  draw_hex

 

      ;--- PLOT the values
	ld	hl,0
	ld	de,_TEMPVALUES
	ld	b,80
	call	draw_label_fast
	ret				
ENDIF		
