;/---------------------------------------------/
;/ Practicas de ETC-II                     UAM /
;/ Andres Prieto-Moreno           13-ene-2005  /
;/ ETC-II                                      /
;/                                             /
;/ Ejemplo de programacion 1                   /
;/ Programa EFECTO                             /
;  Descripcion:                                /
;/  Rota un caracter en la pantalla hasta que  /
;/  pulsamos una tecla                         /
;/ Muestra:                                    /
;/  - Acceso directo a la pantalla             /
;/  - Detectar tecla pulsada                   /
;/  - Realizacion de pausa activa              /
;/                                             /
;/---------------------------------------------/
;/ Este codigo esta probado en una CPU386 por  /
;/ lo que en ordenadores mas modernos sera     /
;/ necesario aumentar el tiempo de espera para /
;/ ver bien el efecto en pantalla. Por este    /
;/ motivo para hacer pausas es mejor utilizar  /
;/ otro procedimiento, comomedir el tiempo con /
;/ el timer o el RTC.                          /
;/---------------------------------------------/

; ETIQUETAS DEL PROGRAMA
VIDEO EQU 0B800H   ; Posicion de memoria donde empieza el modo 80x25

; SEGMENTO DE PILA

stacksg SEGMENT STACK "STACK"
        DB 40H DUP (0)
stacksg ends


; CODIGO DEL PROGRAMA

codesg  SEGMENT
        assume  cs:codesg, DS:codesg, SS:codesg, ES:codesg

; DATOS DEL PROGRAMA
; Efecto de rotacion: | / - \
CAR DB 02FH, 07CH, 05CH, 02DH

;*****************************************
;* Programa princpal                     *
;*****************************************

efecto  proc far
        ; Configuracion inicial
        MOV  AX,VIDEO
        MOV  ES,AX         ; ES apunta a la memoria de video
        MOV  BX,0          ; BX apunta al primer dato de la tabla
        CALL vaciar_buffer ; vaciamos el buffer del teclado

; El bucle principal hace lo siguiente
; Selecciona el caracter de la tabla circular que vamos a pintar
; Pinta el caracter
; Espera un tiempo
; Mira por si hemos pulsado una tecla para salir del programa
; Si no hemos pulsado comienza de nuevo

bucle:
        INC  BX
        CMP  BX,4   ; ¨hemos superado el final tabla ?
        JNE  sigue  ; NO -> apunta al carater que corresponda
        MOV  BX,0   ; SI -> apunta al primer caracter
sigue:
        ; pinta el caracter en la esquina superior izquierda
        MOV  AL, CS:CAR[BX+0]
        MOV  byte ptr ES:[09EH],AL

        ; hace una peque¤a pausa
        MOV  CX,25  ; espera 250 mseg
        CALL pausa

        ; mira si se ha pulsado una tecla para salir del bucle
        MOV  AH,0BH
        INT  21H
        CMP  AL,0
        JE   bucle   ; no hay tecla -> sigue

fin:    ; devuelve el control al DOS
        CALL vaciar_buffer
        MOV  AX, 4C00H
        INT  21H
efecto  endp

; Vacia el Buffer del teclado
; La rutina la utilizamos ates de detectar la pulsacion
; de una tecla y tambi‚n al salir del programa para no
; interferir con otros programas al salir al DOS
vaciar_buffer:
        MOV  AH,0CH
        MOV  AL,0
        INT  21H
        ret

; Espera 10*CX mseg
; Esta rutina hace ua pausa por el procedimiento de espera activa
; es decir, el programa se queda en el bucle hasta que termine la
; pausa. Si llega alguna interrupci¢n se atender  salvo que las
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
end     efecto

