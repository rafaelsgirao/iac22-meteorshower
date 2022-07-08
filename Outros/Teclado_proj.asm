varre_teclado:  ; Obtem o valor da tecla premida:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R7
    PUSH R9
    PUSH R10

    MOV R2, TEC_LIN
    MOV R3, TEC_COL
    MOV R4, DISPLAYS
    MOV R5, MASCARA
    MOV R7, 4
    MOV R9, 0
    MOV R10, 0
escolhe_linha: ; Função que salta para a linha seguinte:
    YIELD
    CMP R0, 1  
    JZ linha2
    
    CMP R0, 2  
    JZ linha3

    CMP R0, 4  
    JZ linha4
   
    JMP linha1

espera_tecla:          ; neste ciclo espera-se at� uma tecla ser premida
 
    MOVB [R2], R0      ; escrever no perif�rico de sa�da (linhas)
    MOVB R1, [R3]      ; ler do perif�rico de entrada (colunas) 
    AND  R1, R5        ; elimina bits para al�m dos bits 0-3
    CMP  R1, 0         ; h� tecla premida?
    JZ   escolhe_linha  ; se nenhuma tecla premida, repete
    JMP altera_linha

; Funcoes que passam para a linha seguinte
; (no caso da linha 4, retorna à linha 1):
linha1:
    MOV R0, 01H
    JMP espera_tecla
linha2:
    MOV R0, 02H
    JMP espera_tecla
linha3:
    MOV R0, 04H
    JMP espera_tecla
linha4:
    MOV R0, TECLADO_4; 
    JMP espera_tecla

;-------------------------------------------------------------------;
; Funcoes que alteram o input, obtendo o output desejado nos displays:
;-------------------------------------------------------------------;
altera_linha: ; Ciclo - conta o numero de SHRs ate 0:
    SHR R0, 1
    ADD R9, 1 ; registo contador das linhas

    CMP R0, 0
    JNZ altera_linha ; Enquanto R0 nao for zero, repete o ciclo

altera_coluna: ; Ciclo - conta o numero de SHRs ate 0:
    SHR R1, 1
    ADD R10, 1 ; registo contador de colunas

    CMP R1, 0
    JNZ altera_coluna ; Enquanto R1 nao for zero, altera o valor da linha

escreve_letra_registo: ; Funcao que escreve a tecla pretendida no registo:

    MOV R0, R9 ; Valor do contador de linhas para R0
    SUB R0, 1 ; Passa o numero da linha para R0

    MOV R1, R10 ; Valor do contador de colunas para R1
    SUB R1, 1 ; Passa o numero da coluna para R1

    MUL R0, R7 ; 4 * linhas (R7 = 4)
    ADD R0, R1 ; Obtem-se assim o numero desejado (4 * linhas + colunas)

acaba_varrer:
    POP R10
    POP R9
    POP R7
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1