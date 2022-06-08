; *********************************************************************************
; * IST-UL
; * Projeto de Introdu��o � Arquitetura de Computadores 2021/2022
; * Chuva de Meteoros
; *
; * Grupo 73
; * ist1103860 Henrique Caro�o
; * ist1103883 Lu�s Calado
; * ist199309  Rafael Gir�o
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
; *************
; * Perif�ricos
; *************
TEC_LIN					EQU 0C000H	; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL					EQU 0E000H	; endere�o das colunas do teclado (perif�rico PIN)
DISPLAYS   				EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
DEFINE_LINHA   	        EQU 600AH   ; endere�o do comando para definir a linha
DEFINE_COLUNA  	        EQU 600CH   ; endere�o do comando para definir a coluna
DEFINE_PIXEL   	        EQU 6012H   ; endere�o do comando para escrever um pixel
APAGA_AVISO             EQU 6040H   ; endere�o do comando para apagar o aviso de nenhum cen�rio selecionado
APAGA_ECR�	 		    EQU 6002H  	; endere�o do comando para apagar todos os pixels j� desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H	; endere�o do comando para selecionar uma imagem de fundo
TOCA_SOM				EQU 605AH   ; endere�o do comando para tocar um som

LINHA_TECLADO	        EQU 1		; linha a testar (1� linha, 1000b)
LINHA_START 	        EQU 8       ; linha a testar para come�ar o jogo(4� linha)
MASCARA		        	EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLADO_1               EQU 1       ; 1� linha/coluna do teclado
TECLADO_2               EQU 2       ; 2� linha/coluna do teclado
TECLADO_3               EQU 4       ; 3� linha/coluna do teclado
TECLADO_4               EQU 8       ; 4� linha/coluna do teclado
COLUNA_2 			    EQU 2


; **********************************
; * Posi��es (coluna) dos 8 meteoros 
; **********************************

POS_METEORO_1           EQU 

; **********************************
; * Constantes de bonecos e do ecr�
; **********************************
LINHA_FUNDO_ECRA        EQU  31     ; linha do Rover (no fundo do ecr�)
COLUNA_MEIO_ECRA		EQU  30     ; coluna inicial do Rover (a meio do ecr�)
LARGURA_ROVER		    EQU  05H	; lagura do rover
ALTURA_ROVER            EQU  04H	; altura do rover

LINHA_INICIAL           EQU 1		; linha inicial do meteoro neutro
LINHA_METEORO_NEUTRO_2  EQU 4		; linha ap�s se aumentar o tamanho do meteoro neutro

LINHA_INICIAL_METEOROS  EQU 7		; linha inicial em que os meteoros se diferenciam
LINHA_METEOROS_2        EQU 10		; linha em que os meteoros aumentam de tamanho
LINHA_METEOROS_3        EQU 13		; linha em que os meteoros aumentam de tamanho pela segunda vez

LINHA_EXPLOSAO          EQU 1
LINHA_DISPARO           EQU 1


MIN_COLUNA	        	EQU 0		; n�mero da coluna mais � esquerda que o objeto pode ocupar
MAX_COLUNA	        	EQU 63      ; n�mero da coluna mais � direita que o objeto pode ocupar
ATRASO		        	EQU	0400H	; atraso para limitar a velocidade de movimento do boneco

; ********************
; * Outras constantes
; ********************
MAX_ENERGIA		        EQU 64H     ; Energia do Rover ao come�ar o jogo (100 em hexadecimal)
MIN_ENERGIA             EQU 0H      ; Energia m�nima do Rover

; **********************
; * Constantes de cores
; **********************
CASTANHO	        	EQU	0FA52H	; cor castanho do rover	
AZUL		        	EQU	0F00FH	; cor azul do rover e disparos
ROSA_EXP	        	EQU	04F0EH  ; Cor rosa da explos�o dos meteoros
VERDE_FORA	        	EQU	0F0F0H	; Meteoros bons
VERDE_DENTRO	        EQU	060F0H	; Meteoros bons
VERMELHO	         	EQU	0FF00H	; Meteoros maus
CINZENTO	         	EQU	0C777H	; Cor neutra - Meteoros de longe

; *********************************************************************************
; * Dados
; *********************************************************************************
PLACE   1000H
pilha:
	    STACK 100H		 	;espa�o reservado para a pilha
							; (200H bytes, pois s�o 100H words)
