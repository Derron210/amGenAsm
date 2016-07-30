.include "m8def.inc"

;������� �������� ����������
;***********************************
.org 0x000	rjmp START
.org 0x003	rjmp TIMER_2_COMP
.org 06		rjmp TIMER_1_COMP_A
.org 0x007	rjmp TIMER_1_COMP_B
.org 0x008	rjmp TIMER_1_OVF
.org 0x00b	rjmp USART_RX
;***********************************

.cseg

;������ �������� ���������
;***********************************
SINAR:
.db 0, 12, 25, 37, 49, 60, 71, 81, 90, 98 
.db  106, 112, 117, 122, 125, 126, 126 , 126
.db  125, 122, 117, 112, 106, 98, 90, 81 
.db  71, 60, 49, 37, 25, 12, 0, -12
.db -25, -37, -49, -60, -71, -81, -90, -98
.db -106, -112, -117, -122, -125, -126  
.db -127,-126, -125, -122, -117, -112, -106, -98
.db -90, -81, -71, -60, -49, -37, -25, -12
;***********************************

;���������
;***********************************
.equ	BUFHEADER		=	150			;��������� ������ UART
.equ   MODE_INTGEN		=	7			;����� ���� �������� MOEDER, 0-������� ������, 1- ���������
.equ   ARRAY_SIZE		=	64			;������ ������� �������� ���������
;***********************************

;���������� ���������
;***********************************
.def	NULL  =	R2						;��������� ������ 0, ����� ��� ����, ����� �� ������������ ��� ��� �����. ��������
.def	T1NVR = R3						;2 ��������, ���������� ������� �������� 1 � 2, ������� ������������ �� ����� ���������� ���������� 
.def	T2NVR = R4
.def	MSIGR = R5						;����. ����������� ���. �������
.def	CARAR = R6						;������� �������� ��������� ������� - [0; 127] 0 - ����. ��������
.def	SIGAR = R7
.def	STATR = R15						;����� ��������� ��������������� �������
.def	GENI1 = R16						;��� �������� ������ ���������� ��� ����������
.def	GENI2 = R17
.def	GENI3 = R18
.def	BUFPR = R19						;��������� ������ uart
.def	GENR1 =	R20						;��� �������� ������ ���������� ��� ���������
.def	GENR2 =	R21
.def	GENR3 = R22
;***********************************

START:
	clr		NULL
	
	;��������� �����
	ldi		GENR1,		low(RAMEND)			; �������� � ������� GENR1 ������ ������� ������� ���
	out		SPL,		GENR1				;����������� �������� �� GENR1 � ������� ��������� ����� SPL
	ldi		GENR1,		high(RAMEND)
	out		SPH,		GENR1

	rcall	LOAD_ARRAY		;������ �������� ��������� � ���

	;��������� USART
	ldi		GENR1,		103
	ldi		GENR2,		0
	out		UBRRH,		GENR2
	out		UBRRL,		GENR1
	ldi		GENR1,		(1<<RXEN)|(1<<TXEN) | (1<<RXCIE)
	out		UCSRB,		GENR1
	ldi		GENR1,		(1<<URSEL)|(1<<USBS)|(3<<UCSZ0);
	out		UCSRC,		GENR1

	;��������� PORTB
	ldi		GENR2,	0b00111111			
	out		DDRB,	GENR2

	rjmp	dmode1

.include "dmodes.asm"

.include "uInterrupts.asm"

;��������� ��� �������, � ���
;***********************************
STOP_ALL:
	ldi GENR1,0
	out TCCR0,GENR1
	out TCCR1A,GENR1
	out TCCR1B,GENR1
	out TCCR2, GENR1
	out ADMUX,GENR1
	out ADCSRA,GENR1
	out TIMSK,GENR1
ret
;***********************************

;�������� ������� ��������� � ���
;***********************************
LOAD_ARRAY:
	ldi		GENR1,	0
	ldi		YL,		LOW(asin)
	ldi		YH,		HIGH(asin)
	ldi		ZL,		LOW(SINAR*2)	;��������� ����� ������� �������� ���������
	ldi		ZH,		HIGH(SINAR*2)
	ldi		GENR1,	ARRAY_SIZE
laloop:
	lpm		GENR2,	Z+
	st		Y+,		GENR2
	dec		GENR1
	cpse	GENR1,	NULL
	rjmp	laloop
laex:
	ldi		YH,		1
	ldi		Yl,		0
	ldi		XH,		1
	ldi		Xl,		0
ret
;***********************************

;������ ����
;***********************************
clearStack:		;������ ����, ����� �������� ���� � R0, � ����� ������ ��� � ����(��� ���� ����� �������� ret)
	cli
	pop		R0
	pop		R1
	ldi		R16,	low(RAMEND)		;�������� � ������� r16 ������ ������� ������� ���
	out		SPL,	R16				;����������� �������� �� r16 � ������� ��������� ����� SPL
	ldi		R16,	high(RAMEND)
	out		SPH,	R16
	push	R1
	push	R0
ret
;***********************************

;�������� �������� � ���, �������� ADMUX ������ ���� � GENR1, ��������� ����� � ADCH
;***********************************
getADCSample:
	out		ADMUX,		GENR1															;������� ���������� �������������� �� ���
	ldi		GENR1,		(1<<ADEN) | (1<<ADSC)  |(1<<ADPS2)
	out		ADCSRA,		GENR1															;������� ���������� ���;
gas1:
	sbic	ADCSRA,		ADSC
	rjmp	gas1
ret
;***********************************

;������ ����� ���������� TIMER_1_COMP_A, ����� ����� ������� �� �������� Z
;***********************************
setTimer1COMPAVect:
	sts		TIMER_1_COMP_A_vect,	ZL
	sts		TIMER_1_COMP_A_vect+1,	ZH
ret
;***********************************

.dseg
uartBuf:				.byte 4				;�����: ���������, ����� �������, ��������, ����������� �����
TIMER_1_COMP_A_vect:	.byte 2				;��������� �� ������ ����������
MODE_START_VECT:		.byte 2				;��������� �� ������ ������
PM_POINTER:				.byte 1	


.org  0x100		;����� ������, ZH ����������� � 1  !!!!!!!!!!!!!!!
aSIN: .byte ARRAY_SIZE