; *********************************************************************************
; * IST-UL
; * Projeto de Introdução à Arquitetura de Computadores 2021/2022
; * Chuva de Meteoros
; *
; * Grupo 73
; * ist1103860 Henrique Caroço
; * ist1103883 Luís Calado
; * ist199309  Rafael Girão
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
; *************
; * Periféricos
; *************
TEC_LIN					EQU 0C000H	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL					EQU 0E000H	; endereço das colunas do teclado (periférico PIN)
DISPLAYS   				EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
DEFINE_LINHA   	        EQU 600AH   ; endereço do comando para definir a linha
DEFINE_COLUNA  	        EQU 600CH   ; endereço do comando para definir a coluna
DEFINE_PIXEL   	        EQU 6012H   ; endereço do comando para escrever um pixel
APAGA_AVISO             EQU 6040H   ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		    EQU 6002H  	; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H	; endereço do comando para selecionar uma imagem de fundo
TOCA_SOM				EQU 605AH   ; endereço do comando para tocar um som

LINHA_TECLADO	        EQU 1		; linha a testar (1ª linha, 1000b)
LINHA_START 	        EQU 8       ; linha a testar para começar o jogo(4ª linha)
MASCARA		        	EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLADO_1               EQU 1       ; 1ª linha/coluna do teclado
TECLADO_2               EQU 2       ; 2ª linha/coluna do teclado
TECLADO_3               EQU 4       ; 3ª linha/coluna do teclado
TECLADO_4               EQU 8       ; 4ª linha/coluna do teclado
COLUNA_2 			    EQU 2


; **********************************
; * Posições (coluna) de importância dos 8 meteoros 
; **********************************



; **********************************
; * Constantes de bonecos e do ecrã
; **********************************
LINHA_LIMITE_DISPARO 	EQU 5
LINHA_DISPARO 			EQU 27
LARGURA_ALTURA_DISPARO   EQU 1

LINHA_FUNDO_ECRA        EQU  31     ; linha do Rover (no fundo do ecrã)
COLUNA_MEIO_ECRA		EQU  30     ; coluna inicial do Rover (a meio do ecrã)

LINHA_INICIAL           EQU 1		; linha inicial do meteoro neutro
LINHA_METEORO_NEUTRO_2  EQU 4		; linha após se aumentar o tamanho do meteoro neutro

LINHA_INICIAL_METEOROS  EQU 4     	; Linha onde os meteoros nascem
LINHA_TRANSICAO_1       EQU 180H    ; Linha em que os meteoros mudam da 1ª para a 2ª fase
LINHA_TRANSICAO_2       EQU 380H    ; Linha em que os meteoros mudam da 2ª para a 3ª fase
LINHA_TRANSICAO_3       EQU 600H    ; Linha em que os meteoros mudam da 3ª para a 4ª fase
LINHA_TRANSICAO_4       EQU 900H    ; Linha em que os meteoros mudam da 4ª para a 5ª fase
                                    ; As 8 colunas onde um meteoro pode 'nascer'
COL_METEORO_1           EQU 30H     ; 1ª coluna de início de um meteoro
COL_METEORO_2           EQU 30H     ; 2ª coluna de início de um meteoro
COL_METEORO_3           EQU 30H     ; 3ª coluna de início de um meteoro
COL_METEORO_4           EQU 30H     ; 4ª coluna de início de um meteoro
COL_METEORO_5           EQU 30H     ; 5ª coluna de início de um meteoro
COL_METEORO_6           EQU 30H     ; 6ª coluna de início de um meteoro
COL_METEORO_7           EQU 30H     ; 7ª coluna de início de um meteoro
COL_METEORO_8           EQU 30H     ; 8ª coluna de início de um meteoro


MIN_COLUNA	        	EQU 0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA	        	EQU 63      ; número da coluna mais à direita que o objeto pode ocupar
ATRASO_ROVER		    EQU	0400H	; atraso para limitar a velocidade de movimento do Rover
ATRASO_EXPLOSAO		    EQU	0FFFFH	; atraso para "atrasar" fim do jogo após rover explodir

; ********************
; * Outras constantes
; ********************
MAX_ENERGIA		        EQU 64H     ; Energia do Rover ao começar o jogo (100 em hexadecimal)
MIN_ENERGIA             EQU 0H      ; Energia mínima do Rover
ENERGIA_METEORO_BOM 	EQU 20H		; Energia que "consumir" um meteoro bom fornece

; **********************
; * Constantes de cores
; **********************
CASTANHO	        	EQU	0FA52H	; cor castanho do rover	
AZUL		        	EQU	0F00FH	; cor azul do rover e disparos
ROSA_EXP	        	EQU	04F0EH  ; Cor rosa da explosão dos meteoros
VERDE_FORA	        	EQU	0F0F0H	; Meteoros bons
VERDE_DENTRO	        EQU	060F0H	; Meteoros bons
VERMELHO	         	EQU	0FF00H	; Meteoros maus
CINZENTO	         	EQU	0C777H	; Cor neutra - Meteoros de longe

; *********************************************************************************
; * Dados
; *********************************************************************************
PLACE   1000H

    STACK 100H
SP_programa_principal:

    STACK 100H
SP_teclado_rover:

    STACK 100H
SP_display_energia:

    STACK 100H
SP_desce_meteoro:

	STACK 100H
SP_dispara_missil:

	STACK 100H
SP_testa_colisoes:

tecla_continua:
	LOCK 0

tecla_carregada:
	LOCK 0

missil:
	LOCK 0

; --------------------- Tabelas de interrupcoes --------------------- ;
tab:
	WORD rot_int_0			; rotina de atendimento da interrupção 0
	WORD rot_int_1			; rotina de atendimento da interrupção 1
	WORD rot_int_2			; rotina de atendimento da interrupção 2