SP_inicial:					; este � o endere�o (1200H) com que o SP deve ser
							; inicializado. O 1.� end. de retorno ser�
							; armazenado em 11FEH (1200H-2)


;---------------------------------------------------------------------------------;
;----------------------TABELAS DE DEFINI��O DAS FIGURAS---------------------------;		
;---------------------------------------------------------------------------------;
  
DEF_ROVER:			    	; Tabela que define o rover.
							; A primeira linha desta tabela cont�m a 1� linha do Rover a contar de baixo.
							; A linha e coluna s�o alteradas quando o Rover � movimentado
	WORD LINHA_FUNDO_ECRA
	WORD COLUNA_MEIO_ECRA
	WORD LARGURA_ROVER
	WORD ALTURA_ROVER

	WORD 0, CASTANHO, 0, CASTANHO, 0
	WORD CASTANHO, AZUL, CASTANHO, AZUL, CASTANHO
	WORD CASTANHO, 0, AZUL, 0, CASTANHO
	WORD 0, 0, CASTANHO, 0, 0
     
METEORO_NEUTRO_1:           ; Defini��o do primeiro meteoro neutro
    WORD LINHA_INICIAL
    WORD CINZENTO 

METEORO_NEUTRO_2:           ; Defini��o do segundo meteoro neutro
    WORD LINHA_METEORO_NEUTRO_2

	WORD CINZENTO,      CINZENTO
    WORD CINZENTO,      CINZENTO

METEORO_BOM_1:              ; Defini��o do primeiro meteoro bom
    WORD LINHA_INICIAL_METEOROS

    WORD 0,             VERDE_FORA,     0
    WORD VERDE_FORA,    VERDE_DENTRO,   VERDE_FORA
    WORD 0, VERDE_FORA, 0

METEORO_BOM_2:              ; Defini��o do segundo meteoro bom
    WORD LINHA_METEOROS_2

    WORD 0,             VERDE_FORA,     VERDE_FORA,     0
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA
    WORD VERDE_FORA,    VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD 0,             VERDE_FORA,     VERDE_FORA,     0

METEORO_BOM_3:              ; Defini��o do terceiro meteoro bom
    WORD LINHA_METEOROS_3

    WORD 0,             VERDE_FORA,     VERDE_FORA,     VERDE_FORA,     0
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD VERDE_FORA,    VERDE_DENTRO,   VERDE_DENTRO,   VERDE_DENTRO,   VERDE_FORA
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD 0,             VERDE_FORA,     VERDE_FORA,     VERDE_FORA,     0

METEORO_MAU_1:              ; Defini��o do primeiro meteoro mau
    WORD LINHA_INICIAL_METEOROS

    WORD VERMELHO,  VERMELHO,   VERMELHO
    WORD 0,         VERMELHO,   0
    WORD VERMELHO,  0,          VERMELHO

METEORO_MAU_2:              ; Defini��o do segundo meteoro mau
    WORD LINHA_METEOROS_2

    WORD VERMELHO,  VERMELHO,   VERMELHO,   VERMELHO
    WORD 0,         VERMELHO,   VERMELHO,   0
    WORD VERMELHO,  0,          0,          VERMELHO
    WORD VERMELHO,  0,          0,          VERMELHO

METEORO_MAU_3:              ; Defini��o do terceiro meteoro mau
    WORD 4                  ; Linha ecr� do meteoro
    WORD COLUNA_MEIO_ECRA   ; Coluna no ecr� do meteoro
    WORD 5                  ; Largura do Meteoro
    WORD 5                  ; Altura do Meteoro

    WORD VERMELHO,  0,          0,          0,          VERMELHO
    WORD VERMELHO,  0,          VERMELHO,   0,          VERMELHO
    WORD 0,         VERMELHO,   VERMELHO,   VERMELHO,   0
    WORD 0,         VERMELHO,   VERMELHO,   VERMELHO,   0
    WORD VERMELHO,  0,          0,          0,          VERMELHO

EXPLOSAO:                   ; Defini��o das explosoes
    WORD LINHA_EXPLOSAO

    WORD 0,         ROSA_EXP,   0,          ROSA_EXP,   0
	WORD ROSA_EXP,  0,          ROSA_EXP,   0,          ROSA_EXP
    WORD 0,         ROSA_EXP,   0,          ROSA_EXP,   0
    WORD ROSA_EXP,  0,          ROSA_EXP,   0,          ROSA_EXP
    WORD 0,         ROSA_EXP,   0,          ROSA_EXP,      0

