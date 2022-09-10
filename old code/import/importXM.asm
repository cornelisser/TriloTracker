_XM_WILDCARD:
	db	"*.XM",0
_XM_INSVOL:		; start volumes needed for post-processing
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


_xm_channelcount	db	8		; number of channels in the current XM file.
_xm_patterncount	db	0		; number of patterns to load.

_xm_samplecount	db	0		; number of samples in the current instrument

;===========================================================
; --- open_xmfile
;
; Open an xmfile. HL needs to point to the file
; Data is loaded into the current song
;===========================================================	
open_xmfile:
	ld	(_catch_stackpointer),sp
	call	reset_hook

	ld	a,00000001b		; NO write
	call	open_file
	
	;--- Check for errors
	and	a
	jr.	nz,catch_diskerror
	
	ld	a,b
	ld	(disk_handle),a
	
	;--- Skip [ID text]
	ld	de,buffer
	ld	hl,17
	call	read_file
	jr.	nz,catch_diskerror
	
	;--- Read Song Name
	ld	de,song_name
	ld	hl,20
	call	read_file
	jr.	nz,catch_diskerror	
	
	;--- erase remaining chars
	ld	de,song_name+20
	ld	b,12
	ld	a,32
88:
	ld	(de),a
	inc	de
	djnz	88b

	;--- Skip [$1a]
	ld	de,buffer
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror

	;--- Read Song Name [TRACKER NAME] + Version number
	ld	de,song_by
	ld	hl,22
	call	read_file
	jr.	nz,catch_diskerror	

	;--- erase remaining chars
	ld	de,song_by+22
	ld	b,10
	ld	a,32
88:
	ld	(de),a
	inc	de
	djnz	88b

	; check if the correct version.
	ld	a,(song_by+20)
	cp	4
	jr.	nz,_oxmf_ver_error
	
	ld	a,(song_by+21)
	cp	1
	jr.	nz,_oxmf_ver_error
	
	;--- header size 
	ld	de,buffer	 ; store header size in first 2 bytes
	ld	hl,4
	call	read_file
	jr.	nz,catch_diskerror

	;--- order/order size 
	ld	de,song_order_len	
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror

	;--- Skip [ORDER len highbyte]
	ld	de,buffer+2 	; header size is in first 2 bytes
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror
	
	;--- check song length
		;--- lowbyte
		ld	a,(song_order_len)
		cp	SONG_SEQSIZE+1
		jr.	nc,_oxm_len_error  	; jump is song order is to large.
		;--- highbyte
		ld	a,(buffer+2)
		and	a
		jr.	nz,_oxm_len_error  	; jump is song order is to large.	
	

	;--- order/order loop/restart 
	ld	de,song_order_loop	
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror
	
	;--- Skip [ORDER loop highbyte]
	ld	de,buffer+2 	; header size is in first 2 bytes
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror
	;---  [NUMBER OF CHANNELS]
	ld	de,_xm_channelcount 	; header size is in first 2 bytes
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror

	;--- Check is not too many channels/tracks per pattern	
		ld	a,(_xm_channelcount)
		cp	9
		jr.	nc,_oxm_chan_error
	
	;--- SKIP # channels to import highbyte
	ld	de,buffer+2 	; header size is in first 2 bytes
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror

	;--- # patterns to import  
	ld	de,_xm_patterncount 	; header size, #chans is in first 3 bytes
	ld	hl,2
	call	read_file
	jr.	nz,catch_diskerror
	
	;--- check if we have too many patterns.
		ld	a,(max_pattern)
		inc	a
		ld	d,a
		ld	a,(_xm_patterncount)
		cp	d
		call	nc,_oxm_pat_warning


	;--- # number of instruments to import + 3 skip bytes
	ld	de,song_instrument_list		; store this here as we will overwrite it later anway
	ld	hl,4
	call	read_file
	jr.	nz,catch_diskerror

	;--- check if we have too many instruments.
		ld	a,(song_instrument_list)
		cp	32
		call	nc,_oxm_instr_warning

	;--- song (default) speed
	ld	de,song_speed
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror
	
	
	;--- TT is twice as fast ;)
	ld	a,(song_speed)
	add	a
	dec	a
	dec	a
	ld	(song_speed),a
	
	
	;--- skip [highbyte, speed,BPM (expected to be around 125)]
	ld	de,buffer+5
	ld	hl,3
	call	read_file
	jr.	nz,catch_diskerror
	

	;--- Sequence/order list 
	ld	de,song_order	
	ld	hl,SONG_SEQSIZE
	call	read_file
	jr.	nz,catch_diskerror
	
	;--- store #chans and #patterns in iy
	ld	a,(_xm_patterncount)
	ld	iyh,a
	ld	a,(_xm_channelcount)
	ld	iyl,a
	

	;--- skip to start of the patterndata
		; calculate the bytes already read from the buffer
	ld	hl,0x50-0x3c
	ld	de,SONG_SEQSIZE
	add	hl,de
	
	ex	de,hl
		; get bufffer size we read earlier
	ld	hl,(buffer)
	xor	a			; make sure to clear the C flag
	sbc	hl,de	
	ld	de,buffer
	call	read_file
	jr.	nz,catch_diskerror	
	
	
	
	;--- Now we can read the patterns.
	ld	a,iyh		; extra check if there a no patterns (0_O)?
	and	a
	jr.	z,_open_xmfile_end

	;---- Add # of patterns to read
	ld	de,_FILMES_importpat+21
	ld	a,iyh
	dec	a
	ld	(buffer),a
	ld	hl,buffer
	call	conv_decimal		; copy pat# in message string
	
	xor	a
	ld	ixh,a		; patternnumber
	
