;/---------------------------------------------/
;/ Practicas de ETC-II                    UAM  /
;/ Andres Prieto-Moreno           26-oct-2006  /
;/ ETC-II                                      /
;/                                             /
;/ Ejemplo de programacion                     /
;/ Programa MUEVE                              /
;  Descripcion:                                /
;/  Mueve un caracter por la pantalla          /
;/  Teclas: O,P,Q,A                            /
;/          . sale del programa                /
;/ Muestra:                                    /
;/  - Acceso directo a la pantalla             /
;/  - Detectar tecla pulsada                   /
;/  - Realizacion de pausa activa              /
;/                                             /
;/---------------------------------------------/


; ETIQUETAS DEL PROGRAMA
VIDEO EQU 0B800H   ; Posicion de memoria donde empieza el modo 80x25

; SEGMENTO DE DATOS
datosg SEGMENT
	POSX DB 0;
	POSY DB 0;
datosg ENDS

; SEGMENTO DE PILA

stacksg SEGMENT STACK "STACK"
	DB 40H DUP (0)
stacksg ends


; CODIGO DEL PROGRAMA

codesg  SEGMENT
    assume  cs:codesg, DS:datosg, SS:stacksg

;=====================================
;= Funciones asociadas a la pantalla =
;=====================================

; Funcion que pasa a modo VGA
VGAmode PROC
	MOV  AH,0
	MOV  AL,12H
	INT  10H   ; Set video mode
	RET
VGAmode ENDP


; Funcion que pasa a modo TEXTO
TEXTmode PROC
	MOV  AH,0
	MOV  AL,3H
	INT  10H   ; Set video mode
	RET
TEXTmode ENDP


; Funcion que pinta un pixel
Pixel PROC
	MOV AH,0CH
	MOV BH,0
	; AL = pixel color (if bit 7 set, value is xor'ed onto screen)
	    ; CX = column
	; DX = row
	INT 10H
	RET
Pixel ENDP

; Funcion que desactiva el cursor
CursorOff PROC
	MOV  AH,01H
	MOV  CH,32
	INT  10H
	RET
cursoroff ENDP

; Funcion que activa el cursor
CursorOn PROC
	MOV  AH,01H
	MOV  CH,6
	MOV  CL,7
	INT  10H
	RET
cursoron ENDP



;==================================
;= Funciones asociadas al teclado =
;==================================

; Funcion que limpia el buffer del teclado
; Entradas: NINGUNA
; Salidas : NINGUNA
ClearKeyBuffer PROC
	PUSH AX
	MOV  AH,0cH
	MOV  AL,0H
	INT  21H
	POP  AX
	RET
ClearKeyBuffer ENDP



; Funcion que mira si hay tecla pulsada
; Es equivalente a kbhit();
; devuelve en AL 0 si no hay tecla
; devuelve en AL 1 si hay tecla
IsKey PROC
	MOV  AH,0BH
	MOV  AL,0H
	INT  21H
	RET
IsKey ENDP


; Funcion que devuelve la tecla pulsada en AL
; Accede al buffer del teclado y devuelve la tecla pulsada
; Si se pulsa una tecla extendida se devuelve 0x00, y luego 
; habra que volver a llamar a la funcion para saber cual ha 
; sido la tecla pulsada
ReadKey PROC
	PUSH DX
	MOV  AH,06H
	MOV  DL,0FFH
	INT  21H
	POP  DX
	RET
ReadKey ENDP


; Funcion que espera a que se pulse una tecla
; momento en la que la devuelve en AL
GetKey PROC
	CALL IsKey
	CMP  AL,0
	JE   GetKey

	CALL ReadKey
	RET
GetKey ENDP


;====================================
;= Otras funciones auxiliares       =
;====================================
 
; Espera 10*CX mseg
; Esta rutina hace una pausa por el procedimiento de espera activa
; es decir, el programa se queda en el bucle hasta que termine la
; pausa. Si llega alguna interrupci¢n se atender  salvo que las
; hayamos deshabilitado.
; Entrada: EN CX ponemos el numero de repeticiones de 10mseg
pausa   PROC
        PUSH  CX
        MOV   CX,03611H
        ; mini bucle que espera 10mseg
pausa100:
        LOOP  pausa100
        POP   CX
        LOOP  pausa
        RET
pausa   ENDP



PintaCursor PROC
	MOV  AL,POSX
	MOV  BL,2
	MUL  BL
	PUSH AX  ; Guardo el resultado coordX

	MOV  AL,POSY
	MOV  BL,160
	MUL  BL
	POP  BX
	ADD  BX,AX

	MOV  byte ptr ES:[BX],'O'
	RET
PintaCursor ENDP


BorraCursor PROC
	MOV  AL,POSX
	MOV  BL,2
	MUL  BL
	PUSH AX  ; Guardo el resultado coordX

	MOV  AL,POSY
	MOV  BL,160
	MUL  BL
	POP  BX
	ADD  BX,AX

	MOV  byte ptr ES:[BX],0
	RET
BorraCursor ENDP





;=======================
;= Programa princpal   =                   
;=======================

mueve  proc far
	; Configuracion inicial
	MOV  AX,datosg
	MOV  DS,AX

	MOV  AX,stacksg
	MOV  SS,AX
	MOV  SP,040H;

        MOV  AX,VIDEO
        MOV  ES,AX          ; ES apunta a la memoria de video
        
	CALL ClearKeyBuffer ; vaciamos el buffer del teclado
	CALL TEXTmode       ; lo usamos para borrar la pantalla
	CALL CursorOff      ; desactivamos el parpadeo del cursor

; El bucle principal hace lo siguiente
; Lee Tecla
; Pinta el caracter
; Espera un tiempo
; Mira por si hemos pulsado una tecla para salir del programa
; Si no hemos pulsado comienza de nuevo

bucle:
	; desplaza cursor
	CALL PintaCursor

	; hace una pausa
	MOV  CX,5  ; espera 250 mseg
	CALL pausa

	; borra el Cursor para pintar el siguiente
	CALL BorraCursor
	; mira si se ha pulsado una tecla para salir del bucle
	CALL ReadKey
;	CALL ClearKeyBuffer   ; para evitar acumulacion de teclas

	CMP  AL,'o'
	JE   izq
	CMP  AL,'p'
	JE   der
	CMP  AL,'q'
	JE   arr
	CMP  AL,'a'
	JE   aba
	CMP  AL,'.'
	JE   fin
	JMP  bucle

izq:
		CMP POSX,0
		JE  bucle
		DEC POSX
		JMP bucle
	
der:    CMP POSX,79
		JE  bucle
		INC POSX
		JMP bucle
	
arr:	CMP POSY,0
		JE  bucle
		DEC POSY
		JMP bucle
	
aba:	CMP POSY,24
		JE  bucle
		INC POSY
		JMP bucle

fin:    ; devuelve el control al DOS
		CALL ClearKeyBuffer
		CALL TEXTmode
        MOV  AX, 4C00H
        INT  21H
mueve   endp


codesg  ends
end     mueve

