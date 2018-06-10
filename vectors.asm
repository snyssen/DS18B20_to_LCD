.cseg
.org    0				; Reset
	rjmp    ProgramEntryPoint
.org	INT0addr
	reti
.org	INT1addr
	reti
.org	PCI0addr
	reti
.org	PCI1addr
	reti
.org	PCI2addr
	reti
.org	WDTaddr
	reti
.org	OC2Aaddr
	reti
.org	OC2Baddr
	reti
.org	OVF2addr
	reti
.org	ICP1addr
	reti
.org	OC1Aaddr
	reti
.org	OC1Baddr
	reti
.org	OVF1addr
	reti
.org	OC0Aaddr
	reti
.org	OC0Baddr
	reti
.org	OVF0addr
	reti
.org	SPIaddr
	reti
.org	URXCaddr
	reti
.org	UDREaddr
	reti
.org	UTXCaddr
	reti
.org	ADCCaddr
	reti
.org	ERDYaddr
	reti
.org	ACIaddr
	reti
.org	TWIaddr
	reti
.org	SPMRaddr
	reti



;	.org	INT0addr		; External Interrupt Request 0
;		reti
;	.org	INT1addr		; External Interrupt Request 1
;		reti
;	.org	ICP1addr		; Timer/Counter1 Capture Event
;		reti
;	.org	OC1Aaddr		; Timer/Counter1 Compare Match A
;		reti
;	.org	OVF1addr		; Timer/Counter1 Overflow
;		reti
;	.org	OVF0addr		; Timer/Counter0 Overflow
;		reti
;	.org	URXCaddr		; USART, Rx Complete
;		reti
;	.org	UDREaddr		; USART Data Register Empty
;		reti
;	.org	UTXCaddr		; USART, Tx Complete
;		reti
;	.org	ACIaddr			; Analog Comparator
;		reti
;	.org	PCIaddr			;
;		reti
;	.org	OC1Baddr		;
;		reti
;	.org	OC0Aaddr		;
;		reti
;	.org	OC0Baddr		;
;		reti
;	.org	USI_STARTaddr	; USI Start Condition
;		reti
;	.org	USI_OVFaddr		; USI Overflow
;		reti
;	.org	ERDYaddr		;
;		reti
;	.org	WDTaddr			; Watchdog Timer Overflow
;		reti
