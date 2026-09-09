# **************************************************************************
#
# Fichero makefile.
#
# En sistemas Linux, use este fichero para compilar y obtener el fichero
# .hex necesario para programar su Skybot.
#
# Para compilar, ejecute "make"
# Para borrar ficheros creados durante compilacion, "make clean"
#
# --------------------------------------------------------------------------
# Licencia GPL. 
# --------------------------------------------------------------------------
# Autor : Javier Valiente <jvaliente@ifara.com>
#***************************************************************************

#-- Compilador
CC = sdcc

SDCCFLAGS = -mpic14 -p16f876a

#-- Modificar NAME1=main por NAME1=(nombre_del_fichero_c_creado)
#-- Ejemplo: Si el fichero se llama ejemplo1.c, NAME1=ejemplo1.c
NAME1=ejemplo9
LIBRERIA_AUX=libreria_skybot
LIBRERIA_TMR=delay0

all: $(NAME1).o $(LIBRERIA_AUX).o $(LIBRERIA_TMR).o
	@ echo "Sacando programa para PIC ..."
	@ sdcc $(SDCCFLAGS) -Wl-m -Wl-ainhx8m -o $(NAME1) $(NAME1).o $(LIBRERIA_AUX).o $(LIBRERIA_TMR).o

$(NAME1).o: $(NAME1).c
	@ echo "Compilando fichero fuente ..."
	@ sdcc $(SDCCFLAGS) -c $(NAME1).c

$(LIBRERIA_AUX).o: $(LIBRERIA_AUX).c $(LIBRERIA_AUX).h
	@ echo "Compilando libreria auxiliar ..."
	@ sdcc $(SDCCFLAGS) -c $(LIBRERIA_AUX).c

$(LIBRERIA_TMR).o: $(LIBRERIA_TMR).c $(LIBRERIA_TMR).h
	@ echo "Compilando libreria timer ..."
	@ sdcc $(SDCCFLAGS) -c $(LIBRERIA_TMR).c


#--------------------
#- LIMPIEZA
#--------------------
clean:
	@ echo "Borrando ficheros objeto ..."
	@ rm -f *.o *.hex *.lst *.p *.d *.asm *.cod *.map *.?~
