/*****************************************************************************/
/* Encoder.c      Julio-2007                                                 */
/*---------------------------------------------------------------------------*/
/* Ejemplo para comprobar los encoders del skybot                            */
/*---------------------------------------------------------------------------*/
/* Prueba del encoder conectado como sensor1. El skybot empieza a avanzar.   */
/* Cuando el sensor detecta 5 transiciones entre el blanco y el negro, en    */
/* cualquier orden, enciende el led y se para.                               */
/*---------------------------------------------------------------------------*/
/*  Javier Valiente <jvaliente@ifara.com>                                    */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#include <pic16f876a.h>

//-- Definiciones de los sensores
#define   SENSOR1  0x01
#define   SENSOR2  0x20

#define   ENCODER1 SENSOR1
#define   LED 0x02


unsigned char sensor;

// Contar numero de vueltas

void CuentaNTransiciones(unsigned char num_segmentos)
{
  unsigned char i=0;
  unsigned char old_lectura_sensor, new_lectura;

  old_lectura_sensor = (PORTB & ENCODER1);

  while (i < num_segmentos)
  {
    new_lectura = (PORTB & ENCODER1);
    if (old_lectura_sensor != new_lectura)
	{
	  old_lectura_sensor = new_lectura;
	  i++; // Suma una transicion
	}
  }
}


void main(void)
{
    TRISB = 0xE1;
	PORTB = 0x1C;
    CuentaNTransiciones(5);
    PORTB=LED; //-- Encender LED y desactivar motores
}
