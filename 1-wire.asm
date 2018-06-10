;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
.equ	OW_PORT	= PORTD
.equ	OW_PIN	= PIND
.equ	OW_DDR	= DDRD
.equ	OW_DQ	= PD1

.def	OWCount = r17



#define ReadRom 0x33
#define SkipRom 0xcc
#define ConvertTemp 0x44				; Initiates temperature conversion.
#define  WScratch 0x4e					; Writes data into scratchpad bytes 2, 3, and4 (TH, TL, and configuration registers).
#define  RScratch 0xbe
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Data segment, variable definitions
;------------------------------------------------------------------------------
.dseg
TempWord: .byte 3
TRegister: .byte 3
ConfigRegister: .byte 2




.cseg
;------------------------------------------------------------------------------
; Output : T - presence bit
;------------------------------------------------------------------------------
OWReset:
	cbi		OW_PORT,OW_DQ
	sbi		OW_DDR,OW_DQ

	ldi		XH, HIGH(DVUS(470))
	ldi		XL, LOW(DVUS(470))
	rcall	Wait4xCycles

	cbi		OW_DDR,OW_DQ

	ldi		XH, HIGH(DVUS(70))
	ldi		XL, LOW(DVUS(70))
	rcall	Wait4xCycles

	set
	sbis	OW_PIN,OW_DQ
	clt

	ldi		XH, HIGH(DVUS(240))
	ldi		XL, LOW(DVUS(240))
	rcall	Wait4xCycles

	ret
;------------------------------------------------------------------------------
; Input : C - bit to write
;------------------------------------------------------------------------------
OWWriteBit:
	brcc	OWWriteZero
	ldi		XH, HIGH(DVUS(1))
	ldi		XL, LOW(DVUS(1))
	rjmp	OWWriteOne
OWWriteZero:
	ldi		XH, HIGH(DVUS(120))
	ldi		XL, LOW(DVUS(120))
OWWriteOne:
	sbi		OW_DDR, OW_DQ
	rcall	Wait4xCycles
	cbi		OW_DDR, OW_DQ

	ldi		XH, HIGH(DVUS(60))
	ldi		XL, LOW(DVUS(60))
	rcall	Wait4xCycles
	ret
;------------------------------------------------------------------------------
; Input : r16 - byte to write
;------------------------------------------------------------------------------
OWWriteByte:
	push	OWCount
	ldi		OWCount,0
OWWriteLoop:
	ror		r16
	rcall	OWWriteBit
	inc		OWCount
	cpi		OWCount,8
	brne	OWWriteLoop
	pop		OWCount
	ret
;------------------------------------------------------------------------------
; Output : C - bit from slave
;------------------------------------------------------------------------------
OWReadBit:
	ldi		XH, HIGH(DVUS(1))
	ldi		XL, LOW(DVUS(1))
	sbi		OW_DDR, OW_DQ
	rcall	Wait4xCycles
	cbi		OW_DDR, OW_DQ
	ldi		XH, HIGH(DVUS(5))
	ldi		XL, LOW(DVUS(5))
	rcall	Wait4xCycles
	clt
	sbic	OW_PIN,OW_DQ
	set
	ldi		XH, HIGH(DVUS(50))
	ldi		XL, LOW(DVUS(50))
	rcall	Wait4xCycles
	sec
	brts	OWReadBitEnd
	clc
OWReadBitEnd:
	ret
;------------------------------------------------------------------------------
; Output : r16 - byte from slave
;------------------------------------------------------------------------------
OWReadByte:
	push	OWCount
	ldi		OWCount,0
OWReadLoop:
	rcall	OWReadBit
	ror		r16
	inc		OWCount
	cpi		OWCount,8
	brne	OWReadLoop
	pop		OWCount
	ret
;------------------------------------------------------------------------------
; 18b20 MainReadTemp
;------------------------------------------------------------------------------
MainReadTemp:

	ldi 	YL,LOW(TempWord)
	ldi   YH,HIGH(TempWord)
	rcall	OWReset						; One wire reset
	brts	MainReadTemp					; If device not present go to MainLoop
	ldi		r16,SkipRom 					; Write Skip Rom one wire in "single-drop"
	rcall	OWWriteByte					;
	ldi		r16, RScratch					; Write ConvertCommand
	rcall	OWWriteByte					;
	rcall	OWReadByte
	st		Y+, r16						; Store TEMPERATURE LSB(50h) byte to table, and increment pointer
	;rcall	LCD_WriteHex8
	rcall	OWReadByte
	st		Y+, r16						; Store TEMPERATURE MSB(05h) byte to table, and increment pointer
	;rcall	LCD_WriteHex8
	ret

TempRequest:
	rcall	OWReset						; One wire reset
	brts	MainReadTemp					; If device not present go to MainLoop

	ldi		r16,SkipRom 					; Write Skip Rom one wire in "single-drop"
	rcall	OWWriteByte					;
	ldi		r16, ConvertTemp					; Write ConvertCommand
	rcall	OWWriteByte					;
	ldi 	r16, 188
	rcall WaitMiliseconds
	reti

ConvertTempForLCD:	;r18 contiendra la partie décimal et xl la partie entiere
	push 	r16
	push	r17
	ldi 	YL,LOW(TempWord)
	ldi		YH,HIGH(TempWord)
	ld		XL, Y+
	ld 		XH, Y+
	lsr		XL
	lsr		XL ;Sup des deux bit inutilisé
	mov		r16, XL
	ldi		r18, 0x03			;Masque des 3 bit de fraction
	AND 	r18, XL					;3bit fraction
	ldi		r16, 25
	mul		r18, r16
	movw		r18, r0
	lsr		XL
	lsr		XL ;Sup des deux bit de fraction
	ldi		r16, 0b00001111
	and		XH,r16
	SWAP	XH
	or		XL,XH
	;mov		r16, R18
	;rcall	LCD_WriteHex8

	pop		r17
	pop 	r16
	ret
