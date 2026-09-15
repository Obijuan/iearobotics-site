/*************************************************/
/* Firmware Flatbot                              */  
/* Andres Prieto-Moreno                  Jul-08  */
/*                                               */
/* Programa servidor del robot FLATBOT para      */
/* la SKYControl. El servidor espera recibir por */
/* el puerto serie instrucciones de como         */
/* mover el robot.                               */
/*                                               */
/* Configuracion puerto serie: 9600, 8n1         */
/* (sin ningún control por hardware o por        */
/* software del flujo.                           */ 
/*                                               */
/* Comandos basicos del servidor:                */
/* ------------------------------                */
/*  q  -> Adelante                               */
/*  a  -> Atras                                  */
/*  o  -> izquierda                              */
/*  p  -> derecha                                */
/* ' ' -> parar                                  */
/*                                               */
/*  +  -> incrementa velocidad en +5             */
/*  -  -> decremente velocidad en -5             */
/*                                               */
/* 0..5 -> Diferentes valores de velocidad       */
/*                                               */
/* Comandos avanzados:                           */
/* -------------------                           */
/*  v  -> Espera recibir tres dígitos indi-      */
/*        cando valor velocidad.                 */
/*        Ej: v'1''5''5'                         */
/*        Una vez recibidos los tres digitos     */
/*        devuelve un '.'                        */
/*                                               */
/*  V  -> Espera a recibir un byte que           */
/*        indica la velocidad. Ej: V61           */
/*        Una vez recibido el valor devuelve     */
/*        un '.'                                 */
/*                                               */
/*  b  -> Espera a recibir dos bytes que         */
/*        indican la velocidad de cada motor     */
/*        primer byte = motor_1                  */
/*        segundo_byte = motor_2                 */
/*        Una vez recibidos los dos bytes        */
/*        devuelve un '.'                        */
/*                                               */
/*  Comando PING                                 */
/*  ------------                                 */
/*  i   -> Responde I (para probar conexion      */
/*                                               */ 
/*************************************************/

//-- Especificar el pic a emplear
#include <pic16f876a.h>

//-- variables del programa
unsigned char car;         // auxiliar
unsigned char buf[3];      // auxiliar
unsigned char velocidad;   // recuerda la velocidad 


/****************************************/
/*  Configuracion del Timer             */
/****************************************/

void pwm_configure() {
	// TOCS=Modo timer bit5=0
	// PS2:PS0 prescaler 
	// PSA=0 para asignar el prescaler al timer0
	// Fosc = 20MHz -> CLKO (frec. bus o ciclo de instruccion= Fosc/4) = 5MHz
	// Hemos quitado el pre-scaler Frec= 5Mhz / 255
	OPTION_REG=0x08;   
	
	// Configura las interrupciones
	INTCON=INTCON|0x80;   // GIE=1    activa interrupciones globales
	INTCON=INTCON|0x40;   // PEIE=1   activa interrupciones perifericos
	
	// Configura el Timer 2
	T2CON = 0x00;  			// Pone el pre-scaler a 1:1 y el post-scaler a 1:1
	T2CON = T2CON | 0x04;   // Activa el timer 2
	
	// Configura el PWM Canal 1 (Motor 1)
	CCP1CON=0x3C;   // CCPxX CCPxY CCPxM3 CCPxM2 CCPxM1 CCPxM0
					// PWM necesita CCPxM3 y CCPxM2 a 1, CCPxM1 y CCPxM0 da igual
	
	// PWM Duty Cycle
	CCPR1L=0;      // Ancho señal cuadrada: valor entre 0 y 255 
	CCP1CON=CCP1CON & 0x0F;
	
	
	// Configura el PWM Canal 2 (Motor 2)
	CCP2CON=0x3C;   // CCPxX CCPxY CCPxM3 CCPxM2 CCPxM1 CCPxM0
					// PWM necesita CCPxM3 y CCPxM2 a 1, CCPxM1 y CCPxM0 da igual
	// PWM Duty Cycle
	CCPR2L=0;       // Ancho señal cuadrada: valor entre 0 y 255 
	CCP2CON=CCP2CON & 0x0F;
	
	PR2=255;		// PWM period = (PR2+1)*Tosc*TMR2_prescaler -> busco Periodo de 20Khz
	
	// Configuro salida por RC2 (CCP1) y RC1 (CCP2)
	TRISC=TRISC & 0xF9;  // para salida pongo un cero
	
}


/*********************************************/
/* Funciones asociadas al puerto serie       */
/*********************************************/

//----------------------------------------------------
// Configurar el puerto serie a N81 y 9600 Baudios  
void sci_conf(void)
{
  SPBRG = 0x81;  //-- 9600 baudios (con cristal de 20MHz)
  TXSTA = 0x24;  //-- Configurar transmisor
  RCSTA = 0x90;  //-- Configurar receptor
  
}


