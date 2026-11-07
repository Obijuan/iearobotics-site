// Control de 8 servos a traves del puerto UART mediante el empleo de un vector de 
// caracteres de tamaño 9, donde el primer caracter sirve para la sincronizacion "PC-Microcontrolador",
// los siguientes 4 caracteres son la velocidad en "ticks" de cada uno de los 4 primeros servos, y los ultimos
// 4 caracteres es la posicion a la que deben ir cada uno de los 4 ultimos servos.
// 
// Para compilar y cargar en el microcontrolador usar:
//			$ avr-gcc ftrackserver.c -mmcu=atmega168 -Wall -o main.o
//			$ avr-objcopy -O ihex main.o main.hex
//			$ avrdude -q -patmega168 -cstk500v1 -P/dev/ttyUSB0 -b19200 -D -Uflash:w:main.hex
//

#include <avr/interrupt.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdio.h>

//--- Definiciones ---

#define F_CPU 16000000
#define UART_BAUD 9600

#define DELAY_0_3ms 19
#define DELAY_0_2ms 12
#define DELAY_1ms   62
#define DELAY_2ms   125
#define DELAY_2_5ms 156

#define CENTRO DELAY_1ms

//--- Declaracion de funciones ---

int uart_getchar(FILE *stream);
unsigned char deg2time(char);
void servo_pos(unsigned char , char);

//--- Variables globales ---

// Estados de la señal PWM usada para el control de los servos
//		- State0: Ancho de pulso 0.3ms (Señal PWM a 1)
// 	- State1: Posicion del servo. Ancho de pulso "pos". Ancho entre 0 y 2ms (señal PWM a 1)
// 	- State2: Complementaria de la posicion del servo. Width = 2ms - State1_Width (señal PWM a 0)
// 	- State3: Ancho de pulso 0.2ms (señal PWM a 0)
enum { STATE0, STATE1, STATE2, STATE3 } state;

unsigned char servo=0;  // Indice del servo (de 0 a 7)

// Posicion del servo en "ticks" (unidades de tiempo)
volatile unsigned char pos[]={CENTRO,CENTRO,CENTRO,CENTRO,CENTRO,CENTRO,CENTRO,CENTRO};

// Flag de comienzo de nuevo ciclo PWM (20ms)
volatile unsigned char pwm_cycle_start=0;

// Número del puerto al que esta conectado el servo (PORTB(0-3) o PORTC(0-3))
unsigned char n_port=0; // Varía entre 0 y 3.

// Usar la UART como un stream de salida
FILE uart_str = FDEV_SETUP_STREAM(NULL, uart_getchar, _FDEV_SETUP_READ);

//--- Rutina de atencion a la interrupcion (ISR) ---
// Se ejecuta cada vez que se dispara el comparador A.
// Es la encargada de generar la señal PWM que controla la posicion de los servos.
ISR(TIMER0_COMPA_vect)
{
	// El "flag" de la interrupcion es limpiado automaticamente.
	// Implementación de una maquina de estados finitos.
	switch(state) {
		case STATE0: //-- Señal PWM a 1. Ancho fijo de 0.3ms.
			if (servo%2){
				PORTB = (1<<n_port);
				n_port++;}
			else {
				PORTC = (1<<n_port);
			}
			OCR0A=DELAY_0_3ms;
			state = STATE1;  // Siguiente estado.
			break;
		
		case STATE1: //-- Señal PWM a 1. Ancho variable de valor pos[servo].
			OCR0A=pos[servo];
			state = STATE2;  // Siguiente estado.
			break;
		
		case STATE2: //-- Señal PWM a 0. Ancho variable de valor "DELAY_2ms - pos[servo]".
			PORTB=0;
			PORTC=0;
			OCR0A=DELAY_2ms - pos[servo];

			state = STATE3;  // Siguiente estado.
			break;
		
		case STATE3: //-- Señal PWM a 0. Ancho fijo de 0.2ms.
			OCR0A=DELAY_0_2ms;
			servo = (servo+1)%8;
			state = STATE0;  // Siguiente estado.
			
			if (servo==0){ // Si se cumple un nuevo ciclo PWM comienza.
				n_port=0;
				pwm_cycle_start=1;
			}
			break;
	}
}

