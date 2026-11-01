;/---------------------------------------------/
;/ Practicas de ETC-II                    UAM  /
;/ Andres Prieto-Moreno           26-oct-2008  /
;/ ETC-II                                      /
;/                                             /
;/ Ejemplo de programacion                     /
;/ Programa que chequea el driver EEPROM       /
;/---------------------------------------------/


; Declaracion de constantes
	ERROR   EQU 0FFH
    OK      EQU 00H


; SEGMENTO DE DATOS
datosg SEGMENT
	Mensaje1 DB "No hay Driver instalado$"
	Mensaje2 DB 13,10,"Driver incorrecto$"
	Mensaje3 DB 13,10,"Driver desinstalado$"
	Mensaje4 DB 13,10,"No es driver valido$"
	Mensaje5 DB 13,10,"Escritura correcta $"
	Mensaje6 DB 13,10,"Lectura incorrecta $"
	Mensaje7 DB 13,10,"Escritura incorrecta $"
	Mensaje8 DB 13,10,"Lectura correcta $"
	Mensaje9 DB 13,10,"Tamano de driver incorrecto $"
	fichero  DB "c:\pra-0809\simul\mem2.bin",0
	
	conversion DB '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
	
	tamano   DW 0
	valor_hex DB 0,0,' ','$'
	fin_linea DB 13,10,'$'
	
datosg ENDS

; SEGMENTO DE PILA

stacksg SEGMENT STACK "STACK"
	DB 400H DUP (0)
stacksg ends


; CODIGO DEL PROGRAMA

codesg  SEGMENT
    assume  cs:codesg, DS:datosg, SS:stacksg

;------------------------------------------
; Mensajes de error
;------------------------------------------		

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


err_mem_driver:
		MOV AH,9	                ;ESCRIBE TEXTO
		MOV DX,OFFSET Mensaje9		
		INT 21H          		
		JMP fin


err_escritura:
		MOV AH,9	                ;ESCRIBE TEXTO
		MOV DX,OFFSET Mensaje7		
		INT 21H          		
		JMP fin


;------------------------------------------
; INICIO DEL PROGRAMA
;------------------------------------------		
inicio  proc far
		; Configuracion inicial
		MOV  AX,datosg
		MOV  DS,AX
		
		MOV  AX,stacksg
		MOV  SS,AX
		MOV  SP,0400H;

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
		CMP AX,0EE01H
		JNE no_responde
		
	
		; Ahora sabemos que el driver es el correcto
		; vamos a comprobar la escritura y lectura de sus posiciones de memoria
		
		; ponemos el nombre del fichero: Uso uno distinto de mem.bin
		MOV AH,0AH
		MOV DI, OFFSET fichero
		INT 61H
		
		
		; Leemos las posiciones de memoria que tiene
		MOV AH,5
		INT 61H
		CMP BL,ERROR
		JE  err_mem_driver
		MOV tamano,AX    ; guardamos la dimension en 'tamano'  
		
		;..........................................
		; Verificamos que escribe correctemante
		;..........................................
		; Primero Escribimos Todo. Empezamos por 0 y se va incrementando hasta 255. Luego vuelve a empezar la cuenta
		
		mov cx,ax       ; contador inicial = tamano memoria
		XOR BL,BL       ; dato inicial. Uso BL porque en algunas versiones del driver AL pierde su valor
		MOV DI,0        ; posicion empieza desde la 0

	test1:
		MOV AH,3        
		MOV AL,BL
		INT 61H             ;  Funcion del driver que escribe. Dato en AL  
		CMP AH,0FFH         ;  comprobamos que la escritura esta bien
		JE  err_escritura   
		INC DI			    ; siguiente posicion
		INC BL              ; siguiente valor
		loop test1

		
		; Si ha llegado aqui es que la escritura de todas las posiciones ha sido correcta
		MOV AH,9	                ;ESCRIBE TEXTO
		MOV DX,OFFSET Mensaje5	    ;Escritura correcta	
		INT 21H  
		MOV DX,OFFSET fin_linea     ; salto de linea
		INT 21H          
		
		;.............................
		; Segundo comprobamos lectura
		;.............................
		
		XOR bl,bl       ; dato incial
		mov cx,tamano   ; contador inicial
		MOV DI,0        ; posicion empieza desde la 0

	
	test2:
		MOV AH,2        
		INT 61H         ; llamamos a la funcion del driver de lectura  
		CMP AL,bl      ; el dato lo devuelve en AL, en BL tenemos el valor que deberia tener
		JNE err_lectura
		INC DI			  ; siguiente posicion
		INC BL            ; siguiente valor

		; pintamos en pantalla el dato leido
		; con el debuger podemos verlo en la variable valor_hex
		call byte_to_hex            ; pasamos a representacion ASCII del valor Hexadecimal
		MOV AH,9	                ;Escribe el dato leido
		MOV DX,OFFSET valor_hex
		INT 21H          
		
		loop test2

		; imprime un salto de linea
		MOV AH,9	               
		MOV DX,OFFSET fin_linea
		INT 21H          

		; indica que la lectura ha sido correcta
		MOV DX,OFFSET Mensaje8		
		INT 21H          

		; termina el programa
  
fin:
        MOV  AX, 4C00H
        INT  21H
		
		


		
		
inicio   endp


;----------------------------------------------------
; Funciones auxiliares 
;----------------------------------------------------


; Procedimiento que le pasas un byte en AL y 
; te devuelve en AX la representacion en ascii del valor en hexadecimal
; también te devuelve dicha representacion de memoria 'valor_hex'
byte_to_hex proc
		PUSH DX    		   	    ; guardo este registro porque lo usa la division
		PUSH BX      			; guardo este registro ya que lo uso de calculo intermedio
		XOR  AH,AH
		MOV  BL,16     			; Dividimos por Base 16
		DIV	 BL        			; Divide AL por BL -> Resto en AH y cociente en AL
		MOV  BL,AH     			; lo paso a BL que es el parametro de entrada para la funcion 'hex_to_ascii'
		call hex_to_ascii		; lo represento en ASCII
		MOV  valor_hex[1],BL    ; lo guardo en memoria
		MOV  BL,AL              ; ahora paso a ascii el cociente
		call hex_to_ascii 		; me devuelve el cociente en byte más significativo
		MOV  valor_hex[0],BL    ; lo guardo
		MOV  AH, valor_hex[0]   ; formo el valor de AX
		MOV  AL, valor_hex[1]
		POP BX                  ; recupero registros
		POP DX
		ret
byte_to_hex endp


; Procedimiento al que le pasas en BL un valor hexadecimal (del 0 a la F) y te 
; devuelve en BL su correspondiente en ascii '0','1'...'F'
hex_to_ascii proc
	PUSH DI
	XOR  BH,BH
	MOV  DI, BX
	MOV  BL, conversion[DI]
	POP  DI
	ret
hex_to_ascii endp



err_lectura:
		MOV AH,9	                ;ESCRIBE TEXTO
		MOV DX,OFFSET Mensaje6		
		INT 21H          		
		JMP fin



codesg  ends
end     inicio

