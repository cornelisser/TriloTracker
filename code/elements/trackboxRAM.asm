_dpe_step:		ds 1
_dpe_step_count:	ds 1
_dpe_step_char:		ds 1
_dpe_pntpos:		ds 2
_dpe_patlen:		ds 1

_LABEL_PATLINE:
	db	"XX          ",135,"        ",135,"        ",135,"        ",135,"        ",135,"        ",135,"        ",135,"           XX",0

	db	255	;end
_COLTAB_COMPACT:
	;chan 1
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 2
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 3
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 4
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 5
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 6
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 7
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5,2	; 5= y
	;chan 8
	db	0,3	; 0= note
	db	1,1	; 1= sample
	db	2,1	; 2= volume
	db	3,1	; 3= command
	db	4,1	; 4= x
	db	5	; 5= y
	db	255
	
