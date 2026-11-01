;/-----------------------------------------------
;/ Ejemplo de Driver                            /
;/ Andres Prieto-Moreno Torres                  /
;/ ETC-II                                       /
;/----------------------------------------------/

; ETIQUETAS DEL PROGRAMA

SERV  EQU 0EE01H  ; codigo que indentifica al driver
ERRN  EQU 0FFH
OK    EQU 00H


; CODIGO DEL PROGRAMA

codesg  SEGMENT
	assume cs:codesg, DS:codesg, SS:codesg , ES:codesg
	; El ORG 100H es necesario para generar programas .COM ya que
	; la zona de memoria anterior es ocupada por el PSP
	ORG	100H

start:
	jmp instalar  ; la primera vez que se ejecuta lo dejamos residente

;************************************************
;* Servicios del Driver                         *
;************************************************

;............................................
;. SERVICIO AH=0 Comprobación del DRIVER    .
;. E - AH=0 Comprobacion del driver         .
;. S - AX=0xEE01H                           .
;............................................

status proc 
	MOV  AX, SERV
	IRET
status endp

;............................................
;. SERVICIO AH=1 Desinstalar                .
;. E - AH=1 Desinstalar                     .
;. S - AH=OK                                .
;............................................
desinstalar proc
	;-- codigo que desinstala el driver --
	MOV AH,OK
	IRET
desinstalar endp

;............................................
;. SERVICIO AH=2 Read                       .
;. E - AH=2 Read                            .
;. E - DI=posicion a leer                   .
;. S - AH=ERRN(fuera tamaño o no disponible).
;. S - AH=OK                                .
;. S - AL=Dato leído                        .
;............................................

read proc
	; -- código que accede a la memoria física y lee valor --
	
	; -- vamos a decir que leemos 0AAH y que no hay error para probar !!!!
	MOV AH,OK
	MOV AL,0AAH   
	
	IRET
read endp

;............................................
;. SERVICIO AH=3 Write                      .
;. E - AH=3 Write                           .
;. E - DI=posicion a escribir               .
;. E - AL=Dato a escribir                   .
;. S - AH=OK                                .
;.   - AH=ERRN(fuera de rango o no se pudo) .
;............................................

write proc
	; -- código que accede a la memoria física y escribe valor --
	IRET
write endp

;............................................
;. SERVICIO AH=4 Working                    .
;. E - AH=4 Working                         .
;. S - AH=OK  puede procesar otras ordenes  .
;.   - AH=ERRN (dispositivo ocupado)        .
;............................................
working proc
	; -- añadir el codigo de working --
	IRET
working endp

;............................................
;. SERVICIO AH=5 EESIZE                     .
;. E - AH=4 EESIZE                          .
;. S - AX=Tamaño (512bytes)                 .
;. S - BL=OK                                .
;............................................
eesize proc
	MOV AX,512 
	MOV BL,OK
	IRET
eesize endp


;............................................
;. SERVICIO AH=6 Led                        .
;. E - AH=6 Led                             .
;. E - AL=0 apaga - 1 enciende              .
;. S - AH=OK                                .
;............................................
led proc
	MOV AH,OK
	CMP AL,0
	JE  apaga_led
enciende_led:
	;-- codigo que enciende el LED --
	IRET
apaga_led:	
	;-- codigo que apaga el LED --
	IRET
led endp 


;***********************************************************
;* Programa principal del driver                           *
;* Comprueba los servicios solicitados                     *
;***********************************************************

; Cuando llamamos a la INT61H esto es lo que se tiene que ejecutar


driver proc far   
			JMP  sigue
			
			; chequeo extra driver
			DW   0CAFEH    

			; para guardar los valores originales de la interrupción 61h
OFFSET_O    DW 0
SEGMEN_O    DW 0

sigue:
	CMP  AH, 0
	JE   status
	CMP  AH, 1
	JE   desinstalar
	CMP  AH, 2
	JE   read
	CMP  AH, 3
	JE   write
	CMP  AH, 4
	JE   working
	CMP  AH, 5
	JE   eesize
	CMP  AH, 6
	JE   led
	; error en llamada a funcion
	MOV  AH, ERRN
	IRET
driver  endp


;=================================================
; CODIGO QUE INSTALA EL DRIVER
;=================================================

instalar proc 

	CLI
	XOR AX,AX
	MOV ES,AX
	
	; actualizo tabla interrupciones para colocar la 61h
	; guardo los valores iniciales
    MOV  AX, word ptr ES:[061H*4]
    MOV  OFFSET_O, AX
    MOV  AX, word ptr ES:[061H*4+2]
    MOV  SEGMEN_O, AX

	; pongo el nuevo valor apuntando al trozo de programa que queremos que se ejecute al 
	; llamar a la interrupcion (driver)
	MOV  ES:[061H*4]  , OFFSET driver  ; colocamos el OFFSET al codigo de inicio en la tabla de interrupciones
	MOV  ES:[061H*4+2], CS             ; colocamos el SEGMENTO al codido de inicio en la tabla de interrupciones
	STI
	
	; funcion que se encarga de dejar el programa residente
	MOV  DX, OFFSET instalar   
	INT  27H
instalar endp

codesg	ends
end	start