DISPARO:                    ; Defini��o dos disparos da nave
    WORD LINHA_DISPARO
    WORD AZUL


; *********************************************************************************
; * C�digo
; *********************************************************************************
PLACE   0                              ; o c�digo tem de come�ar em 0000H
inicio:
    MOV  SP, SP_inicial			       ; inicializa SP para a palavra a seguir
    MOV  [APAGA_AVISO], R1		   	   ; apaga o aviso de nenhum cen�rio selecionado (o valor de R1 n�o � relevante)
    MOV  [APAGA_ECR�], R1		   	   ; apaga todos os pixels j� desenhados (o valor de R1 n�o � relevante)
    MOV	 R1, 0				   		   ; cen�rio de fundo n�mero 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1 ; seleciona o cen�rio de fundo
    MOV  R7, 1				   		   ; valor a somar � coluna do boneco, para o movimentar

    CALL inicializa_energia            ; Inicializa��o do display de energia
    JMP  ecra_inicial 		           ; Ecr� de in�cio de jogo


inicializa_energia:						
    PUSH R4
    MOV  R4, DISPLAYS

    MOV  R8, MAX_ENERGIA            ; Energia inicial
	CALL escreve_decimal 			; escreve 100 nos displays

    POP R4
    RET


escreve_decimal:
	PUSH R11	; num

	PUSH R0		; fator
	PUSH R1		; digito
	PUSH R2		; resultado
	PUSH R10

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

	POP R10
	POP R2
	POP R1
	POP R0

	POP R11
	RET

ecra_inicial:
	MOV R11, ATRASO
	MOV  R6, LINHA_START				; linha a testar no teclado
	CALL	teclado						; leitura �s teclas
	CMP	R0, TECLADO_1  					; compara para ver se a tecla C foi premida
	JNZ ecra_inicial					; se n�o foi premida, espera-se que seja premida para come�ar o jogo
	MOV  [APAGA_ECR�], R1				; apaga todos os pixels j� desenhados (o valor de R1 n�o � relevante)
	MOV	R1, 1							; cen�rio de fundo n�mero 1
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cen�rio de fundo
    CALLF desenha_rover                 ; desenha o rover 
	CALLF desenha_um_meteoro        	; Desenha o meteoro inicial no topo do ecr�
    JMP ciclo_jogo                      ; Iniciar o jogo


ciclo_jogo:                    			; O ciclo principal do jogo.
	CALLF testa_tecla_descer_meteoro	; Verifica se a tecla para descer o meteoro foi premida (e age de acordo)
	CALLF le_tecla_rover  	   			; Verifica se uma tecla para movimentar o rover foi premida e move-o (ou n�o)
    CALL le_tecla_energia
	CALL testa_fim 						; verifica se a tecla premida � a tecla E
	CALL testa_pausa
	JMP ciclo_jogo

; *********************************************************************************
; * Desenha um meteoro neutro no tamanho m�ximo, no meio do ecr�.
; *********************************************************************************

desenha_um_meteoro:
	PUSH R1
	MOV R1, METEORO_MAU_3
	CALL desenha_boneco
	POP R1
	RETF

testa_tecla_descer_meteoro:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R6
	PUSH R11
	MOV  R6, TECLADO_3 					; Argumento de 'teclado' (testa 3� linha)
	CALL teclado           				; Output em R0
	MOV R2, TECLADO_1        			; Tecla de descer o meteoro (3� linha, 1� coluna = tecla 'B')
	CMP R0, R2             				; Verificar se a tecla de descer o meteoro foi premida
	JZ  desce_meteoro
	JMP sai_desce_meteoro


desce_meteoro: 							; Rotina a ser generalizada na entrega final.
	MOV R1, METEORO_MAU_3 				; Tabela que define o meteoro
	MOV R2, [R1]           				; Obt�m a linha atual do meteoro
	MOV R3, LINHA_FUNDO_ECRA
	CALL apaga_boneco     				; Apagar o meteoro na posi��o atual
	CMP R2, R3             				; Testa se o meteoro est� na �ltima linha do ecr�
	JZ sai_desce_meteoro  				; Se estiver, ent�o n�o atualizar a linha
	ADD R2, 1             				; Desce o meteoro uma linha (incrementa a linha atual)
	CALL muda_fundo_meteoro
	MOV [R1], R2           				; Atualiza a linha do meteoro
	CALLF desenha_um_meteoro
	JMP sai_desce_meteoro

