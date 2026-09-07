/*************************************************/
/* delay.h (c) Juan Gonzalez. Marzo 2004         */
/*-----------------------------------------------*/
/* Definiciones y prototipos del modulo delay.c  */
/*-----------------------------------------------*/
/* LICENCIA GPL                                  */
/*************************************************/

/***************************************************/
/* Rutina de pausa, en unidades de 100ms           */
/*-------------------------------------------------*/
/* ENTRADAS:                                       */
/*   time: Numero de unidades de tiempo a esperar  */
/*         Cada unidad de tiempo es de 100ms       */
/***************************************************/
void delay_init(void);


/***************************************************/
/* Rutina de pausa, en unidades de 100ms           */
/*-------------------------------------------------*/
/* ENTRADAS:                                       */
/*   time: Numero de unidades de tiempo a esperar  */
/*         Cada unidad de tiempo es de 100ms       */
/***************************************************/
void delay(unsigned char time);
