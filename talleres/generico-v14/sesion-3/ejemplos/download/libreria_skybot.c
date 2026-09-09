/*****************************************************************************/
/* libreria_skybot.c      Julio-2008                                         */
/*---------------------------------------------------------------------------*/
/* Libreria de funciones auxiliares para el manejo del skybot                */
/*---------------------------------------------------------------------------*/
/* Este fichero contiene el codigo de las funciones de movimiento del skybot */
/* es indispensable incluir en los ficheros de codigo creados por el usuario */
/* el fichero de firmas correspondiente a estas funciones (libreria_skybot.h)*/
/*---------------------------------------------------------------------------*/
/* Dependencias:                                                             */
/*                                                                           */
/* -> delay0            - Libreria de acceso al temporizador del pic 16f876a */
/* -> pic16f876a        - Libreria de acceso a los registros del pic 16f876a */
/* -> libreria_skybot.h - Fichero de cabecera que contiene las firmas y      */
/*                        constantes necesarias para esta libreria           */
/*---------------------------------------------------------------------------*/
/*  Autor: Javier Valiente <javier.valiente@gmail.com>                       */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/


#include "libreria_skybot.h"


unsigned char tmp=0x00;

/**************************************************************
 *                                                            *
 * ConfigurarSkybot                                           *
 * ----------------                                           *
 *                                                            *
 * Funcion encargada de configurar el puerto B del skybot     *
 * para que sepa leer la informacion de los 4 sensores        *
 * infrarrojos, y para que sea capaz de manejar ambos         *
 * motores.                                                   *
 * Tambien inicializa el temporizador a 0.                    *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    Ninguno                          *
 *                                                            *
 **************************************************************/
void ConfigurarSkybot()
{
	//-- Configurar el puerto B para trabajar con el Skybot
	//-- RB0, RB5, RB6 y RB7 como entradas
	//-- RB1, RB2, RB3 y RB4 como salidas
	TRISB=0xE1;
	//TRISA=0xFF;

	//-- Configurar el puerto A para leer los bumpers del Skybot
	ADCON1 = 0x0E;

	//-- Inicializar temporizador a 0
	timer0_configurar();
}




/**************************************************************
 *                                                            *
 * PausaTiempo                                                *
 * ----------------                                           *
 *                                                            *
 * Funcion encargada de pausar la ejecucion del codigo del    *
 * PIC del skybot. De este modo, la ultima instruccion se     *
 * queda activa durante la pausa que se indique.              *
 * Tambien inicializa el temporizador a 0.                    *
 *                                                            *
 * Parametros de la funcion:                                  *
 *       - unsigned int segundos: Nº de segundos de pausa     *
 *       - unsigned int centesimas: Nº de segundos de pausa   *
 *                                                            *
 * Retorno de la funcion:    Ninguno                          *
 *                                                            *
 **************************************************************/
void PausaTiempo(unsigned int segundos,unsigned int centesimas)
{
  // Centesimas:
  while (centesimas > 255)
  {
    delay0(255);
    centesimas-=255;
  }
  delay0(centesimas);

  while (segundos > 2)
  {
	delay0(200);
	segundos-=2;
  }
  if (segundos==2) {
	delay0(200);
  } 
  else if (segundos==1) {
	delay0(100);
  }
  
}




/**************************************************************
 *                                                            *
 * Avanzar                                                    *
 * ----------------                                           *
 *                                                            *
 * Funcion que configura y activa los motores del skybot      *
 * para que avance hacia delante.                             *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    Ninguno                          *
 *                                                            *
 **************************************************************/
void Avanzar()
{
//  TRISB &= ~(TRISB_MOTOR_IZQUIERDO | TRISB_MOTOR_DERECHO);
  PORTB=AVANZA;
  return;
}




/**************************************************************
 *                                                            *
 * GirarIzq                                                   *
 * ----------------                                           *
 *                                                            *
 * Funcion que configura y activa los motores del skybot      *
 * para que gire hacia la izquierda                           *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    Ninguno                          *
 *                                                            *
 **************************************************************/
