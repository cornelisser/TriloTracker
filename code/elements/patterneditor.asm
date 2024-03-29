;===========================================================
; --- draw_patterneditor
;
; Display the pattern editor.  Without actual values 
; 
;===========================================================
draw_patterneditor:
	ld	a,255
	ld	(song_order_update),a
	call	clear_screen
	call	draw_orderbox
	call	draw_songbox
	call	draw_patternbox
	call	draw_instrumentbox


;	ld	hl,SCC_slot
;	ld	de,(0)+44
;	call	draw_decimal

	; patterneditor

	ld	hl,0x0009
	ld	de,0x5001	
	call	draw_colorbox	
	ld	hl,0x000a
	ld	de,0x0210	
	call	draw_colorbox	
	ld	hl,0x4e0a
	ld	de,0x0210	
	call	draw_colorbox	
	ld	hl,0x001a
	ld	de,0x5001	
	call	draw_colorbox	
	
	

	ret

;===========================================================
; --- update_patternbox
;
; Display the pattern area values.
; 
;===========================================================
update_patterneditor:
	call	update_patternbox
	;call	update_editbox
	call	update_trackbox
	call	update_songbox
	call	update_instrumentbox
	call	update_orderbox

	ret
	
	
restore_patterneditor:
	ld	a,(editmode)
	cp	0
	ret	z

	ld	a,6
	call	swap_loadelementblock

	ld	a,0
	ld	(editmode),a		
	call	restore_cursor
	call	draw_patterneditor
	call	update_patterneditor
	call	build_order_list
	call	update_orderbox_always

	;--- Make sure the replay is init correct on 1st play
IFDEF	TTSCC
ELSE
	call	drum_defaults_set
ENDIF
	call	replay_stop
	
	ret
	
	
;===========================================================
; --- update_patternbox
;
; Display the pattern area values.
; 
;===========================================================	
init_patterneditor:

;	ld	a,(editmode)
;	cp	0
;	ret	z

	ld	a,6
	call	swap_loadelementblock

	; --- File selectio pointer to the first entry			
	xor	a
	ld	(menu_selection),a
	; --- init mode
	ld	a,0
	ld	(editmode),a
	ld	a,0
	ld	(editsubmode),a	

	call	reset_cursor_trackbox


	; --- show the screen

	call	draw_patterneditor
	call	update_patterneditor
	ld	a,255
	ld	(song_order_update),a
	call	build_order_list
	call	update_orderbox

	
	ret

;===========================================================
; --- update_patterneditor
; Display the pattern track area.  Without actual values 
; 
;===========================================================	
processkey_patterneditor:

	call	process_key_trackbox_musickb

	;--- general keys for patterneditor
	ld	a,(key)
	and	a
	ret	z

	dec	a		;--- F1 = Playback
	jr.	nz,0f
	
		;--- Check if shift is pressed
		ld	a,(skey)
		cp	1	
		jr.	z,5f
		;-- normal play back
		call	start_playback
		jr.	processkey_patterneditor_END	
5:		;-- stepped playback
		call	start_playback_stepped
		jr.	processkey_patterneditor_END	

0:	dec	a		;--- F2 = Instrument editor
	jr.	nz,0f
		ld	a,4	
		call	swap_loadelementblock
		jr.	init_macroeditor
		;jr.	processkey_patterneditor_END

IFDEF TTSCC		
0:	;--- F3
	dec	a
	jr.	nz,0f
		; TODO disabled for now
;		ld	a,1
;		call	swap_loadelementblock
;		call	set_font_backup
;		jr.	init_sampleeditor
	
ELSE
0:	;--- F3 Drum macro editor
	dec	a
	jr.	nz,0f
		ld	a,8
		call	swap_loadelementblock
		jr.	init_drumeditor

ENDIF

0:	;--- F4
	dec	a
	jr.	nz,0f
;		ld	a,4
;		call	swap_loadblock
		ret
;		jr.	init_trackmanager

0:	;--- F5
	dec	a
	jr.	nz,0f
		ld	a,(skey)
		cp	1	
		jr.	z,44f	;init_configeditor	
	
;		ld    a,6
;		call    swap_loadelementblock
    
		jr.    init_filedialog
		;jr.    processkey_patterneditor_END    

44:
		ld	a,3
		call	swap_loadblock		
		jr.	init_configeditor
			
0:	
	
;	;--- CTRL + S sampleeditor
;	cp	's'
;	jr.	z,0f
;	cp	'S'
;	jr.	nz,1f	
;0:	call	init_macroeditor
;	jr.	processkey_patterneditor_END
1:
;	;--- escape this for GRAPH/ALT
	ld	a,(fkey)
	cp	6
	jr.	nz,_noCTRL

	ld	a,(key)
	;--- CTRL + N - Song Name
	cp	_CTRL_N
	jr.	nz,1f
		ld	a,(editsubmode)
		and	a
		jr.	nz,99f
		call	save_cursor
