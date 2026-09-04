;/---------------------------------------------/
;/ Ejemplos -  Practicas de ETC-II         UAM /
;/ Andres Prieto-Moreno            8-dic-2004  /
;/ ETC-II                                      /
;/                                             /
;/ Ejemplo de programacion 3                   /
;/ Programa Timer                              /
;  Descripcion:                                /
;/  Rota un caracter en la pantalla hasta que  /
;/  pulsamos una tecla. Usa las interrupciones /
;/  del Timer.                                 /
;/ Muestra:                                    /
;/  - Acceso directo a la pantalla             /
;/  - Detectar tecla pulsada                   /
;/  - Realizacion de pausa con el Timer        /
;/                                             /
;/---------------------------------------------/

; ETIQUETAS DEL PROGRAMA
VIDEO EQU 0B800H   ; Posicion de memoria donde empieza el modo 80x25

; SEGMENTO DE PILA

stacksg SEGMENT STACK "stack"
        DB 40H DUP (0)
stacksg ends

; SEGMENTO DE DATOS

datossg SEGMENT    PARA
        OFFSET_O   DW 0
        SEGMEN_O   DW 0
        TABLA      DB  02FH, 07CH, 05CH, 02DH
        CONT       DW 0
        N_TICS     DW 0
datossg ends

; CODIGO DEL PROGRAMA

codesg  SEGMENT PARA PUBLIC
        assume  cs:codesg, ds:datossg, ss:stacksg, es:datossg

;*****************************************
;* Programa princpal                     *
;*****************************************

timer   proc far
        mov  ax,datossg
        mov  ds,ax
        mov  es,ax

        mov  ax,stacksg
        mov  ss,ax

        ; Configuracion inicial
        CALL vaciar_buffer
        CALL config_timer

        ; Instalo el vector de interrupcion 1CH
        CLI
        MOV  ax,0
        MOV  es,ax
        ; guardo los valores originales de la int 1CH (pos 70H)
        MOV  AX, word ptr es:[070H]
        MOV  OFFSET_O, AX
        MOV  ax, word ptr es:[072H]
        MOV  SEGMEN_O, AX
        ; pongo los nuevos
        ; hago que apunte a la subrutina 'serv_int'
        MOV  word ptr es:[070H],offset serv_int
        MOV  word ptr es:[072H],cs
        STI

; El bucle principal espera a que  pulsemos una tecla
; para terminar

bucle:   
        MOV  AH,0BH
        INT  21H
        CMP  AL,0
        JE   bucle   ; no hay tecla -> sigue

fin:
        ; desactivo la interrupcion 1ch
        CLI
        MOV  ax,0
        MOV  es,ax
        MOV  ax, OFFSET_O
        MOV  word ptr es:[070H], ax
        MOV  ax, SEGMEN_O
        MOV  word ptr es:[072H], ax
        STI
        ; vacio el buffer del teclado
        CALL vaciar_buffer
        ; devuelvo el control al DOS
        MOV  ax, 4C00H
        INT  21H
timer   endp

; Vacia el Buffer del teclado
; La rutina la utilizamos ates de detectar la pulsacion
; de una tecla y tambi‚n al salir del programa para no
; interferir con otros programas al salir al DOS
vaciar_buffer:
        MOV  ah,0CH
        MOV  al,0
        INT  21H
        ret

; Funcion que configura el periodo del timer
; en 55mseg -> Cargar el valor 0FFFFH
config_timer proc near
        push ax
        mov  cx, 0FFFFH  ; Lo hemos dejado fijo
        mov  al,036H
        out  043H,al     ; acceso al puerto 67 del temporizador
        mov  al  , cl
        out  040H, al    ; enviamos byte inferior
        mov  al  , ch
        out  040H, al    ; enviamos byte superior
        pop   ax
        ret
config_timer endp

; Rutina de servici de la interrupci¢n 1CH (pos en tabla 70H)
; Se produce cada 55mseg o lo que es lo mismo 18,2 veces por segundo
serv_int proc far
         CLI
         PUSH ax bx es ds

         mov ax, datossg
         mov ds, ax

         ; En N_TICS indico el n£mero de TICS que deben de pasar
         ; para ejecutar el codigo de la interrupci¢n
         MOV  bx, N_TICS
         INC  bx
         CMP  bx,10
         JE   efecto
         MOV  N_TICS,bx
         POP  ds es bx ax
         STI
         IRET

efecto:  MOV  N_TICS, 0
         MOV  ax,VIDEO
         MOV  es,ax      ; ES apunta a la memoria de video
         MOV  bx, CONT   ; BX contiene el estado del puntero a la tabla
         INC  bx
         CMP  bx,4     ; ¨hemos superado el final tabla ?
         JNE  sigue     ; NO -> apunta al carater que corresponda
         MOV  bx,0      ; SI -> apunta al primer caracter
; pinta el caracter en la esquina superior izquierda
sigue:   MOV  al, TABLA[bx+0]
         MOV  byte ptr es:[09EH],al
         ; devuelve el control
         MOV  word ptr CONT,bx
         POP  ds es bx ax
         STI
         IRET
serv_int endp

codesg  ends
end     timer

