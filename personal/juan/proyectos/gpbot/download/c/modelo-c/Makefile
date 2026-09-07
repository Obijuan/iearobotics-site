# **************************************************************************
# Fichero makefile.
# --------------------------------------------------------------------------
# Licencia GPL. Juan Gonzalez Gomez
# --------------------------------------------------------------------------
#
#***************************************************************************

#-- Compilador
CC = sdcc
CFLAGS = -mhc08 --stack-loc 0x023f

#-- Nombre del programa
NAME1=modelo

all: $(NAME1).S19 

clean:
	  rm -f *.o *.rel *.S19 *.sym *.lst *.map *.lnk	*.rst *.mem *.asm *~

#-----------------------
# REGLAS GENERICAS
#-----------------------
#-- Obtencion de los ficheros objeto
%.rel : %.c ; $(CC) -c $(CFLAGS) $<

#-- Obtencion de los ficheros ejecutables
%.S19 : %.rel; $(CC) -o $@ $(CFLAGS) $<
