; Aluno: Felipe Kravec Zanatta
; Arquivo para as funções e funcionamento da calculadora.

; nasm -f elf64 funcoes.asm -o funcoes.o
; nasm -f elf64 main.asm -o main.o
; gcc -m64 -no-pie funcoes.o main.o -o programa_executavel.x
; ./programa_executavel.x

extern printf
extern scanf
extern fopen
extern fclose
extern fprintf

extern main

section .data
    ; Arquivos que armazenarão cada operação
    file_name       : db "resultados.txt"
    open_mode       : db "a", 0  ; Read/Write, cria o arquivo se não existe, posiciona o ponteiro no fim do arquivo

    ; Input inicial do arquivo, depois o formata em pf, char, pf
    operation_input  : db "Insira a operação (número (a)dição/(s)ubtração/(m)ultiplicação/(d)ivisão/(e)xponenciação número) : ", 0
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
