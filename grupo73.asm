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


; **************
; * Periféricos
; **************
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
PAUSA_SOM 				EQU 605EH   ; endereço do comando para pausar um som
ESCONDE_ECRA			EQU 6008H   ; endereço do comando para esconder um ecrã


LINHA_TECLADO	        EQU 1		; linha a testar (1ª linha, 1000b)
LINHA_START 	        EQU 8       ; linha a testar para começar o jogo(4ª linha)
MASCARA		        	EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLADO_1               EQU 1       ; 1ª linha/coluna do teclado
TECLADO_2               EQU 2       ; 2ª linha/coluna do teclado
TECLADO_3               EQU 4       ; 3ª linha/coluna do teclado
TECLADO_4               EQU 8       ; 4ª linha/coluna do teclado
COLUNA_2 			    EQU 2


; **********************************
; * Constantes de bonecos e do ecrã
; **********************************
LINHA_LIMITE_DISPARO 	EQU 5       ; linha limite do alcance do disparo
LINHA_DISPARO 			EQU 27		; linha onde o disparo começa
LARGURA_ALTURA_DISPARO  EQU 1		; largura e altura do disparo(tamanho 1*1)

LINHA_FUNDO_ECRA        EQU  31     ; linha do Rover (no fundo do ecrã)
COLUNA_MEIO_ECRA		EQU  30     ; coluna inicial do Rover (a meio do ecrã)

;LINHA_INICIAL           EQU 1		; linha inicial do meteoro neutro
;LINHA_METEORO_NEUTRO_2  EQU 4		; linha após se aumentar o tamanho do meteoro neutro TODO: remover

LINHA_INICIAL_METEOROS  EQU 0     	; Linha onde os meteoros nascem
LINHA_TRANSICAO_1       EQU 4    ; Linha em que os meteoros mudam da 1ª para a 2ª fase
LINHA_TRANSICAO_2       EQU 7    ; Linha em que os meteoros mudam da 2ª para a 3ª fase
LINHA_TRANSICAO_3       EQU 12    ; Linha em que os meteoros mudam da 3ª para a 4ª fase
LINHA_TRANSICAO_4       EQU 18    ; Linha em que os meteoros mudam da 4ª para a 5ª fase
                                    ; As 8 colunas onde um meteoro pode 'nascer'
COL_METEORO_1           EQU 8	    ; 1ª coluna de início de um meteoro
COL_METEORO_2           EQU 16     ; 2ª coluna de início de um meteoro
COL_METEORO_3           EQU 32     ; 3ª coluna de início de um meteoro
COL_METEORO_4           EQU 48     ; 4ª coluna de início de um meteoro


MIN_COLUNA	        	EQU 0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA	        	EQU 63      ; número da coluna mais à direita que o objeto pode ocupar
ATRASO_ROVER		    EQU	0400H	; atraso para limitar a velocidade de movimento do boneco
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

; Reserva do espaço para as pilhas dos processos
    STACK 100H						; espaço reservado para a pilha do processo "programa principal"
SP_programa_principal:				; este é o endereço com que o SP deste processo deve ser inicializado

    STACK 100H						; espaço reservado para a pilha do processo "teclado rover"
SP_teclado_rover:					; este é o endereço com que o SP deste processo deve ser inicializado

    STACK 100H						; espaço reservado para a pilha do processo "display energia"
SP_display_energia:					; este é o endereço com que o SP deste processo deve ser inicializado

    STACK 100H						; espaço reservado para a pilha do processo "desce meteoro"
SP_desce_meteoro:					; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H						; espaço reservado para a pilha do processo "dispara missíl"
SP_dispara_missil:					; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H						; espaço reservado para a pilha do processo "modo_jogo"
SP_modo_jogo:						; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H						; espaço reservado para a pilha do processo "testa colisões"
SP_testa_colisoes:					; este é o endereço com que o SP deste processo deve ser inicializado

tecla_continua:						; LOCK para o teclado comunicar aos restantes processos que tecla detetou,
	LOCK 0							; enquanto a tecla estiver carregada

tecla_carregada:					; LOCK para o teclado comunicar aos restantes processos que tecla detetou,
	LOCK 0							; uma vez por cada tecla carregada


valor_energia:						; Variavel global da energia - desta forma, os processos podem passar 
	WORD 0							; uns aos outros o valor atual da energia (tal nao acontece com R8,
									; pois cada processo pode ter um valor diferente)

colisao_missil:
	WORD 0							; Caso a variável esteja 1 houve uma colisão entre um meteoro e um missíl
									; , se não houver colisão a variável fica a zero
; --------------------- Tabelas de interrupcoes --------------------- ;
tab:
	WORD int_rel_meteoros			; rotina de atendimento da interrupção 0
	WORD int_rel_missil				; rotina de atendimento da interrupção 1
	WORD int_rel_energia			; rotina de atendimento da interrupção 2

evento_meteoros:					; (INT0) Indica se a interrupção do rel. dos meteoros aconteceu
	LOCK 0

evento_missil:						; (INT1) Indica se a interrupção do rel. do míssil aconteceu
	LOCK 0

evento_energia:						; (INT2) Indica se a interrupção do rel. de energia aconteceu
	WORD 0

; ------------------------------------------------------------------- ;
missil_ativo:
	WORD 0 ; se estiver 1 significa que o missíl foi disparado, a 0 o missíl não está em movimento

modo:
	LOCK 0 ; variável do tipo LOCK usada para bloquear processos caso o estado do jogo não seja ativo
	
modo_jogo:
    WORD 0 ; o modo do jogo define o estado do jogo
           ; 0 - o jogo está para começar
		   ; 1 - o jogo está a decorrer
           ; 2 - o jogo está em pausa/ para ser retomado
           ; 3 - o jogo acabou/ está à espera que um novo jogo seja começado

cenario_fim:
	WORD 2 ; cenario para o fim de jogo, caso o utilizador tenha perdido mete-se uma imagem diferente
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

FIG_METEORO_BOM_2:              ; Definição do segundo meteoro bom
    WORD 4,4                ; Largura e altura do meteoro (4x4 pixels)

    WORD 0,             VERDE_FORA,     VERDE_FORA,     0
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA
    WORD VERDE_FORA,    VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD 0,             VERDE_FORA,     VERDE_FORA,     0

FIG_METEORO_BOM_3:              ; Definição do terceiro meteoro bom
    WORD 5,5                ; Largura e altura do meteoro (5x5 pixels)

    WORD 0,             VERDE_FORA,     VERDE_FORA,     VERDE_FORA,     0
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD VERDE_FORA,    VERDE_DENTRO,   VERDE_DENTRO,   VERDE_DENTRO,   VERDE_FORA
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD 0,             VERDE_FORA,     VERDE_FORA,     VERDE_FORA,     0

FIG_METEORO_MAU_1:              ; Definição do primeiro meteoro mau
    WORD 3,3                ; Largura e altura do meteoro (3x3 pixels)

    WORD VERMELHO,  VERMELHO,   VERMELHO
    WORD 0,         VERMELHO,   0
    WORD VERMELHO,  0,          VERMELHO

FIG_METEORO_MAU_2:              ; Definição do segundo meteoro mau
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
							; Largura e altura do disparo (1x1 pixels)
	WORD LARGURA_ALTURA_DISPARO, LARGURA_ALTURA_DISPARO

    WORD AZUL


;---------------------------------------------------------------------------------;
;-------------------------Posições dos vários Bonecos-----------------------------;
;---------------------------------------------------------------------------------;
POS_DISPARO:
	WORD LINHA_DISPARO, COLUNA_MEIO_ECRA                           ; Valor inicial p/ o disparo. Caso não esteja inicializado
																   ; será colocado em cima do Rover
	WORD FIG_DISPARO

POS_ROVER:
	WORD LINHA_FUNDO_ECRA, COLUNA_MEIO_ECRA
	WORD FIG_ROVER


NR_METEOROS             EQU 4       ; Nº de meteoros que existem no jogo.

POS_METEOROS:	
POS_METEORO_1:			WORD  LINHA_INICIAL_METEOROS, COL_METEORO_1, FIG_METEORO_NEUTRO_1
POS_METEORO_2: 			WORD  LINHA_INICIAL_METEOROS, COL_METEORO_2, FIG_METEORO_NEUTRO_1
POS_METEORO_3: 			WORD  LINHA_INICIAL_METEOROS, COL_METEORO_3, FIG_METEORO_NEUTRO_1
POS_METEORO_4: 			WORD  LINHA_INICIAL_METEOROS, COL_METEORO_4, FIG_METEORO_NEUTRO_1

; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                              ; o código tem de começar em 0000H
inicio:
    MOV  SP, SP_programa_principal	   ; inicializa SP do programa principal
    MOV  [APAGA_AVISO], R1		   	   ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1		   	   ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	 R1, 0				   		   ; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1 ; seleciona o cenário de fundo

  	MOV  BTE, tab		; inicializa BTE (registo de Base da Tabela de Exceções)
    EI0					; permite interrupções 0
	EI1					; permite interrupções 1
	EI2					; permite interrupções 2
	EI					; permite interrupções (geral) 

	CALL inicializa_energia            ; Inicialização do display de energia
	CALL reset_int_2				   ; Reset da interrupçao responsavel pela diminuicao da energia

	CALL testa_estado_jogo			   ; cria o processo responsável por ver qual o modo de jogo
    CALL le_tecla_rover				   ; cria o processo teclado por mover o rover
    CALL gerir_meteoros				   ; cria o processo teclado por gerir os meteoros
	CALL testa_colisoes				   ; cria o processo teclado por testar as colisões
    CALL interrupcao_energia		   ; cria o processo teclado pela interrupção da energia
	CALL le_tecla_missil			   ; cria o processo teclado pelo disparo do missíl



; **********************************************************************
; * Processo de controlo: 
; * para as teclas começar, suspender/continuar, terminar o jogo e recomeçar
; **********************************************************************
PROCESS SP_modo_jogo
testa_estado_jogo:	; rotina principal do processo modo jogo
			
	YIELD		

	CALL testa_inicio 		; verifica se a tecla para começar o jogo foi premida
    CALL testa_pausa  		; verifica se a tecla para pôr o jogo em pausa foi premida
    CALL testa_fim    		; verifuca se a tecla para terminar o jogo foi premida		
	CALL testa_retoma		; verifica se a tecla para retomar o jogo após a pausa foi premida
	CALL testa_recomeca     ; verifica se a tecla para recomeçar um jogo após o fim é premida
    JMP testa_estado_jogo	; repete o processo

testa_inicio:
	
	CALL varre_teclado						; leitura às teclas
	MOV R2, 0CH
	CMP	R0, R2  					; compara para ver se a tecla C foi premida
	JZ testa_estado_comeco				; se for premida, vai-se ver qual o modo do jogo
	RET

testa_estado_comeco:
	MOV R10, 1
	MOV R6, 8
	CALL ha_tecla			; espera-se que a tecla seja largada
	MOV R1, [modo_jogo]
	CMP R1, 0				; verifica se o jogo está no modo para começar
	JNZ testa_estado_jogo	; se não estiver volta-se ao ciclo principal do processo
	JMP ecra_inicial		; se for inicia-se o jogo

ecra_inicial:
	MOV R1, 1
	MOV [modo_jogo], R1					; muda a variável global do jogo para o valor 1(informa que o jogo está no modo ativo)
	MOV [modo], R1
	MOV  R7, 1				   		    ; valor a somar à coluna do boneco, para o movimentar
	MOV  [APAGA_ECRÃ], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 1							; cenário de fundo número 1
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    CALL desenha_rover                 	; desenha o rover 
	MOV R2, 6
	MOV [TOCA_SOM], R2					; toca o som número 6 (som inicial do jogo)
	JMP testa_estado_jogo


testa_estado_pausa:
	MOV R2, 0DH
	CALL varre_teclado						; chama a rotina teclado
	CMP R0, R2					; verifica se  a tecla D é premida
	JZ pausa 							; se for vai para pausa
	RET 								; se não for premida a tecla D, fa-ze return

testa_pausa:
	MOV R1, [modo_jogo]				
	CMP R1, 1							; verifica se o jogo está no modo ativo
	JZ testa_estado_pausa				; se não estiver vai para o ciclo principal
	RET									

pausa:
	MOV R10, 2
	MOV R6, 8
	CALL ha_tecla						; espera-se que a tecla D seja largada
	MOV R2, 2
	MOV [modo_jogo], R2					; muda a variável esta_jogo para 2 para informar que o jogo está em pausa/ para recomeçar
	DI									; Desativa as interrupçoes
	MOV  [ESCONDE_ECRA], R1				; esconde o ecrã do jogo (o valor de R1 não é relevante)
	MOV	R1, 4							; cenário de fundo número 4
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	JMP testa_estado_jogo 				; vai para o ciclo principal do processo


testa_tecla_retoma:
	MOV R2, 0DH 
	CALL varre_teclado 						; chama a rotina teclado
	CMP R0, R2					; verifica se  a tecla D é premida
	JZ retoma 						; se for vai para recomeca
	RET

testa_retoma:
	MOV R1, [modo_jogo]				
	CMP R1, 2							; verifica se o jogo está no modo para recomçar
	JZ testa_tecla_retoma			; verifica se a tecla para recomçar é premida
	RET									
	
retoma:			
	MOV R10, 2
	MOV R6, 8
	CALL ha_tecla						; espera-se que a tecla D seja largada
	MOV R1, 1
	MOV [modo_jogo], R1					; muda-se a variável que guarda o modo do jogo para o modo ativo
	MOV  R1, 1
	MOV [modo], R1						; desbloqueiam-se os vários processos
	MOV	R1, 1 							; guarda no registo R1 o valor 1(vai-se selecionar o cenário número 1)
	MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	EI
	CALL reset_int_2					; evita que a energia diminua imediatamente no recomeco, 
										; caso fique em pausa mais de 1 ciclo do relogio de energia
	JMP testa_estado_jogo

testa_fim:
	CALL varre_teclado			; leitura às teclas
	MOV R2, 0EH					; Verifica tecla E
	CMP	R0, R2					; verifica se a tecla E foi premida
	JNZ retornar 				; se foi nao premida, continua o jogo

	MOV R8, 0					; caso contrario, escreve 0 nos displays
	CALL escreve_decimal		
	MOV R8, 064H
	CALL envia_energia_memoria		; e inicializa a variavel global da energia (mete a 100)
	JMP termina_jogo			; terminando o jogo a seguir
retornar:
	RET 						; se não foi premida faz-se return	


termina_jogo: 
	MOV R10, 1
	MOV R6, 8
	CALL ha_tecla						; espera-se que a tecla E seja largada
	DI									; Desativa as interrupçoes
	MOV  [APAGA_ECRÃ], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, [cenario_fim]				; cenário de fundo para o fim do jogo ou para game over(depende do valor da variável cenário_fim)
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; muda cenário de fundo
	MOV R1, [cenario_fim]
	CMP R1, 3
	JZ som_perdeu_jogo
    MOV R1, 3							
	MOV [modo_jogo], R1					; muda a variável modo_jogo para 3 para o jogo está em espera que um novo jogo seja recomeçado
	JMP testa_estado_jogo

som_perdeu_jogo:						;toca um som caso o jogador tenha chocado com uma nave inimiga ou a enrgia tenha chegado a zero
	MOV R2, 6
	MOV [PAUSA_SOM], R2
	MOV R2, 5
	MOV [TOCA_SOM], R2					; toca o som número 5
	MOV R1, 3							
	MOV [modo_jogo], R1					; muda a variável modo_jogo para 3 para o jogo está em espera que um novo jogo seja recomeçado
	JMP testa_estado_jogo

