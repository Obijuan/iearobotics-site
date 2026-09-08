/*************************************************************************** */
/* sci-menu.c      Julio-2005                                                */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/* Mover el robot desde un terminal serie. Utilizar las teclas o,p,q y a     */
/* en minusculas. Configurarlo a 9600 baudios, 8,n,1                         */
/*---------------------------------------------------------------------------*/
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#define __16f877
#include "pic16f877.h"

//-- Se usa la libreria de comunicaciones serie
#include "sci.h"

//-- Definiciones para los motores. Estos valores define
//-- los movimientos del robot
#define   AVANZA     0x1C
#define   ATRAS      0x16
#define   IZQUIERDA  0x1E 
#define   DERECHA    0x14 
#define   STOP       0x00


/******************************/
/* Sacar el menu de opciones  */
/******************************/
void menu(void)
{
  sci_cad("Menu\n\r");
  sci_cad("----\n\r");
  sci_cad("q.- adelante\n\r");
  sci_cad("a.- atras\n\r");
  sci_cad("o.- izquierda\n\r");
  sci_cad("p.- derecha\n\r");
  sci_cad("ESPACIO.- Parar\n\r");
}

/*********************************/
/* Programa principal            */
/*********************************/
void main(void)
{
  unsigned char c;

  //-- Configurar el puerto B 
  //-- RB0, RB5, RB6 y RB7 como entradas
  //-- RB1, RB2, RB3 y RB4 como salidas
  //-- Todos los sensores de entrada, pero el RB1 de salida, que es
  //-- donde esta el led
  TRISB=0xE1;
  
  //-- Configurar las comunicaciones serie
  sci_conf();
  
  //-- Parar los motores del robot
  PORTB=STOP;
  
  //-- Sacar el menu
  menu();
  
  //-- Bucle infinito
  for (;;) {
    
    //-- Esperar a que llegue opcion del usuario
    c=sci_read();
    
    //-- Segun la tecla pulsada...
    switch(c) {
      case 'q':       //-- Adelante
        PORTB=0x1C;
        break;
      case 'a':
        PORTB=ATRAS;  //-- Atras
        break;
      case 'o':
        PORTB=IZQUIERDA; //-- Izquierda
        break;
      case 'p':
        PORTB=DERECHA;   //-- Derecha
        break;
      
	  case ' ':         //-- stop
        PORTB=STOP;
        break;
    }
  }

}
