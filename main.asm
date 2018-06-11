;------------------------------------------------------------------------------
; iButton serial number reader
; http://avr-mcu.dxp.pl
; e-mail: radek(at)dxp.pl
; (c) Radoslaw Kwiecien
;
; Programme principal
;
; Permet la lecture et la conversion des données envoyées par le capteur de température DS18B20
; Afin de les inscrire sur un afficheur LCD
;
;Datasheet du DS18B20 -> https://cdn.sparkfun.com/datasheets/Sensors/Temp/DS18B20.pdf
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Defines
;------------------------------------------------------------------------------
#define F_CPU 8000000 ; Fréquence microcontrôleur set à 8 MHz

;Table 3. DS18B20 Function Command Set p12
; Set des fonctions du DS18B20
#define ReadRom 0x33					; Lecture de la ROM
#define SkipRom 0xcc					; Skip ROM permet de savoir le mode d'alimentation du DS18B20 (alimentation externe ou via le 1-wire bus)
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
#include "vectors.asm" ; Vecteur d'interruptions
#include "hd44780.asm" ; Bibliothèque de l'afficheur LCD
#include "wait.asm"	   ; Boucle d'attente
#include "1-wire.asm"  ; Lecture et conversion des données reçues du capteur
#include "crc8.asm"    ; Cyclic Redundancy Check des mots de 8 bits reçus
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
Td :
	.db	"C",0,0
;------------------------------------------------------------------------------
; Program entry point
;------------------------------------------------------------------------------
ProgramEntryPoint:
	ldi		r16, LOW(RAMEND)			; Initialize stack pointer
	out		SPL, r16					; Ecrit r16 sur le bas du stack

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
	brts	MainLoop					; If device not present go to MainLoop (brts = BRanch if T flag is Set)

	rcall	TempRequest					; Demande la température (1-wire.asm)
	rcall	MainReadTemp				; Lit la température (1-wire.asm)
	rcall	ConvertTempForLCD			; Convertir la température pour l'afficher sur le LCD (1-wire.asm)
	nop									; Attend 3 cycles d'horloge
	nop
	nop
	;jmp		PC-1;LoadLoop
	

LoadLoop:
	push	r16
	mov		r16, XL						; chargement partie entière
; SET DE L'ALARME
	cpi		XL, 25						; On compare la température relevée à celle max avant alarme
	brsh	SetLED						; allume la LED si on a atteint ou dépassé la temp d'alarme
	cbi		PortB, 7					; LED sur port B7
;	cbi		PortD, 0					; LED sur port D0 (externe à la carte)
	endbr:
	rcall   bin2bcd8
	rcall	LCD_WriteHex8				; display it on LCD in HEX
;	ldi		ZL, LOW(Tp << 1)			; Load string address to Z		A TESTER (rajoute le point décimal
;	ldi		ZH, HIGH(Tp<< 1)			;
;	rcall	LCD_WriteString				; Display string
	mov		r16, r18					; load DEC
	rcall	bin2bcd8
	rcall	LCD_WriteHex8				; display it on LCD in HEX		A TESTER (rajoute le C de Celsius)
;	ldi		ZL, LOW(Td << 1)			; Load string address to Z
;	ldi		ZH, HIGH(Td<< 1)			;
;	rcall	LCD_WriteString				; Display string
	jmp		MainLoop
	brne	LoadLoop					; if not zero, jump to LoadLoop
	rjmp	MainLoop					; jump to MainLoop

SetLED:
	sbi		PortB, 7					; LED sur port B7
;	sbi		PortD, 0					; LED sur port D0 (externe à la carte)
	jmp		endbr

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