muda_fundo_meteoro:
	PUSH R1								; faz push do registo R1
	PUSH R2								; faz push do registo R2
	MOV	R1, 5							; cen�rio de fundo n�mero 5
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cen�rio de fundo
	MOV R2, 1							; som n�mero 1
	MOV [TOCA_SOM], R2					; toca o som
	POP R2								; pop do registo R2
	POP R1								; pop do registo R1
	RET									; retorna


sai_desce_meteoro:
	POP R11
	POP R6
	POP R3
	POP R2
	POP R1
	POP R0
	MOV R10, 1
	MOV R6, 4
	CALL ha_tecla


; *********************************************************************************
; * Desenha o rover no ecr�.
; *********************************************************************************
desenha_rover:
	PUSH R1             				; Resguardar registo a ser alterado
	MOV R1, DEF_ROVER   				; Endere�o da tabela que define o Rover (argumento de desenha_boneco)
	CALL desenha_boneco
	POP R1              				; Resgatar registo alterado
	RETF


le_tecla_rover:							; Verificar se uma tecla para mover o rover est� pressionada
	PUSH R0
	PUSH R6
	PUSH R7
	PUSH R11 				
	MOV  R6, LINHA_TECLADO				; linha a testar no teclado
	CALL	teclado						; leitura �s teclas
	CMP	R0, 0
	JZ	sai_ler_tecla_rover				; se n�o h� tecla pressionada, sair da rotina
	CMP	R0, TECLADO_1
	JNZ	testa_direita
	MOV	R7, -1							; vai deslocar para a esquerda
	CALL atraso
	JMP	ve_limites_rover

le_tecla_energia:
    PUSH R4
    PUSH R9
    PUSH R11

    MOV R11, TECLADO_4	  				; constante 08 fora dos limites - tem que ser guardada no registo
    MOV R4,  DISPLAYS	  				; R4 tem o endereco dos displays
    MOV R6,  TECLADO_3 					; linha 3 (aumenta display)

    CALL teclado
    CMP R0, R11 		  				; coluna 4 (linha 3 e coluna 4 - tecla B)
    JZ aumenta_display					; se for zero aumenta o valor do display de energia

    MOV R6, R11			  				; linha 4 (linha 4, coluna 4 - letra F)	
    CALL teclado
    CMP R0, R11				
    JZ diminui_display					; se for zero diminui o valor do display de energia

	JMP pop_energia		

pop_e_espera:		  					; no caso de alguma das teclas estar premida, espera ate largar
	MOV R10, 8			  				; procura na coluna 4
    CALL ha_tecla

pop_energia:		  					; nenhuma das 2 teclas premidas - n�o precisa de esperar
    POP R11
    POP R9
    POP R4
    RET

aumenta_display:
    MOV R9, MAX_ENERGIA   

    CMP R9, R8			  				; limite superior atingido (100) - salta a adi��o
    JZ pop_e_espera
    
    MOV R9, 01H         
    ADD R8, 1			  				; R8 <- R8 + 1

	CALL escreve_decimal				; escreve nos displays, em decimal
    JMP pop_e_espera


diminui_display:
    MOV R9, 0

    CMP R9, R8							; limite inferior atingido (0) - salta a subtracao
    JZ pop_e_espera

    MOV R9, 01H
    SUB R8, R9							; R8 <- R8 - 1

    CALL escreve_decimal						; escreve nos displays, em decimal
    JMP pop_e_espera

sai_ler_tecla_rover:
	POP R11
	POP R7
	POP R6
	POP R0
	RETF

testa_direita:
	CMP	R0, TECLADO_3 					; verifica se a tecla para mover o rover para a direita foi premida
	JNZ	sai_ler_tecla_rover				; tecla que n�o interessa -> sair
	MOV	R7, +1							; vai deslocar para a direita
	CALL atraso 						; se mover, chama a rotina atraso para n�o mover demasiado r�pido
	JMP    ve_limites_rover 			; verifica se ao mover o rover os limites do ecr� n�o s�o ultrapassados

