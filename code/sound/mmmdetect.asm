; Name: mmm_srch
;
; Input: H = 080h (or 040h) (Significant byte of the memory bank address)
; B = 16 (Possible number of secondary Slot)
;
; Output: A = Slot Number in the form F000SSPP (0FFh if MMM is not found)
; B = Remaining iterations number
;
; Modify: All registers
;
; Size: 65 Bytes
;
; Note: The routine can be called multiple times to complete research in all
; slots until B is set to 0 or until A is set to 0FFh.
;
; Warning: The routine does not replace the original slot after the search.
;
mmm_srch: 
	ld 	l,0FFh 		; HL = Access address to Memory Mapper register
	ld	b,16
	ld	h,$80
mmm_srch_loop:
	push 	hl
	ld 	a,b 			; The Slot it is extended?
	dec 	a
	and 	3
	ld 	hl,0xFCC1		; Main-ROM Slot
	add 	a,l
	ld 	l,a
	ld 	a,b
	dec 	a
	or 	(hl)
	pop 	hl
	jp 	m,ext_slt 		; Jump if the slot is extended
	and 	%00001111
	cp 	4
	jr 	nc,nxt_srch		; If not a value of primary slot
ext_slt: 
	ld 	c,a
	push 	bc
	push 	hl
	call 	enaslt 		; Select Slot to scrutinize
	pop 	hl
	pop 	bc
	di 				; Start of test
	ld 	a,080h
	out 	(03Ch),a 		; Enables access to registers by addressing
	ld 	a,(hl) 		; The value read in address 080FFh (or 040FFh)
	and 	%00011111 		;
	inc 	a 			; must be
					;
	out 	(0FFh),a 		; equal to the value
	or 	%11000000 		;
	cp 	(hl) 			; written to the port 0FFh
	ld 	a,0
	out 	(03Ch),a 		; Disables access to the registers by addressing
	out 	(0FFh),a 		; Restore the page of system working area
	ei
	ld 	a,c 			; Slot Number in the form F000SSPP
	jr 	z,mmm_found
nxt_srch: 
	djnz 	mmm_srch_loop 	; Continues the search
	or 	0FFh 			; MMM not found -> A = 0FFh R = bit Z à 0
	ret
mmm_found:
	dec 	b 			; MMM found
	cp 	a 			; Bit Z to 1
	
	call	mmm_enableSN
	ret
	
	
	
mmm_enableSN:
	ld	h,080h
;	ld	a,(MMM_Slot)
	call	enaslt		; Select MMM RAM at Bank 8000h~BFFFh
		
	ld	a,080h
	out	(03ch),a	; Enable acces register via address
		
	ld	a,040h
	ld	(803Ch),a	; Write protect the MMM banks and disable access 

	;silence the PSG quickly
	LD A,09Fh
	OUT (3Fh),A ; channel 1
	LD A,0BFh
	OUT (3Fh),A ; channel 2
	LD A,0DFh
	OUT (3Fh),A ; channel 3
	LD A,0FFh
	OUT (3Fh),A ; channel 4

;	ld	a,000h
;	out	(03ch),a	; Enable acces register via address
	
	ret