.cseg
.org    0				; Reset
	rjmp    ProgramEntryPoint
.org	INT0addr		; External Interrupt Request 0
	reti
.org	INT1addr		; External Interrupt Request 1
	reti
.org	ICP1addr		; Timer/Counter1 Capture Event
	reti
.org	OC1Aaddr		; Timer/Counter1 Compare Match A
	reti
.org	OVF1addr		; Timer/Counter1 Overflow
	reti
.org	OVF0addr		; Timer/Counter0 Overflow
	reti
.org	URXCaddr		; USART, Rx Complete
	reti
.org	UDREaddr		; USART Data Register Empty
	reti
.org	UTXCaddr		; USART, Tx Complete
	reti
.org	ACIaddr			; Analog Comparator
	reti
.org	PCIaddr			; 
	reti
.org	OC1Baddr		; 
	reti
.org	OC0Aaddr		; 
	reti
.org	OC0Baddr		; 
	reti
.org	USI_STARTaddr	; USI Start Condition
	reti
.org	USI_OVFaddr		; USI Overflow
	reti
.org	ERDYaddr		; 
	reti	
.org	WDTaddr			; Watchdog Timer Overflow
	reti
