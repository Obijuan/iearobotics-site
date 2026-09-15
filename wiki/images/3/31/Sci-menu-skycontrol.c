/*************************************************************************** */
/* sci-menu.c      Julio-2005                                                */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/* Mover el robot desde un terminal serie. Utilizar las teclas o,p,q y a     */
/* en minusculas. Configurarlo a 9600 baudios, 8,n,1                         */
/*---------------------------------------------------------------------------*/
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*  Modificado por: Ricardo Gomez <ricardo@eagleman.org>                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#include <pic16f877a.h>

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


/******************************/
/* Sacar el menu de opciones  */
/******************************/
void menu(void)
{
//  sci_cad("Menu\n\r");
//  sci_cad("----\n\r");
//  sci_cad("q.- adelante\n\r");
//  sci_cad("a.- atras\n\r");
//  sci_cad("o.- izquierda\n\r");
//  sci_cad("p.- derecha\n\r");
//  sci_cad("ESPACIO.- Parar\n\r");
}

/*********************************/
/* Programa principal            */
/*********************************/
void main(void)
{
  unsigned char c;

  //-- Cinfigurar el puerto C
  TRISC=TRISC&0xD8;
  
  //-- Configurar las comunicaciones serie
  sci_conf();
  
 
  //-- Sacar el menu
  menu();
  
  //-- Bucle infinito
  for (;;)
  {
    //-- Esperar a que llegue opcion del usuario
    c=sci_read();
    
    //-- Segun la tecla pulsada...
    switch(c)
    {
      case 'q':       //-- Adelante
        PORTC=PORTC|0x06;
        PORTC=PORTC|0x20;
		PORTC=PORTC&0xFE;
        break;
      case 'a':		  //-- Atras
	    PORTC=PORTC|0x06;
		PORTC=PORTC|0x01;
		PORTC=PORTC&0xDF;
        break;
	  case 'o':		  //-- Izquierda
	    PORTC=PORTC|0x06;
		PORTC=PORTC|0x21;
		break;
	  case 'p':		  //-- Derecha
		PORTC=PORTC|0x06;
		PORTC=PORTC&0xDE;
		break;
	  case ' ':		  //-- Parada
		PORTC=PORTC&0xF9;
    }
  }
}
