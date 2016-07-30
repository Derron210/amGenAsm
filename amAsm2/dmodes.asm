
;//*************************************************************************
;//��������� ��. ������ ��� ������������ ��������, ���������� � �� � R18
;//� GENR1 - 0 ���� �������� �������, �� 0 ���� ����������
;//*************************************************************************
dmode1:
	rcall clearstack

	;����������� ������� START
	clr		STATR
	andi	GENR1,		1
	or		STATR,		GENR1		;����� ���. ������� �������/����������
	ldi		GENR1,		1
	lsl		GENR1
	or		STATR,		GENR1		;����� ������

	ldi		ZL,	LOW(AM_GEN)
	ldi		ZH,	HIGH(AM_GEN)
	rcall   setTimer1COMPAVect

	;��������� ��������
	ldi		GENR2,	0b0000000
	out		TCCR0,	GENR2

	ldi		GENR2,	200
	out		OCR1AL,	GENR2

	ldi		GENR2,	(0<<COM1A1) | (0<<COM1A0) | (0<<COM1B1) | (0<<COM1B0) | (0<<FOC1A) | (0<<FOC1B) | (0<<WGM11) | (0<<WGM10)
	out		TCCR1A,	GENR2

	ldi		GENR2,	(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (1<<WGM12) | (0<<CS12) | (0<<CS11) | (1<<CS10) 
	out		TCCR1B,	GENR2

	ldi		GENR2, (1<<OCIE1A)
	out		TIMSK,	GENR2
	sei;

	sbrs	STATR,		0		;���� ������ ��� START - 1, ��  ��������� ������ ��� ��������� �����. �������
	rjmp	dloop1

	ldi		GENR1,		(1<<WGM21) | (1<<CS21) | (1<<CS20)
	out		TCCR2,		GENR1

	ldi		GENR1,		50
	out		OCR2,		GENR1
	in		GENR1,		TIMSK
	ori		GENR1,		(1<<OCIE2)
	out		TIMSK,		GENR1

dloop1:

	sbrc	STATR,		0
	rjmp	dloop1
	
	;���� ������ �������, �� ��������� ��� �������� � ���
	ldi		GENR1,		(1<<REFS0) | (1<<ADLAR) | (1<<MUX2) | (1<<MUX0)
	rcall	getADCSample
	in		MSIGR,		ADCH	

rjmp dloop1


dmode2:
	rcall	clearstack

	ldi		GENR1,	0b00111111			;��������� PORTB
	out		DDRB,	GENR1

	ldi		GENR2,	1<<WGM10
	out		TCCR1A,	GENR2

	ldi		GENR2,	(1<<WGM12) | (0<<CS12) | (0<<CS11) | (1<<CS10) 
	out		TCCR1B,	GENR2

	ldi		GENR2, (1<<OCIE1B) | (1<<TOIE1)
	out		TIMSK,	GENR2

	sei
dloop2:
	ldi		GENR1,		(1<<REFS0) | (1<<ADLAR) | (1<<MUX2) | (1<<MUX0)	
	rcall	getADCSample
	in		MSIGR,		ADCH

rjmp dloop2





