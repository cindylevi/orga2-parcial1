global miraQueCoincidencia

section .rodata
align 16 
blanco: times 16 db 255
pixel_blanco: times 4 db 255
byte_blanco: times 1 db 255

section .data
align 16 
multiply_colors dd 0.114, 0.587, 0.299, 0
;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void miraQueCoincidencia( uint8_t *A[rdi], uint8_t *B[rsi], uint32_t N[rdx], uint8_t *laCoincidencia [rcx])
miraQueCoincidencia:
    ;prologo
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r15, rcx ; r15 = puntero de imagen de salida
    mov eax, edx
    mul edx ; rdx = N * N en 4 pixeles = cantidad de iteraciones que tengo que hacer para procesar toda la imagen
    mov rdx, rax
    shr rdx, 2 ; rdx = ancho y alto de la imagen medido de a 4 pixeles
    movdqu xmm2, [multiply_colors]
    .ciclo:
        movdqu xmm0, [rdi] ; xmm0 = 4 pixeles imagen A
        movdqu xmm1, [rsi] ; xmm1 = 4 pixeles imagen B
        movdqu xmm3, xmm1 ; xmm3 = 4 pixeles imagen A
        PCMPEQD xmm0, xmm1 ; xmm0 = pixeles iguales son 1, pixeles diferentes son 0

        ;proceso el pixel
        mov r14, 4 ; quiero procesar 4 pixeles, asi que hago 4 veces el ciclo
        .proceso_pixel:
            movd r12d, xmm0 ; r12d = pixel 0 si es diferente, 1 sino
            mov r13b, [byte_blanco]; r13 es el pixel a guardar
            cmp r12d, 0
            jz .continue
                ;si no es blanco ejecuto:
                PMOVZXBD xmm1, xmm3 ; expando el low pixel para que cada uno de sus valores sea un int
                CVTDQ2PS xmm1, xmm1 ; convierto el int a float 
                MULPS xmm1, xmm2 ; multiplico cada valor para convertir el pixel a escala de grises y hago que el alfa valga 0
                CVTTPS2DQ xmm1, xmm1 ; convierte los floats a integers

                PHADDD xmm1, xmm1 ; sumo horizontalmente los valores
                PHADDD xmm1, xmm1

                xor r13d, r13d
                movd r13d, xmm1 ; r13b es el pixel a guardar
            .continue:
            mov byte[r15], r13b
            PSRLDQ xmm3, 4 ; shifteo 4 bytes a la izquierda para procesar el siguiente pixel
            PSRLDQ xmm0, 4 ; shifteo 4 bytes a la izquierda para procesar el siguiente pixel
            add r15, 1
        dec r14
        cmp r14, 0
        jnz .proceso_pixel

        add rdi, 16
        add rsi, 16
    dec rdx
    cmp rdx,0
    jnz .ciclo

	;epilogo
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

