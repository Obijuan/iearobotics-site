/*******************************************************************/
/* tim-pwm-fut8.c  (c) Juan Gonzalez. Mayo 2004                    */
/*-----------------------------------------------------------------*/
/* Ejemplo de posicionamienot de servos Futaba 3003                */
/* Se utiliza el TIM1 para posicionar hasta 8 servos               */
/* El posicionamiento se hace por interrupciones                   */
/* La interrupcion de overflow se configura para que se            */
/* produzca cada 2.5ms. La interrupcion del capturador             */
/* determina el anchu del servo actual.                            */
/*-----------------------------------------------------------------*/
/* LICENCIA GPL                                                    */
/*******************************************************************/
#include "mc68hc908gp32.h"

/********************/
/* Constantes       */
/********************/
#define CENTRO    0x0C72   //-- 1,3ms. Posicion central
#define EXTREMO1  0x02DF   //-- 0,3ms. Un extremo
#define EXTREMO2  0x1605   //-- 2,3ms. El otro extremo
#define T2_5ms    0x17D1   //-- 20ms. Periodo de la senal

/*-------------------*/
/* Variables         */
/*-------------------*/
unsigned int  pos[8];  //-- Posicion de cada servo
unsigned char servo;   //-- Servo actual
unsigned char salidas; //-- Mascara de habilitacion de servos


/************************************************************/
/* Rutina de atencion a la interrupcion del canal 0 (TIM1)  */
/************************************************************/
void rsi_t1ch0 (void) interrupt 4
{
	//-- Desactivar flag de interrupcion
  T1SC0&=(~0x80);
	
	//-- Poner pwm a '0'
	PORTB=0x00; 
	
	//-- En la proxima int. de overflow se 
	//-- actulizara el siguiente servo
	servo++;
	if (servo==8) servo=0;
}

/************************************************************/
/* Rutina de atencion a la interrupcion de overflow (TIM1)  */
/* Se produce cada 2,5ms                                    */
/************************************************************/
void rsi_ov1 (void) interrupt 6
{
	//-- Desactivar flag de interrupcion
  T1SC&=(~0x80);
	
	//-- Poner senal PWM a 1 (Si esta habilitado)
	PORTB|=(0x01<<servo)&salidas; 
	
	//-- Establecer el ancho del pulso
	T1CH0H = (pos[servo]>>8);
	T1CH0L = pos[servo]&0xFF;
}
	
void main(void)
{
	
	static unsigned char i;
	
	/*----------------------------*/
	/* Configurar el sistema      */
	/*----------------------------*/
	CONFIG1|=0x31;  //-- Deshabilitar el COP y el LVI
  DDRB=0xFF;      //-- Configurar Puerto B para salida
	PORTB=0x00;     //-- Poner a 0 Puerto B
	
	/*-----------------------------*/
	/*- Configurar el temporizador */
	/*-----------------------------*/
	T1SC = 0x60;    // Prescaler: Div entre 64
	
	//-- Establecer modulo del contador
	//-- IMPORTANTE!: Se debe realizar en este orden
	//-- primero la parte alta y luego la baja
	T1MODH = 0x17;   // Parte alta
	T1MODL = 0xD1;   // Parte baja
	
	/*----------------------------------------*/
	/*- Configurar el comparador 0 (canal 0)  */
	/*----------------------------------------*/
  // Interrupcion permitida
	// Configurar como comparador, sin salida hardware
	T1SC0 = 0x50;
	
	//-------------------------------//
	//- Inicializar las variables  --//
	//-------------------------------//
	//-- Establecer posiciones iniciales de los servos.
	for (i=0; i<8; i++)
    pos[i]=CENTRO;
	
	pos[0]=EXTREMO1;
	salidas=0xFF;
	servo=0;
	
	//-- Habilitar las interrupciones
	 _asm CLI _endasm;
	
	//-- Activar temporizador
	T1SC&=~(0x20);
	
	for(;;);
}