void GirarIzq()
{
//  TRISB&=~(TRISB_MOTOR_IZQUIERDO | TRISB_MOTOR_DERECHO);
  PORTB=IZQUIERDA;
  return;
}




/**************************************************************
 *                                                            *
 * GirarDer                                                   *
 * ----------------                                           *
 *                                                            *
 * Funcion que configura y activa los motores del skybot      *
 * para que gire hacia la derecha                             *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    Ninguno                          *
 *                                                            *
 **************************************************************/
void GirarDer()
{
//  TRISB&=~(TRISB_MOTOR_IZQUIERDO | TRISB_MOTOR_DERECHO);
  PORTB=DERECHA;
}




/**************************************************************
 *                                                            *
 * Retroceder                                                 *
 * ----------------                                           *
 *                                                            *
 * Funcion que configura y activa los motores del skybot      *
 * para que retroceda                                         *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    Ninguno                          *
 *                                                            *
 **************************************************************/
void Retroceder()
{
//  TRISB&=~(TRISB_MOTOR_IZQUIERDO | TRISB_MOTOR_DERECHO);
  PORTB=ATRAS;
}




/**************************************************************
 *                                                            *
 * Parar                                                      *
 * ----------------                                           *
 *                                                            *
 * Funcion que configura y activa los motores del skybot      *
 * para se detenga                                            *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    Ninguno                          *
 *                                                            *
 **************************************************************/
void Parar()
{
//  TRISB&=~(TRISB_MOTOR_IZQUIERDO | TRISB_MOTOR_DERECHO);
  PORTB=STOP;
}




/**************************************************************
 *                                                            *
 * SensorIR_Izq_Lee_Negro                                     *
 * ----------------                                           *
 *                                                            *
 * Funcion que comprueba si el sensor infrarrojo izquierdo    *
 * esta leyendo negro.                                        *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    VERDADERO o FALSO                *
 *                                                            *
 **************************************************************/
unsigned char SensorIR_Izq_Lee_Negro()
{
  if (LeerSensor3() == NEGRO) return VERDADERO;
  return FALSO;
}




/**************************************************************
 *                                                            *
 * SensorIR_Der_Lee_Negro                                     *
 * ----------------                                           *
 *                                                            *
 * Funcion que comprueba si el sensor infrarrojo derecho      *
 * esta leyendo negro.                                        *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    VERDADERO o FALSO                *
 *                                                            *
 **************************************************************/
unsigned char SensorIR_Der_Lee_Negro()
{
  if (LeerSensor4() == NEGRO) return VERDADERO;
  return FALSO;
}




/**************************************************************
 *                                                            *
 * SensorIR_Izq_Lee_Blanco                                    *
 * ----------------                                           *
 *                                                            *
 * Funcion que comprueba si el sensor infrarrojo izquierdo    *
 * esta leyendo blanco.                                       *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    VERDADERO o FALSO                *
 *                                                            *
 **************************************************************/
unsigned char SensorIR_Izq_Lee_Blanco()
{
  if (LeerSensor3() == BLANCO) return VERDADERO;
  return FALSO;
}




/**************************************************************
 *                                                            *
 * SensorIR_Der_Lee_Blanco                                    *
 * ----------------                                           *
 *                                                            *
 * Funcion que comprueba si el sensor infrarrojo derecho      *
 * esta leyendo blanco.                                       *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    VERDADERO o FALSO                *
 *                                                            *
 **************************************************************/
unsigned char SensorIR_Der_Lee_Blanco()
{
  if (LeerSensor4() == BLANCO) return VERDADERO;
  return FALSO;
}




/**************************************************************
 *                                                            *
 * LeerInfrarrojos                                            *
 * ----------------                                           *
 *                                                            *
 * Funcion que lee ambos sensores infrarrojos         y       *
 * devuelve un valor distinto dependiendo de lo que lee cada  *
 * sensor.                                                    *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:                                     *
 *     3 - Ambos sensores estan detectando algo negro         *
 *     2 - El sensor derecho lee negro, el sensor izquierdo   *
 *         lee blanco                                         *
 *     1 - El sensor izquierdo lee negro, el sensor derecho   *
 *         lee blanco                                         *
 *                                                            *
 **************************************************************/