evento_int:
	LOCK 0				; se 1, indica que a interrupção 0 ocorreu
	LOCK 0				; se 1, indica que a interrupção 1 ocorreu
	WORD 0				; se 1, indica que a interrupção 2 ocorreu
; ------------------------------------------------------------------- ;
missíl_ativo:
	WORD 0 ; se estiver 1 significa que o missíl foi disparado
modo_jogo:
    WORD 0 ; o modo do jogo define o seu estado
           ; 0 - o jogo está para começar ou à para recomeçar
           ; 1 - o jogo está a decorre
           ; 2 - em pausa,  e 3 signfica que o jogo acabou

;---------------------------------------------------------------------------------;
;--------------------Tabelas de Figuras dos vários Bonecos------------------------;
;---------------------------------------------------------------------------------;
  
FIG_ROVER:			    	; Tabela que define o rover.
							; A primeira linha desta tabela contém a 1ª linha do Rover a contar de baixo.
							; A linha e coluna são alteradas quando o Rover é movimentado
	WORD 5, 4               ; Dimensões do rover (5 pixels de largura, 4 de altura)

	WORD 0, CASTANHO, 0, CASTANHO, 0
	WORD CASTANHO, AZUL, CASTANHO, AZUL, CASTANHO
	WORD CASTANHO, 0, AZUL, 0, CASTANHO
	WORD 0, 0, CASTANHO, 0, 0
     
FIG_METEORO_NEUTRO_1:           ; Definição do primeiro meteoro neutro
    WORD 1,1                ; Largura e altura do meteoro (1x1 pixels)

    WORD CINZENTO 

FIG_METEORO_NEUTRO_2:           ; Definição do segundo meteoro neutro
    WORD 2,2                ; Largura e altura do meteoro (2x2 pixels)

	WORD CINZENTO,      CINZENTO
    WORD CINZENTO,      CINZENTO

FIG_METEORO_BOM_1:              ; Definição do primeiro meteoro bom
    WORD 3,3                ; Largura e altura do meteoro (3x3 pixels)

    WORD 0,             VERDE_FORA,     0
    WORD VERDE_FORA,    VERDE_DENTRO,   VERDE_FORA
    WORD 0, VERDE_FORA, 0

METEORO_BOM_2:              ; Definição do segundo meteoro bom
    WORD 4,4                ; Largura e altura do meteoro (4x4 pixels)

    WORD 0,             VERDE_FORA,     VERDE_FORA,     0
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA
    WORD VERDE_FORA,    VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD 0,             VERDE_FORA,     VERDE_FORA,     0

METEORO_BOM_3:              ; Definição do terceiro meteoro bom
    WORD 5,5                ; Largura e altura do meteoro (5x5 pixels)

    WORD 0,             VERDE_FORA,     VERDE_FORA,     VERDE_FORA,     0
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD VERDE_FORA,    VERDE_DENTRO,   VERDE_DENTRO,   VERDE_DENTRO,   VERDE_FORA
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD 0,             VERDE_FORA,     VERDE_FORA,     VERDE_FORA,     0

METEORO_MAU_1:              ; Definição do primeiro meteoro mau
    WORD 3,3                ; Largura e altura do meteoro (3x3 pixels)

    WORD VERMELHO,  VERMELHO,   VERMELHO
    WORD 0,         VERMELHO,   0
    WORD VERMELHO,  0,          VERMELHO

METEORO_MAU_2:              ; Definição do segundo meteoro mau
    WORD 4,4                ; Largura e altura do meteoro (4x4 pixels)

    WORD VERMELHO,  VERMELHO,   VERMELHO,   VERMELHO
    WORD 0,         VERMELHO,   VERMELHO,   0
    WORD VERMELHO,  0,          0,          VERMELHO
    WORD VERMELHO,  0,          0,          VERMELHO

FIG_METEORO_MAU_3:              ; Definição do terceiro meteoro mau
    WORD 5,5                ; Largura e altura do meteoro (5x5 pixels)

    WORD VERMELHO,  0,          0,          0,          VERMELHO
    WORD VERMELHO,  0,          VERMELHO,   0,          VERMELHO
    WORD 0,         VERMELHO,   VERMELHO,   VERMELHO,   0
    WORD 0,         VERMELHO,   VERMELHO,   VERMELHO,   0
    WORD VERMELHO,  0,          0,          0,          VERMELHO

FIG_EXPLOSAO:                   ; Definição das explosões
    WORD 5, 5

    WORD 0,         ROSA_EXP,   0,          ROSA_EXP,   0
	WORD ROSA_EXP,  0,          ROSA_EXP,   0,          ROSA_EXP
    WORD 0,         ROSA_EXP,   0,          ROSA_EXP,   0
    WORD ROSA_EXP,  0,          ROSA_EXP,   0,          ROSA_EXP
    WORD 0,         ROSA_EXP,   0,          ROSA_EXP,      0

FIG_DISPARO:                    ; Definição dos disparos da nave
	WORD LARGURA_ALTURA_DISPARO, LARGURA_ALTURA_DISPARO

    WORD AZUL


;---------------------------------------------------------------------------------;
;-------------------------Posições dos vários Bonecos-----------------------------;
;---------------------------------------------------------------------------------;
POS_DISPARO:
	WORD LINHA_DISPARO, COLUNA_MEIO_ECRA ; Valor inicial p/ o disparo. Caso não esteja inicializado,
										 ; será colocado em cima do Rover
	WORD FIG_DISPARO

POS_ROVER:
	
	WORD LINHA_FUNDO_ECRA, COLUNA_MEIO_ECRA
	WORD FIG_ROVER


NR_METEOROS             EQU 2       ; Nº de meteoros que existem no jogo.
;FIXME: Quando tivermos a rotina de escolher um valor aleatório, alterar isto para ser só uma tabela

