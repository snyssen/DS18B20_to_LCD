;------------------------------------------------------------------------------
; iButton serial number reader
; http://avr-mcu.dxp.pl
; e-mail: radek(at)dxp.pl
; (c) Radoslaw Kwiecien
;------------------------------------------------------------------------------
.include "tn2313def.inc"
;------------------------------------------------------------------------------
; Defines
;------------------------------------------------------------------------------
#define F_CPU 8000000
;------------------------------------------------------------------------------
; Data segment, variable definitions
;------------------------------------------------------------------------------
.dseg

SerialNumber:	.byte 8

;------------------------------------------------------------------------------
; Code segment
;------------------------------------------------------------------------------
.cseg
;------------------------------------------------------------------------------
; Include required files
;------------------------------------------------------------------------------
#include "vectors.asm"
#include "hd44780.asm"
#include "wait.asm"
#include "1-wire.asm"
#include "crc8.asm"
;------------------------------------------------------------------------------
; Constants definition
;------------------------------------------------------------------------------
Text1 : 
	.db "iButton Reader",0,0
Text2 :
	.db "avr-mcu.dxp.pl",0,0
;------------------------------------------------------------------------------
; Program entry point
;------------------------------------------------------------------------------
ProgramEntryPoint:
	ldi		r16, LOW(RAMEND)			; Initialize stack pointer
	out		SPL, r16					;

	rcall	LCD_Init					; Initialize LCD

	ldi		r16, (HD44780_LINE0 + 1)	; 
	rcall	LCD_SetAddressDD			; Set Display Data address to (0,1)
	
	ldi		ZL, LOW(Text1 << 1)			; Load string address to Z 
	ldi		ZH, HIGH(Text1<< 1)			;
	rcall	LCD_WriteString				; Display string

	ldi		r16, (HD44780_LINE1 + 1)	;
	rcall	LCD_SetAddressDD			; Set Display Data address to (1,1)

	ldi		ZL, LOW(Text2 << 1)			; 
	ldi		ZH, HIGH(Text2<< 1)			; Load string address to Z
	rcall	LCD_WriteString				; Display string

MainLoop:
	rcall	OWReset						; One wire reset
	brts	MainLoop					; If device not present go to MainLoop

	ldi		r16, 0x33					; Write ReadRom command
	rcall	OWWriteByte					;

	rcall	CRC8Init					; Initialize CRC8 value

	rcall	OWReadByte					; Read first byte (Family ID)
	cpi		r16,0						; If first byte equal to zero, go to MainLoop	
	breq	MainLoop					; (short circuit on one wire bus)

	rcall	CRC8Update					; Update the CRC
	
	ldi 	YL, LOW(SerialNumber)		;
	ldi		YH, HIGH(SerialNumber)		; Load to Y address of SerialNumber table
	
	st		Y+, r16						; Store first byte to table, and increment pointer

	ldi		r17, 7						; 7 bytes remaining
StoreLoop:
	rcall	OWReadByte					; read next byte
	rcall 	CRC8Update					; update the CRC
	st		Y+, r16						; store next byte to table, and increment pointer
	dec		r17							; decrement loop counter
	brne	StoreLoop					; if greater than zero, jump to StoreLoop

	rcall	GetCRC8						; Read computet CRC8
	cpi		r16,0						; copmare with zero
	brne	MainLoop					; if not equal, jump to MainLoop (bad CRC)
										; else
	ldi		r16, (HD44780_LINE1 + 0)	; 
	rcall	LCD_SetAddressDD			; Set DisplayData address to (0,1)

	ldi 	YL, LOW(SerialNumber)		;
	ldi		YH, HIGH(SerialNumber)		; Load to Y address of SerialNumber table
	ldi		r17,8						; 8 digits to display
LoadLoop:
	ld		r16, Y+						; load to r16 byte from table
	rcall	LCD_WriteHex8				; display it on LCD in HEX
	dec 	r17							; decrement loop conouter
	brne	LoadLoop					; if not zero, jump to LoadLoop
	rjmp	MainLoop					; jump to MainLoop
;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------
