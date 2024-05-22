; Aluno: Felipe Kravec Zanatta
; Arquivo principal (main) da calculadora.

; nasm -f elf64 funcoes.asm -o funcoes.o
; nasm -f elf64 main.asm -o main.o
; gcc -m64 -no-pie funcoes.o main.o -o programa_executavel.x
; ./programa_executavel.

extern printf
extern fprintf
extern exit
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
    file_name       : db "resultados.txt", 0
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

main:
    push rbp
    mov rbp, rsp
    sub rsp, 0x20

    ; Abrir arquivo
    lea rdi, [file_name]
    lea rsi, [open_mode]
    call fopen

    mov [recognize_file], rax

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

    cmp eax, 0x73
    je subtraction

    cmp eax, 0x6d
    je multiply

    cmp eax, 0x64
    je division

    cmp eax, 0x65
    je exponentiation

    ; Caso de operação inválida
    jmp invalid_operation

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

        cmp DWORD [rbp-16], 0
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
        mov BYTE [rbp-5], 0x5e

        jmp final_result

    invalid_operation:
        mov rdi, [recognize_file]
        mov rsi, output_error

        movss xmm0, DWORD [rbp-16]
        cvtss2sd xmm0, xmm0
        movq rdx, xmm0

        movzx eax, BYTE [rbp-17]
        movsx eax, al
        mov r8d, eax

        movss xmm1, DWORD [rbp-12]
        cvtss2sd xmm1, xmm1
        movq r9, xmm1
        
        movsx edx, BYTE [rbp-17]
	    mov rax, 0x03        
        call fprintf
        jmp close_file

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
        mov rdi, [recognize_file]
        mov rsi, output
        mov rax, 0x03
        call fprintf

        ; Fecha arquivo
        mov rdi, [recognize_file]
        call fclose

    file_error:
        mov rdi, [recognize_file]
        lea rsi, [output_error]
        mov rax, 0x04

        call fprintf
        jmp end

close_file:
    ; Fecha arquivo
    mov rdi, [recognize_file]
    call fclose

    jmp end

end:
    mov rsp, rbp
    pop rbp

    mov rax, 60
    xor rdi, rdi
    syscall
