TIMER_1_COMP_A:
	lds		ZL,		TIMER_1_COMP_A_vect
	lds		ZH,		TIMER_1_COMP_A_vect+1
ijmp

;*************************************************************************
;	Таймер 1 считывет значение из таблицы синусов
;*************************************************************************
AM_GEN:				;Обработка прерывания таймера
	out		OCR1AL,	T1NVR
	andi	YL,		ARRAY_SIZE-1				
	ld		GENI1,	Y+				

	mov		GENI2,	MSIGR												;Внешний сигнал считывается в цикле с АЦП или в другом прерывании если сигнал внутрений

	mulsu   GENI1,	GENI2												;Перемножим значение инф. сигнала (беззнаковый) на значение несущей (знаковый)

	mov		GENI2,	R1
	mov		GENI1,	CARAR
	fmulsu	GENI2,	GENI1
	mov		GENI1,	R1													;Приведем к виду [0..255]
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
	;mov		GENI1,	R1													;Приведем к виду [0..255]
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
	lsr		GENI1														;Два раза поделим на 2, т.к. PB7 и PB6 не используются
	out		PORTB,	GENI1
	out		TCNT1L,	NULL
reti


;*************************************************************************
;Исп. для дискретизатора
;*************************************************************************
TIMER_1_COMP_B:
	out		OCR1AL,	T1NVR
	mov		GENI1,	MSIGR
	lsr		GENI1
	lsr		GENI1
	out		PORTB,	GENI1
reti

;*************************************************************************
;Исп. для дискретизатора
;*************************************************************************
TIMER_1_OVF:
	out		PORTB,	NULL
reti

;*************************************************************************
;	Таймер 2 Используется для генерации внутреннего инф. сигнала
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
; ;	На RX что-то приходит
; ;*************************************************************************
; ;//2 байт: [Команда; данные]
; ;//			0 :n	- ничего не делать
; ;//			11:x    - вернуть аналоговый режим
; ;//			22:x	- цифровое управление, режим x;
; ;//			30:x	- записать амплитуду несущей (CARAR) 
; ;//			31:n    - записать частоту несущей (T1NVR (OCR1A))
; ;//			32:n	- записать частоту инф.сигнала (T2NVR (OCR2))

USART_RX:
USART_RECV1:							;//Считываем 1ый байт
	sbis	UCSRA,		RXC
	rjmp	USART_recv1
	in		GENI1,		UDR

	cpi		BUFPR,		0				;Если первый байт в пакете
	BRNE	SKTP
	cpi		GENI1,		BUFHEADER		;То он должен быть равен заголовку
	BREQ	buffst
	rjmp	NOT_HEADER
buffst:									;Запись в буфер заголовка
	sts		uartBuf,	GENI1
	inc		BUFPR
	ldi		GENI1,		1				;Код состояния для выхода
	rjmp	UR1_EXIT

SKTP:
	push	Xl
	push	Xh
	ldi		Xl,		low(uartBuf)
	ldi		XH,		high(uartBuf)
	add		XL,		BUFPR				;Записываем на нужную позицию в буфере
	st		X,		GENI1
	pop		Xh
	pop		XL
	inc     BUFPR

	cpi		BUFPR,	4					;Когда буфер заполнен, обрабатываем
	brne	UR1_EXIT			

	ldi		BUFPR,	0

	lds		GENI1,	uartBuf+1			;т.е ксорим первые три байта, результат должен равняться четвертому
	lds		GENI2,	uartBuf+2
	ldi		GENI3,	BUFHEADER

	push	GENI1
	eor		GENI1,	GENI3
	eor		GENI1,	GENI2

	lds		GENI3,	uartBuf+3

	cp		GENI1,	GENI3		;Проверяем контрольную сумму
	pop		GENI1
	BRNE	INCORRECT_CHECKSUM			;Если не совпала, выходим

	cpi		GENI1,	11
	BREQ	setAmode

	cpi		GENI1,	22
	BREQ	setdMOde

	cpi		GENI1,	30
	BREQ	writeCARAR

	cpi		GENI1,	31
	BREQ	writeT1NVR

	cpi		GENI1,	32
	BREQ	writeT2NVR

	rjmp INT_PREP_EX

writeCARAR:
	mov		CARAR,	GENI2
	rjmp	INT_PREP_EX

setdMode:
	;//Очищаем стек
	rcall STOP_ALL
	
	ldi GENI1,	0
	out GICR,	GENI1
	
	ldi		GENR1,	0b10000000		;В GENR1 содержится инф. о источнике инф. сигнала
	and		GENR1,	GENI2			;Передаем ее с ПК в старшем бите команды
	andi	GENI2,	0b01111111	

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

writeT1NVR:
	mov		T1NVR,	GENI2
	rjmp	INT_PREP_EX

writeT2NVR:
	mov		T2NVR,	GENI2
	rjmp	INT_PREP_EX

INCORRECT_CHECKSUM:					;Ошибка - контрольная сумма не совпала
	ldi		GENI1,		3
	rjmp	UR1_EXIT
NOT_HEADER:							;Ошибка - переданный байт не заголовок
	ldi		GENI1,		0
	rjmp	UR1_EXIT
INT_PREP_EX:
UR1_EXIT:
	sbis	UCSRA,		UDRE
	rjmp	NOT_HEADER
	out		udr,		GENI1
reti


