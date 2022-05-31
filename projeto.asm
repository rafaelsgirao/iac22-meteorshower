; *********************************************************************************
; * IST-UL
; * Projeto de Introdução à Arquitetura de Computadores 2021/2022
; * Chuva de Meteoros
; *
; * ist1103860 Henrique Caroço
; * ist1103883 Luís Calado
; * ist199309  Rafael Girão
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
TEC_LIN				EQU 0C000H	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL				EQU 0E000H	; endereço das colunas do teclado (periférico PIN)
LINHA_TECLADO			EQU 1		; linha a testar (1ª linha, 1000b)
LINHA_START 		EQU 8       ; linha a testar para começar o jogo(4ª linha)
MASCARA				EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA			EQU 1		; tecla na primeira coluna do teclado (tecla 0)
TECLA_DIREITA			EQU 4		; tecla na terceira coluna do teclado (tecla 2)

DEFINE_LINHA    		EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo

LINHA        	EQU  31        ; linha do boneco (a fim do ecrã))
COLUNA			EQU  30        ; coluna do boneco (a meio do ecrã)

;--------------------------------
LINHA_INICIAL               EQU 1
LINHA_METEORO_NEUTRO_2      EQU 4

LINHA_INICIAL_METEOROS      EQU 7
LINHA_METEOROS_2            EQU 10
LINHA_METEOROS_3           	EQU 13

LINHA_EXPLOSAO              EQU 1
LINHA_DISPARO               EQU 1
;--------------------------------

MIN_COLUNA		EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	0400H		; atraso para limitar a velocidade de movimento do boneco

LARGURA			EQU	05H		; largura do boneco
CASTANHO		EQU	0FA52H		
AZUL			EQU	0F00FH	
ROSA_EXP		EQU	04F0EH  ; Cor rosa da explosão dos meteoros
VERDE_FORA		EQU	0F0F0H	; Meteoros bons
VERDE_DENTRO	EQU	060F0H	; Meteoros bons
VERMELHO		EQU	0FF00H	; Meteoros maus
CINZENTO		EQU	0C777H	; Cor neutra - Meteoros de longe

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 100H			; espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)

;---------------------------------------------------------------------------------;
;----------------------TABELAS DE DEFINICAO DAS FIGURAS---------------------------;		
;---------------------------------------------------------------------------------;

DEF_BONECO:					; tabela que define o boneco (cor, largura, pixels)
	WORD		LARGURA
	WORD		0, 0, CASTANHO, 0, 0
	WORD		CASTANHO, 0, AZUL, 0, CASTANHO
	WORD		CASTANHO, AZUL, CASTANHO, AZUL, CASTANHO
	WORD		0, CASTANHO, 0, CASTANHO, 0	
     
METEORO_NEUTRO_1:           ; Definicao do primeiro meteoro neutro
    WORD LINHA_INICIAL

    WORD CINZENTO 

METEORO_NEUTRO_2:           ; Definicao do segundo meteoro neutro
    WORD LINHA_METEORO_NEUTRO_2

    WORD CINZENTO,      CINZENTO
    WORD CINZENTO,      CINZENTO

METEORO_BOM_1:              ; Definicao do primeiro meteoro bom
    WORD LINHA_INICIAL_METEOROS

    WORD 0,             VERDE_FORA,     0
    WORD VERDE_FORA,    VERDE_DENTRO,   VERDE_FORA
    WORD 0, VERDE_FORA, 0

METEORO_BOM_2:              ; Definicao do segundo meteoro bom
    WORD LINHA_METEOROS_2

    WORD 0,             VERDE_FORA,     VERDE_FORA,     0
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA
    WORD VERDE_FORA,    VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD 0,             VERDE_FORA,     VERDE_FORA,     0

METEORO_BOM_3:              ; Definicao do terceiro meteoro bom
    WORD LINHA_METEOROS_3

    WORD 0,             VERDE_FORA,     VERDE_FORA,     VERDE_FORA,     0
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD VERDE_FORA,    VERDE_DENTRO,   VERDE_DENTRO,   VERDE_DENTRO,   VERDE_FORA
    WORD VERDE_FORA,    VERDE_FORA,     VERDE_DENTRO,   VERDE_FORA,     VERDE_FORA
    WORD 0,             VERDE_FORA,     VERDE_FORA,     VERDE_FORA,     0

METEORO_MAU_1:              ; Definicao do primeiro meteoro mau
    WORD LINHA_INICIAL_METEOROS

    WORD VERMELHO,  VERMELHO,   VERMELHO
    WORD 0,         VERMELHO,   0
    WORD VERMELHO,  0,          VERMELHO

METEORO_MAU_2:              ; Definicao do segundo meteoro mau
    WORD LINHA_METEOROS_2

    WORD VERMELHO,  VERMELHO,   VERMELHO,   VERMELHO
    WORD 0,         VERMELHO,   VERMELHO,   0
    WORD VERMELHO,  0,          0,          VERMELHO
    WORD VERMELHO,  0,          0,          VERMELHO