testa_pausa:
	MOV R6, LINHA_START 				; guarda no registo R6 a 4� linha
	CALL teclado 						; chama a rotina teclado
	CMP R0, COLUNA_2 					; verifica se  a tecla D � premida
	JZ pausa 							; se for vai para pausa
	RET 								; se n�o for premida a tecla D, fa-ze return

pausa:
	MOV  [APAGA_ECR�], R1				; apaga todos os pixels j� desenhados (o valor de R1 n�o � relevante)
	MOV	R1, 4							; cen�rio de fundo n�mero 4
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cen�rio de fundo
	MOV R10, 2
    CALL ha_tecla
	JMP recomeca 						; vai para a rotina recome�a

recomeca:								; volta ao ecr� do jogo
	MOV R6, LINHA_START 				; guarda no registo R6 
	CALL nao_ha_tecla 					; fica � espera que uma tecla seja pressionada
	MOV	R1, 1 							; guarda no registo R1 o valor 1(vai-se selecionar o cen�rio n�mero 1)
	MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cen�rio de fundo
	
	CALL ha_tecla	   					; espera que se largue D, caso contrario voltaria ao ciclo de novo
					   					; (ficando preso no menu)

	CALLF desenha_rover 				; desenha-se o rover novamente
	CALLF desenha_um_meteoro
	JMP ciclo_jogo 						; volta-se para a rotina le_tecla_rover

testa_fim:
	MOV  R6, LINHA_START				; linha a testar no teclado
	CALL	teclado						; leitura �s teclas
	CMP	R0, TECLADO_3					; verifica se a tecla E foi premida
	JZ termina_jogo 					; se foi premida, termina-se o jogo
	RET 								; se n�o foi premida faz-se return

termina_jogo: 
	MOV  [APAGA_ECR�], R1				; apaga todos os pixels j� desenhados (o valor de R1 n�o � relevante)
	MOV	R1, 2							; cen�rio de fundo n�mero 2
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; muda cen�rio de fundo
    JMP fim       						; termina o jogo

fim: JMP fim 							; termina o jogo

ve_limites_rover:
	CALL	testa_limites				; v� se chegou aos limites do ecr� e se sim for�a R7 a 0
	CMP	R7, 0
	JZ	sai_ler_tecla_rover				; se n�o � para movimentar o objeto, sai da rotina
	CALL     move_rover         		; Caso contr�rio, movimentar rover
	JMP sai_ler_tecla_rover     		; Terminar rotina

; *********************************************************************
; * MOVE_ROVER (move_rover, coluna_seguinte)
; * Argumentos:
; *    - R7-> a -1 ou 1; mover o boneco ou para a esquerda ou direita.
; * Outros registos usados:
; *    - R1-> Defini��o do Rover
; *    - R2-> Endere�o
; *********************************************************************
move_rover:
	PUSH R1
	MOV  R1, DEF_ROVER           ; Argumento do apaga_boneco
	CALL apaga_boneco		; apaga o boneco na sua posi��o corrente
	POP  R1
	JMP  coluna_seguinte

coluna_seguinte:
	PUSH R1             			; Guarda R1
	PUSH R2             			; Guarda R2
	MOV  R1, DEF_ROVER   			; Endere�o do desenho do rover
	ADD  R1, 2           			; Endere�o da coluna atual do rover
	MOV  R2, [R1]        			; Coluna atual do rover
	ADD  R2, R7          			; Altera coluna atual p/ desenhar o objeto na coluna seguinte (esq. ou dir)
	MOV  [R1], R2        			; Escreve a nova coluna na mem�ria do rover
	PUSH R11
	CALLF desenha_rover				; vai desenhar o boneco de novo
	POP  R11
	POP R2
	POP R1
	RET 				 			; Acaba rotina de move_rover
	

