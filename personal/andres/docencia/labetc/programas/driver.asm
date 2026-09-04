;/---------------------------------------------/
;/ Practicas de ETC-II                    UAM  /
;/ Andres Prieto-Moreno           26-oct-2006  /
;/ ETC-II                                      /
;/                                             /
;/ Ejemplo de programacion                     /
;/ Programa que chequea el driver EEPROM       /
;/---------------------------------------------/


; SEGMENTO DE DATOS
datosg SEGMENT
	Mensaje1 DB "No hay Driver instalado$"
	Mensaje2 DB 13,10,"Driver incorrecto$"
	Mensaje3 DB 13,10,"Driver desinstalado$"
	Mensaje4 DB 13,10,"No es driver valido$"
	Mensaje5 DB 13,10,"No autorizado$"
	Mensaje6 DB 13,10,"Autorizado$"
	fichero  DB "c:\juego\clave.bin",0
datosg ENDS

; SEGMENTO DE PILA

stacksg SEGMENT STACK "STACK"
	DB 400H DUP (0)
stacksg ends


; CODIGO DEL PROGRAMA

codesg  SEGMENT
    assume  cs:codesg, DS:datosg, SS:stacksg



inicio  proc far
		; Configuracion inicial
		MOV  AX,datosg
		MOV  DS,AX
		
		MOV  AX,stacksg
		MOV  SS,AX
		MOV  SP,040H;

		; comprobamos que hay driver
		
		XOR AX,AX
		MOV ES,AX
		MOV AX, ES:[61H*4]
		MOV BX, ES:[61H*4+2]
		ADD AX,BX
		;CMP AX,0
		JE no_driver
		
		; Comprobacion para rizar el rizo
		; Voy a ver si el codigo maquina del driver es lo que espero que sea
		MOV BX, ES:[61H*4]  ; Offset
		MOV AX, ES:[61H*4+2]; Segmento
		MOV ES,AX
		MOV CX,ES:[BX+3]
		CMP CX,0CAFEH
		JNE no_cafe
		
		; comprobamos que me responde
		
		MOV AH,0
		INT 61H
		CMP AX,0EE00H
		JNE no_responde
		
	
		; Ahora sabemos que el driver es el correcto
		; vamos a comprobar la primera posicion de memoria
		
		; ponemos el nombre del fichero
		MOV AH,0AH
		MOV DI, OFFSET fichero
		INT 61H
		
		; leemos una posicion de la memoria
		MOV AH,6
		MOV DI,1        ; posicion segunda, empieza desde la 0
		INT 61H
		CMP AH,0FFH     ; comprobamos que la lectura esta bien
		JE  sin_clave
		CMP AL,55H
		JNE sin_clave
		
		; Autorizado
		MOV AH,9	                ;ESCRIBE TEXTO
		MOV DX,OFFSET Mensaje6		
		INT 21H          		
			
		; desinstalamos el driver
		; no me funciona
		;MOV AH,1
		;INT 61H
		;CMP AH,0
		;JE  driver_desins  

  
fin:
        MOV  AX, 4C00H
        INT  21H
		
		
no_driver:	
		MOV AH,9	                ;ESCRIBE TEXTO
		MOV DX,OFFSET Mensaje1		
		INT 21H
		JMP fin	

no_responde:
		MOV AH,9	                ;ESCRIBE TEXTO
		MOV DX,OFFSET Mensaje2		
		INT 21H                     
		JMP fin

no_cafe:
		MOV AH,9	                ;ESCRIBE TEXTO
		MOV DX,OFFSET Mensaje4		
		INT 21H                     
		JMP fin

		
driver_desins:
		MOV AH,9	                ;ESCRIBE TEXTO
		MOV DX,OFFSET Mensaje3		
		INT 21H          		
		JMP fin

sin_clave:
		MOV AH,9	                ;ESCRIBE TEXTO
		MOV DX,OFFSET Mensaje5		
		INT 21H          		
		JMP fin

		
		
inicio   endp




codesg  ends
end     inicio
