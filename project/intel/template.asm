segment .data
print_float_format: db    "%lf ", 0
read_float_format: db     "%lf", 0
print_int_format: db      "%d", 0
read_int_format: db       "%d", 0
impossible: db            "Impossible", 0
n: dq 0                     ; size of the cofactor matrix
c: dq 0
neg_zero: dq -0.0           ; for changing the sign of floats
three: dq 3.0
matrix: dq 9000000          ; matrix itself

segment .text

global asm_main
extern printf
extern scanf
extern putchar
extern puts

asm_main:
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8

    call read_int                       ;reading n
    mov qword[n], rax                   ; n = rax
    mov r9, rax                         ; r9 = n
    inc rax                             ; rax++
    mul r9                              ; rax = n(n+1)
    mov rcx, rax                        ; rcx = rax
    xor r12, r12                        ; (i)r12 = 0
    input:
        push rcx                        ; saving rcx
        push rcx
        call read_float                 ; reading matrix
        pop rcx
        pop rcx                         ; loading rcx
        movsd [matrix + r12 * 8], xmm0  ; matrix[i] = input
        inc r12                         ; i++
        loop input
    call rref                           ; calculating row reduced echelon form
    cmp rax, [n]                        ; if (output of rref)rax = 0
    jne answer_found                    ; we have a uniqe answer 
    lea rdi, impossible                 ; else print impossible
    call print_string           
    jmp end                             ; go to end
    answer_found:
    mov rcx, qword[n]                   ; rcx = n
    xor r12, r12                        ; (i)r12 = 0
    print_ans:
        push rcx                        ; saving rcx
        push rcx
        mov rdi, r12                    
        mov rsi, [n]
        call twoDToOneD                 ; twoDToOneD(i, n)
        movsd xmm0, [matrix + rax * 8]
        call print_float                ; printf("%lf ", rax)
        pop rcx
        pop rcx                         ; load rcx
        inc r12                         ; i++
        loop print_ans
    call print_nl

    end:
    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


func:                   ; function template
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8


    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


simd:                   ; function template
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8

    mov rax, [n]
    inc rax
    xor rdx, rdx
    mov rcx, 8
    div rcx
    mov rcx, rax
    cmp rcx, 0
    je simd_end_loop
    xor r9, r9
    mov r10, [n]
    inc r10
    simd_loop:
        vmovupd zmm0, [matrix + 8 * r10]
        vbroadcastsd zmm1, [three]
        vdivpd zmm0, zmm0, zmm1
        vmovupd zmm1, [matrix + 8 * r9]
        vsubpd zmm0, zmm1, zmm0
        vmovupd [matrix + 8 * r9], zmm0

    simd_end_loop:

    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret



print_matrix:           ; for debuging
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8

    mov rax, qword[n]                       ; rax = n                 
    mov r9, rax                             ; (j)r9 = n
    inc rax                                 ; rax++
    mul r9                                  ; rax = n(n+1)
    mov rcx, rax                            ; rcx = rax
    xor r12, r12                            ; (i)r12 = 0
    output:
        movsd xmm0, [matrix + r12 * 8]      ; xmm0 = matrix[i]
        push rcx                            ; save rcx
        push rcx
        call print_float                    
        pop rcx
        pop rcx                             ; load rcx
        mov rax, rcx                        ; rax = rcx
        mov r10, qword[n]                   ; r10 = n
        xor rdx, rdx                        ; rdx = 0
        dec rax                             ; rax--
        inc r10                             ; r10 = n+1
        div r10                             ; rdx = rax % (n+1)
        cmp rdx, 0                          ; if rdx == 0
        jne no_enter                        ; print a new line
        push rcx
        push rcx
        call print_nl
        pop rcx
        pop rcx
        no_enter:
        inc r12                             ; i++
        loop output
    
    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


rref:           ; calculating row reduced echelon form of a matrix
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8

    xor r14, r14                            ; (i)r14 = 0
    rows:                                   ; for(i = 0; i < n; i++)
        mov rdi, r14                        ; rdi = i
        call find_non_zero                  ; find_non_zero(i)
        cmp rax, [n]                        ; if rax == n
        je no_answer                        ; we will have a row of zeros, then there is no answer
        mov rdi, r14
        mov rsi, rax
        mov rax, 1
        cvtsi2sd xmm0, rax
        call add_row                        ; adds the row with a non zero element to the ith row to garentee that matrix[i][i] != 0
        mov rdi, r14
        mov rsi, r14
        call twoDToOneD
        movsd xmm0, qword[matrix + rax * 8]
        mov rdi, r14
        call div_row                        ; divides row i with matrix[i][i]
        mov rdi, r14
        call reduce_cols                    ; reduces the column i with row i
        inc r14                             ; i++
        cmp r14, [n]                        ; if i < n
        jl rows                             ; loop
    mov rax, 0


    no_answer:

    
    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


find_non_zero:              ; finding the first non zero elemnt in column y
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8

    mov rcx, [n]                        ; rcx = n
    mov r12, rdi                        ; (j)r12 = y
    mov r10, rdi                        ; (i)r10 = y
    sub rcx, rdi
    find_first_non_zero:
        mov rdi, r10
        mov rsi, r12
        call twoDToOneD                         ; rax = twoDToOneD(i, y)
        pxor xmm0, xmm0
        comisd xmm0, qword [matrix + rax * 8]  ; if !rdx == 0
        jne end_find_non_zero                   ; we have found the index
        inc r10
        loop find_first_non_zero
    end_find_non_zero:
    mov rax, r10

    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