; **********************************************************************
; DESENHA_BONECO - Desenha um boneco a partir da linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:    R1 - Tabela que define o boneco
;
; Outros registos usados:
;                R2 - Linha de refer�ncia do boneco
;                R3 - Coluna de refer�ncia do boneco
;                R4 - Largura do boneco
;                R5 - Altura do boneco
;                R6 - Cor do pixel a ser desenhado
;
; A posi��o e dimens�es do boneco s�o lidas a partir da tabela.
;
; **********************************************************************
desenha_boneco:
	PUSH    R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH    R6
	PUSH    R11
	MOV R11, R1             ; Guardar endere�o inicial da tabela
	MOV R2, [R1]            ; Obt�m a linha do boneco

	ADD R1, 2               ; Endere�o da coluna
	MOV R3, [R1]			; Obt�m a coluna do boneco

	ADD R1, 2               ; Endere�o da largura do boneco
	MOV R4, [R1]            ; Obt�m a largura do boneco

	ADD R1, 2               ; Endere�o da altura do boneco
	MOV R5, [R1]            ; Obt�m a altura do boneco

	ADD	R1, 2				; Endere�o da cor do 1� pixel (2 porque a largura � uma word)
	JMP desenha_linha   	; Come�ar a desenhar a linha

desenha_muda_linha:
	PUSH R11               ; Salvaguardar endere�o inicial da tabela
	ADD R11, 2             ; Endere�o da coluna inicial do boneco
	MOV R3, [R11]          ; Voltar � coluna inicial
	ADD R11, 2             ; Endere�o da largura do boneco
	MOV R4, [R11]          ; Reinicializa a largura do boneco
	SUB R2, 1              ; Passa a escrever na linha de cima do Mediacenter
	SUB R5, 1              ; Decrementa a altura do boneco (menos uma linha a tratar)
	
	POP R11
	JNZ desenha_linha      ; Desenhar a nova linha
	JMP sai_desenha_boneco ; Caso n�o haja nova linha, sair


desenha_linha:             ; Desenha uma linha de pixels do boneco a partir da tabela
    MOV R6, [R1]           ; Obt�m a cor do pr�xima pixel do boneco
	CALL escreve_pixel     ; Escreve o pixel atual
	ADD R1, 2              ; Endere�o da cor do pr�ximo pixel (2 porque cada cor de pixel � uma word)
	ADD R3, 1              ; Pr�xima coluna
	SUB R4, 1              ; Diminui largura do boneco (menos uma coluna a tratar)
	JNZ desenha_linha      ; Desenhar  pr�xima coluna
	JMP desenha_muda_linha ; Caso n�o haja mais colunas, passar � pr�xima linha


sai_desenha_boneco:
	POP R11
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
;                R2 - Linha de refer�ncia do boneco
;                R3 - Coluna de refer�ncia do boneco
;                R4 - Largura do boneco
;                R5 - Altura do boneco
;                R6 - Cor do pixel (sempre 0)
;                R11 - C�pia do argumento da tabela
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
	PUSH    R11
	MOV R11, R1  ; Guardar endere�o inicial da tabela
	MOV R2, [R1] ; Obt�m a linha de refer�ncia do boneco

	ADD R1, 2    ; Endere�o da coluna de refer�ncia do boneco
	MOV R3, [R1] ; Obt�m a coluna de refer�ncia do boneco

	ADD R1, 2    ; Endere�o da largura do boneco
	MOV R4, [R1] ; Obt�m a largura do boneco

	ADD R1, 2    ; Endere�o da altura do boneco
	MOV R5, [R1] ; Obt�m a altura do boneco
	JMP apaga_linha


apaga_muda_linha:
	PUSH R11               ; Salvaguardar endere�o inicial da tabela
	ADD R11, 2             ; Endere�o da coluna inicial do boneco
	MOV R3, [R11]          ; Voltar � coluna inicial
	ADD R11, 2             ; Endere�o da largura do boneco
	MOV R4, [R11]          ; Reinicializa a largura do boneco
	SUB R2, 1              ; Passa a escrever na linha de cima do Mediacenter
	SUB R5, 1              ; Decrementa a altura do boneco (menos uma linha a tratar)
	POP R11                ; Restaura o endere�o inicial
	JNZ apaga_linha        ; Apagar a pr�xima linha
	JMP sai_apaga_boneco   ; Caso n�o haja pr�xima linha, sair


apaga_linha:       			; desenha os pixels do boneco a partir da tabela
	MOV	R6, 0				; cor para apagar o pr�ximo pixel do boneco
	CALL	escreve_pixel	; escreve cada pixel do boneco
        ADD  R3, 1          ; pr�xima coluna
        SUB  R4, 1			; menos uma coluna para tratar
        JNZ  apaga_linha    ; continua at� percorrer toda a largura do objeto
	JMP apaga_muda_linha  	; Linha atual acabou - passar � seguinte


