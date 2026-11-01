# Ejemplo de fichero Makefile Sencillo


all: drvmio.com paral.exe

drvmio.com: drvmio.obj
  TLINK /t /v  drvmio.obj

paral.exe: paral.obj
	TLINK /V  paral.obj


.asm.obj: 
  TASM /zi $<

.obj.lib:
   TLIB $&.lib -+$<

clean:
    del *.obj
    del *.map
    del *.exe
    del *.lib
	del *.com