METEORO_MAU_3:              ; Definicao do terceiro meteoro mau
    WORD LINHA_METEOROS_3

    WORD VERMELHO,  0,          0,          0,          VERMELHO
    WORD 0,         VERMELHO,   VERMELHO,   VERMELHO,   0
    WORD 0,         VERMELHO,   VERMELHO,   VERMELHO,   0
    WORD VERMELHO,  0,          VERMELHO,   0,          VERMELHO
    WORD VERMELHO,  0,          0,          0,          VERMELHO

EXPLOSAO:                   ; Definicao das explosoes
    WORD LINHA_EXPLOSAO

    WORD 0,         ROSA_EXP,   0,          ROSA_EXP,   0
    WORD ROSA_EXP,  0,          ROSA_EXP,   0,          ROSA_EXP
    WORD 0,         ROSA_EXP,   0,          ROSA_EXP,   0
    WORD ROSA_EXP,  0,          ROSA_EXP,   0,          ROSA_EXP
    WORD 0,         ROSA_EXP,   0,          ROSA_EXP,      0

DISPARO:                    ; Definicao dos disparos da nave
    WORD LINHA_DISPARO

    WORD AZUL


; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                     ; o código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial		; inicializa SP para a palavra a seguir
						; à última da pilha
                            
     MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
     MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			; cenário de fundo número 0
     MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV	R7, 1			; valor a somar à coluna do boneco, para o movimentar

comeca:
	MOV R11, ATRASO
	MOV  R6, LINHA_START	; linha a testar no teclado
	CALL	teclado			; leitura às teclas
	CMP	R0, TECLA_ESQUERDA
	JNZ comeca
	MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 1			; cenário de fundo número 0
     MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo

posicao_boneco:
     MOV  R1, LINHA			; linha do boneco
     MOV  R2, COLUNA		; coluna do boneco
	MOV	R4, DEF_BONECO		; endereço da tabela que define o boneco

mostra_boneco:
	CALL	desenha_boneco		; desenha o boneco a partir da tabela

espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
	MOV R11, ATRASO
	MOV  R6, LINHA_TECLADO	; linha a testar no teclado
	CALL	teclado			; leitura às teclas
	CMP	R0, 0
	JZ	espera_tecla		; espera, enquanto não houver tecla
	CMP	R0, TECLA_ESQUERDA
	JNZ	testa_direita
	MOV	R7, -1			; vai deslocar para a esquerda
	CALL atraso
	JMP	ve_limites
testa_direita:
	CMP	R0, TECLA_DIREITA
	JNZ	espera_tecla		; tecla que não interessa
	MOV	R7, +1	; vai deslocar para a direita
	CALL atraso
ve_limites:
	MOV	R6, [R4]			; obtém a largura do boneco
	CALL	testa_limites		; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP	R7, 0
	JZ	espera_tecla		; se não é para movimentar o objeto, vai ler o teclado de novo

move_boneco:
	CALL	apaga_boneco		; apaga o boneco na sua posição corrente
	
coluna_seguinte:
	ADD	R2, R7			; para desenhar objeto na coluna seguinte (direita ou esquerda)

	JMP	mostra_boneco		; vai desenhar o boneco de novo


; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_boneco:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R2, 1               ; próxima coluna
     SUB  R5, 1			; menos uma coluna para tratar
     JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	RET

; **********************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
apaga_boneco:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
apaga_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0			; cor para apagar o próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R2, 1               ; próxima coluna
     SUB  R5, 1			; menos uma coluna para tratar
     JNZ  apaga_pixels      ; continua até percorrer toda a largura do objeto
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	RET


; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R11 - valor que define o atraso
;
; **********************************************************************
atraso:
	PUSH	R11
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP	R11
	RET

; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   impede o movimento (força R7 a 0)
; Argumentos:	R2 - coluna em que o objeto está
;			R6 - largura do boneco
;			R7 - sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário	
; **********************************************************************
testa_limites:
	PUSH	R5
	PUSH	R6
testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JGT	testa_limite_direito
	CMP	R7, 0			; passa a deslocar-se para a direita
	JGE	sai_testa_limites
	JMP	impede_movimento	; entre limites. Mantém o valor do R7
testa_limite_direito:		; vê se o boneco chegou ao limite direito
	ADD	R6, R2			; posição a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JLE	sai_testa_limites	; entre limites. Mantém o valor do R7
	CMP	R7, 0			; passa a deslocar-se para a direita
	JGT	impede_movimento
	JMP	sai_testa_limites
impede_movimento:
	MOV	R7, 0			; impede o movimento, forçando R7 a 0
sai_testa_limites:	
	POP	R6
	POP	R5
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