_oxm_patloop:
	;-- show the progress as import is slow
	ld	de,_FILMES_importpat+18
	ld	a,ixh
	ld	(buffer),a
	ld	hl,buffer
	call	conv_decimal		; copy pat# in message string
	ld	de,_FILMES_importpat
	call	message_filedialog

	;--- TEST IF PATTERN STILL FITS
	ld	a,(max_pattern)
	cp	ixh
	jr.	nc,99f
	;--- skip
	call	skip_xm_pattern		; pattern doesn't fit anymore.
	jr.	88f	
99:
	ld	b,ixh				; set pattern# in b
	call	set_patternpage			; set the memory page of the pattern
	call	load_xm_pattern
88:
	inc	ixh
	dec	iyh ;patterns
	jr.	nz,_oxm_patloop


		
	;--- remove wrong pat# from song_order 
;	ld	a,(current_song)
	call	set_songpage
	
	ld	hl,song_order
	ld	a,(song_order_len)
	ld	b,a
0:
	ld	a,(max_pattern)
	cp	(hl)
	jr.	nc,99f
	ld	(hl),0
99:
	inc	hl
	djnz	0b
	
	;===========================================
	;---- continue reading the instruments.	
	;
	;
	;===========================================
	;---- Add # of instruments to read
	ld	de,_FILMES_importins+24
	ld	hl,song_instrument_list
	call	conv_decimal		; copy instr# in message string

	ld	a,(song_instrument_list)
	ld	iyh,a
	xor	a
	ld	ixh,a
_xm_imp_ins_loop:

	;-- show the progress as import is slow
	ld	de,_FILMES_importins+21
	ld	a,ixh
	ld	(buffer),a
	ld	hl,buffer
	call	conv_decimal		; copy pat# in message string
	ld	de,_FILMES_importins
	call	message_filedialog	
	
	ld	a,ixh
	cp	31	;--- maximun# instruments	
	jr.	c,99f
	ld	a,1
	ld	iyh,1
	jr.	88f
99:
	; instrument read test
	call	load_xm_instrument
	
88:	
	inc	ixh
	dec	iyh ;patterns
	jr.	nz,_xm_imp_ins_loop

	
_open_xmfile_end:

	;---- Set default instruments (waveform + macro)
	
	
	;---- Process all patterns to set note value if needed.




	; --- Set the first pattern in the order after loading	
	ld	a,(song_order)
	ld	(song_pattern),a
	
	call	close_file
	call	set_hook
	
	;--- initialize default instruments
	ld	hl,instrument_macros+6
	xor	a
	ld	bc,INSTRUMENT_SIZE-6
_oxf_instr_loop:
	add	hl,bc
	ld	(hl),1	; length
	inc	hl
	ld	(hl),0	; restart
	inc	hl
	ld	(hl),a	; waveform
	inc	hl
	ld	(hl),0	; no noise
	inc	hl	
	ld	(hl),10001111b	; tone + vol 15	
	inc	hl
	ld	(hl),0	; no freq delta
	inc	hl
	ld	(hl),0	; no freq delta
	inc	a
	cp	32
	jr.	nz,_oxf_instr_loop	

	;--- start the channel manager
	;--- start the channel manager
	ld	hl,_XM_chans
	call	channel_manager
	;--- if we came here reset the error window indicator
	;    for the warnings.
	xor	a
	ld	(window_shown),a

	ret