sai_apaga_boneco:
	POP R11
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
	MOV  [DEFINE_PIXEL], R6 	; altera a cor do pixel na linha e coluna j� selecionadas
	RET


; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R1 - valor que define o atraso
;
; **********************************************************************
atraso:
	PUSH	R1
	MOV R1, ATRASO
ciclo_atraso:
	SUB	R1, 1
	JNZ	ciclo_atraso
	POP	R1
	RET

; **********************************************************************
; TESTA_LIMITES - Testa se o Rover chegou aos limites do ecr� e nesse caso
;			   impede o movimento (for�a R7 a 0)
; Registos Usados:	
;			R1 - Endere�o da defini��o do Rover
;			R2 - coluna em que o objeto est�
;			R6 - largura do Rover
;			R7 - sentido de movimento do Rover (valor a somar � coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	R7 - 0 se j� tiver chegado ao limite, inalterado caso contr�rio
; **********************************************************************
testa_limites:
	PUSH    R1
	PUSH    R2
	PUSH	R5
	PUSH	R6
	MOV     R1, DEF_ROVER 			; Endere�o da defini��o do Rover
	ADD     R1, 2         			; Endere�o da coluna em que o Rover est�
	MOV     R2, [R1]      			; Obt�m coluna
	ADD     R1, 2         			; Endere�o da largura do Rover
	MOV     R6, [R1]      			; Obt�m largura do Rover
	JMP     testa_limite_esquerdo
testa_limite_esquerdo:				; v� se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JGT	testa_limite_direito
	CMP	R7, 0				; passa a deslocar-se para a direita
	JGE	sai_testa_limites
	JMP	impede_movimento	; entre limites. Mant�m o valor do R7
testa_limite_direito:		; v� se o boneco chegou ao limite direito
	ADD	R6, R2				; posi��o a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JLE	sai_testa_limites	; entre limites. Mant�m o valor do R7
	CMP	R7, 0				; passa a deslocar-se para a direita
	JGT	impede_movimento 	; Impedir movimento se este for p/ a direita
	JMP	sai_testa_limites

impede_movimento:
	MOV	R7, 0				; impede o movimento, for�ando R7 a 0
	JMP sai_testa_limites 	; Sair

sai_testa_limites:
	POP	R6
	POP	R5
	POP R2
	POP R1
	RET

; **********************************************************************
; TECLADO - Faz uma leitura �s teclas de uma linha do teclado e retorna o valor lido
; Argumentos:	R6 - linha a testar (em formato 1, 2, 4 ou 8)
;
; Retorna: 	R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)
; **********************************************************************
teclado:
	PUSH	R2
	PUSH	R3
	PUSH	R5
	MOV  R2, TEC_LIN   ; endere�o do perif�rico das linhas
	MOV  R3, TEC_COL   ; endere�o do perif�rico das colunas
	MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6      ; escrever no perif�rico de sa�da (linhas)
	MOVB R0, [R3]      ; ler do perif�rico de entrada (colunas)
	AND  R0, R5        ; elimina bits para al�m dos bits 0-3
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
    MOV  R2, TEC_LIN   ; endere�o do perif�rico das linhas
	MOV  R3, TEC_COL   ; endere�o do perif�rico das colunas
	MOV  R5, MASCARA

    MOVB [R2], R6      ; escrever no perif�rico de sa�da (linhas)
    MOVB R0, [R3]      ; ler do perif�rico de entrada (colunas)
    AND  R0, R5        ; elimina bits para al�m dos bits 0-3

    CMP  R0, R10       ; h� tecla premida? (R10 guarda o valor da coluna pretendida)
    JZ  ht  		   ; se a tecla desejada estiver premida, espera at� n�o haver  
        
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

    MOVB [R2], R6      ; escrever no perif�rico de sa�da (linhas)
    MOVB R0, [R3]      ; ler do perif�rico de entrada (colunas)
    AND  R0, R5        ; elimina bits para al�m dos bits 0-3

    CMP  R0, R10       ; h� tecla premida? (R10 tem o valor da coluna, tal como em ha_tecla)
    JNZ  nht      	   ; se a tecla desejada nao estiver premida, repete o ciclo

    POP	R5
	POP	R3
	POP	R2
    POP R0
	RET