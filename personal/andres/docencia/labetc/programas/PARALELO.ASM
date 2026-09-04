;/---------------------------------------------/
;/ Practicas de ETC-II                    UAM  /
;/ Andres Prieto-Moreno           11-ene-2005  /
;/ ETC-II                                      /
;/                                             /
;/ Ejemplo de programacion 5                   /
;/ Programa PARALELO                           /
;  Descripcion:                                /
;/  Hace parpadear un LED conectado al C7 del  /
;/ analizador logico, o lo que es lo mismo     /
;/ conectado al bit D6 del puerto paralelo     /
;/ Termina al pulsar una tecla.                /
;/                                             /
;/ Muestra:                                    /
;/  - Acceso Puerto Paralelo                   /
;/  - Detectar tecla pulsada                   /
;/  - Realizacion de pausa activa              /
;/                                             /
;/---------------------------------------------/
;/ La pausa activa puede verse reducida al     /
;/ ejecutar este codigo en ordenadores mas     /
;/ rapidos (se ha probado en un 386). Por eso  /
;/ se recomienda usar el timer o el RTC para   /
;/ hacer la pausa.                             /
;/---------------------------------------------/

; SEGMENTO DE PILA

stacksg SEGMENT STACK "STACK"
        DB 40H DUP (0)
stacksg ends


; CODIGO DEL PROGRAMA

codesg  SEGMENT
        assume  cs:codesg, DS:codesg, SS:codesg, ES:codesg

DIR_BASE DW 0

;*****************************************
;* Programa princpal                     *
;*****************************************

paralelo  proc far

; Configuracion inicial

        CALL vaciar_buffer ; vaciamos el buffer del teclado

; El bucle principal hace lo siguiente
; Cambia el estado del LED
; Espera un tiempo
; Mira por si hemos pulsado una tecla para salir del programa
; Si no hemos pulsado comienza de nuevo

        ; saco la direccion del LPT1 (miro en la BIOS)
        MOV  AX, 0040H
        MOV  ES, AX
        MOV  DX, ES:[08H] ; direccion Puerto Paralelo 1
        MOV  DIR_BASE,DX

bucle:
        ; ponemos el dato en el registro de salida
        XOR  BL,0FFH         ; cambio valor de todos los bits
        MOV  AL,BL	     ; para que de igual donde poner el LED
        CALL enviar_dato

        MOV  CX,100   ; espera 1000 mseg
        CALL pausa

        ; mira si se ha pulsado una tecla para salir del bucle
tecla:  MOV  AH,0BH
        INT  21H
        CMP  AL,0
        JE   bucle   ; no hay tecla -> sigue

        ; desactiva el LED
        MOV  AL,0
        CALL enviar_dato

fin:    ; devuelve el control al DOS
        CALL vaciar_buffer
        MOV  AX, 4C00H
        INT  21H
paralelo endp

; enviar dato por el puerto paralelo
; Parametro de entrada AL->dato a enviar
enviar_dato:
        PUSH DX
        MOV  DX,DIR_BASE
        OUT  DX,AL        ; pongo el dato en el registro de datos

        ; activamos el Strobe y el AutoFD
        INC  DX
        INC  DX
        MOV  AL,3
        OUT  DX,AL
        ; desactivamos el Strobe y el AutoFD
        MOV  AL,0
        OUT  DX,AL

        POP  DX
        RET



; Vacia el Buffer del teclado
; La rutina la utilizamos ates de detectar la pulsacion
; de una tecla y tambien al salir del programa para no
; interferir con otros programas al salir al DOS
vaciar_buffer:
        MOV  AH,0CH
        MOV  AL,0
        INT  21H
        ret

; Espera 10*CX mseg
; Esta rutina hace una pausa por el procedimiento de espera activa
; es decir, el programa se queda en el bucle hasta que termine la
; pausa. Si llega alguna interrupcion se atendera salvo que las
; hayamos deshabilitado.
; Entrada: EN CX ponemos el numero de repeticiones de 10mseg
pausa:
        PUSH  CX
        MOV   CX,03611H
        ; mini bucle que espera 10mseg
pausa100:
        LOOP  pausa100
        POP   CX
        LOOP  pausa
        RET

codesg  ends
end     paralelo