//----------------------------------------------
// Devuelve 1 cuando hay dato
// Devuelve 0 cuando no hay dato
unsigned char car_ready() {
	return RCIF;
}

//------------------------------------------------
// Devuelve dato del buffer sin preocuparse de si
// es nuevo o viejo. Se usa en combinacion con la 
// funcion car_ready().
unsigned char get_car() {
	return RCREG;
}


//------------------------------------------
// Espera a recibir un dato por el SCI y lo 
// devuelve.
unsigned char sci_read(void)
{
  //-- Eserar hasta que llegue el dato
  while (!RCIF);
    
  return RCREG;
}


//------------------------------------------------------
// Manda el byte 'car' por el puerto serie
void sci_write(unsigned char car)
{
  //-- Esperar a que Flag de lista para transmitir se active
  while (!TXIF);
    
  //-- Hacer la transmision
  TXREG=car;
}

/***************************************/
/* Funciones auxiliares                */
/***************************************/

//---------------------------------------------------------------
// Multiplica dos CHARS mediante sumas
unsigned char multiplica_char(unsigned char num1, unsigned char num2) {
	unsigned char i;
	unsigned char valor=0;
	
	for (i=0; i<num1; i++) {
		valor=valor+num2;
	}
	return valor;
}

//--------------------------------------------------------
// Recibe tres numeros ascii y lo pasa a binario
// Lo pasamos por parametros para no tener problemas de compilacion
unsigned char ascii_to_vel(unsigned char dat1, unsigned char dat2, unsigned char dat3) {
	unsigned char valor;
	
	dat1=dat1-'0';
	dat2=dat2-'0';
	dat3=dat3-'0';
	
	valor = multiplica_char(dat1, 100);
	valor = valor + multiplica_char(dat2,10);
	valor = valor + dat3;
	
	return valor;
}




/****************************************/
/* Bucle principal                      */
/* El servidor espera a recibir un      */
/* comando para proceder a su ejecucion */
/*                                      */
/* Por interrupciones se controla el    */
/* PWM de los motores                   */
/****************************************/

void main(void)
{
	// inicializacion de variables
	car=0;
	velocidad=0x0;   // minima velocidad al arrancar
		
	//-- Configurar el puerto serie
	sci_conf();
	
	//-- Configurar el Timer0 para controlar los servos
	//-- y activar su interrupcion
	pwm_configure();
		
	//-- Configurar puerto B 
	TRISB=0xF5;
	PORTB=0x0;
	
	//-- Configurar el puerto C
	TRISC=TRISC & 0xDE;
	//PORTC=0x0;
  
	// Bucle principal es infinito
	for(;;) {
  
		if (car_ready()==1) {   // ¿hay dato esperando?
			car=get_car();      //  si -> lo leo y lo proceso
			
			switch (car) {
				case '1':	
							velocidad=170;
							break;
				case '2':
							velocidad=180;
							break;
				case '3':	
							velocidad=210;
							break;
				case '4':	
							velocidad=230;
							break;
				case '5':	
							velocidad=0xFF;
							break;
							
				case '0':  // minima velocidad
							velocidad=0;
							break;
				
				case '-':  // incrementa velocidad
							if (velocidad>=160) {
								velocidad=velocidad-5;
							}
							break;
							
				case '+':  	// decrementa velocidad
							if (velocidad<=250) {
								velocidad=velocidad+5;
							}
							break;
				
				case 'q':  // adelante
							PORTC = PORTC & 0xFE;
							PORTC = PORTC | 0x20;
							continue;
							
				case 'a':  // atras			
							PORTC = PORTC & 0xDF;
							PORTC = PORTC | 0x01;
							continue;
										
				case 'o':  // izquierda
							PORTC = PORTC | 0x21;
							continue;
														
				case 'p':  // derecha		
							PORTC = PORTC & 0xDE;
							continue;
											
				case 'v':  // leer velocidad global en ASCII
							buf[0]=sci_read();
							buf[1]=sci_read();
							buf[2]=sci_read();
							velocidad=ascii_to_vel(buf[0], buf[1], buf[2]);
							sci_write('.');
							break;
							
				
				case 'V':  // leer velocidad global en binario
							velocidad=sci_read();
							sci_write('.');
							break;
							
				case 'b':  // leer velocidad de ambos motores
							CCPR1L=sci_read();
							CCPR2L=sci_read();
							sci_write('.');
							continue;
				
				case 'i':  // Eco, devuelve 'I'
							sci_write('I');
							continue;
							
				default:	
							velocidad=0;
							break;
			}
			CCPR1L=velocidad;
			CCPR2L=velocidad;
			
			PORTB = PORTB ^`0x02;
			
		}
		// No hay dato -> otra vez a empezar
		
	}
}

