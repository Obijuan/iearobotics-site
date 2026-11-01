// Ejemplo de programa en C
// Andres Prieto-Moreno
// UAM - ETCII - 2008

#include <stdio.h>
#include "lib.h"

void main() {
	unsigned char ch;
	unsigned int  valor;

	printf("1. Lee el STATUS del Driver\n");
	printf("2. Lee posicion 2 del Driver\n");
	printf("3. Escribe posicion 2 del Driver\n");
	printf("0. Salir\n");
	
	ch=getchar();
	while (ch!='0') {
		switch (ch) {
			case '1': 	valor=llamada_status_driver();
						printf("Status= %x\n", valor);
						break;
						
			case '2':   valor=llamada_read_driver(2);
						printf("Posicion 2 = %c : 0x%x \n",valor,valor);
						break;
						
			case '3':   fflush(0);
						ch=getchar();  
						llamada_write_driver(2,ch);
						printf("Guardado valor '%c' en pos=2\n",ch);
						break;
						
			default:	printf("Tecla invalida. '0' para salir\n");
						break;
		}
		fflush(0);
		ch=getchar();
	}
	printf("Programa terminado.\n");
}
	