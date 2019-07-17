_FOUND_VDP:	
	db	0		; actual found VDP speed on start
_FOUND_SLOT:	
	db	0		; actual found SCC slot


;--- from here is saved.
_CONFIG_SLOT:
	db	255		; 255 = auto, 1=slot1, 2=slot2
_CONFIG_FREE:	
	db	0		
_CONFIG_KEYJAZZ:
	db	0		; 0 = default off, 1= default on
_CONFIG_VDP:	
	db	255		; 0 = 60 hz, 1 = 50, 255 = auto
_CONFIG_FREE2:	
	db	0		
_CONFIG_SPEED:
	db	7		; default speed on start
_CONFIG_ADD:	
	db	0		; default add on start
_CONFIG_STEP:
	db	8
_CONFIG_EQU:
	db	0		; default speed equalisation
_CONFIG_CLK:	
	db	1		; default keyboard
_CONFIG_THEME:
IFDEF TTPSG
	db	7
ELSEIFDEF TTFM
	db	1
ELSE
	db	0		;default color theme
ENDIF

_CONFIG_AUDIT:	
	db	1		; Note audition. default on
_CONFIG_DEBUG:
	db	0		; Show chip register debug. default on	
_CONFIG_INS:
	db	0		; load inst set 'default.ins' on start up	
_CONFIG_VU:	
	db	1		; vu meter (1=on)
_CONFIG_PSGPORT:
	db	0xa0		; port of the PSG	
_ENV_PROGRAM:
	db	"PROGRAM",0	

IFDEF TTFM
_DEFAULT_CFG:	db	"TTFM.CFG",0
_DEFAULT_CFGLEN:	equ	9	
ELSEIFDEF TTPSG
_DEFAULT_CFG:	db	"TTPSG.CFG",0
_DEFAULT_CFGLEN:	equ	10
ELSEIFDEF TTSMS
_DEFAULT_CFG:	db	"TTSMS.CFG",0	
_DEFAULT_CFGLEN:	equ	10
ELSE
_DEFAULT_CFG:	db	"TT.CFG",0	
_DEFAULT_CFGLEN:	equ	7
ENDIF