//--- Inicializaciones del microcontrolador ---

void ports_init()
{
	//-- Configuración de los puertos.
	// Configura los cuatro primeros pines del puerto B y C como salida
	DDRB= 0x2F;	// 0b00101111
	DDRC= 0x0F;	// 0b00001111
}

void timer0_init()
{
	//-- Configuracion timer0.
	// Configuracion timer en modo CTC (Clear Timer on Compare mode) (WGM02:0 = 0b010)
	TCCR0A = _BV(WGM01); //_BV(i) Devuelve número binario 8bits donde el bit "i" es 1 y el resto 0.

	// Prescaler 256 (CS02:0 = 0b100). Reloj = 16Mhz (T = 1/16MHz = 62.5ns)
	// Ticks con prescaler: 62.5ns/256 = 16us
	TCCR0B = _BV(CS02);
	// Delay of 0.3ms --> OCR0A = 19	(18.750)
	// Delay of 0.2ms --> OCR0A = 12	(12.5)
	// Delay of 1ms	--> 	OCR0A = 62	(62.5)
	// Delay of 2ms --> 	OCR0A = 125	(125)
	// Rango de la posicion: 0 - 125 unidades de tiempo ("ticks") --> [-90, 90] grados
}

void interrupts_init()
{
	//-- Configuración de interrupciones.
	TIMSK0 = _BV(OCIE0A); // Habilitar interrupcion del Comparador A (timer0)
	sei(); // Habilitar interrupciones
}

void uart_init()
{
	//-- Configuracion de la UART (9600 bauds)
	UBRR0L = (F_CPU / (16UL * UART_BAUD)) - 1;
	UCSR0B = _BV(RXEN0); // Habilitar recepcion (rx enable)
}

//--- FUNCION PRINCIPAL ---
int main(void)
{
	char c[8];
	int i;
	
	ports_init();			// Configurar puertos de Entrada/Salida
	timer0_init();			// Configurar timer0
	interrupts_init();	// Configurar interrupciones
	uart_init();			// Configurar UART
	
	stdin = &uart_str; // Se define la UART como el stream de salida por defecto

	while(1) {
		//-- Asignacion de la velocidad de los servos a traves del puerto serie.
		// Si recibe el valor 181 (Valor de sincronizacion) por el puerto serie, se interpretan
		// los siguientes ocho caracteres como las velocidades en "ticks" y posiciones en grados
		// de los servos. En caso contrario, no se lee el puerto serie.
		if (getchar()==181){	// Sirve para sincronizar.
			for(i=0;i<4;i++){
				c[i]=getchar();
				if (c[i]>72){
					pos[i]=125;}
				else if (c[i]<52){
					pos[i]=0;}
				else{
					pos[i]=c[i];}
			}
			for(i=4;i<8;i++){
				c[i]=getchar();
				if (c[i]>180){
					servo_pos(i,0);}
				else{
					servo_pos(i,c[i]-90);}
			}
		PORTB=PORTB^0x20; // El led parpadea si se estan recibiendo datos a traves del puerto serie.
		}
		//fflush(stdin);
	}
	return 0;
}

//--- Definicion de funciones ---

int uart_getchar(FILE *stream)
{
	uint8_t c;

	loop_until_bit_is_set(UCSR0A, RXC0);
	if (UCSR0A & _BV(FE0)){ return _FDEV_EOF; }
	if (UCSR0A & _BV(DOR0)){ return _FDEV_ERR; }

	c = UDR0;
	return c;
}

// Conversion entre grados (deg) y "ticks" (time)
//-- La señal PWM que controla la posicion del servo es calculada en "ticks"
//-- deg: ángulo en grados en el rango [-90,90]
//-- La función devuelve el ancho de la señal PWM en "ticks" (rango entre 0 y 125)
unsigned char deg2time(char deg)
{
	return 25*(90-deg)/36;
}

void servo_pos(unsigned char s, char deg)
{
	pos[s]=deg2time(deg);
}

