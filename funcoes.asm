; Aluno: Felipe Kravec Zanatta
; Arquivo para as funções e funcionamento da calculadora.

; nasm -f elf64 funcoes.asm -o funcoes.o
; nasm -f elf64 main.asm -o main.o
; gcc -m64 -no-pie funcoes.o main.o -o programa_executavel.x
; ./programa_executavel.x

; Funções externas do 'C':
extern printf
extern scanf
extern fopen
extern fclose
extern fprintf

extern main

section .data
    ; Arquivos que armazenarão cada operação
    file_name_p1    : db "resutaldo operação (", 0
    file_name_p2    : db ").txt"
    open_mode       : db "w", 0  ; Abertura para escrita, cria um novo arquivo ou sobrescreve um arquivo existente

    ; Input inicial do arquivo, depois o formata em pf, char, pf
    operation_input  : db "Insira a operação (número (a)dição/(s)ubtração/(m)ultiplicação/(d)ivisão/(e)xponenciação número: )", 0
    operation_inputL : equ $ - operation_input

    param_input     : db "%f %c %f", 0

    ; Saídas, output é o resultado esperado do tipo: número operação número = número
    ; output_error é exibido caso seja inserida uma operação diferente de a/s/m/d/e:
    output          : db "%.2f %c %.2f = %.2f", 10, 0
    output_error    : db "%.2f %c %.2f = Operação indisponível, tente novamente", 10, 0

    aux1            : dq 1
    aux2            : db 0

section .bss
    recognize_file  resq 1
    write_file      resq 1

section .text
    global main
    global sum_function
    global subtraction_function
    global multiply_function
    global division_function
    global exponentiation_function

; Função de soma:
sum_function:
    push rbp
    mov rbp, rsp

    movss DWORD [rbp-4], xmm0
    movss DWORD [rbp-8], xmm1
    movss xmm0, DWORD [rbp-4]
    addss xmm0, DWORD [rbp-8]

    movss DWORD [rbp-4], xmm0
    movss xmm0, DWORD [rbp-4]

    pop rbp
    ret

; Função de subtração
subtraction_function:
    push rbp
    mov rbp, rsp

    movss DWORD [rbp-4], xmm0
    movss DWORD [rbp-8], xmm1
    movss xmm0, DWORD [rbp-4]
    subss xmm0, DWORD [rbp-8]

    movss DWORD [rbp-4], xmm0
    movss xmm0, DWORD [rbp-4]

    pop rbp
    ret

; Função de multiplicação
multiply_function:
    push rbp
    mov rbp, rsp

    movss DWORD [rbp-4], xmm0
    movss DWORD [rbp-8], xmm1
    movss xmm0, DWORD [rbp-4]
    mulss xmm0, DWORD [rbp-8]

    movss DWORD [rbp-4], xmm0
    movss xmm0, DWORD [rbp-4]

    pop rbp
    ret

; Função de divisão
division_function:
    push rbp
    mov rbp, rsp

    movss DWORD [rbp-4], xmm0
    movss DWORD [rbp-8], xmm1
    movss xmm0, DWORD [rbp-4]
    divss xmm0, DWORD [rbp-8]

    movss DWORD [rbp-4], xmm0
    movss xmm0, DWORD [rbp-4]

    pop rbp
    ret

; Função de exponenciação
exponentiation_function:
    push rbp
    mov rbp, rsp

    movss xmm2, xmm0
    cvttss2si rdi, xmm1
    cmp rdi, 0

    je equals_zero
    jl equals_one

    cmp rdi, 1
    je less_than_zero
    jmp exponentiation_loop

equals_zero:
    cvtsi2ss xmm0, [aux1]

equals_one:
    xor r15b, r15b
    mov r15b, 1
    mov [aux2], r15b

    mov rsp, rbp
    pop rbp
    ret

less_than_zero:
    mov rsp, rbp
    pop rbp
    ret

exponentiation_loop:
    mulss xmm0, xmm2
    dec rdi

    cmp rdi, 1
    jne exponentiation_loop
        mov rsp, rbp
    pop rbp
    ret
        jmp main