add_row:                ; adds a multiplician of row b to row a
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8




    movsd [c], xmm0
    mov rcx, [n]                            ; rcx = n
    inc rcx

    mov rax, rdi                            ; rax = i
    mul rcx                                 ; rax = i * (n+1)
    mov rdi, rax

    mov rax, rsi
    mul rcx
    mov rsi, rax

    mov rax, rcx
    mov rcx, 8
    xor rdx, rdx
    div rcx
    mov rcx, rax

    cmp rcx, 0
    je  end_adding_simd
    adding_simd:
        vmovupd zmm0, [matrix + rsi * 8]      ; xmm1 = matrix[i][rax]
        vbroadcastsd zmm1, [c]                ; xmm1 /= xmm0
        vmulpd zmm0, zmm0, zmm1
        vaddpd zmm0, zmm0, [matrix + rdi * 8]
        vmovupd [matrix + rdi * 8], zmm0      ; matrix[i][rax] = xmm1
        add rdi, 8
        add rsi, 8
        loop adding_simd

    end_adding_simd:

    mov rcx, rdx
    cmp rcx, 0
    je  end_adding
    add_row_loop:
        movsd xmm0, [matrix + rsi * 8]  ; xmm0 = matrix[b][i]
        mulsd xmm0, [c]                 ; xmm0 *= xmm1
        addsd xmm0, [matrix + rdi * 8]  ; xmm0 += matrix[a][i]
        movsd [matrix + rdi * 8], xmm0  ; matrix[a][i] = xmm0
        inc rdi                         ; i++
        inc rsi
        loop add_row_loop

    end_adding:

    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


twoDToOneD:             ; calculate the index for [i][j]
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8

    mov rax, rdi            ; rax = i
    mov r9, [n]             ; r9 = n
    inc r9                  ; r9 = n + 1
    mul r9                  ; rax = i * (n+1)
    add rax, rsi            ; rax = i * (n+1) + j

    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


reduce_cols:            ; turns every element in this column to 0 other than row
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8

    mov r13, rdi                        ; r13 = row = col
    inc rdi                             ; row++
    xor r12, r12                         ; (i)r12 = 0
    mov rcx, [n]
    pxor xmm1, xmm1
    reduce_loop:                        ; for i in range(row + 1, n)
        push rcx
        push rcx
        cmp r12, r13
        je no_reducing_needed
        mov rdi, r12
        mov rsi, r13
        call twoDToOneD
        movsd xmm0, [matrix + rax * 8]  ; xmm0 = matrix[i][col] 
        ucomisd xmm0, xmm1              ; if xmm0 != 0
        je no_reducing_needed
        mov rdi, r12
        mov rsi, r13
        movsd xmm2, [neg_zero]
        xorpd xmm0, xmm2
        call add_row                    ; add_row(i, row, xmm0)
        no_reducing_needed:
        inc r12                          ; i++
        pop rcx
        pop rcx
        loop reduce_loop


    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


div_row:                  ; dividing row i by a scalar c
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8

    movsd [c], xmm0
    mov rcx, [n]                            ; rcx = n
    inc rcx

    mov rax, rdi                            ; rax = i
    mul rcx                                 ; rax = i * (n+1)
    mov rdi, rax

    mov rax, rcx
    mov rcx, 8
    xor rdx, rdx
    div rcx
    mov rcx, rax

    mov rax, rdi                            ; rax = i
    cmp rcx, 0
    je  end_dividing_simd
    dividing_loop_simd:
        vmovupd zmm0, [matrix + rax * 8]    ; xmm1 = matrix[i][rax]
        vbroadcastsd zmm1, [c]              ; xmm1 /= xmm0
        vdivpd zmm0, zmm0, zmm1
        vmovupd [matrix + rax * 8], zmm0      ; matrix[i][rax] = xmm1
        add rax, 8
        loop dividing_loop_simd

    end_dividing_simd:
    mov rcx, rdx
    cmp rcx, 0
    jl  end_divide
    dividing_loop:
        movsd xmm1, [matrix + rax * 8]      ; xmm1 = matrix[i][rax]
        divsd xmm1, [c]                     ; xmm1 /= xmm0
        movsd [matrix + rax * 8], xmm1      ; matrix[i][rax] = xmm1
        inc rax
        loop dividing_loop

    end_divide:


    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


read_float:
    sub rsp, 8

    mov rsi, rsp
    mov rdi, read_float_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call scanf
    movsd xmm0, qword [rsp]

    add rsp, 8 ; clearing local variables from stack

    ret

print_float:
    sub rsp, 8

    mov rdi, print_float_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call printf
    
    add rsp, 8 ; clearing local variables from stack

    ret


print_nl:
    sub rsp, 8

    mov rdi, 10
    call putchar
    
    add rsp, 8 ; clearing local variables from stack

    ret


print_string:
    sub rsp, 8

    call puts
    
    add rsp, 8 ; clearing local variables from stack

    ret



read_int:
    sub rsp, 8

    mov rsi, rsp
    mov rdi, read_int_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call scanf

    mov rax, [rsp]

    add rsp, 8 ; clearing local variables from stack

    ret

print_int:
    sub rsp, 8

    mov rsi, rdi

    mov rdi, print_int_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call printf
    
    add rsp, 8 ; clearing local variables from stack

    ret

safe_print_int:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push rbp
    push rsp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    call print_int
    call print_nl
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rsp
    pop rbp
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret