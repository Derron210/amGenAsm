TIMER_1_COMP_A:
	lds		ZL,		TIMER_1_COMP_A_vect
	lds		ZH,		TIMER_1_COMP_A_vect+1
ijmp

;*************************************************************************
;	������ 1 �������� �������� �� ������� �������
;*************************************************************************
AM_GEN:				;��������� ���������� �������
	out		OCR1AL,	T1NVR
	andi	YL,		ARRAY_SIZE-1				
	ld		GENI1,	Y+				

	mov		GENI2,	MSIGR												;������� ������ ����������� � ����� � ��� ��� � ������ ���������� ���� ������ ���������

	mulsu   GENI1,	GENI2												;���������� �������� ���. ������� (�����������) �� �������� ������� (��������)

	mov		GENI2,	R1
	mov		GENI1,	CARAR
	fmulsu	GENI2,	GENI1
	mov		GENI1,	R1													;�������� � ���� [0..255]
rjmp	int_tm1_exit


FM_GEN:
	mov		GENI2,	MSIGR
	ldi		GENI1,	0b00100000
	fmul	GENI2,	GENI1
	mov		GENI1,	T1NVR
	add		GENI1,	R1

	out		OCR1AL,	GENI1
	andi	YL,		ARRAY_SIZE-1				
	ld		GENI1,	Y+		
	;mov		GENI1,	CARAR
	;fmulsu	GENI2,	GENI1
	;mov		GENI1,	R1													;�������� � ���� [0..255]
rjmp int_tm1_exit

PM_GEN:
	out		OCR1AL,	T1NVR

	lds		YL,		PM_POINTER
	mov		GENI2,	YL
	add		YL,		MSIGR
	andi	YL,		0b00111111
			
	ld		GENI1,	Y		
	inc		GENI2
	andi	GENI2,	ARRAY_SIZE-1	
	sts		PM_POINTER,	GENI2
pm_skip:
int_tm1_exit:
	ldi		GENI2,	128
	add		GENI1,	GENI2
	lsr		GENI1
	lsr		GENI1														;��� ���� ������� �� 2, �.�. PB7 � PB6 �� ������������
	out		PORTB,	GENI1
	out		TCNT1L,	NULL
reti


;*************************************************************************
;���. ��� ��������������
;*************************************************************************
TIMER_1_COMP_B:
	out		OCR1AL,	T1NVR
	mov		GENI1,	MSIGR
	lsr		GENI1
	lsr		GENI1
	out		PORTB,	GENI1
reti

;*************************************************************************
;���. ��� ��������������
;*************************************************************************
TIMER_1_OVF:
	out		PORTB,	NULL
reti

;*************************************************************************
;	������ 2 ������������ ��� ��������� ����������� ���. �������
;*************************************************************************
TIMER_2_COMP:
	out		OCR2,		T2NVR
	andi	XL,			ARRAY_SIZE-1
	ld		GENI1,		X+
	subi	GENI1,		128
	mov		GENI2,		SIGAR
	fmul	GENI1,		GENI2
	mov		MSIGR,		R1
reti



_debug_uart:
	ldi		GENI2,		200
	add		GENI2,		BUFPR
	sbis	UCSRA,		UDRE
	rjmp	_debug_uart
	out		udr,		GENI2
ret


; ;*************************************************************************
; ;	�� RX ���-�� ��������
; ;*************************************************************************
; ;//2 ����: [�������; ������]
; ;//			0 :n	- ������ �� ������
; ;//			11:x    - ������� ���������� �����
; ;//			22:x	- �������� ����������, ����� x;
; ;//			44:n	- �������� ������ � R18
; ;//			55:n    - �������� � OCR1A
; ;//			66:n	- �������� � OCR1B
; USART_RX:
; USART_RECV1:			;//��������� 1�� ����
; 	sbis UCSRA, RXC
; 	rjmp USART_recv1
; 	in GENI1,UDR
; USART_RECV2:			;//��������� 2�� ����
; 	sbis UCSRA, RXC
; 	rjmp USART_recv2
; 	in GENI2,UDR
; USART_SEND1:
; 	sbis UCSRA,UDRE
; 	rjmp USART_SEND1
; 	out udr,GENI1
; USART_SEND2:
; 	sbis UCSRA,UDRE
; 	rjmp USART_SEND2
; 	out udr,GENI2
;
;


USART_RX:
USART_RECV1:			;//��������� 1�� ����
	sbis	UCSRA,		RXC
	rjmp	USART_recv1
	in		GENI1,		UDR

USART_SEND1:							;���������� �������
	sbis	UCSRA,		UDRE
	rjmp	USART_SEND1
	out		udr,		GENI1

	cpi		BUFPR,		0				;���� ������ ���� � ������
	BRNE	SKTP
	cpi		GENI1,		BUFHEADER		;�� �� ������ ���� ����� ���������
	BREQ	buffst
	rjmp	UR1_EXIT
buffst:

	sts		uartBuf,	GENI1
	inc		BUFPR
	reti

SKTP:
	push	Xl
	push	Xh
	ldi		Xl,		low(uartBuf)
	ldi		XH,		high(uartBuf)
	add		XL,		BUFPR				;���������� �� ������ ������� � ������
	st		X,		GENI1
	pop		Xh
	pop		XL
	inc     BUFPR

	cpi		BUFPR,	4					;����� ����� ��������, ������������
	brne	UR1_EXIT

	ldi		BUFPR,	0

	lds		GENI1,	uartBuf+1			;�.� ������ ������ ��� �����, ��������� ������ ��������� ����������
	lds		GENI2,	uartBuf+2
	ldi		GENI3,	BUFHEADER

	push	GENI1
	eor		GENI1,	GENI3
	eor		GENI1,	GENI2

	lds		GENI3,	uartBuf+3

	cp		GENI1,	GENI3		;��������� ����������� �����
	pop		GENI1
	BRNE	UR1_EXIT			;���� �� �������, �������

	cpi		GENI1,	11
	BREQ	setAmode

	cpi		GENI1,	22
	BREQ	setdMOde

	cpi		GENI1,	44
	BREQ	writeReg

	cpi		GENI1,	55
	BREQ	writeFreq

	cpi		GENI1,	66
	BREQ	writePLen

	rjmp INT_PREP_EX

setdMode:
	;//������� ����
	ldi GENI1,	0
	out GICR,	GENI1

	rcall STOP_ALL

	cpi GENI2,	1
	BRNE dmd1
	rjmp dmode1
dmd1:
	cpi GENI2,2
	BRNE dmd2
	rjmp dmode2
dmd2:
rjmp dmode2

setAmode:
	rcall STOP_ALL
	ldi GENI1,	(1<<INT0)
	out GICR,	GENI1	
	;rjmp amode1	

writeReg:
	mov		CARAR,	GENI2
	rjmp	INT_PREP_EX

WriteFreq:
	mov		T1NVR,	GENI2
	rjmp	INT_PREP_EX

WritePLen:
	out		OCR1BL,	GENI2
	rjmp	INT_PREP_EX

INT_PREP_EX:
UR1_EXIT:
reti


