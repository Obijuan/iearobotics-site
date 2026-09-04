;/---------------------------------------------/
;/ Practicas de ETC-II                    UAM  /
;/ Andres Prieto-Moreno           11-ene-2005  /
;/ ETC-II                                      /
;/                                             /
;/ Ejemplo de programacion 7                   /
;/ Programa PARALELO II                        /
;/ Descripcion:                                /
;/  Enciende el LED conectado en C7 (bit D6)   /
;/ cuando detecta una entrada en C7 (bit D6)   /
;/                                             /
;/ Muestra:                                    /
;/  - Lectura Puerto Paralelo                  /
;/  - Detectar tecla pulsada                   /
;/  - Realizacion de pausa activa              /
;/                                             /
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
        CALL leer_dato   ; leemos el byte del puerto paralelo
        AND  AL,40H      ; me fijo en el bit7
        JZ  ledon        ; si no es cero -> enciende led
        MOV  AL,0
        CALL enviar_dato ; apago el LED
        JMP  tecla
ledon:  MOV  AL,0ffH
        CALL enviar_dato

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

; leer dato por el puerto paralelo
; Parametro de salida AL <= dato leido
leer_dato:
        PUSH DX

        MOV  DX, DIR_BASE

        ; activamos el buffer triestado y AutoFeed
        INC  DX
        INC  DX
        MOV  AL,22H
        OUT  DX,AL         ; esto esta bien
        DEC  DX
        DEC  DX
        IN   AL,DX         ; leo el dato
        ; desactivamos el buffer triestado y el Autofeed
        PUSH AX
        INC  DX
        INC  DX
        MOV  AL,0
        OUT  DX,AL

        POP  AX
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

codesg  ends
end     paralelo

