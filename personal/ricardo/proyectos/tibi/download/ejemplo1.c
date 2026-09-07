#include <asm/io.h>
#include <unistd.h>
#include <stdio.h>

#define PUERTO 0x31c

int main(void) {
	unsigned char dato;
	
	/*
	 * Se obtiene acceso al puerto 0x31c
	 */
	 
	if (ioperm(PUERTO, 1, 1) < 0) {
		perror("ioperm");
		exit(-1);
	}
	
	/*
	 * Se realiza una lectura
	 */
	
	dato = inb(PUERTO);
	printf("El dato leido es: %d\n", dato); 
	 
	/*
	 * Se escribe un dato en el puerto
	 */
	
	dato = 0xA5;
	outb(dato, PUERTO);
}
	  