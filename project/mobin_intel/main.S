.intel_syntax noprefix
.section .bss
    .lcomm my_buffer, 8   # Reserve 8000 bytes of uninitialized memory
.section .datas
operand1:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
operand2:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
div_operand1:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
div_operand2:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
idiv_operand1:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
idiv_operand2:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
div_tmp:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
digit_tmp:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
sub_operand1:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
sub_operand2:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
mul_operand1:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
mul_operand2:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
zero_operand:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
one_operand:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
ten_operand:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
mone_operand:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
mod_tmp:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
res:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
tmp:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
tmp2:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
tmp3:
    .fill 256, 1, 0     # Reserve 1000 bytes initialized to value 0
.section .data
.section .text

.globl add_256
add_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    
    
    xor rbx, rbx
    xor rbp, rbp
add_256_loop:
    clc
    mov r10, 0[r12]
    mov r11, 0[r13]
    cmp rbp, 0
    je no_carry
    xor rbp, rbp
    stc
no_carry:
    adc r10, r11
    jnc continue
    mov rbp, 1
continue:
    mov 0[r14], r10
    add rbx, 1
    add r12, 8
    add r13, 8
    add r14, 8
    cmp rbx, 4
    jl add_256_loop


    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret



.globl neg_256
neg_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    
    mov r13, r12
    xor rbx, rbx
neg_loop:
    mov r10, 0[r12]
    not r10
    mov 0[r12], r10
    add rbx, 1
    add r12, 8
    cmp rbx, 4
    jl neg_loop

    lea r12, tmp
    call zero_256
    mov rbx, 1
    mov tmp, rbx
    mov r14, r13
    call add_256


    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret






.globl zero_256
zero_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    
    mov r13, r12
    xor rbx, rbx
zero_loop:
    mov r10, 0[r12]
    xor r10, r10
    mov 0[r12], r10
    add rbx, 1
    add r12, 8
    cmp rbx, 4
    jl zero_loop

    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret



.globl sub_256
sub_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    push r13
    lea r13, sub_operand1
    call copy_256
    pop r13

    mov r12, r13
    lea r13, sub_operand2
    call copy_256
    lea r12, sub_operand1
    
    call neg_256
    call add_256
    call neg_256
    mov r12, r14
    call neg_256

    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret


.globl mul_256
mul_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 32

    push r13
    lea r13, mul_operand1
    call copy_256
    pop r13

    mov r12, r13
    lea r13, mul_operand2
    call copy_256
    lea r12, mul_operand1
    
    xor rbx, rbx
    push r12
    mov r12, r14
    call zero_256
    pop r12


mul_outer_loop:
    push r13
    mov r13, 0[r13]
    mov rbp, 1


mul_inner_loop:
    mov r10, r13
    and r10, rbp
    push r13
    cmp r10, 0
    je continue_mul
    mov r13, r14
    call add_256
continue_mul:
    mov r13, r12
    push r14
    mov r14, r12
    call add_256
    pop r14
    pop r13
    sal rbp, 1
    cmp rbp, 0
    jne mul_inner_loop


    pop r13
    inc rbx
    add r13, 8
    cmp rbx, 4
    jl mul_outer_loop

    add rsp, 32
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret



.globl cmp_256
cmp_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    
    mov rbx, 24[r12]
    mov rbp, 24[r13]
    cmp rbx, rbp
    jg pos_label
    jl neg_label

    mov rbx, 16[r12]
    mov rbp, 16[r13]
    cmp rbx, rbp
    jne not_equal

    mov rbx, 8[r12]
    mov rbp, 8[r13]
    cmp rbx, rbp
    jne not_equal

    mov rbx, 0[r12]
    mov rbp, 0[r13]
    cmp rbx, rbp
    jne not_equal
    je eq_label

not_equal:
    mov r10, rbx
    mov r11, rbp
    shr r10, 1
    shr r11, 1
    cmp r10, r11
    jg pos_label
    jl neg_label
    shl rbx, 1
    shl rbp, 1
    shr rbx, 1
    shr rbp, 1
    cmp rbx, rbp
    jg pos_label
    jl neg_label

pos_label:
    mov r8, 1
    jmp done_cmp
neg_label:
    mov r8, -1
    jmp done_cmp
eq_label:
    mov r8, 0
    jmp done_cmp
done_cmp:
    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret



.globl shift_right_256
shift_right_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    
    mov rbx, 32
    xor r13, r13
    add r12, 32
shift_right_loop:
    add rbx, -8
    add r12, -8
    mov r10, 0[r12]
    mov r14, r13
    shl r14, 63
    xor r13, r13
    shr r10, 1
    adc r13, 0
    add r10, r14
    mov 0[r12], r10
    cmp rbx, 0
    jg shift_right_loop

    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret



.globl shift_left_256
shift_left_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    
    xor rbx, rbx
    xor r13, r13
shift_left_loop:
    mov r10, 0[r12]
    mov r14, r13
    xor r13, r13
    shl r10, 1
    adc r13, 0
    add r10, r14
    mov 0[r12], r10
    add rbx, 8
    add r12, 8
    cmp rbx, 32
    jl shift_left_loop

    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret




.globl copy_256
copy_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    mov rax, 0[r12]
    mov 0[r13], rax
    mov rax, 8[r12]
    mov 8[r13], rax
    mov rax, 16[r12]
    mov 16[r13], rax
    mov rax, 24[r12]
    mov 24[r13], rax

    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret




.globl div_256
div_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    push r13
    lea r13, div_operand1
    call copy_256
    pop r13

    mov r12, r13
    lea r13, div_operand2
    call copy_256
    lea r12, div_operand1

    push r12
    lea r12, tmp2
    call zero_256
    lea r12, tmp3
    call zero_256
    mov r12, r14
    call zero_256
    pop r12

    call cmp_256
    cmp r8, 0
    jl exit_div

    mov rax, 1
    mov tmp2[0], rax


div_inc_loop:
    call sub_256
    push r12
    mov r12, r14
    call cmp_256
    pop r12 
    cmp r8, 0
    jl div_continue


    push r12
    mov r12, r13
    call shift_left_256             # b *= 2
    lea r12, tmp2
    call shift_left_256             # tmp2 *= 2
    pop r12
    jmp div_inc_loop

div_continue:
    push r12
    mov r12, r14
    call zero_256
    pop r12
div_loop:
    push r12
    push r13
    lea r12, tmp2
    lea r13, tmp3
    call cmp_256
    pop r13
    pop r12
    cmp r8, 0
    je exit_div
    call cmp_256
    cmp r8, 0
    jl divide_b
    push r14
    mov r14, r12
    call sub_256
    pop r14
    push r12
    pop r12
    push r12
    push r13
    mov r12, r14
    lea r13, tmp2
    call add_256
    pop r13
    pop r12
divide_b:
    push r12
    mov r12, r13
    call shift_right_256
    lea r12, tmp2
    call shift_right_256
    pop r12
    jmp div_loop

    

exit_div:
    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret


.globl same_sign
same_sign:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    
    mov rax, 24[r12]
    mov rbx, 24[r13]
    shr rax, 63
    shr rbx, 63
    xor rax, rbx
    mov r8, rax

    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret


.globl mod_256
mod_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    call idiv_256
    push r12
    mov r12, r14
    call mul_256
    pop r12
    push r13
    mov r13, r14
    call sub_256
    pop r13

    push r13
    mov r13, r14
    call same_sign
    pop r13
    cmp r8, 0
    je done_mod

    push r12
    push r14
    mov r12, r14
    call add_256
    pop r14
    pop r12

    push r13
    mov r13, r14
    call same_sign
    pop r13
    cmp r8, 0
    je done_mod

    push r12
    push r14
    mov r12, r14
    call sub_256
    call sub_256
    pop r14
    pop r12
done_mod:
    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret



.globl idiv_256
idiv_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    push r13
    lea r13, idiv_operand1
    call copy_256
    pop r13

    mov r12, r13
    lea r13, idiv_operand2
    call copy_256
    lea r12, idiv_operand1

    mov rax, 1
    push r12
    lea r12, zero_operand
    call cmp_256
    neg r8
    pop r12
    imul rax, r8
    cmp r8, 0
    jge skip_b_neg
    push r12
    mov r12, r13
    call neg_256
    pop r12
skip_b_neg:
    push r13
    lea r13, zero_operand
    call cmp_256
    pop r13
    imul rax, r8
    cmp r8, 0
    jge skip_a_neg
    call neg_256