unsigned char LeerInfrarrojos()
{
  unsigned char sI=0,sD=0;

  if (SensorIR_Izq_Lee_Negro()) sI=1;
  if (SensorIR_Der_Lee_Negro()) sD=1;

  if (sI && sD) return 3;
  else if (sD) return 2;
  return 1;
}




/**************************************************************
 *                                                            *
 * LeerSensor1                                                *
 * ----------------                                           *
 *                                                            *
 * Funcion que devuelve la lectura del sensor 1 (infrarrojo)  *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    NEGRO o BLANCO                   *
 *                                                            *
 **************************************************************/
unsigned char LeerSensor1()
{
  if ((PORTB & SENSOR1) != 0) return NEGRO;
  return BLANCO;
}




/**************************************************************
 *                                                            *
 * LeerSensor2                                                *
 * ----------------                                           *
 *                                                            *
 * Funcion que devuelve la lectura del sensor 2 (infrarrojo)  *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    NEGRO o BLANCO                   *
 *                                                            *
 **************************************************************/
unsigned char LeerSensor2()
{
  if ((PORTB & SENSOR2) != 0) return NEGRO;
  return BLANCO;
}




/**************************************************************
 *                                                            *
 * LeerSensor3                                                *
 * ----------------                                           *
 *                                                            *
 * Funcion que devuelve la lectura del sensor 3 (infrarrojo)  *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    NEGRO o BLANCO                   *
 *                                                            *
 **************************************************************/
unsigned char LeerSensor3()
{
  if ((PORTB & SENSOR3) != 0) return NEGRO;
  return BLANCO;
}




/**************************************************************
 *                                                            *
 * LeerSensor4                                                *
 * ----------------                                           *
 *                                                            *
 * Funcion que devuelve la lectura del sensor 4 (infrarrojo)  *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    NEGRO o BLANCO                   *
 *                                                            *
 **************************************************************/
unsigned char LeerSensor4()
{
  if ((PORTB & SENSOR4) != 0) return NEGRO;
  return BLANCO;
}




/**************************************************************
 *                                                            *
 * Bumper_Izq_esta_apretado                                   *
 * ----------------                                           *
 *                                                            *
 * Funcion que comprueba si el bumper izquierdo esta apretado *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    VERDADERO o FALSO                *
 *                                                            *
 **************************************************************/
unsigned char Bumper_Izq_esta_apretado()
{
  if (LeerBumperIzquierdo() == APRETADO) return VERDADERO;
  return FALSO;
}




/**************************************************************
 *                                                            *
 * Bumper_Der_esta_apretado                                   *
 * ----------------                                           *
 *                                                            *
 * Funcion que comprueba si el bumper derecho esta apretado   *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    VERDADERO o FALSO                *
 *                                                            *
 **************************************************************/
unsigned char Bumper_Der_esta_apretado()
{
  if (LeerBumperDerecho() == APRETADO) return VERDADERO;
  return FALSO;
}




/**************************************************************
 *                                                            *
 * LeerBumperIzquierdo                                        *
 * ----------------                                           *
 *                                                            *
 * Funcion que devuelve el estado del bumper izquierdo        *
 * (visto desde arriba, desde la rueda loca del skybot)       *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    APRETADO o SIN_APRETAR           *
 *                                                            *
 **************************************************************/
unsigned char LeerBumperIzquierdo()
{
  if (LeerPuertoALinea3() == 1) return APRETADO;
  return SIN_APRETAR;
}




/**************************************************************
 *                                                            *
 * LeerBumperDerecho                                          *
 * ----------------                                           *
 *                                                            *
 * Funcion que devuelve el estado del bumper derecho          *
 * (visto desde arriba, desde la rueda loca del skybot)       *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    APRETADO o SIN_APRETAR           *
 *                                                            *
 **************************************************************/
