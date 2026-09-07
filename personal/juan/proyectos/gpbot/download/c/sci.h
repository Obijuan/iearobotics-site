/**************************************************/
/* sci.h  (c) Juan Gonzalez. Febrero 2004         */
/*------------------------------------------------*/
/* Prototipos y definiciones para el modulo sci.c */
/*------------------------------------------------*/
/* LICENCIA GPL                                   */
/**************************************************/


/***************************************/
/* Inicializar el puerto serie.        */
/* Velocidad: 9600 baudios             */
/***************************************/
void sci_init(void);

/*****************************************/
/* Leer un caracter por el puerto serie  */
/*****************************************/
unsigned char sci_leer_car(void);

/*******************************************/
/* Enviar un caracter por el puerto serie  */
/* ENTRADAS:                               */
/*     - Caracter a enviar                 */
/*******************************************/
void sci_enviar_car(const char c);

/*****************************************/
/* Enviar una cadena por el puerto serie */
/*****************************************/
void sci_enviar(const char *cad);
