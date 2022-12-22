;init_isr:
;	ld	hl,isr
;	ld	a,0xc3
;	ld	(0x38),a
;	ld	(0x39),hl
;	ret


init_hook:
	ld	a, (original_hook)
	or	a
	jr	nz, set_hook	; Only preserve original_hook once. After that, it might not be in place anymore.
	ld	hl, 0xFD9F
	ld	de, original_hook
	ld	bc, 5
	ldir
set_hook:
	di
	push	af
	push	hl
	ld	a,0xc3
	ld	(0xFD9f),a
	ld	hl,interrupt		; install the new isr.
	ld	(0xFDa0),hl
	pop	hl
	pop	af
	ei
	ret

reset_hook:
	push	af
	ld	a, (original_hook)
	or	a
	jr	z, 1f	; Do nothing because original_hook has not been initialized, yet.
	di
	push	bc
	push	de
	push	hl
	ld	hl, original_hook
	ld	de, 0xFD9F
	ld	bc, 5
	ldir
	pop	hl
	pop	de
	pop	bc
	ei
1:
	pop	af
	ret
original_hook:
	db	0	; Ensure a 0 here so we can test if the original_hook has been initialized, yet.
	ds	4

;===========================================================
; --- interrupt
;
; This is for interrupt driven events:
; - sound (playback)
; - cursor blinking?
;===========================================================
isr:
; My own interrupt
	; =====================
	; Restore the registers.
	; =====================
;	push iy
;	push ix
;	push hl
;	push de
;	push bc
;	push af
;	exx
;	ex af
;	push hl
;	push de
;	push bc
;	push af
;	push iy
;	push ix

;	in a,(0x99)			; read VDP status register (to reset int bit)

interrupt:
	call	GET_P2
	push	af

	ld a,(replay_mode)
	and	a
	jr.	z,int_no_music	


	; --- sound
      ld      a,(vsf)
      and     a
      jr.      z,PAL               ; if PAL call at any interrupt;

NTSC:
      ld      hl,cnt               ; if NTSC call 5 times out of 6
      dec     (hl)
      jr.      nz,PAL               ; skip one tic out of 6 when at 60hz

	ld	a,6
	ld	(hl),a			; reset the tich counter
 	ld    (equalization_flag),a	; reset the tic counter

	ld	a,(replay_mode)
	and	a
;	call	NZ,replay_decodedata_NO	
	xor	a
	ld	(equalization_flag),a

IFDEF TTSCC
ELSE
	ld	(FM_DRUM),a			; make sure not to retrigger drums on skip
	;--- Reset keyon flip 
	ld	hl,FM_regToneA+1		; pointer to the backup of reg# $2x
	res	6,(hl)
	ld	hl,FM_regToneB+1		; pointer to the backup of reg# $2x
	res	6,(hl)
	ld	hl,FM_regToneC+1		; pointer to the backup of reg# $2x
	res	6,(hl)
	ld	hl,FM_regToneD+1		; pointer to the backup of reg# $2x
	res	6,(hl)
	ld	hl,FM_regToneE+1		; pointer to the backup of reg# $2x
	res	6,(hl)
	ld	hl,FM_regToneF+1		; pointer to the backup of reg# $2x
	res	6,(hl)
ENDIF

      jr. 	8f                     ; skip sound processing

PAL:                             ; execute the PSG and ayFX core	
	
	
;	ld	a,4
;	or	11110000b
;	out	(0x99),a
;	ld	a,7+128
;	out	(0x99),a	

	call	replay_play
	
;	ld	a,8
;	or	11110000b
;	out	(0x99),a
;	ld	a,7+128
;	out	(0x99),a
8:
	call	replay_route

;	ld	a,0
;	or	11110000b
;	out	(0x99),a
;	ld	a,7+128
;	out	(0x99),a

int_no_music:
	;--- read_musickb (Music module)
	call	musickb_handler

	;--- Keyboard
	call	key_handler
	call	read_functionkeys
	
	;-- Cursor blink
	ld	hl,cursor_timer
	inc	(hl)	

	pop	af
	call	PUT_P2

	jr.	original_hook

