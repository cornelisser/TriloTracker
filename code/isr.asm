;init_isr:
;	ld	hl,isr
;	ld	a,0xc3
;	ld	(0x38),a
;	ld	(0x39),hl
;	ret


init_hook:
	ld	hl,interrupt		; install the new isr.
	di
	ld	a,0xc3
	ld	(0xFD9f),a
	ld	(0xFDa0),hl
	ei
	ret
	
set_hook:
	di
	push	af
;	ld	sp,(org_stack)
	ld	a,0xc3
	ld	(0xFD9f),a
	pop	af
	ei
	ret
reset_hook:
	push	af
	push	hl
	ld	hl,interrupt		; install the new isr.
	di
;	ld	sp,(_catch_stackpointer)
	ld	a,0xc9
	ld	(0xFD9f),a
	ei
	pop	hl
	pop	af
	ret

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
	call	NZ,replay_decodedata_NO	
	xor	a
	ld	(equalization_flag),a
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





	ret

;	; =====================
;	; Restore the registers.
;	; =====================
;	pop ix
;	pop iy
;	pop af
;	pop bc
;	pop de
;	pop hl
;	ex af
;	exx
;	pop af
;	pop bc
;	pop de
;	pop hl
;	pop ix
;	pop iy
;	ei
;	ret    