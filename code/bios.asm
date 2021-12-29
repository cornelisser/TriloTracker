;--- Read value from BIOS using interslotcall
;    Input: [HL] contains address to read
;    Output: [A] value 
read_bios_val:
	push  bc
	push  de
	push  hl
	ld    a, ($fcc1)              ; (EXPTBL)
	call  $0C                     ; RDSLT
	pop   hl
	pop   de
	pop   bc
      ret
