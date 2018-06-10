;------------------------------------------------------------------------------
; iButton serial number reader
; Addapter pour lire le 18b20 par http://adriy.be
; http://avr-mcu.dxp.pl
; e-mail: radek(at)dxp.pl
; (c) Radoslaw Kwiecien
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Defines
;------------------------------------------------------------------------------
#define F_CPU 8000000

;Table 3. DS18B20 Function Command Set p12
#define ReadRom 0x33
#define SkipRom 0xcc
#define ConvertTemp 0x44				; Initiates temperature conversion.
#define  WScratch 0x4e					; Writes data into scratchpad bytes 2, 3, and4 (TH, TL, and configuration registers).
#define  RScratch 0xbe					; Reads the entire scratchpad including theCRC byte.
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
	;.db "temp reader ~0.25",0,0
	.db "Lecture temp",0,0
;Text2 :
;	.db "avr-mcu.dxp.pl",0,0
Tp :
	.db	".",0,0
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
	rcall	LCD_SetAddressDD			; Set Display Data address to (1,1);

ConfigResolTo10Bits:
	rcall	OWReset
	brts	ConfigResolTo10Bits
	ldi		r16, SkipRom					; Write Skip Rom one wire in "single-drop"
	rcall	OWWriteByte	
	ldi		r16, WScratch
	rcall	OWWriteByte
	clr		r16
	rcall	OWWriteByte					;th,tl
	rcall	OWWriteByte					;th,tl
	ldi		r16, 63
	rcall	OWWriteByte					;resol



MainLoop:
	ldi		r16, (HD44780_LINE1 + 1)	;
	rcall	LCD_SetAddressDD			; Set Display Data address to (1,1);
	rcall	OWReset						; One wire reset
	brts	MainLoop					; If device not present go to MainLoop

	rcall	TempRequest
	rcall	MainReadTemp
	rcall	ConvertTempForLCD
	nop
	nop
	nop
	;jmp		PC-1;LoadLoop
	

LoadLoop:
	push	r16
	mov		r16, XL						; chargement partie entière
	rcall bin2bcd8
	rcall	LCD_WriteHex8				; display it on LCD in HEX
	mov		r16, r18						; load DEC
	rcall	bin2bcd8
	rcall	LCD_WriteHex8				; display it on LCD in HEX
	jmp MainLoop
	brne	LoadLoop					; if not zero, jump to LoadLoop
	rjmp	MainLoop					; jump to MainLoop
;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------




;======= Converting from HEX to BCD ====================================================https://evileg.com/en/post/19/
;*****************************************************
;* "bin2BCD8" - 8-bit Binary to BCD conversion
;* This subroutine converts an 8-bit number (temp) to a 2-digit 
;* i.e 0x15 becomes 0x21
;* result in temp
;**********************************************************
;.def	tBCD	= r21			;add this to main asm file
;
bin2bcd8:
	push r21
	clr	r21			;clear temp reg
bBCD8_1:
	subi	r16,10		;input = input - 10
	brcs	bBCD8_2		;abort if carry set
	subi	r21,-$10 		;tBCD = tBCD + 10
	rjmp	bBCD8_1		;loop again
bBCD8_2:
	subi	r16,-10		;compensate extra subtraction
	add	r16,r21
	pop r21	
	ret