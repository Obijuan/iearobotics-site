@echo off
REM ***********************************************************
REM    Creando Ejecutables. 
REM    En caso de error/warning, revisar codigo del programa
REM
REM    Para compilar un programa, configurar el programmers
REM    notepad, o teclear desde consola lo siguiente:
REM    crear_ejecutable nombrefichero_c ruta
REM    Donde:
REM       nombrefichero es el nombre del programa principal
REM       ruta es la ruta completa hasta el directorio actual
REM   Ejemplo:
REM       crear_ejecutable "ejemplo1" "C:\robotica\ejemplos\"
REM
REM   Importante: El fichero se escribe sin la terminacion ".c"
REM    
REM ***********************************************************
cd %2
sdcc -mpic14 -p16f876a -c %1.c
sdcc -mpic14 -p16f876a -c libreria_skybot.c
sdcc -mpic14 -p16f876a -c delay0.c
sdcc -mpic14 -p16f876a -o %1 %1.o libreria_skybot.o delay0.o