POS_METEOROS:
POS_METEORO_1:			WORD  LINHA_INICIAL_METEOROS, COLUNA_MEIO_ECRA, FIG_METEORO_MAU_3
POS_METEORO_2: 			WORD  LINHA_INICIAL_METEOROS, COL_METEORO_4, FIG_METEORO_NEUTRO_2
;POS_METEOROS:        	TABLE 6H    ; Tabela que guarda os N meteoros.
                                    ; Cada meteoro ocupa 3 WORDs (A linha, coluna e a sua figura)
                                    ; Quando o nº de meteoros se quer alterado,
                                    ; multiplicar o  valor de NR_METEOROS por 3 e alterar aqui



; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                              ; o código tem de começar em 0000H
inicio:
    MOV  SP, SP_programa_principal			       ; inicializa SP para a palavra a seguir
    MOV  [APAGA_AVISO], R1		   	   ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1		   	   ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    MOV	 R1, 0				   		   ; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1 ; seleciona o cenário de fundo
    MOV  R7, 1				   		   ; valor a somar à coluna do boneco, para o movimentar

  	MOV  BTE, tab		; inicializa BTE (registo de Base da Tabela de Exceõees)
    EI0					; permite interrupções 0
	EI1					; permite interrupções 1
	EI2					; permite interrupções 2
	EI					; permite interrupções (geral) 

    CALL inicializa_energia            ; Inicialização do display de energia
    JMP  ecra_inicial 		           ; Ecrã de início de jogo


inicializa_energia:						
    PUSH R4
    MOV  R4, DISPLAYS

    MOV  R8, MAX_ENERGIA            ; Energia inicial
	CALL escreve_decimal 			; escreve 100 nos displays

    POP R4
    RET


ecra_inicial:
	MOV  R6, LINHA_START				; linha a testar no teclado
	CALL	teclado						; leitura às teclas
	CMP	R0, TECLADO_1  					; compara para ver se a tecla C foi premida
	JNZ ecra_inicial					; se não foi premida, espera-se que seja premida para começar o jogo
	MOV  [APAGA_ECRÃ], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 1							; cenário de fundo número 1
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    CALL desenha_rover                  ; desenha o rover 
	CALL desenha_um_meteoro       	 	; Desenha o meteoro inicial no topo do ecrã

	CALL reset_int_2

    CALL le_tecla_rover
    CALL testa_tecla_descer_meteoro
    CALL interrupcao_energia
	CALL le_tecla_missil
	CALL testa_colisoes

; **********************************************************************
; * Rotina que testa colisões entre todos os meteoros e o míssil/rover.
; **********************************************************************
PROCESS SP_testa_colisoes
testa_colisoes:
	YIELD
	CALL testa_estado_jogo

	MOV R3, POS_ROVER					; Testar colisões meteoro-rover.
	CALL aux_testa_colisoes
	MOV R1, [missíl_ativo]
	CMP R1, 1
	JNZ testa_colisoes
	MOV R3, POS_DISPARO					; Testar colisões meteoro-míssil.
	CALL aux_testa_colisoes

	JMP testa_colisoes					; Fim

aux_testa_colisoes:						; Testa colisões meteoro-rover.
	MOV R1, POS_METEOROS				; Inicializa R1 ao 1º meteoro
	MOV R5, NR_METEOROS					; Testa colisão para cada um dos N meteoros
loop_colisoes:
	SUB R5, 1							; Menos um meteoro a tratar
	CALL testa_colisao					; Testar colisão
	CMP R0, 0							; Testar se houve colisão
	JNZ tratar_colisao_meteoro_mau_rover; Tratar colisão ;FIXME: this ain't right! gotta be more generic...
	ADD R1, 6							; Endereço do meteoro seguinte
	CMP R5, 0							; Verificar se ainda há meteoros a tratar
	JNZ loop_colisoes					; Tratar o meteoro seguinte
	RET									; Retornar


