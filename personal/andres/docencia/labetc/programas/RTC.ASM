;/---------------------------------------------/
;/ Ejercicios - Practicas de ETC-II        UAM /
;/ Andres Prieto-Moreno            8-dic-2004  /
;/ ETC-II                                      /
;/                                             /
;/ Ejemplo de programacion 4                   /
;/ Programa RTC                                /
;  Descripcion:                                /
;/  Rota un caracter en la pantalla hasta que  /
;/  pulsamos una tecla. Usa las interrupciones /
;/  del RTC.                                   /
;/ Muestra:                                    /
;/  - Acceso directo a la pantalla             /
;/  - Detectar tecla pulsada                   /
;/  - Realizacion de pausa con el RTC          /
;/                                             /
;/---------------------------------------------/

; ETIQUETAS DEL PROGRAMA
VIDEO EQU 0B800H   ; Posicion de memoria donde empieza el modo 80x25

; SEGMENTO DE PILA

stacksg SEGMENT STACK "stack"
        DB 40H DUP (0)
stacksg ends

; SEGMENTO DE DATOS

datossg SEGMENT
        OFFSET_O   DW 0
        SEGMEN_O   DW 0
        TABLA      DB  02FH, 07CH, 05CH, 02DH
        CONT       DW 0
datossg ends

; CODIGO DEL PROGRAMA

codesg  SEGMENT
        assume  cs:codesg, DS:datossg, SS:stacksg, ES:datossg

;*****************************************
;* Programa princpal                     *
;*****************************************

rtc     proc far

        ; configuracion interna
        MOV  AX,datossg
        MOV  DS,AX
        MOV  ES,AX
        MOV  AX,stacksg
        MOV  SS,AX

        ; Configuracion inicial del teclado y RTC
        CALL vaciar_buffer
        CALL config_rtc
        CALL start_rtc

        ; Instalo el vector de interrupcion 70H  (pos 1C0H)
        CLI
        MOV  AX,0
        MOV  ES,AX
        ; guardo los valores iniciales
        MOV  AX, word ptr ES:[01C0H]
        MOV  OFFSET_O, AX
        MOV  AX, word ptr ES:[01C2H]
        MOV  SEGMEN_O, AX
        ; pongo los nuevos
        ; hago que apunte a la subrutina 'serv70_int'
        MOV  word ptr ES:[01C0H],offset serv70_int
        MOV  word ptr ES:[01C2H],cs
        STI

; El bucle principal espera a que  pulsemos una tecla
; para terminar
bucle:
        MOV  AH,0BH
        INT  21H
        CMP  AL,0
        JE   bucle   ; no hay tecla -> sigue

fin:
        ; desactivo la iterrupcion del RTC
        CALL stop_rtc
        CLI
        ; desactivo la interrupcion 70h
        MOV  AX,0
        MOV  ES,AX
        ; coloco los vectores originales
        MOV  AX, OFFSET_O
        MOV  word ptr ES:[01C0H], AX
        MOV  AX, SEGMEN_O
        MOV  word ptr ES:[01C2H], AX
        STI
        ; vacio el buffer del teclado
        CALL vaciar_buffer
        ; devuelvo el control al DOS
        MOV  AX, 4C00H
        INT  21H
rtc     endp


; Vacia el Buffer del teclado
vaciar_buffer:
        MOV  AH,0CH
        MOV  AL,0
        INT  21H
        ret

; ............................................
; . Funciones relacionadas  con el RTC       .
; ............................................

; Funcion que configura el periodo del RTC
config_rtc proc near
        PUSH ax

        CLI
        ; configuro PIC
        IN    AL,021H
        AND   AL, 0FBH
        OUT   021H, AL   ; Pongo a 0 bit 2 puerto 21H
        IN    AL,0A1H
        AND   AL, 0FEH
        OUT   0A1H, AL   ; Pongo a 0 bit 0 puerto A1H

        ; configuro la frecuencia
        MOV   AL, 0AH
        OUT   070H,AL
        MOV   AL,02FH   ; 0010-xxxx
        OUT   071H,AL

        STI
        POP AX
        RET
config_rtc endp

; Activa las interrupciones del RTC
start_rtc proc near
        PUSH AX
        CLI

        ; activo interrupcion PIE
        MOV   AL, 0BH
        OUT   070H,AL
        IN    AL,071H
        OR    AL,040H
        AND   AL,047H
        MOV   AH,AL
        MOV   AL,0BH
        OUT   070H,AL
        MOV   AL,AH
        OUT   071H,AL
        MOV   AL, 0CH   ; necesario para activar las interrupciones
        OUT   070H,AL
        IN    al,071H

        STI
        POP   AX
        RET
start_rtc endp

; Desactiva las interrupciones del RTC
stop_rtc proc near
        PUSH AX
        CLI
        ; desactivo interrupcion PIE
        MOV   AL, 0BH
        OUT   070H,AL
        IN    AL,071H
        AND   AL,0BFH
        MOV   AH,AL
        MOV   AL,0BH
        OUT   070H,AL
        MOV   AL, AH
        OUT   071H,AL
        MOV   AL, 0CH
        OUT   070H,AL
        IN    AL,071H

        STI
        POP   AX
        RET
stop_rtc endp

;........................................................................
;. Rutina de servicio de la interrupci¢n 1CH (pos en tabla 70H)         .
;........................................................................
serv70_int proc far
         CLI
         PUSH AX BX ES DS

         MOV  AX,datossg
         MOV  DS,AX

        ; compruebo que ha sido el PIE quien ha interrumpido
        MOV   AL, 0CH
        OUT   070H,AL
        IN    AL,071H
        AND   AL,040H
        JNZ  pi_int
        JMP  salir

pi_int:  ; codigo de mi rutina de interrupcion
         MOV  AX,VIDEO
         MOV  ES,AX      ; ES apunta a la memoria de video
         MOV  BX, CONT   ; BX contiene el estado del puntero a la tabla
         INC  BX
         CMP  BX,4     ; ¨hemos superado el final tabla ?
         JNE  sigue     ; NO -> apunta al carater que corresponda
         MOV  BX,0      ; SI -> apunta al primer caracter
; pinta el caracter en la esquina superior izquierda
sigue:   MOV  AL, TABLA[BX+0]
         MOV  byte ptr ES:[09EH],AL
         ; devuelve el control
         MOV  word ptr CONT,BX

salir:   ;  necesario para terminar correctamente la interrrupcion
         MOV  al, 020H   ; cargo EOI
         OUT  020H, al   ; mando EOI al PIC maestro
         OUT  0A0H, al   ; mando EOI al PIC esclavo

         POP  DS ES BX AX
         STI
         IRET
serv70_int endp


codesg  ends
end     rtc

