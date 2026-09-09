/*****************************************************************************/
/* libreria_skybot.h      Julio-2008                                         */
/*---------------------------------------------------------------------------*/
/* Libreria de firmas de las funciones auxiliares para el manejo del skybot  */
/*---------------------------------------------------------------------------*/
/* Este fichero esta pensado para ser incluido en el programa principal.     */
/* Antes de utilizar las funciones de movimiento del skybot,es indispensable */
/* llamar a la funcion ConfigurarSkybot().                                   */
/*---------------------------------------------------------------------------*/
/* Dependencias:                                                             */
/*                                                                           */
/* -> delay0            - Libreria de acceso al temporizador del pic 16f876a */
/* -> pic16f876a        - Libreria de acceso a los registros del pic 16f876a */
/* -> libreria_skybot.c - Fichero que contiene el codigo de las funciones de */
/*                        acceso al skybot                                   */
/*---------------------------------------------------------------------------*/
/*  Autor: Javier Valiente <javier.valiente@gmail.com>                       */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/



#ifndef _LIBRERIA_SKYBOT
#define _LIBRERIA_SKYBOT


#include <pic16f876a.h>
#include "delay0.h"

#define TRISB_MOTOR_IZQUIERDO 0x00000110b
#define TRISB_MOTOR_DERECHO 0x00011000b

//-- Definiciones para los motores. Estos valores define
//-- los movimientos del robot
#define   AVANZA     0x1C
#define   ATRAS      0x16
#define   IZQUIERDA  0x1E 
#define   DERECHA    0x14 
#define   STOP       0x00

#define LED 0x02

#define   SENSOR1  0x01
#define   SENSOR2  0x20
#define   SENSOR3  0x40
#define   SENSOR4  0x80


//-- Constantes de acceso a los infrarrojos
#define NEGRO 1
#define BLANCO 0

//-- Constantes de acceso a los bumpers
#define APRETADO 1
#define SIN_APRETAR 0

//-- Constantes de acceso al pulsador
#define PULSADO 1
#define SIN_PULSAR 0

//-- Constantes de acceso al led
#define ENCENDIDO 1
#define APAGADO 0


#define VERDADERO 1
#define FALSO 0


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
void ConfigurarSkybot();




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
void PausaTiempo(unsigned int segundos,unsigned int centesimas);




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
void Avanzar();




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
void GirarIzq();




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
void GirarDer();




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
void Retroceder();




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
void Parar();




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
unsigned char SensorIR_Izq_Lee_Negro();




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
unsigned char SensorIR_Der_Lee_Negro();




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
unsigned char SensorIR_Izq_Lee_Blanco();




/**************************************************************
 *                                                            *
 * SensorIR_Der_Lee_Blanco                                    *
 * ----------------                                           *
 *                                                            *
 * Funcion que comprueba si el sensor infrarrojo derecho esta *
 * leyendo blanco.                                            *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:    VERDADERO o FALSO                *
 *                                                            *
 **************************************************************/
unsigned char SensorIR_Der_Lee_Blanco();




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
unsigned char LeerInfrarrojos();




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
unsigned char LeerSensor1();




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
unsigned char LeerSensor2();




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
unsigned char LeerSensor3();




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
unsigned char LeerSensor4();




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
unsigned char Bumper_Izq_esta_apretado();




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
unsigned char Bumper_Der_esta_apretado();




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
unsigned char LeerBumperIzquierdo();




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
unsigned char LeerBumperDerecho();




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
unsigned char LeerPuertoALinea1();




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
unsigned char LeerPuertoALinea2();




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
unsigned char LeerPuertoALinea3();




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
unsigned char LeerPuertoALinea4();




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
void EncenderLed();




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
void ApagarLed();




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
unsigned char Led_esta_encendido();




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
unsigned char Led_esta_apagado();




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
unsigned char EstadoLed();




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
void CambiarLed();




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
unsigned char LeerPulsador();




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
unsigned char Pulsador_esta_pulsado();




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
unsigned char Pulsador_no_esta_pulsado();




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
 * obtenida a un valor entre 0 y 255 y lo devuelve            *
 *                                                            *
 * Parametros de la funcion: Ninguno                          *
 * Retorno de la funcion:   valor entre 0 y 255               *
 *                                                            *
 **************************************************************/
unsigned char LeerLDR();

#endif