99:		ld	a,1
		ld	(editsubmode),a
		call	reset_cursor_songbox
		jr.	processkey_patterneditor_END
1:
	;--- CTRL + B - Song By
	cp	_CTRL_B
	jr.	nz,1f
		ld	a,(editsubmode)
		and	a
		jr.	nz,99f
		call	save_cursor
99:		ld	a,2
		ld	(editsubmode),a
		call	reset_cursor_songbox
		jr.	processkey_patterneditor_END
1:
	;--- CTRL + P - Pattern number
	cp	_CTRL_P
	jr.	nz,1f
		ld	a,(editsubmode)
		and	a
		jr.	nz,99f
		call	save_cursor
99:		ld	a,3
		ld	(editsubmode),a
		call	reset_cursor_patternbox
		jr.	processkey_patterneditor_END
;1:
;	;--- CTRL + L - Pattern Length
;	cp	_CTRL_L
;	jr.	nz,1f
;		ld	a,(editsubmode)
;		and	a
;		jr.	nz,99f
;		call	save_cursor
;99:		ld	a,4
;		ld	(editsubmode),a
;		call	reset_cursor_patternbox
;		jr.	processkey_patterneditor_END
1:
	;--- CTRL + S - Song speed
	cp	_CTRL_S
	jr.	nz,1f
		ld	a,(editsubmode)
		and	a
		jr.	nz,99f
		call	save_cursor
99:		ld	a,5
		ld	(editsubmode),a
		call	reset_cursor_patternbox
		jr.	processkey_patterneditor_END
1:
	;--- CTRL + O - Octave
	cp	_CTRL_O
	jr.	nz,1f
		ld	a,(editsubmode)
		and	a
		jr.	nz,99f
		call	save_cursor
99:		ld	a,6
		ld	(editsubmode),a
		call	reset_cursor_patternbox
		jr.	processkey_patterneditor_END
1:
	;--- CTRL + D - Pattern order list
	cp	_CTRL_D
	jr.	nz,1f
_ppp_orderlist:
		ld	a,(editsubmode)
		and	a
		jr.	nz,99f
		call	save_cursor
99:		ld	a,7
		ld	(editsubmode),a
		call	reset_cursor_orderbox
		jr.	processkey_patterneditor_END
1:
	;--- CTRL + R - Restart/loop
		cp	_CTRL_R
	jr.	nz,1f
		ld	a,(editsubmode)
		and	a
		jr.	nz,99f
		call	save_cursor
99:		ld	a,8
		ld	(editsubmode),a
		call	reset_cursor_patternbox
		jr.	processkey_patterneditor_END
1:
	;--- CTRL + A - Add (rows after input to cursor)
	cp	_CTRL_A
	jr.	nz,1f
		ld	a,(editsubmode)
		and	a
		jr.	nz,99f
		call	save_cursor
99:		ld	a,9
		ld	(editsubmode),a
		call	reset_cursor_patternbox
		jr.	processkey_patterneditor_END
1:
	;--- CTRL + T - Step edit
	cp	_CTRL_T
	jr.	nz,1f
		ld	a,(editsubmode)
		and	a
		jr.	nz,99f
		call	save_cursor
99:		ld	a,10
		ld	(editsubmode),a
		call	reset_cursor_patternbox
		jr.	processkey_patterneditor_END
1:
	;--- CTRL + I - Instruments
	cp	_CTRL_I
	jr. 	z,_ppp_instruments
	cp	_KEY_TAB
	jr.	nz,1f
_ppp_instruments:	
		ld	a,(editsubmode)
		and	a
		jr.	nz,99f
		call	save_cursor
99:		ld	a,11
		ld	(editsubmode),a
		call	reset_cursor_instrumentbox
		jr.	processkey_patterneditor_END
1:
	;--- CTRL + M - Volume balance mixer
	cp	_CTRL_M
	jr.	nz,1f
		ld	a,(editsubmode)
		and	a
		jr.	nz,99f
		call	save_cursor
99:		ld	a,12
		ld	(editsubmode),a
		call	reset_cursor_songbox
		jr.	processkey_patterneditor_END
1:
	; CTRL-HOME
	;--- Check here the skey's
	ld	a,(skey)
	cp	2		;HOME
	jr.	nz,0f

	;-- restore the cursor from the stack if editsubmode>0
	ld	a,(editsubmode)
	and	a
	jr.	z,99f
	call	restore_cursor
99:
	
	; To start of pattern
	xor	a
	ld	(song_order_pos),a
	ld	hl,song_order
	ld	a,(hl)
	ld	(song_pattern),a	
	jr.	_pkp_home_cont