_XM_chans:
	db	"12345678"	
	




;===========================================================
; --- load_xm_sample
;
; Loads 1 sample into waveform.
; input:	[B] contains the waveform
;===========================================================
load_xm_sample:
	push	bc
	
	;--- Get length of sample
	ld	de,buffer+8
	ld	hl,4
	call	read_file
	jr.	nz,catch_diskerror

	;--- skip to start data
	ld	a,(buffer+6)
	sub	4
	ld	l,a
	ld	h,0
	ld	de,buffer+12
	call	read_file
	jr.	nz,catch_diskerror


0:	; skip headers and calculate the sampledata to load	
	;----- skip any other samples.
	ld	a,(buffer+4)
	dec	a
	jr.	z,1f
	
	ld	(buffer+4),a


	;--- Get length of sample + rest of the header
	ld	de,buffer+12
	ld	a,(buffer+6)
	ld	h,0
	ld	l,a
	call	read_file
	jr.	nz,catch_diskerror
	
	; add sample size (32 bit)
	ld	hl,(buffer+8)
	ld	de,(buffer+12)
	add	hl,de
	ld	(buffer+8),hl
	ld	hl,(buffer+10)
	ld	de,(buffer+14)
	adc	hl,de	
	ld	(buffer+10),hl

	jr.	0b
	
1:
	pop	af
	;--- load first 32 bytes in waveform
	;--- get waveform address in RAM
	ld	hl,_WAVESSCC
	ld	de,32
	and	a
	jr.	z,0f
99:	add	hl,de
	dec	a
	jr.	nz,99b

	
0:		
	ex	de,hl
	
	;--- Check if sample length is < 32
	ld	a,(buffer+9)
	and	a
	jr.	nz,1f		; jmp is highbyte sample len >0
	ld	a,(buffer+8)
	cp	32
	jr.	nc,1f		; jmp is sample len >= 32
	ld	l,a	

1:
	; DE = address of waveform
	; HL = 32 of smaller length	
	call	read_file
	jr.	nz,catch_diskerror	


	;--- Check is sample >= 16kb
	ld	a,(buffer+10)
	and	a
	jr.	z,0f	

_load_xm_sam_skip16kb_loop:
	push	af		; in a the number of 16 blocks.	
	ld	b,0		;-- 256 times.
88:		; read 256 byte
		push	bc
		ld	de,buffer+12
		ld	hl,256
		call	read_file
		jr.	nz,catch_diskerror
		pop	bc
		djnz	88b
		
	pop	af
	dec	a
	jr.	nz,_load_xm_sam_skip16kb_loop

0:
	;--- Check if sample length is < 32
	ld	a,(buffer+9)
	and	a
	jr.	nz,1f		; jmp is highbyte sample len >0
	ld	a,(buffer+8)
	cp	32
	jr.	nc,1f		; jmp is sample len >= 32
	ret			; no more data to read.	

1:	
	;---- skip remaining sample data (if needed)	
	ld	de,32
	ld	hl,(buffer+8)
	xor	a		; clear carry 
	sbc	hl,bc

_load_xm_sam_loop:
	;load sample data in 256 byte blocks
	ld	a,h
	and	a		; less than 256 bytes?
	jr.	z,1f
	
	dec	h
	push	hl

	ld	de,buffer+8	
	ld	hl,256
	call	read_file
	jr.	nz,catch_diskerror
	
	pop	hl
	jr.	_load_xm_sam_loop		
	
1:	;--- load remaining bytes from sample
	; hl still has remaining bytes
	ld	de,buffer+8	
	call	read_file
	jr.	nz,catch_diskerror

	ret	
	

;===========================================================
; --- load_xm_instrument
;
; Loads 1 instrument.
; input:	[A] contains the instrument
;===========================================================
load_xm_instrument:
	push	af
	;---load the header size
	ld	de,buffer
	ld	hl,4
	call	read_file
	jr.	nz,catch_diskerror	
	
	pop	af	
	push	af
	;--- load name of the instrument
	ld	hl,song_instrument_list
	ld	de,16
	and	a
	jr.	z,88f
99:
	add	hl,de
	dec	a
	jr.	nz,99b	

