// Estructura FILA 1
// Campus PArty Iberoamérica 2008


#include "libreria_skybot.h"
#include "libRGB.h"

#define TIEMPO 5

unsigned char i;


// Modificaciones  a realizar para representar las 22 banderas

void Secuencia_Colores() {
	
	// bandera 1
	RGB(0xff,0xff,0x00,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 2
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 3
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 4
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 5
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 6
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 7
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 8
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 9
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 10
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 11
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 12
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 13
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 14
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 15
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 16
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 17
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 18
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 19
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 20
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 21
	RGB(0xff,0xff,0xff,0); 
	PausaTiempo(TIEMPO,0);
	
	// bandera 22
	RGB(0xff,0xff,0xff,0); 
		
	for (;;);  // EL programa termina aquí.
}


// ---------- Programa principal ---------
// --------------- NO TOCAR  -------------

void main() {
	
	RGB_init();          // arranco la placa RGB
	ConfigurarSkybot();  // configuro el SkyBot
	
	while (!SensorIR_Izq_Lee_Negro() && !SensorIR_Der_Lee_Negro() ) {
		Parar();
	}
		
	while(1)
	{
		 
		if (SensorIR_Izq_Lee_Negro() && SensorIR_Der_Lee_Negro() ) {
			Avanzar();           // Avanza
		}
		else if (!SensorIR_Izq_Lee_Negro() && !SensorIR_Der_Lee_Negro() ) {
			Parar();
			while ((i<200) && !SensorIR_Izq_Lee_Negro() && !SensorIR_Der_Lee_Negro() ) {
				i=i+1;
				delay0(1);
			}
			if (i>=199) {
				PausaTiempo(3,0);   // Fila 1
				Secuencia_Colores();
			}
			i=0;
		}
		else if ( !SensorIR_Izq_Lee_Negro() ) {
			GirarIzq();
		} 
		else {
			GirarDer();
		}
		
	}
}

