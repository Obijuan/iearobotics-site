# Ejemplo de fichero Makefile Sencillo

driver.exe: driver.obj 
  TLINK /V  driver.obj, driver

driver.obj: driver.asm
  TASM /ZI driver.asm

clean:
	del driver.obj 
	del driver.map