88:
	ex	de,hl
	call	read_file
	jr.	nz,catch_diskerror

	;--- skip last chars of instrument,type
	ld	de,buffer+4
	ld	hl,6+1
	call	read_file
	jr.	nz,catch_diskerror
	
	
	;--- load #samples to process +sample header size
	ld	de,buffer+4
	ld	hl,6
	call	read_file
	jr.	nz,catch_diskerror	
	
	;--- skip (for now) instrument data

	ld	hl,(buffer)
	ld	bc,33
	xor	a	;clear flag
	sbc	hl,bc		; we alread read 33 bytes from header

	cp	h
	jr.	z,_l_xm_i_skip_end		; load the remaining data
_l_xm_i_skip_loop:	
	push	hl
	ld	hl,$100
	ld	de,buffer+10
	call	read_file
	call	nz,catch_diskerror
	pop	hl
	dec	h
	jr.	nz,_l_xm_i_skip_loop


_l_xm_i_skip_end:			; only L has value, H not
	xor	a
	cp	l
	jr.	z,23f
	ld	de,buffer+10
	call	read_file
	jr.	nz,catch_diskerror	

23:
	pop	bc	; get the instrument# == waveform#

	;read samples (# in buffer+4).	
	ld	a,(buffer+4)
	and	a
	jr.	z,_load_xm_instrument_END	

	; load 1st sample in waveform
	call	load_xm_sample

_load_xm_instrument_END:		
	ret

;===========================================================
; --- skip_xm_pattern
;
; Skips 1 pattern from the current XM file.
; Nothing is done with the data 
;===========================================================	
skip_xm_pattern:
	;---load the header size
	ld	de,buffer
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror	
		
	;--- load the header (minus the size byte)
	ld	a,(buffer)
	sub	3
	ld	h,0
	ld	l,a	
	ld	de,buffer+3
	call	read_file
	jr.	nz,catch_diskerror

	;--- get bytes to skip
	ld	de,buffer
	ld	hl,2
	call	read_file
	jr.	nz,catch_diskerror	

	;--- and now skip the damn thing
	ld	hl,(buffer)
	ld	de,buffer
	call	read_file
	jr.	nz,catch_diskerror	

	ret	

;===========================================================
; --- load_xm_pattern
;
; Load 1 pattern from the current XM file. HL points to pattern start 
; to the file data is loaded into the current pattern
;===========================================================	
load_xm_pattern:
	push	hl	; store the pat start in RAM
	
	
	;---load the header size
	ld	de,buffer
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror	
	
	;--- load the header (minus the size byte)
	ld	a,(buffer)
	dec	a
	ld	h,0
	ld	l,a	
	ld	de,buffer+3
	call	read_file
	jr.	nz,catch_diskerror


	pop	hl		; get patpointer from the stack

	
	;--- now for every row (buffer+4) we read the channels [iyl]	
_lxmp_rowloop:

	push	hl	
	;--- init the channel loop
	ld	a,(_xm_channelcount)
	ld	ixl,a	

	
_lxmp_chanloop:
	
	;--- load the compression byte from the file
	call	_lxmp_loadbyte
	ld	a,(buffer)
	ld	b,a
	;-- check if compressed data
	bit	7,a
	jr.	nz,0f
	;-- not compressed, fake compression
	ld	b,255
;	sub	12
	jr.	1f	

0:
	;check note	
	xor	a
	bit	0,b
	jr.	z,1f
	;--- next is a note!
	call	_lxmp_loadbyte
	ld	a,(buffer)
1:
	cp	13
	jr.	c,99f
	cp	97
	jr.	nc,99f
	sub	12
99:
	ld	(hl),a
	inc	hl
	
	xor	a		; default volume
	;check instrument
	bit	1,b
	jr.	z,1f
	;--- next is instrument
	call	_lxmp_loadbyte
	ld	a,(buffer)
	and	0x1f
1:
	ld	(hl),a
	inc	hl

	;check volume
	xor	a		; default vol = 0
	bit	0,b		; is there a note?
	jr.	z,88f	
	ld	a,$f0		; set default vol of there was a note

88:	bit	2,b
	jr.	z,1f
	;--- next is volume
	call	_lxmp_loadbyte
	ld	a,(buffer)
	sub	10
	cp	0x40		; volume 64
	jr.	nz,1f
	ld	a,0x39	; volume 63	
1:
	; volume and cmd are combined in RAM
;!!!! NEED TO ADD VOLUME TRANSLATION!!!	
	sla	a
	sla	a
	and	0xf0
	ld	(hl),a
;	inc	hl		; don't inc as we need to write it for cmd too.

	;check cmd
	xor	a
	bit	3,b
	jr.	z,1f
	;--- next is cmd
	call	_lxmp_loadbyte
	ld	a,(buffer)
1:
	ld	c,a		; save for later
	; volume and cmd are combined in RAM
	ld	a,(hl)
	or	c
	ld	(hl),a
	inc	hl		
	
	;check xy
	xor	a
	bit	4,b
	jr.	z,1f
	;--- next is xy
	call	_lxmp_loadbyte
	ld	a,(buffer)
	
	ld	b,a	;param in b
	ld	a,c	;cmd in a
	;---- process command parameters
	cp	8
	jr.	c,_lxpc_low	; process cmd 0-7
	jr.	_lxpc_high	; process cmd 8-f
_lxpc_continue:	; return here
	
1:
	; volume and cmd are combined in RAM
	ld	(hl),a
	inc	hl		
	
	;channel is read
	
	dec	ixl
	jr.	nz,_lxmp_chanloop
	

	pop	hl
	ld	de,8*4
	add	hl,de
	
	
	
	;--- check if we loaded all rows.
	ld	a,(buffer+7)
	dec	a
	ld	(buffer+7),a
	jr.	nz,_lxmp_rowloop	

	;--- end the pattern hack ;)
	dec	hl
	dec	hl
	ld	a,(hl)
	and	0xf0
	or	0x0d
	ld	(hl),a
	
	;--- pattern is done reading. Return
	ret
	
