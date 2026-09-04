/********************************************************/
/* PROYECTO LABOBOT.  Juan Gonzalez.  Febrero 2002      */
/* LICENCIA GPL.                                        */
/********************************************************/

#include <stdio.h>
#include "work.h"

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <bsp.h>
#include <m68360.h>
#include <rtems/error.h>
#include <rtems/rtems_bsdnet.h>
#include <rtems/tftp.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <nc360/md.h>
#include <nc360/cpld.h>
#include <nc360/mubus.h>
#include <nc360/clock.h>
#include <nc360/flash.h>
#include <nc360/interrupts.h>
#include <nc360/identification.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/timeb.h>
#include <time.h>
#include <netdb.h>
#include <math.h>
#include <stdio.h>
#include <sys/time.h>

#include "labomat3.h"
#include "rlib.h"
#include "usuals.h"

/********************************************************************/
/* MODULO SERVO. Rutinas de posicionamiento de 4 servos conectados  */
/* a la tarjeta PLM-3003 enchufada al conector J27 de la LABOMAT    */
/********************************************************************/

/*------------------*/
/* DEFINICIONES     */
/*------------------*/

/* Direccion de acceso a la FPGA, donde esta mapeado  */
/* el registro de posicion de los servos, de 32 bits  */
#define FPGA 0x16000000

/* Anchura minima, media y maxima de la señal PWM, que se corresponde con */
/* las posiciones -90, 0 y 90 grados del servo                            */
#define TIC_MIN    0x20
#define TIC_MAX    0xEC

/*--------------------------------*/
/* VARIABLES INTERNAS DEL MODULO  */
/*--------------------------------*/

/* Copia del registro de posicion */
static Card32 reg_pos_copy=0;

/* Puntero al registro de posicion en la FPGA */
static volatile Card32 *reg_pos=(Card32 *)FPGA;

/*----------------------------*/
/* FUNCIONES DE INTERFAZ      */
/*----------------------------*/

void servo_posicionar_all(int pos1, int pos2, int pos3, int pos4)
/********************************************************************/
/* Posicionar los 4 servos. Las posiciones de los servos vienen     */
/* en grados sexagesimales [-90,90]                                 */
/********************************************************************/
{
  /* Posiciones en tics de reloj */
  Card8 pos1_tic;
  Card8 pos2_tic;
  Card8 pos3_tic;
  Card8 pos4_tic;

  /* Realizar la conversion de grados a tics */
  pos1_tic=((TIC_MAX - TIC_MIN)*(pos1+90))/180 + TIC_MIN;
  pos2_tic=((TIC_MAX - TIC_MIN)*(pos2+90))/180 + TIC_MIN;
  pos3_tic=((TIC_MAX - TIC_MIN)*(pos3+90))/180 + TIC_MIN;
  pos4_tic=((TIC_MAX - TIC_MIN)*(pos4+90))/180 + TIC_MIN;

  /* Actualizar copia del registro de posicion */
  reg_pos_copy = (pos4_tic << 24) | (pos3_tic << 16) | (pos2_tic << 8) | pos1_tic;

  /* Enviar posiciones al registro de posicion "verdadero" */
  *reg_pos=reg_pos_copy;
}

void servo_posicionar(int ns, int pos)
/************************************************/
/* Posicionar solo un servo y dejar los demas   */
/* en la misma posicion en la que estaban       */
/* ENTRADAS:                                    */
/*   ns : Numero del servo a posicionar [1-4]   */
/*   pos: Posicion en grados [-90,90]           */
/************************************************/
{
  Card8 pos_tic;

  /* Numero de servo incorrecto. No se posiciona */
  if (ns<1 || ns>4) return;
  ns--; /* Internamente se usa la numeracion 0-3 para los servos */

  /* Obtener la nueva posicion */
  pos_tic=((TIC_MAX - TIC_MIN)*(pos+90))/180 + TIC_MIN;
  printf ("Posicion %d: \n",pos);
  printf ("Posicion en tics: %x\n",pos_tic);

  /* Actualizar la copia del registro de posicion */
  switch(ns) {
    case 0: reg_pos_copy=(reg_pos_copy & ~0x000000FF);
            reg_pos_copy=(reg_pos_copy | pos_tic);
            break;
    case 1: reg_pos_copy=(reg_pos_copy & ~0x0000FF00);
            reg_pos_copy=(reg_pos_copy | (pos_tic<<8));
            break;
    case 2: reg_pos_copy=(reg_pos_copy & ~0x00FF0000);
            reg_pos_copy=(reg_pos_copy | (pos_tic<<16));
            break;
    case 3: reg_pos_copy=(reg_pos_copy & ~0xFF000000);
            reg_pos_copy=(reg_pos_copy | (pos_tic<<24));
            break;
  }

  /* Enviar posiciones al registro de posicion "verdadero" */
  *reg_pos=reg_pos_copy;
}

/*----------------------------*/
/* FUNCIONES PRIVADAS         */
/*----------------------------*/



/**********************************************/
/* PROGRAMA DE PRUEBA PARA EL MODULO SERVO    */
/**********************************************/
void play_sec1()
/*******************************************/
/* Reproducir una secuencia de movimiento  */
/*******************************************/
{
  int nv=5;           /* Numero de vectores de posicion       */
  int sec1[][4]= {    /* Vectores de posicion de la secuencia */
    {-45,45,-45,-45},
    {-45,-45,-45,45},
    {45,-45,45,45},
    {45,45,45,-45},
    {0,0,0,0}
  };
  int i;

  for (i=0; i<nv; i++) {
    /* Posicionar */
    servo_posicionar_all(sec1[i][0],sec1[i][1],sec1[i][2],sec1[i][3]);

    /* Realizar una pausa */
    sleep(1);

  }

}

void play_sec2()
/*******************************************/
/* Reproducir una secuencia de movimiento  */
/*******************************************/
{
  int nv=3;           /* Numero de vectores de posicion       */
  int sec[][4]= {    /* Vectores de posicion de la secuencia */
    {-90,-90,-90,-90},
    {90,90,90,90},
    {0,0,0,0}
  };
  int i;

  for (i=0; i<nv; i++) {
    /* Posicionar */
    servo_posicionar_all(sec[i][0],sec[i][1],sec[i][2],sec[i][3]);

    /* Realizar una pausa */
    sleep(1);

  }

}

void prueba1()
{
  char   buffer[100];
  int    posicion;

  while (1) {
    printf ("Servo1[-90,90]: ");
    read_line(buffer,sizeof(buffer));
    sscanf(buffer,"%d",&posicion);
    servo_posicionar_all(posicion,posicion,posicion,posicion);

    printf ("  Copia Reg. Posicion: %x \n",reg_pos_copy);
  }
}

void main_work(void)
{
  char   buffer[100];
  int    opcion;

  /* Inicializar las posiciones de los servos */
  servo_posicionar_all(0,0,0,0);

  while (1) {
    printf ("introduzca secuencia (1-2):\n");
    read_line(buffer,sizeof(buffer));
    sscanf(buffer,"%d",&opcion);
    switch(opcion) {
      case 1 : play_sec1();
               break;
      case 2 : play_sec2();
    }
  }

  return;
}




