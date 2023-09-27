extern malloc

global templosClasicos
global cuantosTemplosClasicos

%define TEMPLO_COL_LARGA 0
%define TEMPLO_PUNT_NOMBRE 8
%define TEMPLO_COL_CORTO 16
%define LONG_TEMPLO 24

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;templo* templosClasicos(templo *temploArr[rdi], size_t temploArr_len[rsi]);
templosClasicos:
    ;prologo
	push rbp
	mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi ; r12 = *temploArr
    mov r13, rsi ; r13 = length arr

    call cuantosTemplosClasicos

    mov rdi, rax ; rdi = cant de templos clasicos
    mov rax, LONG_TEMPLO ; rax = cuanto mide en bytes un templo en memoria
    mul rdi ; rax = cuanto va a medir el array de templos clasicos
    ;pido la memoria para el array de clasicos
    mov rdi, rax ; rdi = cuanto va a medir el array de templos clasicos
    call malloc
    mov r14, rax ;r14 = primera pos de memoria del array de clasicos
    push r14
    SUB RSP, 0x8

    mov rcx, r13 ; carga la cantidad de templos para recorrer el array
	.cycle:     ; etiqueta a donde retorna el ciclo que itera sobre arr
        xor r8, r8 ;r8 = templo columnas largas
        xor r15, r15 ; r15 = puntero a nombre del array
        xor r9, r9; r9 = templo columnas cortas, luego cambia su valor
        xor r13,r13 ; r13 = templo columnas cortas
        xor rax, rax


		mov r8b, byte[r12 + TEMPLO_COL_LARGA] ; r8 = templo columnas largas
        mov r15, [r12 + TEMPLO_PUNT_NOMBRE ] ; r15 = puntero a nombre del array
		mov r9b, byte[r12 + TEMPLO_COL_CORTO] ; r9 = templo columnas cortas
        mov r13b, r9b ; r13 = templo columnas cortas

        mov rax, 2
        mul r9
        mov r9, rax
        add r9,1 ; r9 = 2N+1
        cmp r8, r9 ; si 2N+1 = M suma uno al contador
        jnz .continue ; como es clasico, lo agrego al nuevo array
            mov [r14 + TEMPLO_COL_LARGA], r8 
            mov [r14 + TEMPLO_PUNT_NOMBRE ], r15
            mov [r14 + TEMPLO_COL_CORTO], r13
            add r14, LONG_TEMPLO
        .continue:
        add r12, LONG_TEMPLO
	loop .cycle ; decrementa ecx y si es distinto de 0 salta a .cycle

    add RSP, 0x8
    pop r14
    mov rax, r14

    ;epilogo
    pop r15
    pop r14
    pop r13
    pop r12
	pop rbp
	ret
    
;uint32_t cuantosTemplosClasicos(templo *temploArr [rdi], size_t temploArr_len[rsi]);
cuantosTemplosClasicos:
    ;prologo
	push rbp
	mov rbp, rsp
	push r12
    push r13

    xor r12, r12;r12 = contador de templos clasicos
    
    mov rcx, rsi ; carga la cantidad de templos para recorrer el array
	.cycle:     ; etiqueta a donde retorna el ciclo que itera sobre arr
        xor r8, r8 ;r8 = templo columnas largas
        xor r9, r9; r9 = templo columnas cortas
        xor rax, rax


		mov r8b, byte[rdi + TEMPLO_COL_LARGA] ; r8 = templo columnas largas
		mov r9b, byte[rdi + TEMPLO_COL_CORTO] ; r9 = templo columnas cortas

        mov rax, 2
        mul r9
        mov r9, rax
        add r9,1 ; r9 = 2N+1
        sub r8, r9 ; si 2N+1 = M suma uno al contador
        jnz .continue
        add r12, 1
        .continue:
        add rdi, LONG_TEMPLO
	loop .cycle 

    mov eax, r12d
	;epilogo
    pop r13
    pop r12
	pop rbp
	ret

