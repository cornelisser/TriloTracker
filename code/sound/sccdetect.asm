;------------------------------------------------------------
; SCC-search v1.0
; by Alwin Henseler
; using method described in bulletin # 18 MSX-club Enschede
; input: none
; output: B=slot that contains SCC (=255 if no SCC found)

enaslt:          equ #0024
exptbl:          equ #fcc1
slttbl:          equ #fcc5

scc_type_check:	db	0				 

find_SCC:
	di
                 in a,(#a8)        ; read prim. slotregister
                 rra
                 rra
                 rra
                 rra
                 and %00000011     ; A = prim.slot page 2
                 ld b,0
                 ld c,a
                 ld hl,exptbl
                 add hl,bc
                 bit 7,(hl)        ; page 2-slot expanded ?
                 jr z,scctest
                 ld hl,slttbl
                 add hl,bc
                 ld a,(hl)         ; A = sec.sel.reg. of page 2-slot
                 rra
                 rra
                 and %00001100     ; bit 1/2 = sec.slot page 2
                 or c
                 set 7,a           ; compose sec.slot-code
scctest:         push af           ; save page 2-slot on the stack
                 ld a,(exptbl)     ; 1st slot to test

testslot:        push af           ; save test-slot on the stack
                 ld h,#80
                 call enaslt       ; switch slot-to-test in 8000-bfffh

	ld	a,(scc_type_check)		; 0 = scc, 1=scc+/scc-I
	and	a
	jr.	z,scc_test

scci_test:
                 ld hl,#b000
                 ld b,(hl)         ; save contents of address 9000h
                 ld (hl),#3f       ; activate SCC (if present)
                 ld h,#9c          ; address of SCC-register mirrors
                 ld de,#b800       ; 9800h = address of SCC-registers
testregi:         ld a,(de)
                 ld c,a            ; save contents of address 98xxh
                 ld a,(hl)         ; read byte from address 9cxxh
                 cpl               ; and invert it
                 ld (de),a         ; write inverted byte to 98xxh
                 cp (hl)           ; same value on 9cxxh ?
                 ld a,c
                 ld (de),a         ; restore value on 98xxh
                 jr nz,nextslot    ; unequal -> no SCC -> continue search
                 inc hl
                 inc de            ; next test-addresses
                 bit 7,l           ; 128 adresses (registers) tested ?
                 jr z,testregi      ; no -> repeat mirror-test
                 ld a,b
                 ld (#b000),a      ; restore value on 9000h
                 xor	a
                 ld	($bfff),a	; Set SCC+ in SCC mode
                 pop bc            ; retrieve slotcode (=SCC-slot) from stack
                 jr done           ; SCC found, restore page 2-slot & return

scc_test:
                 ld hl,#9000
                 ld b,(hl)         ; save contents of address 9000h
                 ld (hl),#3f       ; activate SCC (if present)
                 ld h,#9c          ; address of SCC-register mirrors
                 ld de,#9800       ; 9800h = address of SCC-registers
testreg:         ld a,(de)
                 ld c,a            ; save contents of address 98xxh
                 ld a,(hl)         ; read byte from address 9cxxh
                 cpl               ; and invert it
                 ld (de),a         ; write inverted byte to 98xxh
                 cp (hl)           ; same value on 9cxxh ?
                 ld a,c
                 ld (de),a         ; restore value on 98xxh
                 jr nz,nextslot    ; unequal -> no SCC -> continue search
                 inc hl
                 inc de            ; next test-addresses
                 bit 7,l           ; 128 adresses (registers) tested ?
                 jr z,testreg      ; no -> repeat mirror-test
                 ld a,b
                 ld (#9000),a      ; restore value on 9000h
                 pop bc            ; retrieve slotcode (=SCC-slot) from stack
                 jr done           ; SCC found, restore page 2-slot & return




nextslot:        ld a,b
                 ld (#b000),a      ; restore value on 9000h
                 pop bc            ; retrieve slotcode from stack
                 bit 7,b           ; test-slot = sec.slot ?
                 jr z,nextprim
                 ld a,b
                 add a,4           ; increase sec.slotnumber
                 bit 4,a           ; sec.slot = 4 ?
                 jr z,testslot
nextprim:        ld a,b
                 and %00000011
                 cp 3              ; prim.slot = 3 ?
                 jr z,noscc
                 inc a             ; increase prim.slotnumber
                 ld d,0
                 ld e,a
                 ld hl,exptbl
                 add hl,de
                 or (hl)           ; combine slot-expansion with slotcode
                 jr testslot

noscc:           ld b,255          ; code for no SCC
done:            pop af            ; retrieve page 2-slot from stack
                 push bc
                 ld h,#80
                 call enaslt       ; restore original page 2-slot
                 pop bc
                 ei
        ;--- store the found slot. 
  	ld	a,b
	ld	(SCC_slot_found),a               
                 
        ret		 
