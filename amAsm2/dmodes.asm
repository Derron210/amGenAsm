;//*************************************************************************
;//Генерация АМ
;//В GENR1 - 0 если источник внешний, 1 если внутренний
;//*************************************************************************
dmode1:
	rcall clearstack

	;Настраиваем регистр START
	clr		STATR
	andi	GENR1,		1
	or		STATR,		GENR1		;Режим инф. сигнала внешний/внутренний
	ldi		GENR1,		1
	lsl		GENR1
	or		STATR,		GENR1		;Номер режима

	ldi		ZL,	LOW(AM_GEN)
	ldi		ZH,	HIGH(AM_GEN)
	rcall   setTimer1COMPAVect

	;Настройка таймеров
	ldi		GENR2,	0b0000000
	out		TCCR0,	GENR2

	out		OCR1AL,	T1NVR

	ldi		GENR2,	(0<<COM1A1) | (0<<COM1A0) | (0<<COM1B1) | (0<<COM1B0) | (0<<FOC1A) | (0<<FOC1B) | (0<<WGM11) | (0<<WGM10)
	out		TCCR1A,	GENR2

	ldi		GENR2,	(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (1<<WGM12) | (0<<CS12) | (0<<CS11) | (1<<CS10) 
	out		TCCR1B,	GENR2

	ldi		GENR2, (1<<OCIE1A)
	out		TIMSK,	GENR2
	sei;

	sbrs	STATR,		0		;Если первый бит START - 1, то  запускаем таймер для генерации внутр. сигнала
	rjmp	dloop1
		
	ldi		GENR1,		(1<<WGM21) | (1<<CS21) | (1<<CS20)
	out		TCCR2,		GENR1

	out		OCR2,		T2NVR
	in		GENR1,		TIMSK
	ori		GENR1,		(1<<OCIE2)
	out		TIMSK,		GENR1

dloop1:

	sbrc	STATR,		0
	rjmp	dloop1
	
	;Если сигнал внешний, то считываем его значение с АЦП
	ldi		GENR1,		(1<<REFS0) | (1<<ADLAR) | (1<<MUX2) | (1<<MUX0)
	rcall	getADCSample
	in		MSIGR,		ADCH	

rjmp dloop1


;//*************************************************************************
;//Генерация ЧМ
;//В GENR1 - 0 если источник внешний, 1 если внутренний
;//*************************************************************************
dmode2:
	rcall clearstack

	;Настраиваем регистр START
	clr		STATR
	andi	GENR1,		1
	or		STATR,		GENR1		;Режим инф. сигнала внешний/внутренний
	ldi		GENR1,		2
	lsl		GENR1
	or		STATR,		GENR1		;Номер режима

	ldi		ZL,	LOW(FM_GEN)
	ldi		ZH,	HIGH(FM_GEN)
	rcall   setTimer1COMPAVect

	;Настройка таймеров
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

	sbrs	STATR,		0		;Если первый бит START - 1, то  запускаем таймер для генерации внутр. сигнала
	rjmp	dloop2
	
	ldi		GENR1,		100
	mov		SIGAR,		GENR1
	
	ldi		GENR1,		(1<<WGM21) | (1<<CS21) | (1<<CS20)
	out		TCCR2,		GENR1

	ldi		GENR1,		100
	out		OCR2,		GENR1
	in		GENR1,		TIMSK
	ori		GENR1,		(1<<OCIE2)
	out		TIMSK,		GENR1

dloop2:

	sbrc	STATR,		0
	rjmp	dloop2
	
	;Если сигнал внешний, то считываем его значение с АЦП
	ldi		GENR1,		(1<<REFS0) | (1<<ADLAR) | (1<<MUX2) | (1<<MUX0)
	rcall	getADCSample
	in		MSIGR,		ADCH	

rjmp dloop1

;//*************************************************************************
;//Генерация ФМ (фазовая модуляция)
;//В GENR1 - 0 если источник внешний, 1 если внутренний
;//*************************************************************************
dmode3:
	rcall clearstack

	;Настраиваем регистр STATR
	clr		STATR
	andi	GENR1,		1
	or		STATR,		GENR1		;Режим инф. сигнала внешний/внутренний
	ldi		GENR1,		3
	lsl		GENR1
	or		STATR,		GENR1		;Номер режима

	ldi		ZL,	LOW(PM_GEN)
	ldi		ZH,	HIGH(PM_GEN)
	rcall   setTimer1COMPAVect

	;Настройка таймеров
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

	sbrs	STATR,		0		;Если первый бит START - 1, то  запускаем таймер для генерации внутр. сигнала
	rjmp	dloop3
	
	ldi		GENR1,		100
	mov		SIGAR,		GENR1
	
	ldi		GENR1,		(1<<WGM21) | (1<<CS21) | (1<<CS20)
	out		TCCR2,		GENR1

	ldi		GENR1,		100
	out		OCR2,		GENR1
	in		GENR1,		TIMSK
	ori		GENR1,		(1<<OCIE2)
	out		TIMSK,		GENR1

dloop3:

	sbrc	STATR,		0
	rjmp	dloop3
	
	;Если сигнал внешний, то считываем его значение с АЦП
	ldi		GENR1,		(1<<REFS0) | (1<<ADLAR) | (1<<MUX2) | (1<<MUX0)
	rcall	getADCSample
	in		MSIGR,		ADCH	

rjmp dloop3


;//*************************************************************************
;//Синусоида умноженная на знач. SIGAR
;//Только для управления с ПК
;//*************************************************************************
dmode4:
	rcall clearstack

	;Настраиваем регистр START
	clr		STATR
	ldi		GENR1,		4
	lsl		GENR1
	or		STATR,		GENR1		;Номер режима

	ldi		ZL,	LOW(AM_GEN)
	ldi		ZH,	HIGH(AM_GEN)
	rcall   setTimer1COMPAVect

	;Настройка таймеров
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
dloop4:
	mov		GENR1,	SIGAR
	mov		MSIGR,	GENR1
rjmp dloop4


;//*************************************************************************
;//СМХ
;//Пока только два вар.	Вырисовывается кривая
;//*************************************************************************
AR1AR: .db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 5, 9, 14, 20, 27, 35, 44
	   .db 54, 64, 76, 87, 99, 111, 124, 136, 149, 161, 173, 184, 195, 205, 215, 223, 231, 238, 243, 248, 251, 253, 254, 254, 254, 254

AR2AR: .db 0, 0, 0, 0, 0, 0, 2, 5, 9, 14, 20, 27, 35, 44, 54, 64, 76, 87, 99, 111, 124, 136, 149, 161, 173, 184, 195, 205, 215, 223
	   .db  231, 238, 243, 248, 251, 253, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254

dmode5:
	rcall clearstack

	clr		STATR
	andi	GENR1,		1
	or		STATR,		GENR1			;Отрисовывать смх или регулировать через CARAR
	cli
	
	;Грузим значения варианта смх в оперативную память
	push    ZL
	push	ZH
	push    YL
	push	YH
	ldi		GENR1,	0
	lds		GENR2,	VARIANT

	cpi		GENR2,	0				;Варианты
	brne    j2	
	ldi		ZL,		LOW(AR1AR*2)	;Считываем адрес массива значений синусоиды
	ldi		ZH,		HIGH(AR1AR*2)
	rjmp j3
j2:	cpi		GENR2,	1
;	brne	j3
	ldi		ZL,		LOW(AR2AR*2)	
	ldi		ZH,		HIGH(AR2AR*2)
j3:
	ldi		YL,		LOW(aSMH)
	ldi		YH,		HIGH(aSMH)
	ldi		GENR1,	ARRAY_SIZE
_laloop:
	lpm		GENR2,	Z+
	st		Y+,		GENR2
	dec		GENR1
	cpse	GENR1,	NULL
	rjmp	_laloop
	
	pop		YH
	pop		YL
	ldi		ZL,		LOW(aSmh)	
	ldi		ZH,		HIGH(aSmh)
	sts		smhZL,	ZL				;Сохраняем Z в оперативную память, а потом вытаскиваем пред. знач. из стэка
	sts		smhZH,	ZH
	
dloop5:
	sbrc	STATR,		0
	rjmp	smh_internal

	;Внеш. регулировка СМХ (из регистра CARAR)
	lds		ZH,		smhZH
	mov		ZL,  CARAR
	lsr		ZL
	lsr		ZL
	ld		GENR1,	Z
	rjmp	print_smh
smh_internal:
	lds		ZL,		smhZL
	lds		ZH,		smhZH
	ld		GENR1,	Z+				;Считываем адрес
	andi	ZL,		ARRAY_SIZE-1
	sts		smhZL,	ZL				;Сохраняем Z в оперативную память, а потом вытаскиваем пред. знач. из стэка
	sts		smhZH,	ZH

print_smh:
	pop		ZH
	pop		ZL
	sei								;Включаем прерывания, в это время может смениться режим или еще-что нибудь
	lsr		GENR1
	lsr		GENR1
	out		PORTB,	GENR1
	cli								;Выключаем прерывания, сохраняем Z в стэк, и записываем в Z сохраненное знач Z из опертив. памяти					
	push		ZL
	push		ZH
rjmp dloop5
