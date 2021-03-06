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

BAM_GEN:				;Обработка прерывания таймера
	out		OCR1AL,	T1NVR
	andi	YL,		ARRAY_SIZE-1				
	ld		GENI1,	Y+				

	mov		GENI2,	MSIGR												;Внешний сигнал считывается в цикле с АЦП или в другом прерывании если сигнал внутрений

	muls    GENI1,	GENI2												;Перемножим значение инф. сигнала (беззнаковый) на значение несущей (знаковый)

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
rjmp int_tm1_exit

;Генерация синусоидального сигнала
;*************************************************************************
GEN_SIN_SIGNAL:
	out		OCR1AL,		T1NVR			;Задаем частоту сигнала
	ld		GENI1,		Y+				;Считываем значение из таблицы синусов
	andi	YL,			ARRAY_SIZE-1					
rjmp int_tm1_exit

;Генерация прямоугольного сигнала
;*************************************************************************
GEN_SQUARE_SIGNAL:
	out		OCR1AL,		T1NVR			;Задаем частоту сигнала
	inc		COUNR						;Регулировка скважности, когда COUNR >= SQLER сигнал на выходе 1, в противном случае 0
	ldi		GENI1,		127				
	cp		COUNR,		SQLER
	brlo	dnc	
	clr		GENI1
dnc:
rjmp int_tm1_exit


int_tm1_exit:
	ldi		GENI2,	128
	add		GENI1,	GENI2

	SIGNAL_OFFSET	GENI1,	OFFSR
	lsr		GENI1
	lsr		GENI1														;Два раза поделим на 2, т.к. PB7 и PB6 не используются
	out		PORTB,	GENI1
	out		TCNT1L,	NULL
	sbic	UCSRA,	RXC
	rjmp	USART_RX
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
	andi	XL,		    ARRAY_SIZE-1
	ld		GENI1,		X+
	mov		GENI2,		SIGAR
	LIMIT_OVERFLOW		GENI1,	GENI2,	GENI3
	ldi		GENI3,		3
	cp		PARAR,		GENI3
	BREQ	skip_add_t2c
	ldi		GENI3,		128
	add		GENI1,		GENI3
skip_add_t2c:
	mov		MSIGR,		GENI1
reti


_debug_uart:
	ldi		GENI2,		200
	add		GENI2,		BUFPR
	sbis	UCSRA,		UDRE
	rjmp	_debug_uart
	out		udr,		GENI2
ret


.macro UART_SEND
UEXIT:
	sbis	UCSRA,		UDRE
	rjmp	UEXIT
	out		udr,		@0
.endm

; ;*************************************************************************
; ;	На RX что-то приходит
; ;*************************************************************************
; ;//4 байта: [Заголовок; Команда; данные; контрольная сумма]
; ;//			0 :n	- ничего не делать
; ;//			22:x	- цифровое управление, режим x;
; ;//			23:x	- Генерация сигнала (dmode6), x - тип сигнала
; ;//			30:x	- записать амплитуду несущей (CARAR) 
; ;//			31:n    - записать частоту несущей (T1NVR (OCR1A))
; ;//			32:n	- записать частоту инф.сигнала (T2NVR (OCR2))
; ;//			33:n	- записать амплитуду внутреннего инф. сигнала (SIGAR)
; ;//			34:n	- записать смещние несущей сигнала (OFFSR) (Пока только для АМ)

USART_RX:
USART_RECV1:							;//Считываем 1ый байт
	sbis	UCSRA,		RXC
	rjmp	USART_recv1
	in	GENI1,		UDR

	cpi	BUFPR,		0				;Если первый байт в пакете
	BRNE	SKTP
	cpi		GENI1,		BUFHEADER		;То он должен быть равен заголовку
	BREQ	buffst
	rjmp	NOT_HEADER
