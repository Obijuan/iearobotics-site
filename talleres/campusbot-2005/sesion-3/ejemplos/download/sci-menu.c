/*************************************************************************** */
/* sci-menu.c      Julio-2005                                                */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/* Mover el robot desde un terminal serie. Utilizar las teclas o,p,q y a     */
/* en minusculas                                                             */
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
#define   AVANZA     0x18
#define   ATRAS      0x78
#define   IZQUIERDA  0x58 
#define   DERECHA    0x38 
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
  //-- RB0, RB2 y RB7 como entradas
  //-- RB1, RB3, RB4, RB5, RB6 como salidas
  //-- Todos los sensores de entrada, pero el RB1 de salida, que es
  //-- donde esta el led
  TRISB=0x85;
  
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
        PORTB=AVANZA;
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
    
    //-- Cambiar el led de estado
    PORTB^=0x02;
  }

}