unsigned char LeerBumperDerecho()
{
  if (LeerPuertoALinea2() == 1) return APRETADO;
  return SIN_APRETAR;
}




/**************************************************************
 *                                                            *
 * LeerPuertoALinea1                                          *
 * ----------------                                           *
 *                                                            *
 * Funcion que lee el pin 1 del puerto A                      *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    1 / 0                            *
 *                                                            *
 **************************************************************/
unsigned char LeerPuertoALinea1()
{
  if ((PORTA & 0x01) != 0) return 1;
  return 0;
}




/**************************************************************
 *                                                            *
 * LeerPuertoALinea2                                          *
 * ----------------                                           *
 *                                                            *
 * Funcion que lee el pin 2 del puerto A                      *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    1 / 0                            *
 *                                                            *
 **************************************************************/
unsigned char LeerPuertoALinea2()
{
  if ((PORTA & 0x02) != 0) return 1;
  return 0;
}




/**************************************************************
 *                                                            *
 * LeerPuertoALinea3                                          *
 * ----------------                                           *
 *                                                            *
 * Funcion que lee el pin 3 del puerto A                      *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    1 / 0                            *
 *                                                            *
 **************************************************************/
unsigned char LeerPuertoALinea3()
{
  if ((PORTA & 0x04) != 0) return 1;
  return 0;
}




/**************************************************************
 *                                                            *
 * LeerPuertoALinea4                                          *
 * ----------------                                           *
 *                                                            *
 * Funcion que lee el pin 4 del puerto A                      *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    1 / 0                            *
 *                                                            *
 **************************************************************/
unsigned char LeerPuertoALinea4()
{
  if ((PORTA & 0x08) != 0) return 1;
  return 0;
}




//-- SECCION LED:
//-- IMPORTANTE!: El led comparte su "informacion" con el motor 1,
//-- de modo que al encender/apagar LED se está cambiando el valor
//-- que indica el sentido de giro de dicho motor.




/**************************************************************
 *                                                            *
 * EncenderLed                                                *
 * ----------------                                           *
 *                                                            *
 * Funcion que enciende el LED del skybot                     *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    Ninguno                          *
 *                                                            *
 **************************************************************/
void EncenderLed()
{
	PORTB |= LED;
}




/**************************************************************
 *                                                            *
 * ApagarLed                                                  *
 * ----------------                                           *
 *                                                            *
 * Funcion que apaga el LED del skybot                        *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    Ninguno                          *
 *                                                            *
 **************************************************************/
void ApagarLed()
{
	PORTB &= ~LED;
}




/**************************************************************
 *                                                            *
 * Led_esta_encendido                                         *
 * ----------------                                           *
 *                                                            *
 * Funcion que comprueba si el LED del skybot se encuentra    *
 * encendido                                                  *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    VERDADERO / FALSO                *
 *                                                            *
 **************************************************************/
unsigned char Led_esta_encendido()
{
	if (EstadoLed() == ENCENDIDO) return VERDADERO;
	return APAGADO;
}




/**************************************************************
 *                                                            *
 * Led_esta_apagado                                           *
 * ----------------                                           *
 *                                                            *
 * Funcion que comprueba si el LED del skybot se encuentra    *
 * apagado                                                    *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    VERDADERO / FALSO                *
 *                                                            *
 **************************************************************/
unsigned char Led_esta_apagado()
{
	if (EstadoLed() == APAGADO) return VERDADERO;
	return APAGADO;
}




/**************************************************************
 *                                                            *
 * EstadoLed                                                  *
 * ----------------                                           *
 *                                                            *
 * Funcion que devuelve el estado del LED del skybot          *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    ENCENDIDO / APAGADO              *
 *                                                            *
 **************************************************************/
unsigned char EstadoLed()
{
	if ( (PORTB&0x02)==0 ) return APAGADO;
	return ENCENDIDO;
}




/**************************************************************
 *                                                            *
 * CambiarLed                                                 *
 * ----------------                                           *
 *                                                            *
 * Funcion que invierte el estado del led de apagado a        *
 * encendido, y viceversa                                     *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    Ninguno                          *
 *                                                            *
 **************************************************************/
