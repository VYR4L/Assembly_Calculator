; Aluno: Felipe Kravec Zanatta
; Arquivo principal (main) da calculadora.

; nasm -f elf64 funcoes.asm -o funcoes.o
; nasm -f elf64 main.asm -o main.o
; gcc -m64 -no-pie funcoes.o main.o -o programa_executavel.x
; ./programa_executavel.

extern printf
extern exit
extern fprintf
extern scanf
extern fopen
extern fclose

extern funcoes
extern sum_function
extern subtraction_function
extern multiply_function
extern division_function
extern exponentiation_function

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

main:
    push rbp
    mov rbp, rsp

    sub rsp, 0x20

    ; Abrir arquivo
    mov rdi, file_name_p1
    mov rsi, recognize_file
    call fopen
    mov qword [write_file], rax

    cmp rax, 0
    jz file_error

    mov rdi, operation_input
    call printf

    lea rsi, [rsp+10]
    mov rdi, param_input
    call scanf

    mov rax, 1
    mov rdi, 1
    lea rsi, [operation_input]
    mov edx, operation_inputL
    syscall

    lea rcx, [rbp-16]
    lea rdx, [rbp-17]
    lea rax, [rbp-12]

    mov rsi, rax
    mov edi, param_input
    mov eax, 0
    call scanf

    movzx eax, BYTE [rbp-17]
    movsx eax, al

    cmp eax, 0x61
    je sum

    cmp eax, 0x71
    jp subtraction

    cmp eax, 0x6d
    je multiply

    cmp eax, 0x64
    je division

    cmp eax, 0x65
    je exponentiation

    jmp final_result

    sum:
        movss xmm0, DWORD [rbp-16]
        mov eax, DWORD [rbp-12]
        movaps xmm1, xmm0
        movd xmm0, eax
        call sum_function

        movd eax, xmm0
        mov DWORD [rbp-4], eax
        mov BYTE [rbp-5], 0x2b

        jmp final_result

    subtraction:
        movss xmm0, DWORD [rbp-16]
        mov eax, DWORD [rbp-12]
        movaps xmm1, xmm0
        movd xmm0, eax
        call subtraction_function

        movd eax, xmm0
        mov DWORD [rbp-4], eax
        mov BYTE [rbp-5], 0x2d

        jmp final_result
        
    multiply:
        movss xmm0, DWORD [rbp-16]
        mov eax, DWORD [rbp-12]
        movaps xmm1, xmm0
        movd xmm0, eax
        call multiply_function

        movd eax, xmm0
        mov DWORD [rbp-4], eax
        mov BYTE [rbp-5], 0x2a

        jmp final_result

    division:
        movss xmm0, DWORD [rbp-16]
        mov eax, DWORD [rbp-12]
        movaps xmm1, xmm0
        movd xmm0, eax
        call division_function

        movd eax, xmm0
        mov DWORD [rbp-4], eax
        mov BYTE [rbp-5], 0x2f

        je division_by_zero

        jmp final_result

        division_by_zero:
            mov r8, 1
            jmp final_result

    exponentiation:
        movss xmm0, DWORD [rbp-16]
        mov eax, DWORD [rbp-12]
        movaps xmm1, xmm0
        movd xmm0, eax
        call exponentiation_function

        movd eax, xmm0
        mov DWORD [rbp-4], eax
        mov BYTE [rbp-5], 0x2e

        jmp final_result

    final_result:
        pxor xmm1, xmm1
        cvtss2sd xmm1, DWORD [rbp-4]

        movss xmm0, DWORD [rbp-16]
        cvtss2sd xmm0, xmm0

        movsx edx, BYTE [rbp-5]
        movss xmm2, DWORD [rbp-12]

        pxor xmm3, xmm3
        cvtss2sd xmm3, xmm2

        movq rax, xmm3
        movapd xmm2, xmm1
        movapd xmm1, xmm0

        mov esi, edx
        movq xmm0, rax

        xor r15b, r15b
        mov r15b, [aux2]
        cmp r15b, 0
        jne file_error

        cmp r8, 1
        je file_error

    ; Escrever arquivo
    mov rax, qword [write_file]
    mov rsi, param_input
    call fprintf

    ; Fecha arquivo
    mov rdi, qword [write_file]
    call fclose

exit:
    xor rdi, rdi
    call exit

file_error:
    mov rdi, output_error
    call printf
    jmp exit
