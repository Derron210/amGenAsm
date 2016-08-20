.include "m8def.inc"

;Таблица векторов прерываний
;***********************************
.org 0x000	rjmp START
.org 0x003	rjmp TIMER_2_COMP
.org 06		rjmp TIMER_1_COMP_A
.org 0x007	rjmp TIMER_1_COMP_B
.org 0x008	rjmp TIMER_1_OVF
.org 0x00b	rjmp USART_RX
;***********************************

.cseg

;Массив значений синусоиды
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

;Константы
;***********************************
.equ	BUFHEADER		=	150			;Заголовок пакета UART
.equ   MODE_INTGEN		=	7			;НОМЕР бита регистра MOEDER, 0-внешний сигнал, 1- внутрений
.equ   ARRAY_SIZE		=	64			;Размер массива значений синусоиды
;***********************************

;Объявления регистров
;***********************************
.def	NULL  =	R2						;Константа равная 0, нужна для того, чтобы не использовать РОН для арифм. операций
.def	T1NVR = R3						;2 регистра, содержажие частоту таймеров 1 и 2, которая установиться во время следующего прерывания 
.def	T2NVR = R4
.def	MSIGR = R5						;Знач. внутреннего инф. сигнала
.def	CARAR = R6						;Регистр содержит амлпитуду несущей - [0; 127] 0 - макс. значение
.def	SIGAR = R7
.def	STATR = R15						;Выбор источника информационного сигнала
.def	GENI1 = R16						;Три регистра общего назначения для ПРЕРЫВАНИЙ
.def	GENI2 = R17
.def	GENI3 = R18
.def	BUFPR = R19						;Указатель буфера uart
.def	GENR1 =	R20						;Три регистра общего назначения для ПРОГРАММЫ
.def	GENR2 =	R21
.def	GENR3 = R22
;***********************************

START:
	clr		NULL
	
	;Настройка стека
	ldi		GENR1,		low(RAMEND)			; Загрузка в регистр GENR1 адреса верхней границы ОЗУ
	out		SPL,		GENR1				;Копирование значения из GENR1 в регистр указателя стека SPL
	ldi		GENR1,		high(RAMEND)
	out		SPH,		GENR1

	rcall	LOAD_ARRAY		;Грузим значения синусоиды в ОЗУ

	;Настройка USART
	ldi		GENR1,		103
	ldi		GENR2,		0
	out		UBRRH,		GENR2
	out		UBRRL,		GENR1
	ldi		GENR1,		(1<<RXEN)|(1<<TXEN) | (1<<RXCIE)
	out		UCSRB,		GENR1
	ldi		GENR1,		(1<<URSEL)|(1<<USBS)|(3<<UCSZ0);
	out		UCSRC,		GENR1

	;Настройка PORTB
	ldi		GENR2,	0b00111111			
	out		DDRB,	GENR2

	ldi		GENR1,	100
	mov		T1NVR,	GENR1
	mov		SIGAR,	GENR1
	mov		T2NVR,	GENR1

	ldi		GENR1,	255
	mov		CARAR,	GENR1

	clr		GENR1
	rjmp	dMode1

.include "dmodes.asm"

.include "uInterrupts.asm"

;Выключает все таймеры, и АЦП
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

;Загрузка массива синусоиды в ОЗУ
;***********************************
LOAD_ARRAY:
	ldi		GENR1,	0
	ldi		YL,		LOW(asin)
	ldi		YH,		HIGH(asin)
	ldi		ZL,		LOW(SINAR*2)	;Считываем адрес массива значений синусоиды
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

;Чистит стэк
;***********************************
clearStack:		;Чистит стек, адрес возврата сует в R0, а затем пихает его в стек(для того чтобы сработал ret)
	cli
	pop		R0
	pop		R1
	ldi		R16,	low(RAMEND)		;Загрузка в регистр r16 адреса верхней границы ОЗУ
	out		SPL,	R16				;Копирование значения из r16 в регистр указателя стека SPL
	ldi		R16,	high(RAMEND)
	out		SPH,	R16
	push	R1
	push	R0
ret
;***********************************

;Получает значение с АЦП, значение ADMUX должно быть в GENR1, результат будет в ADCH
;***********************************
getADCSample:
	out		ADMUX,		GENR1															;Регистр управления мультиплексора на АЦП
	ldi		GENR1,		(1<<ADEN) | (1<<ADSC)  |(1<<ADPS2)
	out		ADCSRA,		GENR1															;Регистр управления АЦП;
gas1:
	sbic	ADCSRA,		ADSC
	rjmp	gas1
ret
;***********************************

;Меняет адрес прерывания TIMER_1_COMP_A, новый адрес берется из регистра Z
;***********************************
setTimer1COMPAVect:
	sts		TIMER_1_COMP_A_vect,	ZL
	sts		TIMER_1_COMP_A_vect+1,	ZH
ret
;***********************************

.dseg
uartBuf:				.byte 4				;Буфер: заголовок, номер команды, параметр, контрольная сумма
TIMER_1_COMP_A_vect:	.byte 2				;Указатель на начало прерывания
MODE_START_VECT:		.byte 2				;Указатель на начало режима
PM_POINTER:				.byte 1	


.org  0x100		;После такого, ZH обязательно в 1  !!!!!!!!!!!
aSIN: .byte ARRAY_SIZE
