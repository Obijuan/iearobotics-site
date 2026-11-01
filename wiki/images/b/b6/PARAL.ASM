;/---------------------------------------------/
;/ Practicas de ETC-II                    UAM  /
;/ Andres Prieto-Moreno           12-oct-2008  /
;/ ETC-II                                      /
;/                                             /
;/ Programacion puerto paralelo                /
;/ Descripcion:                                /
;/  Hace parpadear un LED conectado al D3 del  /
;/ registro de datos del puerto paralelo       /
;/                                             /
;/ Muestra:                                    /
;/  - Acceso Puerto Paralelo                   /
;/  - Detectar tecla pulsada                   /
;/                                             /
;/ Información                                 /
;/ El puerto paralelo esta formado por tres    /
;/ registros:                                  /
;/   DIR_BASE+0 = Datos   (8 bits de salida)   /
;/   DIR_BASE+1 = Status  (5 bits de entrada   /
;/   DIR_BASE+2 = Control (4 bits de salida)   /
;/                                             /
;/   La dirección base generalmente es igual   /
;/  para cada PC, pero la mejor forma es       /
;/  mirar en la propia BIOS donde se encuentra /
;/                                             /
;/---------------------------------------------/

; SEGMENTO DE PILA

stacksg SEGMENT STACK "STACK"
        DB 400H DUP (0)
stacksg ends

; SEGMENTO DE DATOS
datossg SEGMENT
        DIR_BASE  DW 0    
        DATO      DB 0
datossg ends



; CODIGO DEL PROGRAMA

codesg  SEGMENT
        assume  cs:codesg, DS:datossg, SS:codesg, ES:datossg


;*****************************************
;* rutinas auxiliares                    *
;*****************************************

; Vacia el Buffer del teclado
; La rutina la utilizamos ates de detectar la pulsacion
; de una tecla y tambi‚n al salir del programa para no
; interferir con otros programas al salir al DOS
vaciar_buffer proc
	MOV  AH,0CH
	MOV  AL,0
	INT  21H
	ret
vaciar_buffer endp


; enviar dato por el puerto paralelo
; Parametro de entrada AL->dato a enviar
enviar_dato proc
	PUSH DX
	
	MOV  DX,DIR_BASE
	OUT  DX,AL        ; pongo el dato en el registro de datos

	POP  DX
	RET
enviar_dato endp


; Rutina que hace una pausa por espera activa
; Cambiando el valor de DX se ajusta
pausa	proc
		PUSH DX
		PUSH CX
		
		MOV  DX,010H

buno:   MOV  CX,0FFFFH
bdos:	DEC  CX
		CMP  CX,0
		JNE  bdos
		DEC  DX
		CMP  DX,0
		JNE  buno  
		
		POP  CX
		POP  DX
		RET
pausa	endp



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

		MOV  SP, 0400H
		
		; configuracion inicial
        CALL vaciar_buffer ; vaciamos el buffer del teclado
        
        ; saco la direccion del LPT1 (miro en la BIOS)
        MOV  AX, 0040H     ; zona de la BIOS que me indica las direcciones de los puertos
        MOV  ES, AX
        MOV  DX, ES:[08H] ; direccion Puerto Paralelo 1
        MOV  DIR_BASE,DX


; El bucle principal hace lo siguiente
; Mira por si hemos pulsado una tecla para salir del programa

bucle:
		; cambia el estado del LED
		MOV  AL, Dato
		XOR  AL,08H;  //cambio el estado del LED
		CALL enviar_dato
		MOV  Dato,AL
		
		CALL pausa
		
		; mira si se ha pulsado una tecla para salir del bucle
tecla:  MOV  AH,0BH
        INT  21H
        CMP  AL,0
        JE   bucle   ; no hay tecla -> sigue

fin:    ; desactiva el LED al salir
        MOV  AL,0
        CALL enviar_dato

        ; vacio buffer teclado
        CALL vaciar_buffer
		
		; salgo del programa
        MOV  AX, 4C00H
        INT  21H
paralelo endp



codesg  ends
end     paralelo


