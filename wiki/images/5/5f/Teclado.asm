
;==================================
;= Funciones asociadas al teclado =
;==================================

;DEFINICION DEL SEGMENTO DE CODIGO
TECLADOLIB SEGMENT BYTE PUBLIC 'CODE'
		 ASSUME CS:TECLADOLIB


; Funcion que desactiva el cursor
CursorOff PROC FAR
	PUSH AX 
	PUSH CX
	MOV  AH,01H
	MOV  CH,32
	INT  10H
	POP  CX
	POP  AX
	RET
CursorOff ENDP

; Funcion que activa el cursor
CursorOn PROC FAR
	PUSH AX
	PUSH CX
	MOV  AH,01H
	MOV  CH,6
	MOV  CL,7
	INT  10H
	POP  CX
	POP  AX
	RET
CursorOn ENDP

; Funcion que limpia el buffer del teclado
; Entradas: NINGUNA
; Salidas : NINGUNA
ClearKeyBuffer PROC FAR
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
IsKey PROC FAR
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
ReadKey PROC FAR
	PUSH DX
	MOV  AH,06H
	MOV  DL,0FFH
	INT  21H
	POP  DX
	RET
ReadKey ENDP


; Funcion que espera a que se pulse una tecla
; momento en la que la devuelve en AL
GetKey PROC FAR
	CALL IsKey
	CMP  AL,0
	JE   GetKey

	CALL ReadKey
	RET
GetKey ENDP


TECLADOLIB ENDS
		PUBLIC  ClearKeyBuffer
		PUBLIC  IsKey
		PUBLIC  ReadKey
		PUBLIC  GetKey
		PUBLIC  CursorOn
		PUBLIC  CursorOff
		END