0:	


	call	check_channel_mute
	;--- Check here the other combinations	
_noCTRL:	; when no CTRL was pressed
	call	check_channel_soloplay
	
	;--- Check here the skey's
	ld	a,(skey)
	cp	2		;HOME
	jr.	nz,0f

	;-- restore the cursor from the stack if editsubmode>0
	ld	a,(editsubmode)
	and	a
	jr.	z,99f
	call	restore_cursor
99:
_pkp_home_cont:
	; To start of pattern
	; save current column values
	ld	bc,(cursor_input)	; get input AND column
	ld	a,(cursor_x)
	ld	d,a
	ld	a,(cursor_type)
	ld	e,a	 

	push	de
	push	bc

	call	flush_cursor
	call	reset_cursor_trackbox
	
	;-- restore column values
	pop	bc
	pop	de
	ld	(cursor_input),bc
	ld	a,d
	ld	(cursor_x),a
	ld	a,e
	ld	(cursor_type),a
	
	call	reset_selection		
	call	build_order_list
	call	update_patterneditor
	jr.	processkey_patterneditor_END

0:		

	;--- End the CTRL and skey checks
	ld	a,(key)
	;--- '`' - Pattern order list
	cp	0x60	;"`"
	jr.	nz,1f
	ld	a,(editmode)
	cp	7
	ld	a,(key)
	jr.	nz,_ppp_orderlist
	
	;--- Instrument select
;1:	cp	_KEY_TAB
;	jr.	nz,1f
;	ld	a,(editmode)
;	cp	11
;	ld	a,(key)
;	jr.	nz,_ppp_instruments

1:
	cp	_SPACE
	jr.	nz,1f
	;--- only if we are editing
	ld	a,(editsubmode)
	and	a
	jr.	nz,1f
	ld	a,(keyjazz)
	xor 	1
	ld	(keyjazz),a
	jr.	set_textcolor		
1:


	;--- dispatch to editmode handler
	ld	a,(editsubmode)
	and	a	
	jr.	nz,0f
	;--- Track edit mode
		jr.	process_key_trackbox	
0:	dec	a
	jr.	nz,0f
	;--- Song name
		call	process_key_songbox
		jr.	processkey_patterneditor_END	
0:	dec	a
	jr.	nz,0f
	;--- Song by
		call	process_key_songbox
		jr.	processkey_patterneditor_END		
0:
	dec	a
	jr.	nz,0f
	;--- Pattern number
		call	process_key_patternbox_pattern
		jr.	processkey_patterneditor_END		
0:
	dec	a
	jr.	nz,0f
	;--- Pattern length
;		call	process_key_patternbox_length
		jr.	processkey_patterneditor_END		
0:
	dec	a
	jr.	nz,0f
	;--- Pattern speed
		call	process_key_patternbox_speed
		jr.	processkey_patterneditor_END		
0:
	dec	a
	jr.	nz,0f
	;--- Pattern octave
		call	process_key_patternbox_octave
		jr.	processkey_patterneditor_END		
0:
	dec	a
	jr.	nz,0f
	;--- Pattern order list
		call	process_key_orderbox
		jr.	processkey_patterneditor_END		
0:
	dec	a
	jr.	nz,0f
;	;--- Restart (order loop) 
		call	process_key_patternbox_restart
		jr.	processkey_patterneditor_END		
0:
	dec	a
	jr.	nz,0f
	;--- Add edit 
		call	process_key_patternbox_add
		jr.	processkey_patterneditor_END		
0:
	dec	a
	jr.	nz,0f
	;--- Pattern step
		call	process_key_patternbox_step
		jr.	processkey_patterneditor_END		
0:
	dec	a
	jr.	nz,0f
	;--- Instruments
		call	process_key_instrumentbox
		jr.	processkey_patterneditor_END		
0:
	dec	a
	jr.	nz,0f
	;--- Volume balance
		call	process_key_songbox_volume
		jr.	processkey_patterneditor_END		
0:


	
processkey_patterneditor_END:
	ret	

check_channel_soloplay:
	;--- GRAPH / ALT
	ld	a,(fkey)
	cp	7
	ret	nz

	ld	a,(key)
	sub	$30
	and	a
	jr.	z,0f
	cp	9
	jr.	c,99f
	ret
0:	
	;-- ONLY DRUM
	ld	a,(DrumMixer)	
	bit 	5,a
	jr.	z,22f
	
	ld	a,(MainMixer)	
	and	a
	jr.	z,.enableAll
22:
	ld	a,100000b
	ld	(DrumMixer),a
	xor	a
	ld	(MainMixer),a
	call	draw_pattern_header
.end	xor	a
	ld	(key),a
	ret				