testa_recomeca:
	MOV R1, [modo_jogo]
	CMP R1, 3
	JZ testa_tecla_recomeca
	RET

testa_tecla_recomeca:
	MOV R2, 0FH 
	CALL varre_teclado 			; chama a rotina teclado
	CMP R0, R2					; verifica se  a tecla F é premida
	JZ recomeca 				; se for vai para recomeca
	RET

recomeca:
  	MOV R1, 0
	EI
	MOV [modo_jogo], R1
	MOV  [APAGA_AVISO], R1		   	   ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1		   	   ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	 R1, 0				   		   ; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1 ; seleciona o cenário de fundo
	CALL inicializa_energia            ; Inicialização do display de energia
	CALL envia_energia_memoria			   ; Inicializa tambem a variavel global de energia
	CALL reset_int_2				   ; Reset na interrupçao da energia, para nao diminuir
									   ; a energia instataneamente
	JMP testa_estado_jogo

; *********************************************************************************
; * Rotina auxiliar para o processo responsável por ver o modo de jogo
; * 
; *********************************************************************************


ve_modo_jogo:							; rotina responsável por bloquear os processos caso o jogo não esteja no modo ativo 
	PUSH R1
	MOV R1, [modo_jogo]
	CMP R1, 1			
	JNZ bloqueia_processo				; se o modo do jogo não for ativo bloqueia o processo

continua_ve_modo_jogo:	
	POP R1
	RET									; retorna para o respetivo processo

bloqueia_processo:
	MOV R1, [modo]						; bloqueia o processo
	JMP continua_ve_modo_jogo



; *********************************************************************************
; * Rotinas que tratam dos comportamentos dos meteoros:
; *   Criação de novos meteoros
; *   Descer meteoros existentes
; *   'Evoluir' meteoros
; *********************************************************************************
PROCESS SP_desce_meteoro
gerir_meteoros:
	YIELD
	CALL recebe_energia_memoria					; Recebe o valor global da energia (FIXME: ew).
	CALL ve_modo_jogo

	MOV R0, 0							; Registo auxiliar
	MOV R6, [evento_meteoros]			; Testa se interrupção ocorreu
	CMP R6, R0							; Verifica se evento ocorreu (não está a zero)
	JZ gerir_meteoros					; Se não há evento a consumir, reiniciar processo
	MOV [evento_meteoros], R0			; Consome o evento
	
	CALL descer_meteoros				; Descer meteoros, caso estejam ativos

	CALL envia_energia_memoria				; envia valor da energia para a variavel global
	JMP gerir_meteoros					; Reiniciar processo

descer_meteoros:
	MOV R5, NR_METEOROS					; Nº de meteoros a tratar
	MOV R1, POS_METEOROS				; Inicializar endereço ao 1º meteoro
loop_descer_meteoros:
	CALL descer_um_meteoro
	SUB R5, 1							; Menos um meteoro a tratar
	JZ 	jmp_ret							; Acaba de descer meteoros
meteoro_seguinte:
	ADD R1, 6							; Endereço do meteoro seguinte
	JMP loop_descer_meteoros			; Processa o meteoro seguinte

descer_um_meteoro: 						; Desce um único meteoro.
	MOV R2, [R1]           				; Obtém a linha atual do meteoro
	MOV R3, LINHA_FUNDO_ECRA
	CALL apaga_boneco     				; Apagar o meteoro na posição atual
	CMP R2, R3             				; Testa se o meteoro está na última linha do ecrã
	JZ meteoro_chegou_chao				; Se estiver, meteoro colidiu com o planeta
	CALL testar_transicao_meteoro		; Testar se o meteoro tem que passar à próx. fase

	ADD R2, 1             				; Desce o meteoro uma linha (incrementa a linha atual)
	MOV [R1], R2           				; Atualiza a linha do meteoro
	CALL desenha_boneco					; Desenha o meteoro na nova linha
    RET

meteoro_chegou_chao:					; Comportamento quando um meteoro chega ao chão
	CALL diminui_cinco					; Diminui energia em cinco pontos
	CALL reset_meteoro					; Reinicializa o meteoro
	RET

; *********************************************************
; * Reinicializa o meteoro passado como argumento em R1.
; *********************************************************
reset_meteoro:	
	PUSH R1
	PUSH R2
	CALL apaga_boneco			 	; Apaga meteoro como está
	MOV R2, FIG_METEORO_NEUTRO_1 	; Meteoro inicial
	MOV [R1+4], R2				 	; Reset à figura do meteoro
	MOV R2, LINHA_INICIAL_METEOROS
	MOV [R1], R2 ; Meteoro volta à 1ª linha
	CALL desenha_boneco				 ; Desenha o novo meteoro

	POP R2
	POP R1
	RET
    
; *********************************************************
; * Testa se o meteoro se encontra numa linha de transição
; * E passa o à fase seguinte se sim.
; *********************************************************
testar_transicao_meteoro:				
	MOV R6, [R1]						; Linha do meteoro
