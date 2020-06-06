;=======================================
; opll detection routine
; taken from Grauw in a forum post on MRC
; https://www.msx.org/forum/msx-talk/development/how-to-detect-sound-chips-without-bios?page=3
;=======================================

RDSLT: equ 0CH
WRSLT: equ 14H
;EXPTBL: equ 0FCC1H

MSXMusic_ID_ADDRESS: equ 4018H
MSXMusic_ENABLE_ADDRESS: equ 7FF6H

; f <- c: found
; a <- slot
; b <- 0: external, -1: internal
MSXMusic_Detect:
    ld 	hl,MSXMusic_MatchInternalID
    call 	Memory_SearchSlots
    ld 	b,-1
    jp 	c,.end
    ld 	hl,MSXMusic_MatchExternalID
    call 	Memory_SearchSlots
    ld 	b,0
    
    ;--- restore the page before returning
	ld	a,(mapper_slot)				; Recuperamos el slot
	ld	h,0x80
	call enaslt
.end
  

; a = slot id
; f <- c: found
MSXMusic_MatchInternalID:
    ld 	de,MSXMusic_internalId
    ld 	hl,MSXMusic_ID_ADDRESS
    ld 	bc,8
    jp 	Memory_MatchSlotString

; a = slot id
; f <- c: found
MSXMusic_MatchExternalID:
    ld 	de,MSXMusic_externalId
    ld 	hl,MSXMusic_ID_ADDRESS + 4
    ld 	bc,4
    call 	Memory_MatchSlotString
    ret 	nc
    push 	af
    ld 	hl,MSXMusic_ENABLE_ADDRESS
    call 	RDSLT
    ei
    set 	0,a
    ld 	e,a
    pop	af
    push	af
    ld 	hl,MSXMusic_ENABLE_ADDRESS
    call 	WRSLT
    ei
    pop 	af
    ret

; Search all slots and subslots for a match.
; Invoke Continue to continue searching where a previous search left off.
; hl = detection routine (receives a = slot ID, can modify all)
; f <- c: found
; a <- slot number
; Modifies: af, bc, de
Memory_SearchSlots:
    ld 	a,0
Memory_SearchSlots_PrimaryLoop:
    ex 	de,hl
    ld 	hl,EXPTBL
    ld 	b,0
    ld 	c,a
    add 	hl,bc
    ld 	a,(hl)
    ex 	de,hl
    and 	10000000B
    or 	c
Memory_SearchSlots_SecondaryLoop:
    push 	af
    push 	hl
    call 	Memory_SearchSlots_JumpHL
    pop 	hl
    jp 	c,Memory_SearchSlots_Found
    pop 	af
Memory_SearchSlots_Continue:
    add 	a,00000100B
    jp 	p,Memory_SearchSlots_NextPrimary
    bit 	4,a
    jp 	z,Memory_SearchSlots_SecondaryLoop
Memory_SearchSlots_NextPrimary:
    inc 	a
    and 	00000011B
    ret 	z  ; not found
    jp 	Memory_SearchSlots_PrimaryLoop
Memory_SearchSlots_Found:
    pop 	af
    scf
    ret
Memory_SearchSlots_JumpHL:
    jp 	hl

; a = slot
; bc = string length
; de = string
; hl = address
; f <- c: found
; Modifies: f, bc, de, hl
Memory_MatchSlotString:
    push 	af
    push 	bc
    push 	de
    call 	RDSLT
    ei
    pop 	de
    pop 	bc
    ex 	de,hl
    cpi
    jr 	nz,Memory_MatchSlotString_NotFound
    jp 	po,Memory_MatchSlotString_Found
    inc 	de
    ex 	de,hl
    pop 	af
    jp 	Memory_MatchSlotString
Memory_MatchSlotString_Found:
    pop 	af
    scf
    ret
Memory_MatchSlotString_NotFound:
    pop 	af
    and 	a
    ret

MSXMusic_internalId:
    db "APRLOPLL"

MSXMusic_externalId:
    db "OPLL"