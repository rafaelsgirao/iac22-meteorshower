; *********************************************************************
; * IST-UL
; * Modulo:    lab3.asm
; * Descri��o: Exemplifica o acesso a um teclado.
; *            L� uma linha do teclado, verificando se h� alguma tecla
; *            premida nessa linha.
; *
; * Nota: Observe a forma como se acede aos perif�ricos de 8 bits
; *       atrav�s da instru��o MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
; ATEN��O: constantes hexadecimais que comecem por uma letra devem ter 0 antes.
;          Isto n�o altera o valor de 16 bits e permite distinguir n�meros de identificadores
DISPLAYS   EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)
LINHA      EQU 8     ; linha a testar (4� linha, 1000b)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; **********************************************************************
; * C�digo
; **********************************************************************

varre_teclado:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R11
    
; inicializa��es
    MOV R1, 00H    ; Inicializa contador de linhas
    MOV  R2, TEC_LIN   ; endere�o do perif�rico das linhas
    MOV  R3, TEC_COL   ; endere�o do perif�rico das colunas
    MOV  R4, DISPLAYS  ; endere�o do perif�rico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

    MOV R8, 4 ; Utilizado para multiplicar por 4
    MOV R7, 064H ; Registo que guarda o valor do display
    MOV [R4], R7 ; escreve linha e coluna a zero nos displays
;-------------------------------------------------------------------;
; Corpo principal do programa
;-------------------------------------------------------------------;

escolhe_linha: ; Função que salta para a linha seguinte:
    MOV R1, R11 ; R1 tinha sido alterado

    CMP R1, 1  
    JZ linha2
    
    CMP R1, 2  
    JZ linha3

    CMP R1, 4  
    JZ linha4
   
    JMP linha1

espera_tecla:          ; neste ciclo espera-se at� uma tecla ser premida
    MOV R11, R1
    
    MOVB [R2], R1      ; escrever no perif�rico de sa�da (linhas)
    MOVB R0, [R3]      ; ler do perif�rico de entrada (colunas) 
    AND  R0, R5        ; elimina bits para al�m dos bits 0-3
    CMP  R0, 0         ; h� tecla premida?
    JZ   escolhe_linha  ; se nenhuma tecla premida, repete
    JMP altera_linha

ha_tecla:              ; neste ciclo espera-se at� NENHUMA tecla estar premida

    MOV R9, 0          ; Reinicializa contadores auxiliares
    MOV R10, 0

    MOV  R1, R11       ; R1 tinha sido alterado (altera_display)
    MOVB [R2], R1      ; escrever no perif�rico de sa�da (linhas)
    MOVB R0, [R3]      ; ler do perif�rico de entrada (colunas)
    AND  R0, R5        ; elimina bits para al�m dos bits 0-3
    CMP  R0, 0         ; h� tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera at� n�o haver
    JMP  escolhe_linha         ; repete ciclo


;-------------------------------------------------------------------;
; Funcoes que alteram o input, obtendo o output desejado nos displays:
;-------------------------------------------------------------------;
altera_linha: ; Ciclo - conta o numero de SHRs ate 0:
    SHR R1, 1
    ADD R9, 1 ; registo contador das linhas

    CMP R1, 0
    JNZ altera_linha ; Enquanto R1 nao for zero, repete o ciclo

    JMP altera_coluna ; Caso contrario, passa ao proximo passo


altera_coluna: ; Ciclo - conta o numero de SHRs ate 0:
    SHR R0, 1
    ADD R10, 1 ; registo contador de colunas

    CMP R0, 0
    JNZ altera_coluna ; Enquanto R0 nao for zero, altera o valor da linha

altera_display: ; Funcao que escreve o numero pretendido no display:

    MOV R1, R9 ; Valor do contador de linhas para R1
    SUB R1, 1 ; Passa o numero da linha para R1

    MOV R0, R10 ; Valor do contador de colunas para R0
    SUB R0, 1 ; Passa o numero da coluna para R0

    MUL R1, R8 ; 4 * linhas (R8 = 4)
    ADD R1, R0 ; Obtem-se assim o numero desejado (4 * linhas + colunas)

    MOV R6, 07H ; Contador auxiliar, testa a tecla 7
    MOV R9, 0BH ; Contadores agora testam as teclas B e F
    MOV R10, 0FH 

    CMP R1, R6
    JZ  desce_meteoro

    CMP R1, R9
    JZ aumenta_display

    CMP R1, R10
    JZ diminui_display

    MOV R9, 00H ; Reset nos contadores
    MOV R10, 00H
    JMP ha_tecla 

;-------------------------------------------------------------------;
; Funcoes que passam para a linha seguinte
; (no caso da linha 4, retorna à linha 1):
;-------------------------------------------------------------------;
linha1:
    MOV R1, 01H
    JMP espera_tecla
linha2:
    MOV R1, 02H
    JMP espera_tecla
linha3:
    MOV R1, 04H
    JMP espera_tecla
linha4:
    MOV R1, LINHA ; LINHA = 8
    JMP espera_tecla


aumenta_display:
    MOV R9, 064H
    CMP R9, R7
    JZ ha_tecla

    MOV R9, 01H
    ADD R7, R9

    MOV [R4], R7

    MOV R9, 0
    MOV R10, 0
    JMP ha_tecla

diminui_display:
    MOV R9, 00H

    CMP R9, R7
    JZ ha_tecla
    MOV R9, 01H
    SUB R7, R9

    MOV [R4], R7

    MOV R9, 0
    MOV R10, 0
    JMP ha_tecla

desce_meteoro:
    JMP ha_tecla

    POP R11
    POP R10
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET
