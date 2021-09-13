################################################################
#                                                              #
#       Lucas Araujo Pena - 130056162                          #
#       UnB - OAC 2021 - Jacobi                                #
#                                                              #
#       Algoritmo de Bresenham em Assembly (RISC-V)            #
#                                                              #
#       - Algoritmo para criar uma linha entre dois pontos     #
#         em um sistema de matrizes.                           #
#                                                              #
################################################################
.data
################################################################

color:          .word 0xFFFF        # Azul turquesa
dx:             .word 64            # 64p linhas
dy:             .word 64            # 64p coluna
org:            .word 0x10040000    # Endereco de origem da imagem

printx0:        .string     "Insira o valor de x0: "
printx1:        .string     "Insira o valor de x1: "
printy0:        .string     "Insira o valor de y0: "
printy1:        .string     "Insira o valor de y1: "

################################################################
.text
################################################################

main:

    la  a0, printx0                 # Passa a string a ser mostrada para o a0
    li  a7, 4                       # Codigo para mostrar uma string no console
    ecall                           # Pede o valor de x0 no console
    li  a7, 5                       # Codigo para receber um inteiro
    ecall                           # Recebe um inteiro para x0
    mv  s0, a0                      # Salva x0 em s0

    la  a0, printy0                 # Passa a string a ser mostrada para o a0
    li  a7, 4                       # Codigo para mostrar uma string no console
    ecall                           # Pede o valor de y0 no console
    li  a7, 5                       # Codigo para receber um inteiro
    ecall                           # Recebe um inteiro para y0
    mv  s2, a0                      # Salva y0 em s2

    la  a0, printx1                 # Passa a string a ser mostrada para o a0
    li  a7, 4                       # Codigo para mostrar uma string no console
    ecall                           # Pede o valor de x1 no console
    li  a7, 5                       # Codigo para receber um inteiro
    ecall                           # Recebe um inteiro para x1
    mv  s1, a0                      # Salva x1 em s1
    
    la  a0, printy1                 # Passa a string a ser mostrada para o a0
    li  a7, 4                       # Codigo para mostrar uma string no console
    ecall                           # Pede o valor de y1 no console
    li  a7, 5                       # Codigo para receber um inteiro
    ecall                           # Recebe um inteiro para y1
    mv  s3, a0                      # Salva y1 em s3


bresenham:                          ## Comeco do algoritmo

    #########################################
    #  (x0, x1) -> (s0, s1)                 #
    #  (y0, y1) -> (s2, s3)                 #
    #  dx       -> s4                       #
    #  dy       -> s5                       #
    #  D        -> s6                       #
    #  y        -> s7                       #
    #  org      -> s8                       #
    #  x        -> s9                       #
    #  color    -> a2                       #
    #########################################

    lw  a2, color                   # Carrega o valor de color
    lw  s8, org                     # Carrega o valor do primeiro pixel 

    sub s4, s1, s0                  # dx(s4) = x1(s1) - x0(s0)
    sub s5, s3, s2                  # dy(s5) = y1(s3) - y0(s2)
    add t0, s5, s5                  # 2 * dy
    sub s6, t0, s4                  # D(s6) = [2 * dy](t0) - dx(s4)

    mv  s7, s2                      # y = y0
    mv  s9, s0                      # x = x0
    jal  set_pixel                  # Pinta o pixel de origem
    addi s9, s0, 1                  # Salva o valor de x0 + 1


loop:                               ## Loop para o calculo do algoritmo

    bgez s6, D_maior_que_zero       # Se a D > 0, vai para D_maior_que_zero

    jal  set_pixel                  # Pinta o pixel (continua se for falso)
    add  t0, s5, s5                 # 2 * dy
    add  s6, s6, t0                 # D = D + (2*dy)
    

    branch_return:

        addi s9, s9, 1              # Soma mais um para continuar o loop
        beq  s9, s1, fim            # Se X chegar ao valor de x1, finaliza
        j    loop                   # Continua no loop

    D_maior_que_zero:

        addi s7, s7, 1              # y = y + 1
        jal  set_pixel              # Pinta o pixel

        add  t0, s5, s5             # 2 * dy
        add  t1, s4, s4             # 2 * dx
        sub  t2, t0, t1             # (2*dy - 2*dx)
        add  s6, s6, t2             # D = D + (2*dy - 2*dx)

        j    branch_return          # Retorna para onde estava


set_pixel:                          ## Pinta o pixel recebido

    li  t0, 256                     # Offset para pular uma linha (Y)
    li  t1, 4                       # Offset para ir ao prox pixel (X)

    mul t2, s7, t0                  # Calcula o ponto de Y
    #mul t2, s7, s4                  # y * dx
    #mul t2, t2, t1                  # 4 *(y*dx) [ Calcula o ponto de Y]
    mul t3, s9, t1                  # Calcula o ponto de X
    add t2, t2, t3                  # Soma os dois offsets
    add t4, s8, t2                  # Adiciona o offset ao endereco

    sw  a2, 0(t4)                   # Pinta o pixel

    ret                             # Retorna para onde estava

fim:                                ## Finaliza o programa

    li  a7, 10                      # Codigo para finalizar o programa
    ecall                           # Chama a finalizacao do programa