;--- just load a byte in the buffer	
_lxmp_loadbyte:
	push	bc
	push	hl
	ld	de,buffer
	ld	hl,1
	call	read_file
	jr.	nz,catch_diskerror
	pop	hl
	pop	bc
	ret	

;--- pre process cmd and parameters
_lxpc_low:
	and	a
	jr.	z,_lxpc0
	dec	a
	jr.	z,_lxpc1
	dec	a
	jr.	z,_lxpc2
	dec	a
	jr.	z,_lxpc3
	dec	a
	jr.	z,_lxpc4
	dec	a
	jr.	z,_lxpc5
	dec	a
	jr.	z,_lxpc6
	dec	a
	jr.	z,_lxpc7
	
_lxpc_high:
	sub	8
	jr.	z,_lxpc8
	dec	a
	jr.	z,_lxpc9
	dec	a
	jr.	z,_lxpcA
	dec	a
	jr.	z,_lxpcB
	dec	a
	jr.	z,_lxpcC
	dec	a
	jr.	z,_lxpcD
	dec	a
	jr.	z,_lxpcE
	dec	a
	jr.	z,_lxpcF


_lxpc0:	; arpeggio
	jr.	_lxpc_continue	; nothing needed
_lxpc1:	; portamento up
	jr.	_lxpc_continue	; nothing needed
_lxpc2:	; portamento down
	jr.	_lxpc_continue	; nothing needed
_lxpc3:	; portamento tone
	jr.	_lxpc_continue	; nothing needed
_lxpc4:	; vibrato
	jr.	_lxpc_continue	; nothing needed
_lxpc5:	; tone portamento + vol slide
	jr.	_lxpc_continue	; nothing needed
_lxpc6:	; vibrato + vol slide
	jr.	_lxpc_continue	; nothing needed
_lxpc7:	; tremolo
	jr.	_lxpc_clear		; tremolo is not implemented
_lxpc8:	; panning
	jr.	_lxpc_clear		; panning is not implemented
_lxpc9:	; sample offset
	jr.	_lxpc_clear		; sample offset is not implemented
_lxpcA:	; volume slide
	jr.	_lxpc_continue	; nothing needed
_lxpcB:	; position jump
	jr.	_lxpc_clear		; position jump is not implemented
_lxpcC:	; set volume
	jr.	_lxpc_clear		; volume is not implemented
_lxpcD:	; pattern break
	jr.	_lxpc_continue	; nothing needed
_lxpcE:	; extended commands
	ld	a,b
	and	$f0
	cp	$40
	jr.	z,_lxpc_continue	
	cp	$90
	jr.	z,_lxpc_continue
	cp	$D0
	jr.	z,_lxpc_continue
	jr.	_lxpc_clear
_lxpcF:	;speed
	ld	a,b
	add	a			; TT is twice as fast
	dec	a
	ld	b,a
	jr.	_lxpc_continue		
 