skip_a_neg:

    mov rbx, rax
    call div_256
    cmp rbx, 0
    jge skip_inc
    push r12
    push r14
    mov r12, r14
    lea r14, div_tmp
    call mul_256
    pop r14
    pop r12
    push r13
    lea r13, div_tmp
    call cmp_256
    pop r13
    cmp r8, 0
    je skip_inc
skip_inc:
    mov r12, r14
    cmp rbx, 0
    jge skip_res_neg
    call neg_256
skip_res_neg:

    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret



.globl read_int_256
read_int_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24
    
    call zero_256
    mov rbp, 1
loop_until_start:
    call getchar
    cmp rax, '0'
    jl not_digit_start
    cmp rax, '9'
    jg not_digit_start
    jmp got_first_valid_digit

not_digit_start:
    cmp rax, '-'
    je got_neg_sign
    cmp rax, '+'
    je got_pos_sign
    jmp loop_until_start

got_neg_sign:
    mov rbp, -1
    jmp loop_until_start
got_pos_sign:
    mov rbp, 1
    jmp loop_until_start
got_first_valid_digit:
reading_digit_loop:
    add rax, -48
    push r12
    lea r12, digit_tmp
    call zero_256
    mov 0[r12], rax
    pop r12
    lea r13, ten_operand
    mov r14, r12
    call mul_256
    lea r13, digit_tmp
    call add_256
    call getchar
    cmp rax, '0'
    jl done_read_256
    cmp rax, '9'
    jg done_read_256
    jmp reading_digit_loop

done_read_256:
    cmp rbp, 0
    jge skip_read_res_neg
    call neg_256
skip_read_res_neg:
    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret



.globl print_int_256
print_int_256:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 1032
    
    xor rbp, rbp
    lea r13, zero_operand
    call cmp_256
    cmp r8, 0
    jl print_neg_int
    jg print_abs_int
    mov rdi, '0'
    call putchar
    jmp done_print747
print_neg_int:
    mov rdi, '-'
    call putchar
    call neg_256
print_abs_int:
    lea r13, ten_operand
    lea r14, digit_tmp
    call mod_256
    mov rbx, digit_tmp[0]
    add rbx, 48
    push rbx
    inc rbp
    mov r14, r12
    call div_256
    lea r13, zero_operand
    call cmp_256
    cmp r8, 0
    jg print_abs_int

print_digits_from_stack:
    pop rbx
    mov rdi, rbx
    call putchar
    dec rbp
    cmp rbp, 0
    jg print_digits_from_stack
done_print747:
    add rsp, 1032
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret



.globl asm_main
asm_main:
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    lea r12, zero_operand
    call zero_256
    lea r12, one_operand
    call zero_256
    lea r12, mone_operand
    call zero_256
    mov r12, 1
    mov one_operand[0], r12
    mov mone_operand[0], r12
    lea r12, mone_operand
    call neg_256
    lea r12, ten_operand
    call zero_256
    mov r12, 10
    mov ten_operand[0], r12

    
main_next:
    call getchar
    cmp rax, 'q'
    je done_all
    mov rbx, rax
    lea r12, operand1
    call read_int_256
    lea r12, operand2
    call read_int_256
    cmp rbx, '+'
    je addition
    cmp rbx, '-'
    je subtraction
    cmp rbx, '*'
    je multiplication
    cmp rbx, '/'
    je division
    cmp rbx, '%'
    je modulo

addition:
    lea r12, operand1
    lea r13, operand2
    lea r14, res
    call add_256
    lea r12, res
    call print_int_256
    mov rdi, 10
    call putchar
    jmp main_next
subtraction:
    lea r12, operand1
    lea r13, operand2
    lea r14, res
    call sub_256
    lea r12, res
    call print_int_256
    mov rdi, 10
    call putchar
    jmp main_next
multiplication:
    lea r12, operand1
    lea r13, operand2
    lea r14, res
    call mul_256
    lea r12, res
    call print_int_256
    mov rdi, 10
    call putchar
    jmp main_next
division:
    lea r12, operand1
    lea r13, operand2
    lea r14, res
    call idiv_256
    lea r12, res
    call print_int_256
    mov rdi, 10
    call putchar
    jmp main_next
modulo:
    lea r12, operand1
    lea r13, operand2
    lea r14, res
    call mod_256
    lea r12, res
    call print_int_256
    mov rdi, 10
    call putchar
    jmp main_next

done_all:
    add rsp, 24
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret
