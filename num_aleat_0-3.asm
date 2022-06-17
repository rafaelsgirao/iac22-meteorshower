
gera_num_aleatorio:
    PUSH R0
    PUSH R1

    MOV R0, TEC_COL
    MOV R1, [R0]
    SHR R1, 5
    MOV R2, R1
    MOV R0, 4
    MOD R2, R0

    POP R1
    POP R0
  