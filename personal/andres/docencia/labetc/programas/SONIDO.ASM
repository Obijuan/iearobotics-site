;/---------------------------------------------/
;/ Practicas de ETC-II                     UAM /
;/ Andres Prieto-Moreno            8-dic-2004  /
;/ ETC-II                                      /
;/                                             /
;/ Ejemplo de programacion 2                   /
;/ Programa Sonido                             /
;  Descripcion:                                /
;/  Emite un sonido por el altavoz interno     /
;/  Usa el timer2 y para al pulsar  una tecla. /
;/ Muestra:                                    /
;/  - Emision de sonidos con Timer2            /
;/  - Detectar tecla pulsada                   /
;/                                             /
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

;*****************************************
;* Programa princpal                     *
;*****************************************

sonido  proc far
        ; Configuracion inicial
        CALL vaciar_buffer
        CALL son_con
        CALL son_on

; El bucle principal espera a que  pulsemos una tecla
; para terminar

bucle:   
        MOV  AH,0BH
        INT  21H
        CMP  AL,0
        JE   bucle   ; no hay tecla -> sigue

fin:
        ; vacio el buffer del teclado
        CALL vaciar_buffer
        CALL son_off
        ; devuelvo el control al DOS
        MOV  AX, 4C00H
        INT  21H
sonido  endp

; Vacia el Buffer del teclado
; La rutina la utilizamos ates de detectar la pulsacion
; de una tecla y tambi‚n al salir del programa para no
; interferir con otros programas al salir al DOS
vaciar_buffer:
        MOV  AH,0CH
        MOV  AL,0
        INT  21H
        ret

; Funcion que configura el periodo del timer
; en 55mseg -> Cargar el valor 0FFFFH
; cambiando el valor cambia la frecuencia del altavoz

son_con proc near
        push ax
        mov  cx, 0FFFFH  ; Lo hemos dejado fijo
        mov  al,182
        out  043H,al     ; acceso a los registros del temporizador
        mov  al  , cl
        out  042H, al    ; enviamos byte inferior
        mov  al  , ch
        out  042H, al    ; enviamos byte superior
        pop   ax
        ret
son_con endp

; El Registro 61H es del sistema y el bit0 hace que la onda del TIMER2 [0..2]
; acceda al altavoz.  Por otro lado el bit1 actica el altavoz
son_on proc near
        push ax
        in   al,061H
        or   al,03H
        out  061H,al
        pop  ax
        ret
son_on  endp

; El Registro 61H es del sistema y el bit0 hace que la onda del TIMER2 [0..2]
; acceda al altavoz.  Por otro lado el bit1 activa el altavoz
son_off proc near
        push ax
        in   al,97
        and  al,0FCH
        out  97,al
        pop  ax
        ret
son_off  endp


codesg  ends
end     sonido

