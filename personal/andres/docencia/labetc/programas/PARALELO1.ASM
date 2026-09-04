;/---------------------------------------------/
;/ Practicas de ETC-II                    UAM  /
;/ Andres Prieto-Moreno           11-ene-2005  /
;/ ETC-II                                      /
;/                                             /
;/ Ejemplo de programacion 6                   /
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
;/  - Realizacion de pausa con RTC             /
;/                                             /
;/---------------------------------------------/

; SEGMENTO DE PILA

stacksg SEGMENT STACK "STACK"
        DB 40H DUP (0)
stacksg ends

; SEGMENTO DE DATOS
datossg SEGMENT
        OFFSET_O  DW 0
        SEGMEN_O  DW 0
        DIR_BASE  DW 0
        DATO      DW 0
datossg ends



; CODIGO DEL PROGRAMA

codesg  SEGMENT
        assume  cs:codesg, DS:datossg, SS:codesg, ES:datossg

;*****************************************
;* Programa princpal                     *
;*****************************************

paralelo  proc far

        ; Configuracion inicial

        MOV  AX, datossg
        MOV  DS, AX
        MOV  ES, AX
        MOV  AX, stacksg
        MOV  SS, AX


        CALL vaciar_buffer ; vaciamos el buffer del teclado
        CALL config_rtc
        CALL start_rtc

        ; Instalo el vector de interrupcion 70H (pos 1C0H)
        CLI
        MOV  AX, 0
        MOV  ES, AX
        ; guardo los valores iniciales
        MOV  AX, word ptr ES:[01C0H]
        MOV  OFFSET_O, AX
        MOV  AX, word ptr ES:[01C2H]
        MOV  SEGMEN_O, AX
        ; pongo los nuevos
        ; hago que apunte a la rutina 'ser70_int'
        MOV word ptr ES:[01C0H], offset serv70_int
        MOV word ptr ES:[01C2H], cs

        ; saco la direccion del LPT1 (miro en la BIOS)
        MOV  AX, 0040H
        MOV  ES, AX
        MOV  DX, ES:[08H] ; direccion Puerto Paralelo 1
        MOV  DIR_BASE,DX


; El bucle principal hace lo siguiente
; Mira por si hemos pulsado una tecla para salir del programa


bucle:
        ; mira si se ha pulsado una tecla para salir del bucle
tecla:  MOV  AH,0BH
        INT  21H
        CMP  AL,0
        JE   bucle   ; no hay tecla -> sigue

fin:    ; desactiva el LED
        MOV  AL,0
        CALL enviar_dato

        ; desactivo la interrupcion
        CALL stop_rtc
        CLI
        MOV  AX, 0
        MOV  ES, AX
        MOV  AX, OFFSET_O
        MOV  word ptr ES:[01C0H], AX
        MOV  AX, SEGMEN_O
        MOV  word ptr ES:[01C2H], AX
        STI

        ; vacio buffer teclado
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
; de una tecla y tambi‚n al salir del programa para no
; interferir con otros programas al salir al DOS
vaciar_buffer:
        MOV  AH,0CH
        MOV  AL,0
        INT  21H
        ret

; Configuramos el RTC
config_rtc proc near
        PUSH  AX

        CLI
        ; configuro interrupciones del PIC
        IN  AL,   021H
        AND AL,   0FBH
        OUT 021H, AL
        IN  AL,   0A1H
        AND AL,   0FEH
        OUT 0A1H, AL

        ; configuro frecuencia
        MOV AL,   0AH
        OUT 070H, AL
        MOV AL  , 02DH   ; ----xxxx en X indico periodo
        OUT 071H, AL

        STI
        POP AX
        RET
config_rtc endp

; activa las interrupciones del RTC
start_rtc proc near
        PUSH  AX
        CLI

        ; activo la interrupcion PIE
        MOV  AL, 0BH
        OUT  070H, AL
        IN   AL, 071H
        OR   AL, 040H
        AND  AL, 047H
        MOV  AH, AL
        MOV  AL, 0BH
        OUT  70H, AL
        MOV  AL, AH
        OUT  71H, AL
        MOV  AL, 0CH  ; necesario para activar interrupcion
        OUT  070H,AL
        IN   AL, 071H

        STI
        POP  AX
        RET

start_rtc  endp

; desactiva las interrupciones del RTC
stop_rtc proc near
        PUSH   AX
        CLI

        ; desactivo interrupciones del PIE
        MOV  AL, 0BH
        OUT  070H, AL
        IN   AL, 071H
        AND  AL, 0BFH
        MOV  AH, AL
        MOV  AL, 0BH
        OUT  70H, AL
        MOV  AL, AH
        OUT  71H, AL
        MOV  AL, 0CH
        OUT  070H,AL
        IN   AL, 071H

        STI
        POP  AX
        RET
stop_rtc endp

; Rutina de atencion a la interrupcion
serv70_int proc far
        CLI
        PUSH  AX BX ES DS

        MOV   AX, datossg
        MOV   DS, AX

        ; comprueba que ha sido el PIE quien ha interrumpido
        MOV  AL, 0CH
        OUT  070H, AL
        IN   AL, 071H
        AND  AL, 040H
        JNZ  pi_int
        JMP  salir

pi_int:  ; codigo de mi rutina de interrupcion

        MOV  BX, DATO
        XOR  BL,0FFH         ; cambio todas las salidas para que de
        MOV  AL,BL           ; igual donde pongamos el LED
        CALL enviar_dato
        MOV  DATO, BX



salir:  ; necesario para terminar correctamente la interrupcion
        MOV  AL, 020H
        OUT  020H, AL
        OUT  0A0H, AL

        POP  DS ES BX AX
        STI
        IRET
serv70_int endp



codesg  ends
end     paralelo


