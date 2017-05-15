/*
 * amControlBoard.c
 *
 * Created: 22.11.2016 16:48:20
 *  Author: Derron
 */ 

#define F_CPU 12000000UL			//Частота микроконтроллера
#define UARTRATE (F_CPU/16)/9600-1			//FCPU/(16*BUADRATE)-1

#include <avr/io.h>
#include <util/delay.h>

//Команды
#define BUFHEADER 150
#define CMD_MODE 22
#define CAR_AMPL 30
#define CAR_FREQ 31
#define INF_FREQ 32
#define INF_AMPL 33
#define CAR_OFFSET 34

//Режимы
#define AM_MODE 1
#define FM_MODE 2
#define PM_MODE 3
#define BAM_MODE 7
//***
#define SMH     5
#define UNKNOWN 0

//Кнопки
#define AM_BUTTON  1<<PD2
#define FM_BUTTON  1<<PD3
#define PM_BUTTON  1<<PD4
#define SMH_BUTTON 1<<PD5
#define BAM_BUTTON 1<<PD6

volatile char pindState;
volatile char mode;
volatile char source;

volatile unsigned char carAmpl;
volatile unsigned char carFreq;
volatile unsigned char infAmpl;
volatile unsigned char infFreq;
volatile unsigned char carOffset;

 char getMode(char val)
{
	//val = ~(val & 0b00111100) & 0b00111100;
	val = (val ^ pindState) & 0b01111100;
	switch(val)
	{
		case AM_BUTTON: return AM_MODE;
		case FM_BUTTON: return FM_MODE;
		case PM_BUTTON: return PM_MODE;
		case SMH_BUTTON: return SMH;
		case BAM_BUTTON: return BAM_MODE;
		default: return UNKNOWN;
	}
}

void sendCommand(char cmd, char param)
{
	send(BUFHEADER);
	send(cmd);
	send(param);
	send(BUFHEADER ^ cmd ^ param);
}

void setLEDs(char ledState)	//Если бит = 0, то DDRD = 1, PORTD= 0;
{
	ledState = ~ledState & 0b01111111;//| 0b10000000;
	DDRD  = (~DDRD & ledState);
	PORTD = ~(PORTD & ledState);
}

void send(unsigned char c)
{
	while (!( UCSRA & (1<<UDRE)));
	UDR = c;	
}

unsigned char readADC(unsigned char pin)
{
	ADMUX = (1<<REFS0) | (1<<ADLAR) | pin;
	ADCSRA = (1<<ADEN) | (1<<ADSC) | 0b111;
	while (ADCSRA & (1<<ADSC));
	return ADCH;	
}

int main(void)
{
	DDRD = 0;
	PORTD = 0xFF;
	UBRRH = 0;
	UBRRL = UARTRATE;
	UCSRB = (1<<RXEN) | (1<<TXEN) ;
	UCSRC = (1<<URSEL) | (1<<USBS) | (3<<UCSZ0);
	pindState = PIND & 0b11111100;
	source = 0b10000000;
    while(1)
    {
		char newState = PIND & 0b11111100;
		if(pindState != newState)
		{
			_delay_ms(20);					//Защита от дребезга контактов
			newState = PIND & 0b11111100;
			char newSource = PIND & 0b10000000;
			if(pindState != newState)
			{
				unsigned char newMode = getMode(newState);	//Получаем новый режим
				if (newMode == UNKNOWN)
				{
					if(source != newSource)(sendCommand(CMD_MODE, mode | newSource));
					source = newSource;
					goto ext;		//Если неизвестный режим то выходим
				}
				if (mode != newMode){
					 sendCommand(CMD_MODE, newMode | newSource);
					 setLEDs(newState | mode);
					}	
			mode = newMode;
			source = newSource;
			ext: pindState =  PIND & 0b11111100; 	
			}
		}
		unsigned char tempr;
		tempr = readADC(PINC4) /2;
		if((tempr > carAmpl+10)||(tempr<carAmpl-10)) { 
			sendCommand(CAR_AMPL, tempr);
			carAmpl = tempr;
		}
		tempr = readADC(PINC3);
		if((tempr > carFreq+10)||(tempr<carFreq-10)) {
			sendCommand(CAR_FREQ, tempr);
			carFreq = tempr;
		}		
		tempr = readADC(PINC2)/2 ;
		if((tempr > infAmpl+10)||(tempr<infAmpl-10)) {
			sendCommand(INF_AMPL, tempr);
			infAmpl = tempr;
		}		
		tempr = readADC(PINC1) /2;
		if((tempr > infFreq+10)||(tempr<infFreq-10)) {
			sendCommand(INF_FREQ, tempr);
			infFreq = tempr;
		}
		tempr = readADC(PINC0) /2;
		if((tempr > carOffset+10)||(tempr<carOffset-10)) {
			sendCommand(CAR_OFFSET, tempr);
			carOffset = tempr;
		}
    }
}
