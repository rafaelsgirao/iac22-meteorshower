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
MASCARA				EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA			EQU 1		; tecla na primeira coluna do teclado (tecla 0)
TECLA_DIREITA			EQU 4		; tecla na segunda coluna do teclado (tecla 2)

DEFINE_LINHA    		EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo

; Constantes do Rover
LINHA_INICIAL_ROVER        		EQU  31        ; linha do boneco (a meio do ecrã)
COLUNA_INICIAL_ROVER			EQU  30        ; coluna do boneco (a meio do ecrã)
LARGURA_ROVER			EQU	05H		; largura do boneco
ALTURA_ROVER          EQU 04H

MIN_COLUNA		EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	0400H		; atraso para limitar a velocidade de movimento do boneco

; Cores
CASTANHO		EQU	0FA52H
AZUL			EQU	0F00FH
ROSA_EXP		EQU	08800H  ; Cor rosa da explosão dos meteoros
VERDE_FORA		EQU	0F0F0H		; Meteoros bons
VERDE_DENTRO	EQU	0A080H	; Meteoros bons
VERMELHO		EQU	0FF00H	; Meteoros maus
CINZENTO		EQU	0A888H	; Cor neutra - Meteoros de longe

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

DEF_ROVER:			    ; tabela que define o rover.
	; A primeira linha desta tabela contém a 1ª linha do Rover a contar de baixo.
	; A linha e coluna são alteradas quando o Rover é movimentado
	WORD            LINHA_INICIAL_ROVER
	WORD            COLUNA_INICIAL_ROVER
	WORD	        LARGURA_ROVER
	WORD            ALTURA_ROVER
	WORD		0, CASTANHO, 0, CASTANHO, 0
	WORD		CASTANHO, AZUL, CASTANHO, AZUL, CASTANHO
	WORD		CASTANHO, 0, AZUL, 0, CASTANHO
	WORD		0, 0, CASTANHO, 0, 0


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
	JMP ciclo           ; Começar ciclo do jogo
;	CALL desenha_rover_inicial ; Inicializa o desenho do rover

ciclo:
	CALL desenha_rover

; *********************************************************************************
; * Desenha o rover no ecrã.
; *********************************************************************************
desenha_rover:
	PUSH R1             ; Resguardar registo a ser alterado
	MOV R1, DEF_ROVER   ; Endereço da tabela que define o Rover (argumento de desenha_boneco)
	CALL desenha_boneco
	POP R1              ; Resgatar registo alterado
	RET


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
; DESENHA_BONECO - Desenha um boneco a partir da linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - Tabela que define o boneco
;
; Outros registos usados:
;                R2 - Linha de referência do boneco
;                R3 - Coluna de referência do boneco
;                R4 - Largura do boneco
;                R5 - Altura do boneco
;                R6 - Cor do pixel a ser desenhado
;
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
	PUSH    R11
	MOV R11, R1             ; Guardar endereço inicial da tabela TODO: ver se isto é válido
	MOV R2, [R1]            ; Obtém a linha do boneco

	ADD R1, 2               ; Endereço da coluna
	MOV R3, [R1]			; Obtém a coluna do boneco

	ADD R1, 2               ; Endereço da largura do boneco
	MOV R4, [R1]            ; Obtém a largura do boneco

	ADD R1, 2               ; Endereço da altura do boneco
	MOV R5, [R1]            ; Obtém a altura do boneco

	ADD	R1, 2			; Endereço da cor do 1º pixel (2 porque a largura é uma word)
	JMP desenha_linha   ; Começar a desenhar a linha

desenha_muda_linha:
	PUSH R11               ; Salvaguardar endereço inicial da tabela
	ADD R11, 4             ; Endereço da largura do boneco
	MOV R4, [R11]          ; Reinicializa a largura do boneco
	SUB R2, 1              ; Passa a escrever na linha de cima do Mediacenter
	SUB R5, 1              ; Decrementa a altura do boneco (menos uma linha a tratar)
	POP R11
	JNZ desenha_linha      ; Desenhar a nova linha
	JMP sai_desenha_boneco ; Caso não haja nova linha, sair


desenha_linha:             ; Desenha uma linha de pixels do boneco a partir da tabela
    MOV R6, [R1]           ; Obtém a cor do próxima pixel do boneco
	CALL escreve_pixel     ; Escreve o pixel atual
	ADD R1, 2              ; Endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
	ADD R3, 1              ; Próxima coluna
	SUB R4, 1              ; Diminui largura do boneco (menos uma coluna a tratar)
	JNZ desenha_linha      ; Desenhar  próxima coluna
	JMP desenha_muda_linha     ; Caso não haja mais colunas, passar à próxima linha


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
; Argumentos:   R1 - tabela que define o boneco


; Outros registos usados:
;                R2 - Linha de referência do boneco
;                R3 - Coluna de referência do boneco
;                R4 - Largura do boneco
;                R5 - Altura do boneco
;                R6 - Cor do pixel (sempre 0)
;                R11 - Cópia do argumento da tabela
;
;
; **********************************************************************

	; WORD        LINHA_INICIAL_ROVER
	; WORD        COLUNA_INICIAL_ROVER
	; WORD		LARGURA
	; WORD        ALTURA

apaga_boneco:
	PUSH    R1
	PUSH    R2
	PUSH    R3
	PUSH    R4
	PUSH    R5
	PUSH    R6
	PUSH    R11
	MOV R2, [R1] ; Obtém a linha de referência do boneco

	ADD R1, 2    ; Endereço da coluna de referência do boneco
	MOV R3, [R1] ; Obtém a coluna de referência do boneco

	ADD R1, 2    ; Endereço da largura do boneco
	MOV R4, [R1] ; Obtém a largura do boneco

	ADD R1, 2    ; Endereço da altura do boneco
	MOV R5, [R1] ; Obtém a altura do boneco
	JMP apaga_linha


apaga_muda_linha:
	PUSH R11               ; Salvaguardar endereço inicial da tabela
	ADD R11, 4             ; Endereço da largura do boneco
	MOV R4, [R11]          ; Reinicializa a largura do boneco
	SUB R2, 1              ; Passa a escrever na linha de cima do Mediacenter
	SUB R5, 1              ; Decrementa a altura do boneco (menos uma linha a tratar)
	POP R11
	JNZ apaga_linha      ; Apagar a próxima linha
	JMP sai_apaga_boneco ; Caso não haja próxima linha, sair

; desenha_linha:             ; Desenha uma linha de pixels do boneco a partir da tabela
;     MOV R6, [R1]           ; Obtém a cor do próxima pixel do boneco
; 	CALL escreve_pixel     ; Escreve o pixel atual
; 	ADD R1, 2              ; Endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
; 	ADD R3, 1              ; Próxima coluna
; 	SUB R4, 1              ; Diminui largura do boneco (menos uma coluna a tratar)
; 	JNZ desenha_linha      ; Desenhar  próxima coluna
; 	JMP desenha_muda_linha     ; Caso não haja mais colunas, passar à próxima linha


apaga_linha:       		; desenha os pixels do boneco a partir da tabela
	MOV	R6, 0			; cor para apagar o próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
    ADD  R3, 1               ; próxima coluna
    SUB  R4, 1			; menos uma coluna para tratar
    JNZ  apaga_linha      ; continua até percorrer toda a largura do objeto
	JMP apaga_muda_linha  ; Linha atual acabou - passar à seguinte
	; JMP sai_apaga_boneco


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
	MOV  [DEFINE_COLUNA], R3		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R6 	; altera a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R1 - valor que define o atraso
;
; **********************************************************************
atraso:
	PUSH	R1
ciclo_atraso:
	SUB	R1, 1
	JNZ	ciclo_atraso
	POP	R1
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