void CambiarLed()
{
	if (EstadoLed()==0) {
		EncenderLed();
	} 
	else {
		ApagarLed();
	}
}




//-- SECCION PULSADOR:
//-- IMPORTANTE!: El pulsador comparte su "informacion" con el sensor 1,
//-- de modo que al apretar/soltar el pulsador, el skybot cree que el
//-- sensor 1 esta emitiendo informacion de algun tipo.
//-- Por eso el pulsador sirve como "emulador" del sensor1.




/**************************************************************
 *                                                            *
 * LeerPulsador                                               *
 * ----------------                                           *
 *                                                            *
 * Funcion que lee el estado del pulsador del skybot          *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    PULSADO / SIN_PULSAR             *
 *                                                            *
 **************************************************************/
unsigned char LeerPulsador()
{
  if ((PORTB & SENSOR1) != 0) return SIN_PULSAR;
  return PULSADO;
}




/**************************************************************
 *                                                            *
 * Pulsador_esta_pulsado                                      *
 * ----------------                                           *
 *                                                            *
 * Funcion que comprueba si el pulsador del skybot esta       *
 * pulsado                                                    *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    VERDADERO / FALSO                *
 *                                                            *
 **************************************************************/
unsigned char Pulsador_esta_pulsado()
{
  if (LeerPulsador() == PULSADO) return VERDADERO;
  return FALSO;
}




/**************************************************************
 *                                                            *
 * Pulsador_no_esta_pulsado                                   *
 * ----------------                                           *
 *                                                            *
 * Funcion que comprueba si el pulsador del skybot no esta    *
 * pulsado                                                    *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    VERDADERO / FALSO                *
 *                                                            *
 **************************************************************/
unsigned char Pulsador_no_esta_pulsado()
{
  if (LeerPulsador() == SIN_PULSAR) return VERDADERO;
  return FALSO;
}




//-- SECCION LDR:
//-- IMPORTANTE!: La LDR hace uso de un coversor de señal se la skypic.
//-- Para leer el valor de la LDR, se ha de convertir a un valor entre
//-- 0 y 255, que representa el nivel de "oscuridad" que lee la LDR.
//-- La conversion tarda una fraccion de tiempo que hay que tener en
//-- cuenta si se quiere incluir en esquemas de temporizacion estrictos.
//-- La funcion lee el valor de la LDR y comprueba si supera un determinado
//-- valor umbral (pasado como argumento a la funcion).




/**************************************************************
 *                                                            *
 * LeerLDR                                                    *
 * ----------------                                           *
 *                                                            *
 * Funcion que configura la skypic para leer la informacion   *
 * suministrada por la LDR. La obtiene. Convierte la lectura  *
 * obtenida a un valor entre 0 y 255 y comprueba si dicho     *
 * valor sobrepasa el valor umbral suministrado.              *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:   valor entre 0 y 255               *
 *                                                            *
 **************************************************************/

unsigned char LeerLDR()
{
  //-- Configurar conversor analogico/digital
  //-- Entrada analogica: PA0 (Clema 2 de la CT293)
  //-- Resto de entradas del puerto A: digitales
  ADCON0 = 0x01;  // enciendo el conversor
  ADCON1 = 0x0E;  // configuro AN0 como entrada analogica, resto digital

  //-- Activar la conversion
  //-- Hay que hacerlo cada vez que se quiere realizar una conversion nueva
  ADCON0 |= 0x04;

  //-- Esperar a que se haga la conversion
  tmp = ADCON0 & 0x04;

  while ( (ADCON0 & 0x04) == 0);

  //--   El dato se encuentra en el registro ADRESH. Se corresponde
  //--   con un valor entre 0 y 255, y me indica el nivel de intensidad
  //--   de luz recibida por el sensor.
  //--   Debido al circuito de polarizacion de la SKY293 y al propio sensor
  //--   el umbral ha de situarse cerca del 200. Cuando se ilumina el sensor
  //--   el valor leido disminuye.
  tmp = ADRESH;
  return tmp;
}


