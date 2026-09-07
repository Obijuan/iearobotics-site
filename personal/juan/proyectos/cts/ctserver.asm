        ORG $0000

TMPC    EQU 65         ; Transferencia de bloques del micro al PC
TPCM    EQU 66         ; Transferencia de bloques del PC al micro
JEXE    EQU 67         ; Servicio JUMP & EXECUTE
ALIVE   EQU 68         ; Servicio de supervivencia
GBEE    EQU 69         ; Grabar un bloque en la EEPROM

OKALIVE EQU 'J'

BAUD    equ  $2B
SCCR1   equ  $2C
SCCR2   equ  $2D
SCSR    equ  $2E
SCDR    equ  $2F


PPROG   equ $103b       ; Control de programacion de la EEPROM
CONFIG  equ $103f       ; Registro de Configuraci*n del MICRO


        BRA inicializar

dirini   RMB  2   ; Direccion inicio
longbloq RMB  2   ; Tamano bloque
codigo   RMB  1   ; Codigo de servicio solicitado

inicializar

PORTA   equ  $00

        LDX #$1000       ; Para acceder a registros del SCI

waitt  BRCLR SCSR,X $40 waitt  ; Esperar a que se termine en enviar
	LDAA #$30	; Velocidad 9600 baudios
	STAA BAUD,X

begin_server LDX #$1000           ; Comienzo del servidor
        BSR leer_car    ; Esperar a que el PC solicite un servicio
        STAA codigo     ; Almacenar temporalmente el c*digo
        CMPA #ALIVE     ; *Servicio de supervivencia?
        BEQ serv_alive
        CMPA #JEXE      ; *Servicio JUMP & EXECUTE?
        BEQ serv_jexec
        CMPA #TMPC      ; *Servicio Transmisi*n micro-PC?
        BEQ serv_tmpc
        CMPA #TPCM      ; *Servicio Transmision PC-micro?
        BEQ serv_tpcm
        CMPA #GBEE      ;  *Servicio Grabacion de EEPROM?
        BEQ serv_gbee

        JMP begin_server

serv_alive LDAA #OKALIVE             ; Servicio de supervivencia
        BSR enviar
        JMP begin_server

serv_tpcm INC codigo
          BRA comun
serv_tmpc CLR codigo

comun   BSR leer_dir
        STY dirini
        BSR leer_dir    ; Leer tama*o del bloque
        STY longbloq    ; Almacenar tama*o bloque
bucle_tmpc CPY #0                  ; *Bloque transferido?
        BEQ fin_ser_tmpc        ; si -> fin
        LDY dirini
        LDAA codigo
        TSTA
        BNE tpcm
        LDAA 0,Y                ; Leer un byte
        BSR enviar              ; Enviar byte
        BRA sigue
tpcm    BSR leer_car            ; Leer un byte
        STAA 0,Y                ; Almacenar byte

sigue   INY
        STY dirini              ; Apuntar siguiente direcci*n
        LDY longbloq
        DEY
        STY longbloq            ; Un byte menos queda por enviar
        BRA bucle_tmpc
fin_ser_tmpc
        JMP begin_server

serv_jexec
        BSR leer_dir    ; Leer direcci*n de inicio
        STY dirini      ; Almacenar direcci*n inicio
        JMP 0,Y

leer_car BRCLR SCSR,X $20 leer_car   ; Esperar hasta que llegue un car*cter
        LDAA SCDR,X
        RTS

enviar  BRCLR SCSR,X $80 enviar
        STAA SCDR,X
        RTS

leer_dir
        PSHA            ; Salvar registros utilizados
        PSHB

        BSR leer_car    ; Leer byte bajo de la direcci*n
        TAB             ; B contiene byte bajo direcci*n
        BSR leer_car    ; A contiene byte alto de la direcci*n
        XGDY            ; Ahora Y contiene la direcci*n leida

        PULB            ; Recuperar registros utilizados
        PULA
        RTS

serv_gbee
        BSR leer_dir
        STY dirini
        BSR leer_dir    ; Leer tama*o del bloque
        STY longbloq    ; Almacenar tama*o bloque
bucle_gbee
        CPY #0                  ; *Bloque transferido?
        BEQ fin_ser_gbee        ; si -> fin
        LDY dirini

        LDAB #$16
        STAB PPROG  ; ponemos modo borrar BYTE
        STAB $0,Y
        LDAB #$17   ;
        STAB PPROG  ; Activo programaci*n
        BSR  PAUSA  ; Realizo la pausa de 10ms

        LDAB #$02
        STAB PPROG  ; ponemos EELAT=1 (EEPGM=0)
        BSR  leer_car
        STAA $0,Y
        LDAB #$03   ; 
        STAB PPROG  ; Activo programaci*n EEPGM=1  (EELAT=1)
        BSR  PAUSA  ; Realizo la pausa de 10ms
        BSR  enviar

        INY
        STY dirini              ; Apuntar siguiente direcci*n
        LDY longbloq
        DEY
        STY longbloq            ; Un byte menos queda por enviar
        BRA bucle_gbee
fin_ser_gbee
        CLR  PPROG  ; Desactivo programacion y pongo modo READ
        JMP begin_server

PAUSA
        PSHY
        LDY   #$0D10
SIGUE   DEY
        CPY #$00
        BNE SIGUE
        PULY
        RTS

        END