_lxpc_clear:	; clear cmd + param	
	dec	hl			
	ld	a,(hl)
	and	$f0		; erase cmd
	ld	(hl),a
	inc	hl
	ld	b,0		; erase param
	jr.	_lxpc_continue	


;--------------------------------------------------
;
;
;
;
;--------------------------------------------------	
	;-- too many channels
_oxm_chan_error:
	ld	hl,_WIN_XM_CHAN_ERROR
	jr.	_oxmf_cont_error
;--------------------------------------------------
;
;
;
;
;--------------------------------------------------	
	;-- song order too long.
_oxm_len_error:
	ld	hl,_WIN_XM_LEN_ERROR
	jr.	_oxmf_cont_error
	
;--------------------------------------------------
;
;
;
;
;--------------------------------------------------	
	;-- unsupported version
_oxmf_ver_error:
		ld	hl,_WIN_XM_VERSION_ERROR
_oxmf_cont_error:
		call	window_custom
		ld	sp,(_catch_stackpointer)
		ret


;--------------------------------------------------
;
;
;
;
;--------------------------------------------------	
;-- too many instruments
_oxm_instr_warning:
	ld	hl,_WIN_XM_INSTR_WARNING
	jr.	_oxmf_cont_warning
	
;--------------------------------------------------
;
;
;
;
;--------------------------------------------------	
	;-- to many patterns.
_oxm_pat_warning:
	ld	hl,_WIN_XM_PAT_WARNING
_oxmf_cont_warning:
	call	window_custom
	ret	


_WIN_XM_VERSION_ERROR:
	;-- box
	dw	(80*12)+20		; HL = position in PNT (relative)
	dw	0x2809		; D = width; E = height
	;-- color
	dw	0x140c		; H = x pos	; L = y pos
	dw	0x2809		; D = width ; E = height
	;-- text
	dw	(80*12)+22
	db	"[XM IMPORT ERROR]",0,0
	db	"The XM version of this XM file is not",0
	db	"compatible with the import routine.",0
	db	"Only files of XM format version 1.4 are supported",0,0
	db	"Press any key to stop import",0,255
	db	255
;	db	_OPTION_CLOSE
	
_WIN_XM_LEN_ERROR:
	;-- box
	dw	(80*12)+20		; HL = position in PNT (relative)
	dw	0x2808		; D = width; E = height
	;-- color
	dw	0x140c		; H = x pos	; L = y pos
	dw	0x2808		; D = width ; E = height
	;-- text
	dw	(80*12)+22
	db	"[XM IMPORT ERROR]",0,0
	db	"The XM song length is too long.",0,0,0,0
	db	"Press any key to stop import",0,255
	db	255
;	db	_OPTION_CLOSE
	
_WIN_XM_CHAN_ERROR:
	;-- box
	dw	(80*12)+20		; HL = position in PNT (relative)
	dw	0x2808		; D = width; E = height
	;-- color
	dw	0x140c		; H = x pos	; L = y pos
	dw	0x2808		; D = width ; E = height
	;-- text
	dw	(80*12)+22
	db	"[XM IMPORT ERROR]",0,0
	db	"The XM song contains too many tracks.",0
	db	"(channels) per pattern. Maximum is 8.",0,0,0
	db	"Press any key to stop import",0,255
	db	255
;	db	_OPTION_CLOSE

_WIN_XM_PAT_WARNING:
	;-- box
	dw	(80*12)+20		; HL = position in PNT (relative)
	dw	0x2808		; D = width; E = height
	;-- color
	dw	0x140c		; H = x pos	; L = y pos
	dw	0x2808		; D = width ; E = height
	;-- text
	dw	(80*12)+22
	db	"[XM IMPORT ERRROR]",0,0
	db	"The XM song contains more patterns",0
	db	"than TT can store in RAM.",0
	db	"Not all patterns will be imported!",0,0
	db	"Press any key to continue",0,255
	db	255
;	db	_OPTION_CLOSE

_WIN_XM_INSTR_WARNING:
	;-- box
	dw	(80*12)+20		; HL = position in PNT (relative)
	dw	0x2808		; D = width; E = height
	;-- color
	dw	0x140c		; H = x pos	; L = y pos
	dw	0x2808		; D = width ; E = height
	;-- text
	dw	(80*12)+22
	db	"[XM IMPORT ERRROR]",0,0
	db	"The XM song contains more instruments",0
	db	"than TT can store in RAM.",0
	db	"Not all instruments will be imported!",0,0
	db	"Press any key to continue",0,255
	db	255
;	db	_OPTION_CLOSE