; **********************************************************************
; * Rotinas que tratam do comportamento de colisões.
; * Casos que são tratados:
; * 	- Colisão rover-meteoro mau: som de explosão, 
; *			substituir rover por explosão, acabar jogo
; * 	- Colisão rover-meteoro bom: som de powerup, apagar meteoro, aumentar display
; *  	- Colisão míssil-meteoro: som de explosão, substituir meteo. por explosão,
; *			apagar míssil e meteoro, aumentar display (?)
; * FIXME: implementar isto tudo
; * Ver se é melhor separar rotinas, 
; * já que o testa colisões trata cada caso separadamente
; **********************************************************************
tratar_colisao_meteoro_mau_rover: ; Assumindo meteoro em R3 (FIXME: doesn't matter)
	PUSH R1
	MOV R1, POS_ROVER+4     ; Endereço da figura do Rover
	MOV R3, FIG_EXPLOSAO
	MOV [R1], R3			; Rover é substituído por figura de explosão
	SUB R1, 4				; Endereço normal do Rover
	CALL desenha_boneco		; Desenha uma explosão na posição do Rover
	CALL atraso_colisao     ; Pequeno atraso antes de fim do jogo
	CALL atraso_colisao     ; 	Não usar uma interrupção para fazer um atraso
	CALL atraso_colisao     ; 	para ter a certeza que não existe comportamento indesejado.
	CALL atraso_colisao     
	JMP termina_jogo		; Acabou o jogo

tratar_colisao_meteoro_bom_rover: ; Assumindo meteoro EM R1 E ROVER EM R3
	PUSH R1
	MOV R1, POS_ROVER+4     ; Endereço da figura do Rover
	MOV R3, FIG_EXPLOSAO
	MOV [R1], R3			; Rover é substituído por figura de explosão
	SUB R1, 4				; Endereço normal do Rover
	CALL desenha_boneco		; Desenha uma explosão na posição do Rover
	CALL atraso_colisao     ; Pequeno atraso antes de fim do jogo
	JMP termina_jogo		; Acabou o jogo

	
; **********************************************************************
; * Rotina esta se ocorreu uma colisão entre dois bonecos.
; * Argumentos:    R1 - Definição do boneco A
; * Argumentos:    R3 - Definição do boneco B
; * Outros registos usados:
;				   R2 - Figura do boneco A
;				   R4 - Figura do boneco B
;
; Retorna: 	R0 - 0 caso não haja colisão, 1 caso contrário
; fixme: REMOVE L8r
; Condições em que não há colisão:
; 	Se coluna do canto sup. esq. de B estiver à direita 
;   do canto inferior direito de A não há colisão
; * 
; Condições em que há colisão;
; Canto superior direito de A está à direita ou coincide com o 
;     canto inf esq. de B AND 
; ******************************************************************

testa_colisao:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	MOV R2, [R1+4]	  ; Def. de A + 4 = figura de A
	MOV R4, [R3+4]    ; Figura de B
	JMP caso_colisao_horizontal

; R5 -> limite inferior de A
; R6 -> limite inferior de A
; R7 -> Registo auxiliar
caso_colisao_horizontal:	; Verificar se a linha inferior de A é está abaixo do limite superior de B
					; Caso positivo, poderá haver colisão
					; Por convenção, A(R1) será sempre um meteoro e B(R3) o Rover ou o míssil
	MOV R5, [R1]	; Limite inferior de A

	MOV R6, [R3]	; Limite inferior de B
	MOV R7, [R4+2]  ; Figura de B + 2 = Altura de B
	ADD R6, R7		; Lim. inf. de B + altura = Lim. sup. de B
	
	CMP R5, R6
	JGE caso_vertical_1_1  ; Testar caso seguinte
	JMP nao_ha_colisao	   ; Impossível haver colisão: sair

;caso_colisao_horizontal_2: ; Não precisamos FIXME: ver RMarkable e remover
caso_vertical_1_1:	; Verificar que lim. dir. de B 
					; está à direita de lim. esq. de A
	MOV R5, [R1+2]	; Limite esquerdo de A

	MOV R6, [R3+2]	; Limite esquerdo de B
	MOV R7, [R4]	; Largura de B
	ADD R6, R7		; Lim. esq. de B + largura = Lim. dir. de B
	CMP R6, R5		; (Col. do lim. dir. de B) > (Col. do lim. esq. de A)?
	JGE caso_vertical_1_2	; Passar ao caso seguinte
	JMP caso_vertical_2_1	; Ainda é possível haver colisão no 2º caso

caso_vertical_1_2: 	; Verificar que lim. esq. de B NÃO está à direita
					; de lim. dir. de A
	MOV R5, [R1+2]	; Limite esquerdo de A
	MOV R7, [R2]	; Largura de A
	ADD R5, R7		; Lim esq. de A + largura = lim. dir. de A

	MOV R6, [R3+2]	; Lim. esq. de B
	CMP R6, R5		; (Col. do lim. esq. de B) > (Col. do lim. dir. de A)?
	JGE	nao_ha_colisao			; Se sim, é impossível haver colisão
	JMP ha_colisao	; Caso contrário, temos colisão

caso_vertical_2_1:	; Verificar que lim. esq. de B
					; está à esquerda de limite direito de A
	MOV R5, [R1+2]	; Limite esquerdo de A
	MOV R7, [R2]	; Largura de A
	ADD R5, R7		; Lim esq. de A + largura = lim. dir. de A

	MOV R6, [R3+2]	; Limite esquerdo de B
	CMP R6, R5		; (Col. do lim. esq. de B) < (Col. do lim. dir. de A)?
	JLE caso_vertical_2_2 ; Se sim, tesstar caso seguinte
	JMP nao_ha_colisao	; Caso contrário, é impossível haver colisão

caso_vertical_2_2:  ; Verificar que lim. dir. de B
					; NÃO está à esq. de lim. esq. de A
	MOV R5, [R1+2]	; Limite esquerdo de A
	
	MOV R6, [R3+2]	; Limite esquerdo de B
	MOV R7, [R4]	; Largura de B
	ADD R6, R7		; Lim. esq. de B + altura = lim. dir. de B
	CMP R6, R5		; (Col. do lim. dir. de B) < (Col. do lim. esq. de A)?
	JLT	nao_ha_colisao	; Se sim, é impossível haver colisão
	JMP ha_colisao  ; Caso contrário, há colisão



caso_colisao_1_2:
	JMP sai_testa_colisao

ha_colisao:
	MOV R0, 1
	JMP sai_testa_colisao

nao_ha_colisao:
	MOV R0, 0
	JMP sai_testa_colisao
	
sai_testa_colisao:
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET


; ***************************************************************
; * Desenha um meteoro neutro no tamanho máximo, no meio do ecrã.
; ***************************************************************
PROCESS SP_desce_meteoro
testa_tecla_descer_meteoro:

    YIELD

    CALL testa_estado_jogo
	MOV  R6, TECLADO_3 					; Argumento de 'teclado' (testa 3ª linha)
	CALL teclado           				; Output em R0
	MOV R2, TECLADO_1        			; Tecla de descer o meteoro (3ª linha, 1ª coluna = tecla 'B')
	CMP R0, R2             				; Verificar se a tecla de descer o meteoro foi premida
	JZ  desce_meteoro
	JMP testa_tecla_descer_meteoro

desce_meteoro: 							; Rotina a ser generalizada na entrega final.
    MOV [tecla_carregada], R2            ; informa quem estiver bloqueado neste LOCK que uma tecla foi carregada

	MOV R1, POS_METEORO_1				; Tabela que define o meteoro
	MOV R2, [R1]           				; Obtém a linha atual do meteoro
	MOV R3, LINHA_FUNDO_ECRA
	CALL apaga_boneco     				; Apagar o meteoro na posição atual
	CMP R2, R3             				; Testa se o meteoro está na última linha do ecrã
	JZ sai_desce_meteoro  				; Se estiver, então não atualizar a linha
	ADD R2, 1             				; Desce o meteoro uma linha (incrementa a linha atual)
	MOV [R1], R2           				; Atualiza a linha do meteoro
	CALL desenha_um_meteoro
    JMP sai_desce_meteoro
    
sai_desce_meteoro:
	MOV R10, 1
	MOV R6, 4
    CALL ha_tecla
    JMP testa_tecla_descer_meteoro

; *********************************************************************************
; * Desenha o rover no ecrã.
; *********************************************************************************
PROCESS SP_teclado_rover
le_tecla_rover:							; Verificar se uma tecla para mover o rover está pressionada
    
    YIELD

    CALL testa_estado_jogo
	MOV  R6, LINHA_TECLADO				; linha a testar no teclado
	CALL	teclado						; leitura às teclas
	CMP	R0, 0
	JZ	le_tecla_rover			; se não há tecla pressionada, sair da rotina
	CMP	R0, TECLADO_1
	JNZ	testa_direita

    MOV [tecla_continua], R0

	MOV	R7, -1							; vai deslocar para a esquerda
	CALL atraso_rover
	JMP	ve_limites_rover

testa_direita:
	CMP	R0, TECLADO_3 					; verifica se a tecla para mover o rover para a direita foi premida
	JNZ	le_tecla_rover

    MOV [tecla_continua], R0

	MOV	R7, +1							; vai deslocar para a direita
	CALL atraso_rover 						; se mover, chama a rotina atraso para não mover demasiado rápido
	JMP    ve_limites_rover 			; verifica se ao mover o rover os limites do ecrã não são ultrapassados

ve_limites_rover:
	CALL	testa_limites				; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP	R7, 0
	JZ le_tecla_rover				; se não é para movimentar o objeto, sai da rotina
	CALL     move_rover         		; Caso contrário, movimentar rover
	JMP le_tecla_rover  	

; *********************************************************************************
; * Pausa e fim do jogo
; *********************************************************************************

testa_pausa:
	MOV R6, LINHA_START 				; guarda no registo R6 a 4ª linha
	CALL teclado 						; chama a rotina teclado
	CMP R0, COLUNA_2 					; verifica se  a tecla D é premida
	JZ pausa 							; se for vai para pausa
	RET 								; se não for premida a tecla D, fa-ze return

pausa:
	MOV  [APAGA_ECRÃ], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 4							; cenário de fundo número 4
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV R10, 2
    CALL ha_tecla
	JMP recomeca 						; vai para a rotina recomeça

recomeca:								; volta ao ecrã do jogo
	MOV R6, LINHA_START 				; guarda no registo R6 
	CALL nao_ha_tecla 					; fica à espera que uma tecla seja pressionada
	MOV	R1, 1 							; guarda no registo R1 o valor 1(vai-se selecionar o cenário número 1)
	MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	CALL reset_int_2					; evita que a energia diminua imediatamente no recomeco, 

	CALL ha_tecla	   					; espera que se largue D, caso contrário voltaria ao ciclo de novo
					   					; (ficando preso no menu)

	CALL desenha_rover 					; desenhar o rover novamente
	CALL desenha_um_meteoro
    RET

testa_fim:
	MOV  R6, LINHA_START				; linha a testar no teclado
	CALL	teclado						; leitura às teclas
	CMP	R0, TECLADO_3					; verifica se a tecla E foi premida
	JZ termina_jogo 					; se foi premida, termina-se o jogo
	RET 								; se não foi premida faz-se return

termina_jogo: 
	MOV  [APAGA_ECRÃ], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 2							; cenário de fundo número 2
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; muda cenário de fundo
    JMP fim       						; termina o jogo

fim: JMP fim 							; termina o jogo


testa_estado_jogo:
    CALL testa_pausa
    CALL testa_fim
    RET

; *********************************************************************************
; * Escreve nos displays de energia.
; *********************************************************************************

desenha_um_meteoro:
    PUSH R1
	MOV R1, POS_METEORO_1
	CALL desenha_boneco
    POP R1
	RET

desenha_rover:
    PUSH R1
	MOV R1, POS_ROVER   				; Endereço da tabela que define o Rover (argumento de desenha_boneco)
	CALL desenha_boneco
    POP R1
	RET

escreve_decimal:
	PUSH R0		; fator
	PUSH R1		; digito
	PUSH R2		; resultado
	PUSH R10
	PUSH R11	; num

	MOV R11, R8	

	MOV R0, 1000 ; fator inicial
	MOV R10, 10	 ; R10 - registo com o valor 10 fixo

ciclo_conversao:
	MOD R11, R0	; resto do numero pelo fator
	
	DIV R0, R10	; divisao inteira do fator por 10

	MOV R1, R11	; digito = numero
	DIV R1, R0	; divisao do digito pelo fator

	SHL R2, 4	; passa os digitos para a esquerda
	OR R2, R1	; e escreve o proximo digito

	CMP R0, R10	 
	JGE ciclo_conversao	; se o fator for inferior a 10, acaba o ciclo

	MOV [R4], R2	; escreve o resultado nos displays e retorna, a seguir

	POP R11
	POP R10
	POP R2
	POP R1
	POP R0

	RET

PROCESS SP_display_energia
interrupcao_energia:

    YIELD

	MOV R4, DISPLAYS
    MOV R5, evento_int
    MOV R2, [R5+4]			; Vai buscar o valor da interrupcao 2 na tabela evento_int
    CMP R2, 0				; Verifica se a interrupção aconteceu
    JZ mid_energia			; Valor 0 - sem interrupção - salta para a escrita nos displays

	MOV R2, 0				; Registo auxiliar
	MOV [R5+4], R2			; "Consome" a interrupção

	CALL diminui_cinco		; Diminuir display em 5 valores
	JMP interrupcao_energia	; Reiniciar processo

mid_energia:
    CALL testa_estado_jogo

pop_e_espera:		  					; no caso de alguma das teclas estar premida, espera ate largar
	MOV R10, TECLADO_4			  		; procura na coluna 4
    CALL ha_tecla
    JMP interrupcao_energia

aumenta_cinco:
	PUSH R1
	MOV R1, 5
	CALL aumenta_display
	POP R1
	RET

diminui_cinco:
	PUSH R1
	MOV R1, 5
	CALL diminui_display
	POP R1
	RET

aumenta_display:	; Funcao generica de alteracao da energia
					; (Necessita de funcao auxiliar para determinar o valor do aumento)
	PUSH R9

    MOV  [tecla_carregada], R0
    MOV R9, MAX_ENERGIA   
    SUB R9, R1
	CMP R9, R8			  				; limite superior atingido (100) - salta a adição
    JLE maxim_energia 
         
    ADD R8, R1			  				; R8 <- R8 + 1

	JMP  _escreve_decimal				; escreve nos displays, em decimal
     
maxim_energia:		; Caso o valor da energia seja igual ou superior ao limite, 
					; coloca o display a 100
	MOV R8, 064H

_escreve_decimal:
	CALL escreve_decimal
	POP R9
	RET


diminui_display:	; Funcao generica de alteracao da energia
					; (Necessita de funcao auxiliar para determinar o valor da diminuicao)
	PUSH R9
    MOV [tecla_carregada], R0
    MOV R9, 0
    ADD R9, R1
	CMP R9, R8							; limite inferior atingido (0) - Fim de jogo!
    JGE termina_jogo_

    SUB R8, R1							; R8 <- R8 - 1
	JMP __escreve_decimal


termina_jogo_:
	MOV R8, 0							; Registo auxiliar
	CALL escreve_decimal				; Escreve zero nos displays de energia
	JMP termina_jogo					; Acabou

__escreve_decimal:
    CALL escreve_decimal				; escreve nos displays, em decimal
	POP R9
    RET

; *********************************************************************
; * MOVE_ROVER (move_rover, coluna_seguinte)
; * Argumentos:
; *    - R7-> a -1 ou 1; mover o boneco ou para a esquerda ou direita.
; * Outros registos usados:
; *    - R1-> Definição do Rover
; *    - R2-> Endereço
; *********************************************************************
move_rover:
	PUSH R1
	MOV  R1, POS_ROVER           ; Argumento do apaga_boneco
	CALL apaga_boneco		; apaga o boneco na sua posição corrente
	POP  R1
	JMP  coluna_seguinte

coluna_seguinte:
	PUSH R1             			; Guarda R1
	PUSH R2             			; Guarda R2
	MOV  R1, POS_ROVER   			; Endereço do desenho do rover
	ADD  R1, 2           			; Endereço da coluna atual do rover
	MOV  R2, [R1]        			; Coluna atual do rover
	ADD  R2, R7          			; Altera coluna atual p/ desenhar o objeto na coluna seguinte (esq. ou dir)
	MOV  [R1], R2        			; Escreve a nova coluna na memória do rover
	PUSH R11
	CALL desenha_rover				; vai desenhar o boneco de novo
	POP  R11
	POP R2
	POP R1
	RET 				 			; Acaba rotina de move_rover
	

; **********************************************************************
; DESENHA_BONECO - Desenha um boneco a partir da linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:    R1 - Tabela que contém posição e figura do boneco
;
; Outros registos usados:
;                R2 - Linha de referência do boneco
;                R3 - Coluna de referência do boneco
;                R4 - Largura do boneco
;                R5 - Altura do boneco
;                R6 - Cor do pixel a ser desenhado
;                R7 - Tabela da figura do boneco
;                R11 - Cópia de endereço original de R7
; A posição e dimensões do boneco são lidas a partir da tabela.
;
; **********************************************************************
desenha_boneco:
	PUSH    R1              
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH    R6
    PUSH    R7
	PUSH    R11

	MOV R2, [R1]            ; Obtém a linha de posição do boneco

	ADD R1, 2               ; Endereço da coluna de posição
	MOV R3, [R1]			; Obtém a coluna de posição do boneco

    ADD R1, 2               ; Endereço que contém endereço da figura do boneco
    MOV R7, [R1]            ; Figura do boneco
	MOV R11, R7 			; Cópia do endereço da figura
	SUB R1, 4 				; Volta ao endereço da linha de posição

	MOV R4, [R7]            ; Obtém a largura do boneco

	ADD R7, 2               ; Endereço da altura do boneco
	MOV R5, [R7]            ; Obtém a altura do boneco

	ADD	R7, 2				; Endereço da cor do 1º pixel (2 porque a largura é uma word)
	JMP desenha_linha   	; Começar a desenhar a linha

desenha_muda_linha:
;	PUSH R11           	   ; Salvaguardar endereço
	ADD R1, 2      	       ; Endereço da coluna inicial do boneco
	MOV R3, [R1]           ; Voltar à coluna inicial
	SUB R1, 2			   ; Voltar ao endereço inicial (linha do boneco)
;	ADD R11, 2             ; Endereço da largura do boneco
	MOV R4, [R11]          ; Reinicializa a largura do boneco
;	SUB R11, 2			   ; Volta ao endereço inicial da figura
	SUB R2, 1              ; Passa a escrever na linha de cima do Mediacenter
	SUB R5, 1              ; Decrementa a altura do boneco (menos uma linha a tratar)
	
;	POP R11
	JNZ desenha_linha      ; Desenhar a nova linha
	JMP sai_desenha_boneco ; Caso não haja nova linha, sair


desenha_linha:             ; Desenha uma linha de pixels do boneco a partir da tabela
    MOV R6, [R7]           ; Obtém a cor do próxima pixel do boneco
	CALL escreve_pixel     ; Escreve o pixel atual
	ADD R7, 2	           ; Endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
	ADD R3, 1              ; Próxima coluna
	SUB R4, 1              ; Diminui largura do boneco (menos uma coluna a tratar)
	JNZ desenha_linha      ; Desenhar  próxima coluna
	JMP desenha_muda_linha ; Caso não haja mais colunas, passar à próxima linha


sai_desenha_boneco:
	POP R11
    POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET

; **********************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:    R1 - tabela que define o boneco


; Outros registos usados:
;                R2 - Linha de referência do boneco
;                R3 - Coluna de referência do boneco
;                R4 - Largura do boneco
;                R5 - Altura do boneco
;                R6 - Cor do pixel (sempre 0)
;                R7 - Tabela de figura do boneco
;                R11 - Cópia do endereço da figura
;
;
; **********************************************************************

apaga_boneco:
	PUSH    R1
	PUSH    R2
	PUSH    R3
	PUSH    R4
	PUSH    R5
	PUSH    R6
	PUSH	R7
	PUSH    R11
	MOV 	R2, [R1] ; Obtém a linha de referência do boneco

	ADD 	R1, 2    ; Endereço da coluna de referência do boneco
	MOV 	R3, [R1] ; Obtém a coluna de referência do boneco

	ADD 	R1, 2    ; Endereço da figura do boneco
	MOV 	R7, [R1] ; Obtém a figura do boneco
	MOV 	R11, R7  ; Guarda cópia do endereço da figura
	MOV 	R4, [R7] ; Obtém a largura do boneco

	ADD 	R7, 2    ; Endereço da altura do boneco
	MOV 	R5, [R7] ; Obtém a altura do boneco
	SUB     R1, 4    ; Volta ao endereço original da posição do boneco
	JMP 	apaga_linha


apaga_muda_linha:
	ADD		R1, 2              ; Endereço da coluna inicial do boneco
	MOV 	R3, [R1]		   ; Voltar à coluna inicial
	SUB  	R1, 2			   ; Volta ao endereço original de R1
;	ADD 	R11, 2             ; Endereço da largura do boneco
	MOV 	R4, [R11]          ; Reinicializa a largura do boneco
	SUB 	R2, 1              ; Passa a escrever na linha de cima do Mediacenter
	SUB 	R5, 1              ; Decrementa a altura do boneco (menos uma linha a tratar)
	JNZ 	apaga_linha        ; Apagar a próxima linha
	JMP 	sai_apaga_boneco   ; Caso não haja próxima linha, sair


apaga_linha:       			; desenha os pixels do boneco a partir da tabela
	MOV	R6, 0				; cor para apagar o próximo pixel do boneco
	CALL	escreve_pixel	; escreve cada pixel do boneco
    ADD  R3, 1          ; próxima coluna
    SUB  R4, 1			; menos uma coluna para tratar
    JNZ  apaga_linha    ; continua até percorrer toda a largura do objeto
	JMP apaga_muda_linha  	; Linha atual acabou - passar à seguinte


sai_apaga_boneco:
	POP R11
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET


; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R2 - linha
;               R3 - coluna
;               R6 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R2		; seleciona a linha
	MOV  [DEFINE_COLUNA], R3	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R6 	; altera a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R1 - valor que define o atraso
;
; **********************************************************************
atraso_rover:
	PUSH R1
	MOV R1, ATRASO_ROVER				; Ciclo de atrasar movimento do rover
	JMP ciclo_atraso
atraso_colisao:
	PUSH R1
	MOV R1, ATRASO_EXPLOSAO				; Ciclo de atrasar fim do jogo após rover explodir
	JMP ciclo_atraso
ciclo_atraso:
	SUB	R1, 1
	JNZ	ciclo_atraso
	POP	R1
	RET

; **********************************************************************
; TESTA_LIMITES - Testa se o Rover chegou aos limites do ecrã e nesse caso
;			   impede o movimento (força R7 a 0)
; Registos Usados:	
;			R1 - Endereço da definição do Rover
;			R2 - coluna em que o objeto está
;			R6 - largura do Rover
;			R7 - sentido de movimento do Rover (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário
; **********************************************************************
testa_limites:
	PUSH    R1
	PUSH    R2
	PUSH	R5
	PUSH	R6
	MOV     R1, POS_ROVER 			; Endereço da definição do Rover
	ADD     R1, 2         			; Endereço da coluna em que o Rover está
	MOV     R2, [R1]      			; Obtém coluna

	ADD     R1, 2         			; Endereço da figura do Rover
	MOV     R11, [R1]				; Figura do Rover

	MOV     R6, [R11]      			; Obtém largura do Rover
	JMP     testa_limite_esquerdo
	
testa_limite_esquerdo:				; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JGT	testa_limite_direito
	CMP	R7, 0				; passa a deslocar-se para a direita
	JGE	sai_testa_limites
	JMP	impede_movimento	; entre limites. Mantém o valor do R7
testa_limite_direito:		; vê se o boneco chegou ao limite direito
	ADD	R6, R2				; posição a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JLE	sai_testa_limites	; entre limites. Mantém o valor do R7
	CMP	R7, 0				; passa a deslocar-se para a direita
	JGT	impede_movimento 	; Impedir movimento se este for p/ a direita
	JMP	sai_testa_limites

impede_movimento:
	MOV	R7, 0				; impede o movimento, forçando R7 a 0
	JMP sai_testa_limites 	; Sair

sai_testa_limites:
	POP	R6
	POP	R5
	POP R2
	POP R1
	RET

; **********************************************************************
; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
; Argumentos:	R6 - linha a testar (em formato 1, 2, 4 ou 8)
;
; Retorna: 	R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)
; **********************************************************************
teclado:
	PUSH	R2
	PUSH	R3
	PUSH	R5
	MOV  R2, TEC_LIN   ; endereço do periférico das linhas
	MOV  R3, TEC_COL   ; endereço do periférico das colunas
	MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6      ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
	AND  R0, R5        ; elimina bits para além dos bits 0-3
	POP	R5
	POP	R3
	POP	R2
	RET


ha_tecla:          	   ; neste ciclo espera-se ate a tecla desejada nao estar premida
    PUSH R0
    PUSH	R2
	PUSH	R3
	PUSH	R5

ht:				       ; ciclo interior do ha_tecla, sem os pushes
    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
	MOV  R3, TEC_COL   ; endereço do periférico das colunas
	MOV  R5, MASCARA

    MOVB [R2], R6      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3

    CMP  R0, R10       ; hé tecla premida? (R10 guarda o valor da coluna pretendida)
    JZ  ht  		   ; se a tecla desejada estiver premida, espera até não haver  
        
    POP	R5
	POP	R3
	POP	R2
    POP R0
	RET

nao_ha_tecla:          ; neste ciclo espera-se ate que se prima a tecla desejada 
					   ; (oposto de ha_tecla)
    PUSH R0
    PUSH	R2
	PUSH	R3
	PUSH	R5
    
nht:			   ; ciclo interior do nao_ha_tecla, sem os push'es
    MOV  R2, TEC_LIN   
	MOV  R3, TEC_COL   
	MOV  R5, MASCARA

    MOVB [R2], R6      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3

    CMP  R0, R10       ; há tecla premida? (R10 tem o valor da coluna, tal como em ha_tecla)
    JNZ  nht      	   ; se a tecla desejada nao estiver premida, repete o ciclo

    POP	R5
	POP	R3
	POP	R2
    POP R0
	RET

rot_int_2:
    PUSH R0
	PUSH R1
	MOV  R0, evento_int
	MOV  R1, 1			; assinala que houve uma interrupção 0
	MOV  [R0+4], R1			; na componente 2 da variável evento_int
	POP  R1
	POP  R0
	RFE

rot_int_0:
	RFE

reset_int_2:
	PUSH R0
	PUSH R1

	MOV R0, evento_int
	MOV R1, 0
	MOV [R0+4], R1
	POP R1
	POP R0
	RET

; **********************************************************************
; ROT_INT_1 - 	Rotina de atendimento da interrupção 1, do missíl
;			Faz simplesmente uma escrita no LOCK que o processo boneco lê.
;			Como basta indicar que a interrupção ocorreu (não há mais
;			informação a transmitir), basta a escrita em si, pelo que
;			o registo usado, bem como o seu valor, é irrelevante
; **********************************************************************
rot_int_1:
	PUSH R0
	PUSH R1
	MOV  R0, evento_int
	MOV  R1, 1			; assinala que houve uma interrupção do missíl
	MOV  [R0+2], R1			; na componente 0 da variável evento_int
	POP  R1
	POP  R0
	RFE

PROCESS SP_dispara_missil
le_tecla_missil:
 	YIELD
	
	CALL testa_estado_jogo
	MOV  R6, TECLADO_1 					; Argumento de 'teclado' (testa 1ª linha)
	CALL teclado           				; Output em R0
	MOV R2, TECLADO_2        			; Tecla de descer o meteoro (1ª linha, 2ª coluna = tecla '1')
	CMP R0, R2             				; Verificar se a tecla de para disparar o missíl foi premida
	JZ  disparo
	JMP le_tecla_missil

disparo:
	MOV R1, POS_DISPARO 				; Tabela que define o disparo
	MOV R2, [R1]           			; Obtém a linha atual do missíl
	CALLF atualiza_coluna_missil
	JMP dispara_missil


dispara_missil:

	MOV R2, 1
	MOV [missíl_ativo], R2

	CALLF desenha_missil

	MOV R4, [evento_int+2]	

	CALL apaga_boneco     				; Apagar o missíl na posição atual

	MOV R1, POS_DISPARO 				; Tabela que define o disparo
	MOV R2, [R1]           			; Obtém a linha atual do missíl
	MOV R3, LINHA_LIMITE_DISPARO
	CMP R2, R3             				; Testa se o missíl chegou ao seu alcance máximo
	JZ reinicia_disparo  				; Se estiver, então não atualizar a linha
	SUB R2, 2             				; Sobe o missíl 2 linhas (decrementa 2 vezes a linha atual)
	MOV [R1], R2           				; Atualiza a linha do disparo
	CALLF desenha_missil
    JMP dispara_missil

reinicia_disparo:
	MOV R0, POS_DISPARO
	MOV R1, LINHA_DISPARO
	MOV [R0], R1
	JMP sai_disparo

sai_disparo:  
	MOV R10, 2
	MOV R6, 1
    CALL ha_tecla
	MOV R1, 0
	MOV [missíl_ativo], R1
    JMP le_tecla_missil

desenha_missil:
	PUSH R1
	MOV R1, POS_DISPARO
	CALL desenha_boneco
    POP R1
	RETF


atualiza_coluna_missil:
    PUSH R1
	PUSH R2
	PUSH R3
	MOV R2, POS_ROVER
	MOV R3, [R2+2]
	ADD R3, 2
	MOV R1, POS_DISPARO
	MOV [R1+2], R3
	POP R3
	POP R2
    POP R1
	RETF