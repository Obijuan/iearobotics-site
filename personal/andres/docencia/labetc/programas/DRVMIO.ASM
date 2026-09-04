;/-----------------------------------------------
;/ Driver residente para el analizador lógico   /
;/ Andres Prieto-Moreno            7-dic-2004   /
;/ ETC-II                                       /
;/----------------------------------------------/

; ETIQUETAS DEL PROGRAMA

SERV  EQU 055ABH  ; codigo que indentifica al driver

; CODIGO DEL PROGRAMA

codesg  SEGMENT
	assume cs:codesg, DS:codesg, SS:codesg , ES:codesg
	; El ORG 100H es necesario para generar programas .COM ya que
	; la zona de memoria anterior es ocupada por el PSP
	ORG	100H

start:
	jmp instalar

;************************************************
;* Servicios del Driver                         *
;************************************************

;............................................
;. SERVICIO AH=0 Comprobación del DRIVER    .
;. E - AH=0 Comprobacion del driver         .
;. S - AX=0x55ABH                           .
;. S - CL= numero de pareja de practica     .
;. S - DL= letra del grupo                  .
;. S - DH= numero de pareja                 .
;............................................

status: 
	MOV  AX, 55ABH
	MOV  CX, 01H
	MOV  DX, 0FF0DH
	IRET

;............................................
;. SERVICIO AH=2 Start/Stop Adquisicion     .
;. E - AH=2 Start/Stop                      .
;. E - AL=0 Stop                            .
;.     S - Por defecto                      .
;. E - AL=1 Start                           .
;.     S - CX=numero bytes en el buffer     .
;.     S - DS:SI= buffer ciclico            .
;............................................
control:
	CMP  AL, 0
	JE   c_stop
	CMP  AL, 1
	JE   c_start
	MOV  AH , 0FEH  ; error en parametro AL
	IRET
c_stop:
	JMP  fin
c_start:
	JMP  fin

;..............................................
;. SERVICIO AH=1 define parametros del driver .
;. E - AH=1 Parametros                        .
;. E - AL=0 Paramtros del reloj del RTC       .
;.     S - Por defecto                        .
;. E - AL=1 Condicion de arranque             .
;.     Parametros de entrada 3 bytes          .
;.     S - Por defecto                        .
;. E - AL=2 Condicion de parada               .
;.     Parametros de entrada 3 bytes          .
;.     S - Por defecto                        .
;..............................................
param:
	CMP  AL, 0
	JE   p_reloj
	CMP  AL, 1
	JE   p_start
	CMP  AL, 2
	JE   p_stop
	MOV  AH, 0FEH   ; error en parametro AL
	IRET
p_reloj:
	; configuramos el timer para el periodo de muestreo
	MOV  AH, 0FEH  ; error en parametro AL
	IRET

p_start:
	; comenzamos a rellenar datos
	MOV  AH, 0FEH  ; error en parametro AL
	IRET

p_stop:
	; paramos la captura de datos
	MOV  AH, 0FEH  ; error en parametro AL
	IRET

;............................................................
;. SERVICIO AH=3 LECTURA DE DATOS DEL DRIVER                .
;. E - ES:DI= Espacio de memoria donde depositar los datos  .
;. E - CX= Numero maximo de muestras para devolver          .
;. S - CX= Numero real de muestras devueltas                .
;. S - DX= Numero de muestras que quedan en el driver       .
;. S - AL= 0 OK <-> AL=1 Buffer Overrun                     .
;. S - BX OPCIONAL = Numero de muestras perdidas            .
;............................................................

lectura:
	MOV  CX, 0
	MOV  DX, 0
	MOV  AL, 1
	IRET

;***********************************************************
;* Programa principal del driver                           *
;* Comprueba los servicios solicitados                     *
;***********************************************************

driver proc far
	CMP  AH, 0
	JE   status
	CMP  AH, 1
	JE   param
	CMP  AH, 2
	JE   control
	CMP  AH, 3
	JE   lectura
	; error en llamada a funcion
	MOV  AH, 0FDH
	IRET
fin:	; salimos sin error en el driver
	MOV  AH, 0
	IRET

driver  endp


;=================================================
; CODIGO QUE INSTALA EL DRIVER
;=================================================

instalar proc 
	XOR  AX, AX
	MOV  ES, AX
	MOV  AX, OFFSET driver
	MOV  BX, CS
	CLI
	MOV  ES:[061H*4]  , AX
	MOV  ES:[061H*4+2], BX
	STI
	MOV  DX, OFFSET instalar
	INT  27H
instalar endp

codesg	ends
end	start