99:
	;-- ONLY 1 CHANNEL
	cp	9
	ret	nc			
	;-- get mask
	ld	hl,_mixer_mask-1
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:	
	ld	d,(hl)
	ld	a,(MainMixer)
	xor	d
	jr.	z,.enableAll
	ld	a,d
	ld	(MainMixer),a
	;-- silence drums
	ld	a,(DrumMixer)
	;and	011111b
	xor	a
	ld	(DrumMixer),a
	call	draw_pattern_header
	jr.	.end				
	
.enableAll:
	ld	a,(DrumMixer)
	or	100000b
	ld	(DrumMixer),a
	ld	a,$ff
	ld	(MainMixer),a
	call	draw_pattern_header
	jr.	.end					
	
_mixer_mask:
	db	00100000b
	db	01000000b
	db	10000000b
	db	00000001b
	db	00000010b
	db	00000100b
	db	00001000b
	db	00010000b
	
check_channel_mute:
	ld	a,(fkey)
	and	a
	jr.	z,99f			; Hack for no CTRL or ALT
	cp	6
	ret	nz			; Check if CTRL is used.
	;-- CTRL
	ld	a,(key)
	sub	a,"0"+128
	jr.	88f
99:
	ld	a,(key)
	sub	a,"0"	
88:
	and	a
	jr.	z,.drum
	cp	9
	jr.	z,.drum	
	ret	nc

	;-- get mask
	ld	hl,_mixer_mask-1
	add	a,l
	ld	l,a
	jr.	nc,99f
	inc	h
99:	
	ld	d,(hl)
	ld	a,(MainMixer)
	xor	d
	ld	(MainMixer),a
	call	draw_pattern_header
.end	xor	a
	ld	(key),a
	ret					

.drum:	
	ld	a,(DrumMixer)
	xor	100000b
	ld	(DrumMixer),a
	call	draw_pattern_header
	jr. 	.end	


process_key_numpad:
	;--- set octave using numpad
	ld	a,(key_value)
	 
	cp	72
	jr.	c,.end_no
	cp	89
	jr.	nc,.end_no

	ld	a,(key)
	;--- Octave down
	cp	"/"
	jr. 	nz,.octave_up

	ld	a,(song_octave)
	dec	a
	jr.	z,.end_yes		; 1 is lowest octave
	ld	(song_octave),a
	jr.	.end_yes

.octave_up:
	;--- Octave up
	cp	"*"
	jr.	nz,.ins_down

	ld	a,(song_octave)
	inc	a
	cp	9
	jr.	nc,.end_yes
	ld	(song_octave),a
	jr.	.end_yes

.ins_down:	
	;--- Instrument down
	cp	"-"
	jr.	nz,.ins_up

	ld	a,(song_active_instrument)
	dec	a
	and	31
	ld	b,a
	call	_set_ins
	cp	31
	jr.	c,0f
	ld	a,31-6
	jr.	88f
0:	ld	a,(song_instrument_offset)
	cp	b
	jr.	c,99f
	ld	a,b
88:
	ld	(song_instrument_offset),a	
99:
	call	build_instrument_list
	jr.	.end_yes

.ins_up:
	;--- Instrument up
	cp	"+"
	jr.	nz,.ins_reset

	ld	a,(song_active_instrument)
	inc	a
	and	31
	call	_set_ins
	jr.	z,88f
	ld	b,a
	ld	a,(song_instrument_offset)
	add	6
	cp	b
	jr.	nc,99f
	ld	a,b
	sub	6
88:
	ld	(song_instrument_offset),a
99:
	call	build_instrument_list
	jr.	.end_yes

.ins_reset:
	;--- Instrument reset
	cp	"0"
	jr.	nz,.add_down

	xor	a
	ld	(song_instrument_offset),a
	call	_set_ins
	call	build_instrument_list
	jr.	.end_yes


.add_down:
	;--- Add down
	cp	"."
	jr.	nz,.add_up

	ld	a,(song_add)
	and	a
	jr.	z,.end_yes
	dec	a
	ld	(song_add),a
	jr	.end_yes

.add_up:
	;--- Add up
	cp	","
	jr.	z,0f
	cp	"9"
	jr.	nz,.octave
0:
	ld	a,(song_add)
	cp	16
	jr.	nc,.end_yes
	inc	a
	ld	(song_add),a
	jr	.end_yes

.octave:	
	;--- set octave
	sub	"0"
	ld	(song_octave),a


.end_yes:		;--- Key input processed
	xor	a
	ld	(key),a
	scf
	ret

.end_no:		;--- no numpad key found
	xor	a
	ret

_set_ins:
	ld	(song_active_instrument),a
	ld	(tmp_cur_instrument),a
	and	a
	ret	z
	ld 	(song_cur_instrument),a
	ret