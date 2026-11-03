/*****************************************************************************/
/* test-servo1.c  Enero-2007                                                 */
/*---------------------------------------------------------------------------*/
/* Ejemplo para mover un servo del tipo futaba 3003                          */
/* El servo que se mueve es el numero 1 de la Skypic, conectado al PB0       */
/* Implementado para la tarjeta Skypic a 20MHz                               */
/*---------------------------------------------------------------------------*/
/* Para compilar:                                                            */
/*  sdcc -mpic14 -p16f876a -Wl-m -Wl-ainhx8m test-servo1.c                   */
/* Probado con SDCC v. 2.6.0                                                 */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@iearobotics.com>                            */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

/*******************************************************/
/* NOTAS:                                              */
/*-----------------------------------------------------*/
/* Hemos configurado el Timer para tener un prescaler  */
/* de 64. Una vez hecho el automata de estados, tenemos*/
/* los siguientes valores:                             */
/*    valor posición - temporizacion                   */
/*               0x0 - 0,3  mseg (extremo A)           */
/*              0x10 - 0,5  mseg                       */ 
/*              0x20 - 0,72 mseg                       */
/*              0x30 - 0,9  mseg                       */
/*              0x40 - 1,1  mseg                       */
/*              0x50 - 1,32 mseg                       */
/*              0x90 - 2,1 mseg                        */
/*              0x99 - 2,3 mseg (extremo B)            */
/*                                                     */
/* Con estos valores tenemos una resolucion de 1,17º   */
/* ya que tenemos 153 valores posibles para mover el   */
/* eje del motor en 180 grados.                        */
/*                                                     */
/*******************************************************/ 

//-- Especificar el pic a emplear
#include <pic16f876a.h>
	
//------------- RELACIONADAS CON LOS SERVOS -----------------
#define DELAY_0_3ms 0xEA	  // Tiempo 0'3ms, con prescaler a =64
#define DELAY_1_0ms 0xB0	  // Posicion central: 1ms, pres a = 64
#define DELAY_2_2ms 0x52    // Tiempo 2,2ms, con prescaler a =64

#define CENTRO	    DELAY_1_0ms
#define EXTREMO1    0xE0
#define EXTREMO2    0x90

// --Posicion de los servos
unsigned char pos_servos[8];  // Posicion servo
unsigned char indice;        // indice de servo
unsigned char servo_actual;  // Servo actual

unsigned char salidas;	    // Máscara que indica qué salidas están activas
unsigned char estado;	
	
unsigned char car;   // Caracter recibido por el SCI
unsigned char pos;   // Calculos intermedios


#define RETRASO 0xFFFF


//-- Realizar una pausa mediante espera activa
void pausa(unsigned int retraso)
{
  while (retraso>0) {
    retraso--;
  }  
}

void pausa2(unsigned char ticks)
{
  for (;ticks>0; ticks--)
    pausa(RETRASO);
}


/***************************************
   Configuracion del Timer 0
****************************************/

void timer0_configure() {
  // TOCS=Modo timer bit5=0
  // PS2:PS9 prescaler a 64
  // PSA=0 para asignar el prescaler al timer0
  OPTION_REG=0x05;   
	
  // Borra flag de interrupcion TIMER0 TOIF
  INTCON=INTCON&0xFB;   // TOIF=0  borra flag interrupcion del timer
  INTCON=INTCON|0x20;   // TOIE=1  activa interrupciones del timer
  INTCON=INTCON|0x80;   // GIE=1   activa interrupciones globales
  TMR0=0;               // Inicializa el registro del timer
}

/******************************************
	Rutina de atención a la interrupción
*******************************************/

void intr(void) interrupt 0 {
	
  // Borra flag de interrupcion TIMER0 TOIF
  INTCON=INTCON&0xFB;   // TOIF=0  borra flag interrupcion del timer

  if (estado==0) {
    PORTB=salidas & servo_actual;  // servo activo con mascara de las salidas
    //-- Lanzar temporizador para calcular anchura fija de 0.3ms
    TMR0=DELAY_0_3ms;
    estado=1;
  }
  else if (estado==1) {
    //-- Anchura para situar el servo
    TMR0=pos_servos[indice];
    estado=2;
  }
  else if (estado==2) {
    PORTB=0;
    TMR0=DELAY_2_2ms-pos_servos[indice];   
    estado=0;
		
    //-- Pasar al siguiente servo
    servo_actual=servo_actual<<1;
    indice++;
    if (servo_actual==0x00) { 
      servo_actual=1;
      indice=0;
     }	
  }	 
  else {
    // si llega aquí es por error -> vuelvo a estado inicial
    estado=0;
  }	
}


//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{
  unsigned char ret=0;
  unsigned char i;
	
  //-- configura como salida el Puerto B 
  TRISB=0x00;
  PORTB=0x02;  // enciende el LED
	
  //--inicializacion de variables
  for (i=0; i<8; i++) {
    pos_servos[i]=CENTRO;  // Motores en el centro como inicio
  }
  salidas=0xff;
  indice=0;
  estado=0;
  servo_actual=1;		
	
  //-- Configurar el Timer0 para controlar los servos
  //-- y activar su interrupcion
  timer0_configure();

  //-- Bucle principal
  while (1) {

    //-- Poner servo en un extremo
    pos_servos[0]=EXTREMO1;
    pausa2(6);

    //-- Poner servo en el otro extremo
    pos_servos[0]=EXTREMO2;
    pausa2(6);
  }

}