testar_1a_transicao:					; Da 1ª fase (neutro 1x1) para 2ª fase (neutro 2x2)
	MOV R7, LINHA_TRANSICAO_1
	CMP R6, R7 							; Testar linha da 2ª fase
	JNZ testar_2a_transicao				; Se não for esta, testar a próxima
	MOV R11, FIG_METEORO_NEUTRO_2		; Registo auxiliar
	MOV [R1+4], R11						; Mudar figura da 1ª p/ a 2ª fase
	RET									; Transição feita! Sair

testar_2a_transicao:					; Da 2ª fase (neutro 2x2) para 2ª fase (bom ou mau 3x3
	MOV R7, LINHA_TRANSICAO_2
	CMP R6, R7							; Linha atual = linha transição de 2ª fase?
	JNZ testar_3a_transicao				; Se não for esta, testar a próxima
	CALL escolher_fig_meteoro			; Na 2ª transição temos que escolher se um meteoro será bom ou mau.
	MOV [R1+4], R11						; Transicionar para o meteoro que a rotina acima deu de output
	RET									; Transição feita! Sair

testar_3a_transicao:						; Da 3ª fase (bom/mau 3x3) p/ 4ª fase (bom/mau 3x3)
	MOV R7, LINHA_TRANSICAO_3		
	CMP R6, R7							; Meteoro está na última linha?
	JNZ testar_4a_transicao				; Senão for esta, testar a próx. linha
			
	MOV R9, [R1+4]						; Atual figura do meteoro
	MOV R7, FIG_METEORO_BOM_1			; Meteoro é um meteoro bom?
	CMP R7, R9
	JNZ transicao_3_aux					; Se não for bom, transitar p/ meteoro mau
	JNZ jmp_ret
	MOV R11, FIG_METEORO_BOM_2			; Transitar p/ bom seguinte, caso contrário
	MOV [R1+4], R11
	RET
	
transicao_3_aux:										; Se não, transicionar p/ meteoro mau seguinte
	MOV R11, FIG_METEORO_MAU_2
	MOV [R1+4], R11						; Escrever nova figura do meteoro
	RET		
	

testar_4a_transicao:					; Da 4ª fase (bom/mau 4x4) p/ 5ª fase (bom/mau 5x5)
	MOV R7, LINHA_TRANSICAO_4
	CMP R6, R7
	JNZ jmp_ret							; Senão for esta, sair (não há mais p/ testar)

	MOV R9, [R1+4]						; Atual figura do meteoro
	MOV R7, FIG_METEORO_BOM_2
	CMP R7, R9							; Meteoro atual é mau?
	JNZ transicao_4_aux					; Se sim, transitar p/ meteoro mau seguinte
	MOV R11, FIG_METEORO_BOM_3			; Caso contrário é porque é bom
	MOV [R1+4], R11						; Escrever novo meteoro
	RET
transicao_4_aux:
	MOV R11, FIG_METEORO_MAU_3			; FIXME:! Ver FIXME imediatamente acima
	MOV [R1+4], R11
	RET

; ********************************************************************************
; * Rotina que tem 25% chance de retornar a figura de um meteoro bom (3x3) no R11
; * E 75% chance de retornar a figura de um meteoro mau (3x3).
; ********************************************************************************
escolher_fig_meteoro: ; TODO: actually implement random function
	PUSH R1
	CALL gera_num_aleatorio	; Retorna um nº aleatório de 0 a 3 em R1
	CMP R1, 1				; Retorna um meteoro bom se for 1 (escolha arbitrária)
	JZ gera_meteoro_bom
	MOV R11, FIG_METEORO_MAU_1	; Caso contrário, retorna um meteoro mau
	POP R1
	RET

gera_meteoro_bom:			
	MOV R11, FIG_METEORO_BOM_1
	POP R1
	RET


; ***************************
; * Desenha o rover no ecrã.
; ***************************
PROCESS SP_teclado_rover
le_tecla_rover:							; Verificar se uma tecla para mover o rover está pressionada
    
    YIELD
    CALL ve_modo_jogo			; linha a testar no teclado
	CALL varre_teclado			; leitura as teclas
	CMP R0, 0						
	JZ testa_esquerda			; se não há tecla pressionada, sair da rotina
	CMP	R0, 2
	JZ	testa_direita		
	JMP le_tecla_rover

testa_esquerda:
	MOV [tecla_continua], R0

	MOV	R7, -1							; vai deslocar para a esquerda
	CALL atraso 						; se mover, chama a rotina atraso para não mover demasiado rápido
	JMP    ve_limites_rover 

testa_direita:
    MOV [tecla_continua], R0

	MOV	R7, +1							; vai deslocar para a direita
	CALL atraso 						; se mover, chama a rotina atraso para não mover demasiado rápido
	JMP    ve_limites_rover 			; verifica se ao mover o rover os limites do ecrã não são ultrapassados

ve_limites_rover:
	CALL	testa_limites				; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP	R7, 0
	JZ le_tecla_rover					; se não é para movimentar o objeto, sai da rotina
	CALL     move_rover         		; Caso contrário, movimentar rover
	JMP le_tecla_rover  	

jmp_ret:	RET			; Etiqueta cujo único propósito é permitir
						; Fazer retornos condicionais.

; **********************************************************************
; * Rotinas que testam colisões entre todos os meteoros e o míssil/rover.
; **********************************************************************
PROCESS SP_testa_colisoes
testa_colisoes:
	YIELD
	CALL recebe_energia_memoria					; recebe o valor atual da energia
	
	CALL testa_colisao_missil			; Testar colisões míssil-meteoro
	MOV R3, POS_ROVER					; Testar colisões meteoro-rover.
	CALL aux_testa_colisoes

	CALL envia_energia_memoria				; envia o valor da energia para a variavel global
	JMP testa_colisoes					; Fim

testa_colisao_missil:
	MOV R1, [missil_ativo]
	JNZ jmp_ret							; Retornar caso míssil não esteja ativo
	MOV R3, POS_DISPARO
	CALL aux_testa_colisoes				; Testar colisões com o míssil

aux_testa_colisoes:						; Testa colisões meteoro-rover.
	MOV R1, POS_METEOROS				; Inicializa R1 ao 1º meteoro
	MOV R5, NR_METEOROS					; Testa colisão para cada um dos N meteoros
loop_colisoes:
	SUB R5, 1							; Menos um meteoro a tratar
	CALL testa_colisao					; Testar colisão
	CMP R0, 0							; Testar se houve colisão
	JNZ tratar_colisao					; Tratar da colisão
colisao_seguinte:						; Tratar do próximo meteoro
	ADD R1, 6							; Endereço do meteoro seguinte
	CMP R5, 0							; Verificar se ainda há meteoros a tratar
	JNZ loop_colisoes					; Tratar o meteoro seguinte
	RET									; Retornar


; ************************************************************************************
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
; * 
; * Por convenção, assumir que R3 contém sempre o Rover ou um míssil
; * E R1 um meteoro.
; *
; * Argumentos:    R1 - Definição do meteoro
; *				   R3 - Definição do Rover ou míssil
; * Outros registos:
; *   			   R2 - Registo auxiliar
; ************************************************************************************
tratar_colisao:
	MOV R2, POS_DISPARO						; É uma colisão meteoro-míssil?
	CMP R2, R3
	JZ tratar_colisao_missil_meteoro
											; A partir daqui tem que ser uma colisão meteoro-rover
	MOV R5, [R1+4]							; Figura do meteoro a comparar

	MOV R2, FIG_METEORO_BOM_3
	CMP R2, R5								; Testar se é uma colisão meteoro bom <-> rover
	JZ	tratar_colisao_rover_meteoro_bom

	JMP tratar_colisao_rover_meteoro_mau	; Caso contrário, é colisão com um meteoro mau

tratar_colisao_rover_meteoro_mau: 		
	MOV R1, POS_ROVER+4     ; Endereço da figura do Rover
	MOV R3, FIG_EXPLOSAO
	MOV [R1], R3			; Rover é substituído por figura de explosão
	SUB R1, 4				; Endereço normal do Rover
	CALL desenha_boneco		; Desenha uma explosão na posição do Rover
	MOV R2, 3
	MOV [TOCA_SOM], R2
	CALL atraso_colisao     ; Pequeno atraso antes de fim do jogo
	CALL atraso_colisao     ; Não usar uma interrupção para fazer um atraso
	CALL atraso_colisao     ; para ter a certeza que não existe comportamento indesejado.
	CALL atraso_colisao     
	MOV R1, 3
	MOV [cenario_fim], R1
	JMP termina_jogo		; Acabou o jogo

tratar_colisao_rover_meteoro_bom:
	CALL reset_meteoro				; Rover 'consome' o meteoro (reinicializá lo)
	CALL aumenta_cinco				; Aumentar energia em dez pontos
	CALL aumenta_cinco
	CALL envia_energia_memoria			; Escreve o valor do display em memória

	MOV R2, 4
	MOV [TOCA_SOM], R2
	;TODO: meter som aqui
	JMP testa_colisoes			; Colisão tratada! Reiniciar processo.

tratar_colisao_missil_meteoro:	; Não interessa se o meteoro é bom ou mau neste caso
; TODO: Adicionar rotina para fazer som de explosão
; *  	- Colisão míssil-meteoro: som de explosão, substituir meteo. por explosão,
; *			apagar míssil e meteoro, aumentar display (?)
;	CALL apaga_boneco				; Apaga forma antiga do meteoro TODO: stuff
	MOV R2,     FIG_EXPLOSAO		; Figura de explosão
	MOV [R1+4], R2					; Substituir figura do meteoro por uma explosão
	CALL desenha_boneco				; Desenha explosão por cima dos restos do meteoro antigo
	CALL aumenta_cinco				; Aumenta cinco pontos por destruir um meteoro 
	CALL envia_energia_memoria
	MOV R2, 2						; toca o som número 2
	MOV [TOCA_SOM], R2
	MOV R8, 1
	MOV [colisao_missil], R8		; avisa o processo do missíl que houve uma colisão
	YIELD							; Permitir que outros processos corram antes de atraso
	CALL atraso_colisao				; Atraso para que a explosão seja percetível
	YIELD							; Permitir outra vez que corram
	CALL reset_meteoro				; Reinicializa o meteoro destruído 
	
	; TODO: fazer atrasos mas deixar outros processos correr

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
	SUB R6, R7		; Lim. inf. de B + altura = Lim. sup. de B
	
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
	MOV [tecla_carregada], R0
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

; **********************************
; * Escreve nos displays de energia.
; **********************************

desenha_rover:
    PUSH R1
	MOV R1, POS_ROVER   				; Endereço da tabela que define o Rover (argumento de desenha_boneco)
	CALL desenha_boneco
    POP R1
	RET

escreve_decimal:
	PUSH R11	; num

	PUSH R0		; fator
	PUSH R1		; digito
	PUSH R2		; resultado
	PUSH R4
	PUSH R10

	MOV R11, R8	
	MOV R4, DISPLAYS

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

	POP R10
	POP R4
	POP R2
	POP R1
	POP R0

	POP R11
	RET
;*********************************************************************************
; *Processo - Displays de Energia
;*********************************************************************************
PROCESS SP_display_energia
interrupcao_energia:

    YIELD
	CALL recebe_energia_memoria		; recebe o valor atual da energia

	MOV R4, DISPLAYS
    MOV R5, evento_energia
    MOV R2, [R5]			; Vai buscar o valor da interrupcao 2 na tabela evento_energia
    CMP R2, 0		
    JZ mid_energia			; Valor 0 - sem interrupcao - salta (para ja) a escrita nos displays

	MOV R2, 0
	MOV [R5], R2

	CALL diminui_cinco		; energia = energia - 5
	CALL envia_energia_memoria	; Envia a energia para a variavel global
	JMP interrupcao_energia

mid_energia:
    CALL ve_modo_jogo	
    JMP interrupcao_energia


aumenta_cinco:				; energia = energia + 5
	PUSH R1
	MOV R1, 5
	CALL aumenta_display	; chama a funcao generica
	POP R1
	RET

diminui_cinco:				; energia = energia - 5
	PUSH R1
	MOV R1, 5
	CALL diminui_display	; chama a funcao generica
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

termina_jogo_:		; Coloca a energia a zero e termina o jogo
	MOV R8, 0
	CALL escreve_decimal	; 0 nos displays
	MOV R1, 3
	MOV [cenario_fim], R1
	JMP termina_jogo

__escreve_decimal:
    CALL escreve_decimal						; escreve nos displays, em decimal
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
atraso:
	PUSH	R1
	MOV R1, ATRASO_ROVER
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

int_rel_energia:				; rotina de interrupcao da energia
    PUSH R0
	PUSH R1
	MOV  R0, evento_energia
	MOV  R1, 1					; assinala que houve uma interrup��o 0
	MOV  [R0], R1				; no evento_energia
	POP  R1
	POP  R0
	RFE

int_rel_meteoros:			  ; (INT0) Interrupção causada pelo relógio dos meteoros
	PUSH R0
	PUSH R1
	
	MOV R0, 1				  ; Registo auxiliar
	;MOV R1, [R] ; Registar que interrupção ocorreu
	MOV [evento_meteoros], R0	; Registar que interrupção ocorreu

	POP R1
	POP R0
	RFE

reset_int_2:		; funcao que evita diminuicoes da energia,
					; logo apos de comecar (ou recomecar) o jogo a partir da pausa
	PUSH R0
	PUSH R1

	MOV R1, 0
	MOV [evento_energia], R1	; coloca o valor da interrupcao a 0

	POP R1
	POP R0
	RET

; **************************************************************************
; INT_REL_MISSIL - Rotina de atendimento da interrupção 1, do relógio do missíl.
;			Faz simplesmente uma escrita no LOCK que o processo boneco lê.
;			Como basta indicar que a interrupção ocorreu (não há mais
;			informação a transmitir), basta a escrita em si, pelo que
;			o registo usado, bem como o seu valor, é irrelevante
; **************************************************************************
int_rel_missil:
	PUSH R0
	PUSH R1
	MOV  R0, evento_missil
	MOV  R1, 1			; assinala que houve uma interrupção do missíl
	MOV  [R0], R1			; na variável evento_missil
	POP  R1
	POP  R0
	RFE

; **********************************************************************
; * Processo do missíl
; **********************************************************************
PROCESS SP_dispara_missil
le_tecla_missil:
 	YIELD
	CALL recebe_energia_memoria				; recebe o valor atual da energia
	CALL ve_modo_jogo										; Argumento de 'teclado' (testa 1ª linha)
	CALL varre_teclado         				; Output em R0
	MOV R2, 1      			; Tecla de descer o meteoro (1ª linha, 2ª coluna = tecla '1')
	CMP R0, R2             				; Verificar se a tecla de para disparar o missíl foi premida
	JZ  disparo							; se a tecla for premida vai para disparo

	CALL envia_energia_memoria				; envia o valor da energia para a variavel global
	JMP le_tecla_missil					; ciclo principal do processo do missíl

disparo:
	MOV R1, POS_DISPARO 				; Tabela que define o disparo
	MOV R2, [R1]           				; Obtém a linha atual do missíl
	CALLF atualiza_coluna_missil		; atualiza a coluna do missíl em caso do rover se ter movido
	JMP	ativa_missil					; dispara o missíl


ativa_missil:
	MOV R2, 1
	MOV [missil_ativo], R2	
	CALL diminui_cinco					; Perder cinco energia ao disparar
	CALL envia_energia_memoria
	MOV R2, 0
	MOV [TOCA_SOM], R2
	JMP dispara_missil

dispara_missil:
	CALLF desenha_missil				; desenha o missíl
	MOV R4, [evento_missil]				; ativa a interrupção do missíl
	CALL apaga_boneco     				; Apagar o missíl na posição atual
	CALL testa_colisao_ativa			; se houver colisão com um meteoro, sai da rotina dispara missíl
	MOV R1, POS_DISPARO 				; Tabela que define o disparo
	MOV R2, [R1]           				; Obtém a linha atual do missíl
	MOV R3, LINHA_LIMITE_DISPARO		
	CMP R2, R3             				; Testa se o missíl chegou ao seu alcance máximo
	JZ reinicia_disparo  				; Se estiver, então não atualizar a linha
	SUB R2, 2             				; Sobe o missíl 2 linhas (decrementa 2 vezes a linha atual)
	MOV [R1], R2           				; Atualiza a linha do disparo
	CALLF desenha_missil				; Volta a desenhar o missíl na nova posição
    JMP dispara_missil					; repete o ciclo até o missíl chegar ao seu alcance máximo ou haver uma colisão

testa_colisao_ativa:					; verifica se houve uma colisão entre um meteoro e um missil
	MOV R1, [colisao_missil]			; para caso haja colisão apagar o missíl
	CMP R1, 1
	JZ reinicia_disparo
	RET

reinicia_disparo:
	MOV R1, 0
	MOV [colisao_missil], R1			; reinicia o valor da variável colisão missíl
	MOV R0, POS_DISPARO				
	MOV R1, LINHA_DISPARO
	MOV [R0], R1						; reinicia a linha do missíl para o próximo missíl
	JMP sai_disparo						; sai desta parte do processo

sai_disparo:  
	MOV R10, 2							; R10 guarda o valor da coluna da tecla do missíl(1)
	MOV R6, 1							; R6 guarda o valor da linha da tecla do missíl(1)
    CALL ha_tecla						; espera que a tecla 1, do missíl, seja largada
	MOV R1, 0
	MOV [missil_ativo], R1
    JMP le_tecla_missil					; volta para o ciclo principal do processo

desenha_missil:
	PUSH R1
	MOV R1, POS_DISPARO
	CALL desenha_boneco
    POP R1
	RETF

atualiza_coluna_missil:					; a rotina  atualiza a coluna do missíl caso este se tenha movido
    PUSH R1
	PUSH R2
	PUSH R3
	MOV R2, POS_ROVER					; guarda em R2 a tabela com a posição do ROVER
	MOV R3, [R2+2]						; guarda em R3 a coluna do rover
	ADD R3, 2							; obtém-se a coluna atual do missíl
	MOV R1, POS_DISPARO					; guarda em R1 a tabela com a posição do missíl
	MOV [R1+2], R3						; atualiza a colluna do missíl para a atual
	POP R3
	POP R2
    POP R1
	RETF



inicializa_energia:						
    PUSH R4
    MOV  R4, DISPLAYS

    MOV  R8, MAX_ENERGIA            ; Energia inicial
	CALL escreve_decimal 			; escreve 100 nos displays

	CALL envia_energia_memoria			; envia o valor da energia para a memoria

    POP R4 
    RET

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
	JMP linha1


escolhe_linha: ; Função que salta para a linha seguinte:
    CMP R0, 1
	JZ linha2
	
    CMP R0, 2  
    JZ linha3

    CMP R0, 4  
    JZ linha4
   
    JMP acaba_varrer   ; Apos ter corrido todas as linhas sem teclas premidas,
					   ; sai da funcao com valor 8 (nao prejudica o programa, pois
					   ; R0 guarda o valor das teclas premidas e a tecla 8
					   ; nao possui nenhuma funcionalidade nesta entrega final,
					   ; nao entrando em conflito com nenhuma outra tecla)

espera_tecla:          ; neste ciclo espera-se at� uma tecla ser premida
 
    MOVB [R2], R0      ; escrever no perif�rico de sa�da (linhas)
    MOVB R1, [R3]      ; ler do perif�rico de entrada (colunas) 
    AND  R1, R5        ; elimina bits para al�m dos bits 0-3
    CMP  R1, 0         ; h� tecla premida?
    JZ   escolhe_linha  ; se nenhuma tecla premida, repete
    JMP altera_linha

;------------------------------------------;
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
    MOV R0, 08H; 
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
	JMP acaba_varrer

acaba_varrer: ; Pop nos registos usados (exceto R0)
    POP R10
    POP R9
    POP R7
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET
;----------------------------------------------------------------------------------------;
;-----------Funcoes que enviam e recebem o valor da energia da memoria-------------------;
;-------(Deste modo o valor da energia pode passar de processo em processo)--------------;
;----------------------------------------------------------------------------------------;

envia_energia_memoria:		; Escreve o valor da energia na memoria
	MOV [valor_energia], R8
	RET

recebe_energia_memoria:			; Le o valor da energia da memoria
	MOV R8, [valor_energia]
	RET


gera_num_aleatorio:		; Gera um de quatro numeros aleatoriamente
						; (pois a chance de um meteoro bom e de 1 em 4)
    PUSH R0
    MOV R0, TEC_COL
    MOV R1, [R0]
    SHR R1, 5			; Escolhidos os bits do teclado nao utilizados (numero pseudo aleatorio)
    MOV R0, 4
    MOD R1, R0			; Resto da divisão por 4, obtendo-se 1 de 4 numeros possíveis

	POP R0
	RET					; Retornar nº aleatório em R1

