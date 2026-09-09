/****************************************************************************/
/* delay0.h      Mayo-2006                                                  */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/* Este fichero esta pensado para ser incluido en el programa principal.     */
/* Antes de utilizar la funcion delay0() es necesario llamar a               */
/* timer0_configurar() para configurar correctamente el timer 0              */
/*---------------------------------------------------------------------------*/
/* Utilizacion del temporizador 0 para generar una pausa de 10ms y           */
/* obtener una rutina de delay en unidades de 10ms                           */
/* No se utilizan interrupciones                                             */
/* El temporizador 0 es de 8 bits                                            */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*  Ricardo Gomez <ricardo@eagleman.org>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Definiciones
#define TICKS10 0x3D  // Valor con el que inicializar contador para
                      // conseguir TICKs de 10ms

/************************************/
/* Configurar el temporizador 0     */
/************************************/
void timer0_configurar()
{
  //-- Usarlo en modo temporizador, prescaler = 256
  OPTION_REG = OPTION_RE &0x87;
}

/************************************************/
/* Hacer una pausa en unidades de 10ms          */
/* ENTRADA:                                     */
/*   -pausa: Valor de la pausa en decenas de ms */
/************************************************/
void delay0(unsigned char pausa)
{
  
  //-- Esperar hasta que trancurran pausa ticks de reloj
  while(pausa>0) {
    TMR0=TICKS10;   // Inicializar contador
    T0IF=0;         // Quitar flag overflow
    //-- Esperar hasta que bit T0IF se ponga a '1'. Esto
    //-- indica que han transcurrido 10ms
    while (!T0IF);
      
    //-- Ha transcurrido un tick
    pausa--;
  }    
}