buffst:									;Запись в буфер заголовка
	sts	uartBuf,	GENI1
	inc	BUFPR
	ldi	GENI1,		1				;Код состояния для выхода
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

	ldi		GENI3,	4
	cpse	BUFPR,	GENI3				;Когда буфер заполнен, обрабатываем
	rjmp	UR1_EXIT		

	ldi		BUFPR,	0

	lds		GENI1,	uartBuf+1			;т.е ксорим первые три байта, результат должен равняться четвертому
	lds		GENI2,	uartBuf+2
	ldi		GENI3,	BUFHEADER

	push	GENI1
	eor		GENI1,	GENI3
	eor		GENI1,	GENI2

	lds		GENI3,	uartBuf+3

	cp		GENI1,	GENI3				;Проверяем контрольную сумму
	pop		GENI1
	BREQ	go_next_to_switch			;В противном случае будет Relative jump out of range
	rjmp	INCORRECT_CHECKSUM			;Если не совпала, выходим

go_next_to_switch:
	cpi		GENI1,	22
	BREQ	setdMOde

	cpi		GENI1, 23
	breq	setSigGenMode

	cpi		GENI1,	30
	BREQ	writeCARAR

	cpi		GENI1,	31
	BREQ	writeT1NVR

	cpi		GENI1,	32
	BREQ	writeT2NVR

	cpi		GENI1,	33
	breq	writeSIGAR

	cpi		GENI1,	34
	breq	writeOFFSR

	ldi		GENI1,	2					;Неизвестная команда
	rjmp INT_PREP_EX

setdMode:
	rcall STOP_ALL					;Останавливаем все таймеры
	
	ldi GENI1,	0
	out GICR,	GENI1
	
	ldi		GENR1,	0b10000000		;В GENR1 содержится инф. о источнике инф. сигнала
	and		GENR1,	GENI2			;Передаем ее с ПК в старшем бите команды
	andi	GENI2,	0b01111111	
	sbrc	GENR1,	7
	ldi		GENR1,	1
	
	UART_SEND		GENI1
	
	cpi		GENI2,	1
	BRNE	dmd1
	rjmp	dmode1
dmd1:
	cpi		GENI2,	2
	brne	dmd2
	rjmp	dmode2
dmd2:
	cpi		GENI2,	3
	brne	dmd3
	rjmp	dmode3
dmd3:
	cpi		GENI2,	4
	brne	dmd4
	rjmp	dmode4
dmd4:
	cpi		GENI2,	5
	brne	dmd5
	rjmp	dmode5
dmd5:
	cpi		GENI2,	7
	brne	dmd6
	rjmp	dmode7
dmd6:
rjmp dmode1

writeCARAR:
	mov	GENI1,	GENI2
	mov		CARAR,	GENI2
	rjmp	INT_PREP_EX

writeT1NVR:
	mov	GENI1,	GENI2
	mov	T1NVR,	GENI2
	rjmp	INT_PREP_EX

writeT2NVR:
	mov	T2NVR,	GENI2
	mov	GENI1,	GENI2
	rjmp	INT_PREP_EX

writeSIGAR:
	mov	GENI1,	GENI2
	mov	SIGAR,	GENI2
	rjmp	UR1_EXIT

writeOFFSR:
	mov	GENI1,	GENI2
	mov	OFFSR,  GENI2
	rjmp	UR1_EXIT

setSigGenMode:
	rcall STOP_ALL	
	andi	GENI2,	0b01111111
	mov		GENR1,	GENI2
	UART_SEND		GENI1
	rjmp	dmode6

INCORRECT_CHECKSUM:					;Ошибка - контрольная сумма не совпала
	ldi	GENI1,		3
	rjmp	UR1_EXIT
NOT_HEADER:							;Ошибка - переданный байт не заголовок
	ldi	GENI1,		0
	rjmp	UR1_EXIT
INT_PREP_EX:
UR1_EXIT:
	UART_SEND	GENI1
reti


