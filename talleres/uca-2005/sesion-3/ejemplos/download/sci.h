/*************************************************************************** */
/* sci.h      Julio-2005                                                     */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/* Rutinas para manejo del puerto serie del PIC                              */
/* Comunicaciones a 9600 baudios (Configuracion 8N1)                         */
/*---------------------------------------------------------------------------*/
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

/****************************************************/
/* Configurar el puerto serie a N81 y 9600 Baudios  */
/****************************************************/
void sci_conf(void)
{
  SPBRG = 0x81;  //-- 9600 baudios (con cristal de 20MHz)
  TXSTA = 0x24;  //-- Configurar transmisor
  RCSTA = 0x90;  //-- Configurar receptor
  
}

/******************************************/
/* Recibir un caracter por el SCI         */
/*----------------------------------------*/
/* DEVUELVE:                              */
/*   -Caracter recibido                   */
/******************************************/
unsigned char sci_read(void)
{
  //-- Eserar hasta que llegue el dato
  while (!RCIF);
    
  return RCREG;
}

/*****************************************/
/* Transmitir un caracter por el SCI     */
/*---------------------------------------*/
/* ENTRADAS:                             */
/*   -car: Caracter a enviar             */
/*****************************************/
void sci_write(unsigned char car)
{
  //-- Esperar a que Flag de lista para transmitir se active
  while (!TXIF);
    
  //-- Hacer la transmision
  TXREG=car;
}

/*--------------------------------------------------*/
/* Enviar una cadena por el puerto serie            */
/* NOTA: con esta funcion solo se pueden enviar     */
/* cadenas constantes y NO un puntero a una cadena  */
/* Observar que se usa el atributo __code           */
/* No esta soluconado todavia en el SDCC 2.5.1      */
/* Ejemplo de uso:                                  */
/*    sci_cad("Hola");                              */
/*--------------------------------------------------*/
void sci_cad(__code unsigned char *cad)
{ 
  unsigned char i=0;
  
  while (cad[i]!=0) {
    sci_write(cad[i]);
    i++;
  }  
}

/*---------------------------------------------------------*/
/* Envio de una cadena por el puerto serie                 */
/* Con esta funcion si podemos enviar punteros a cadenas,  */
/* pero no cadenas constantes                              */
/* Ejemplo de uso:                                         */
/*     sci_cad2(mi_cadena);                                */
/*---------------------------------------------------------*/
void sci_cad2(unsigned char *cad)
{ 
  unsigned char i=0;
  
  while (cad[i]!=0) {
    sci_write(cad[i]);
    i++;
  }  
}
