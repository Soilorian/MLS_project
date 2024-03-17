.data
dc:
	operand1: .zero 32
	operand2: .zero 32
	one:	.zero 7
	 .byte 1 
	 .zero 24
	zero:	.zero 32
	ten_operand:	.zero 7
	 .byte 10 
	 .zero 24
	res: .zero 32
	tmp_operand1: .zero 32
	tmp_operand2: .zero 32
	tmp_operand1_div: .zero 32
	tmp_operand2_div: .zero 32
	tmp_operand1_idiv: .zero 32
	tmp_operand2_idiv: .zero 32
	tmp_256: .zero 32
	tmp_257: .zero 32
	tmp_258: .zero 32
	compare_result: .zero 8
	sign1: .zero 8
	sign2: .zero 8
	sign3: .zero 8
	print_arr: .zero 400
 
.text

func:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)




	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14


mod_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)

	stg %r6, 0(%r15)
	stg %r7, 8(%r15)
	stg %r8, 16(%r15)
	brasl %r14, idiv_256

	
	lg %r6, 8(%r15)
	lg %r7, 16(%r15)
	larl %r8, tmp_258
	brasl %r14, mul_256

	lg %r6, 0(%r15)
	larl %r7, tmp_258
	lg %r8, 16(%r15)
	brasl %r14, subtract_256

	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14



div_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)


	lgr %r9, %r7
	larl %r7, tmp_operand1_div
	brasl %r14, copy_256

	lgr %r6, %r9
	larl %r7, tmp_operand2_div
	brasl %r14, copy_256

	larl %r6, one
	larl %r7, tmp_256
	brasl %r14, copy_256

	lgr %r7, %r8
	larl %r6, zero
	brasl %r14, copy_256

	lgr %r9, %r8

	div_loop_b2a:

		larl %r6, tmp_operand1_div
		larl %r7, tmp_operand2_div
		larl %r8, tmp_257
		brasl %r14, subtract_256

		larl %r6, tmp_operand2_div
		larl %r7, tmp_257
		brasl %r14, compare_256

		larl %r1, compare_result
		lg %r0, 0(%r1)
		cghi %r0, 0
		jh next_div_action

		larl %r6, tmp_operand2_div
		brasl %r14, shift_left_256

		larl %r6, tmp_256
		brasl %r14, shift_left_256

		j div_loop_b2a


	next_div_action:
		larl %r6, tmp_operand1_div
		larl %r7, tmp_operand2_div
		brasl %r14, compare_256

		larl %r1, compare_result
		lg %r0, 0(%r1)
		cghi %r0, 0
		jl continue_div


			

		larl %r6, tmp_operand1_div
		larl %r7, tmp_operand2_div
		lgr %r8, %r6
		brasl %r14, subtract_256

		lgr %r6, %r9
		larl %r7, tmp_256
		lgr %r8, %r9
		brasl %r14, add_256

		continue_div:

		larl %r6, tmp_256
		brasl %r14, shift_right_256

		larl %r6, tmp_operand2_div
		brasl %r14, shift_right_256

		larl %r6, tmp_256
		larl %r7, zero
		brasl %r14, compare_256

		larl %r1, compare_result
		lg %r0, 0(%r1)
		cghi %r0, 0
		jne next_div_action

	

	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14



idiv_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)

	lgr %r9, %r6
	lgr %r10, %r7
	lgr %r11, %r8

	lgr %r6, %r9
	larl %r7, tmp_operand1_idiv
	brasl %r14, copy_256

	lgr %r6, %r10
	larl %r7, tmp_operand2_idiv
	brasl %r14, copy_256

	larl %r9, tmp_operand1_idiv
	larl %r10, tmp_operand2_idiv

	larl %r7, sign1
	lghi %r2, 0
	stg %r2, 0(%r7)

	larl %r7, sign2
	lghi %r2, 0
	stg %r2, 0(%r7)

	lgr %r6, %r9
	lg	%r7, 24(%r6)
	cghi %r7, 0
	jhe no_neg_needed_a

	brasl %r14, neg_256
	larl %r7, sign1
	lghi %r2, 1
	stg %r2, 0(%r7)

	no_neg_needed_a:

	lgr %r6, %r10
	lg	%r7, 24(%r6)
	cghi %r7, 0
	jhe no_neg_needed_b

	brasl %r14, neg_256
	larl %r7, sign2
	lghi %r2, 1
	stg %r2, 0(%r7)


	no_neg_needed_b:

	lgr %r6, %r9
	lgr %r7, %r10
	lgr %r8, %r11
	brasl %r14, div_256

	
	larl %r7, sign1
	lg %r2, 0(%r7)
	
	cghi %r2, 0
	je no_action_a

	lgr %r6, %r11
	brasl %r14, neg_256

	no_action_a:

	larl %r7, sign2
	lg %r2, 0(%r7)

	cghi %r2, 0
	je no_action_b

	lgr %r6, %r11
	brasl %r14, neg_256

	no_action_b:


	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14


mul_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)


	lgr %r9, %r7
	larl %r7, tmp_operand1
	brasl %r14, copy_256

	lgr %r6, %r9
	larl %r7, tmp_operand2
	brasl %r14, copy_256

	larl %r6, one
	larl %r7, tmp_256
	brasl %r14, copy_256

	lgr %r7, %r8
	larl %r6, zero
	brasl %r14, copy_256

	lgr %r9, %r8

	mul_loop:

		larl %r6, tmp_256
		larl %r7, tmp_operand2
		larl %r8, tmp_257
		brasl %r14, and_256

		larl %r6, tmp_257
		larl %r7, zero
		brasl %r14, compare_256

		larl %r1, compare_result
		lg %r0, 0(%r1)
		cghi %r0, 0
		je no_action_mul


		larl %r6, tmp_operand1
		lgr  %r7, %r9
		lgr	 %r8, %r9
		brasl %r14, add_256 


		no_action_mul:
		larl %r6, tmp_256
		brasl %r14, shift_left_256

		larl %r6, tmp_operand1
		brasl %r14, shift_left_256

		larl %r6, tmp_256
		larl %r7, zero
		brasl %r14, compare_256


		larl %r1, compare_result
		lg %r0, 0(%r1)
		cghi %r0, 0
		jne mul_loop




	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14


compare_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)


	lg %r5, 24(%r6)
	lg %r2, 24(%r7)
	cgr	%r5, %r2
	jh load_one
	jl	load_neg_one

	lg %r5, 16(%r6)
	lg %r2, 16(%r7)
	clgr	%r5, %r2
	jh load_one
	jl	load_neg_one

	lg %r5, 8(%r6)
	lg %r2, 8(%r7)
	clgr	%r5, %r2
	jh load_one
	jl	load_neg_one

	lg %r5, 0(%r6)
	lg %r2, 0(%r7)
	clgr	%r5, %r2
	jh load_one
	jl	load_neg_one

	lghi %r3, 0
	larl %r2, compare_result
	stg %r3, 0(%r2)
	j end_compare

	load_neg_one:
	lghi %r3, -1
	larl %r2, compare_result
	stg %r3, 0(%r2)
	j end_compare

	load_one:	
	lghi %r3, 1
	larl %r2, compare_result
	stg %r3, 0(%r2)


	end_compare:

	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14


and_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)
	

	lg %r5, 0(%r6)
	lg %r2, 0(%r7)
	ngr	%r5, %r2
	stg %r5, 0(%r8)

	lg %r5, 8(%r6)
	lg %r2, 8(%r7)
	ngr	%r5, %r2
	stg %r5, 8(%r8)

	lg %r5, 16(%r6)
	lg %r2, 16(%r7)
	ngr	%r5, %r2
	stg %r5, 16(%r8)

	lg %r5, 24(%r6)
	lg %r2, 24(%r7)
	ngr	%r5, %r2
	stg %r5, 24(%r8)

	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14


shift_right_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)
	
	lghi	%r2, 1

	lg %r5, 24(%r6)
	ngr %r2, %r5
	srlg %r5, %r5, 1
	stg %r5, 24(%r6)
	sllg %r3, %r2, 63


	lghi	%r2, 1

	lg %r5, 16(%r6)
	ngr %r2, %r5
	srlg %r5, %r5, 1
	agr %r5, %r3
	stg %r5, 16(%r6)
	sllg %r3, %r2, 63

	lghi	%r2, 1

	lg %r5, 8(%r6)
	ngr %r2, %r5
	srlg %r5, %r5, 1
	agr %r5, %r3
	stg %r5, 8(%r6)
	sllg %r3, %r2, 63

	lghi	%r2, 1

	lg %r5, 0(%r6)
	ngr %r2, %r5
	srlg %r5, %r5, 1
	agr %r5, %r3
	stg %r5, 0(%r6)


	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14


shift_left_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)
	
	lgr %r7, %r6
	lgr %r8, %r6
	brasl %r14, add_256

	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14


subtract_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)
	
	lgr %r9, %r6
	lgr %r6, %r7
	larl %r7, tmp_operand2
	brasl %r14, copy_256
	
	larl %r6, tmp_operand2
	brasl %r14, neg_256

	lgr %r6, %r9
	larl %r7, tmp_operand2

	brasl %r14, add_256


	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14



copy_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)

	lg %r9, 0(%r6)
	stg %r9, 0(%r7)

	lg %r9, 8(%r6)
	stg %r9, 8(%r7)
	
	lg %r9, 16(%r6)
	stg %r9, 16(%r7)
	
	lg %r9, 24(%r6)
	stg %r9, 24(%r7)


	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14


neg_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)

	lghi %r2, -1

	lg %r5, 0(%r6)
	xgr	%r5, %r2
	stg %r5, 0(%r6)

	lg %r5, 8(%r6)
	xgr %r5, %r2
	stg %r5, 8(%r6)

	lg %r5, 16(%r6)
	xgr %r5, %r2
	stg %r5, 16(%r6)

	lg %r5, 24(%r6)
	xgr %r5, %r2
	stg %r5, 24(%r6)


	larl %r7, one
	lgr %r8, %r6
	brasl %r14, add_256
	

	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14


print_binary_64:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)

	xgr %r9, %r9
	aghi %r9, 1
	sllg %r9,%r9, 63
print_bin_loop:
	stg %r2, 0(%r15)
	ngr %r2, %r9
	cghi %r2, 0
	je print_zero_bit
	lghi %r2, '1'
	brasl %r14, putchar
	j done_print_bit
print_zero_bit:
	lghi %r2, '0'
	brasl %r14, putchar
done_print_bit:
	lg %r2, 0(%r15)
	srlg %r9, %r9,  1
	cghi %r9, 0
	jne print_bin_loop

	lghi %r2, 10
	brasl %r14, putchar
	

	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14


add_with_carry:
	stmg %r9, %r14, -72(%r15)
	lay %r15, -200(%r15)

	stg %r6, 0(%r15)
	stg %r7, 8(%r15)
	stg %r8, 16(%r15)
	xgr %r8, %r8

	ag %r6, 8(%r15)
	
	clg %r6, 0(%r15)
	jhe skip_add_carry1
	lghi %r8, 1

skip_add_carry1:
	stg %r6, 0(%r15)
	ag %r6, 16(%r15)
	clg %r6, 0(%r15)
	jhe skip_add_carry2
	lghi %r8, 1

skip_add_carry2:
	lay %r15, 200(%r15)
	lmg %r9, %r14, -72(%r15)
	br %r14


add_256:
	stmg     %r11, %r15, -40(%r15)
	lay %r15, -200(%r15)

	stg %r6, 0(%r15)
	stg %r7, 8(%r15)
	stg %r8, 16(%r15)


	lg %r6, 0(%r15)
	lg %r7, 8(%r15)
	lg %r6, 0(%r6)
	lg %r7, 0(%r7)
	xgr	%r8, %r8
	brasl %r14, add_with_carry
	lg %r9, 16(%r15)
	stg %r6, 0(%r9)


	lg %r6, 0(%r15)
	lg %r7, 8(%r15)
	lg %r6, 8(%r6)
	lg %r7, 8(%r7)
	brasl %r14, add_with_carry
	lg %r9, 16(%r15)
	stg %r6, 8(%r9)



	lg %r6, 0(%r15)
	lg %r7, 8(%r15)
	lg %r6, 16(%r6)
	lg %r7, 16(%r7)
	brasl %r14, add_with_carry
	lg %r9, 16(%r15)
	stg %r6, 16(%r9)




	lg %r6, 0(%r15)
	lg %r7, 8(%r15)
	lg %r6, 24(%r6)
	lg %r7, 24(%r7)
	brasl %r14, add_with_carry
	lg %r9, 16(%r15)
	stg %r6, 24(%r9)


done_add:
	lay %r15, 200(%r15)
	lmg     %r11, %r15, -40(%r15)
	br %r14


read_int_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)

	stg %r6, 0(%r15)

    lghi %r9, 1

	stg %r9, 8(%r15)
	loop_until_start:
	    brasl %r14,  getchar

	    cghi %r2, '0'
	    jl not_digit_start
	    cghi %r2, '9'
	    jh not_digit_start
	    j got_first_valid_digit

	not_digit_start:
	    cghi %r2, '-'
	    je got_neg_sign
	    cghi %r2, '+'
	    je got_pos_sign
	    j loop_until_start

	got_neg_sign:
	    lghi %r9, -1
		stg %r9, 8(%r15)
	    j loop_until_start
	got_pos_sign:
	    lghi %r9, 1
		stg %r9, 8(%r15)
	    j loop_until_start
	got_first_valid_digit:

	reading_digit_loop:
	    aghi %r2, -48
	
	    larl  %r6, zero
		larl  %r7, tmp_258
		brasl %r14, copy_256

	    stg   %r2, 0(%r7)


	    larl  %r7, ten_operand
		lg  %r6, 0(%r15)
		lgr %r8, %r6
	    brasl %r14,  mul_256





		lg  %r6, 0(%r15)
	    larl  %r7, tmp_258
	    brasl %r14,  add_256

	    brasl %r14,  getchar
	    cghi %r2, '0'
	    jl done_read_256
	    cghi %r2, '9'
	    jh done_read_256
	    j reading_digit_loop

	done_read_256:
		
		lg %r9, 8(%r15)

	    cghi %r9, -1
	    jne skip_read_res_neg
		lg  %r6, 0(%r15)
	    brasl %r14,  neg_256
	skip_read_res_neg:


	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14


print_int_256:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)


	larl %r1, print_arr
	lghi %r3, 100
	zero_it:
		lghi %r0, 0
		st	%r0, 0(%r1)
		aghi %r1, 4
		aghi %r3, -1
		cghi %r3, 0
		jh zero_it



	lghi %r0, 0
	larl %r3, sign3

	lg %r0, 24(%r6)
	cghi %r0, 0
	jhe already_pos
	lghi %r0, -1
	brasl %r14, neg_256

	already_pos:
	stg %r0, 0(%r3)



	larl %r4, print_arr

	getting_digits:



		larl %r6, res
		stg %r4, 0(%r15)
		larl %r7, ten_operand
		larl %r8, tmp_258
		brasl %r14, mod_256

		
		larl %r8, tmp_258
		xgr %r2, %r2
		lg	%r2, 0(%r8)
		aghi %r2, 48



		lg %r4, 0(%r15)
		st  %r2, 0(%r4)
		aghi %r4, 4
		stg %r4, 0(%r15)
		
		larl %r6, res
		larl %r7, ten_operand
		lgr %r8, %r6
		brasl %r14, div_256

		

		larl %r6, res
		larl %r7, zero
		brasl %r14, compare_256

		larl %r6, compare_result
		lg	%r7, 0(%r6)
		cghi %r7, 0

		lg %r4, 0(%r15)
		jne getting_digits



	
	larl %r1, sign3
	lg	%r0, 0(%r1)
	
	cghi %r0, 0
	je no_sign_needed

	lg %r4, 0(%r15)
	lghi %r2, '-'
	st  %r2, 0(%r4)
	aghi %r4, 4

	no_sign_needed:

	print_loop:
		aghi %r4, -4
		stg %r4, 0(%r15)
		l %r2, 0(%r4)
		sllg %r2, %r2, 56
		srlg %r2, %r2, 56
		brasl %r14, putchar

		larl %r5, print_arr
		lg %r4, 0(%r15)
		cgr %r4, %r5
		jh print_loop

		

	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14





.globl asm_main
	asm_main:
	stmg %r6, %r14, -72(%r15)
	lay %r15, -200(%r15)


	main_next:
	brasl %r14, getchar
    cghi %r2, 'q'
    je done_all
	larl %r3, sign2
    stg %r2, 0(%r3)
	brasl %r14, getchar


	larl %r6, zero
	larl %r7, tmp_256
	brasl %r14, copy_256

	larl %r6, zero
	larl %r7, tmp_257
	brasl %r14, copy_256
	
	larl %r6, zero
	larl %r7, tmp_258
	brasl %r14, copy_256
	
	larl %r6, zero
	larl %r7, tmp_operand1
	brasl %r14, copy_256
	
	larl %r6, zero
	larl %r7, tmp_operand2
	brasl %r14, copy_256
	
	larl %r6, zero
	larl %r7, tmp_operand1_div
	brasl %r14, copy_256
	
	larl %r6, zero
	larl %r7, tmp_operand2_div
	brasl %r14, copy_256
		
	larl %r6, zero
	larl %r7, tmp_operand1_idiv
	brasl %r14, copy_256
	
	larl %r6, zero
	larl %r7, tmp_operand2_idiv
	brasl %r14, copy_256
	
	
	larl %r6, zero
	larl %r7, operand1
	brasl %r14, copy_256


	larl %r6, zero
	larl %r7, operand2
	brasl %r14, copy_256


	larl %r6, zero
	larl %r7, res
	brasl %r14, copy_256
	
	

    larl %r6, operand1
    brasl %r14, read_int_256
    larl %r6, operand2
    brasl %r14, read_int_256


	larl %r3, sign2
	lg %r3, 0(%r3)




    cghi %r3, '+'
    je addition
    cghi %r3, '-'
    je subtraction
    cghi %r3, '*'
    je multiplication
    cghi %r3, '/'
    je division
    cghi %r3, '%'
    je modulo

	addition:
	    larl %r6, operand1
	    larl %r7, operand2
	    larl %r8, res
	    brasl %r14,  add_256
	    larl %r6, res
	    brasl %r14,  print_int_256
	    lghi %r2, 10
	    brasl %r14,  putchar
	    j main_next
	subtraction:
	    larl %r6, operand1
	    larl %r7, operand2
	    larl %r8, res
	    brasl %r14,  subtract_256
	    larl %r6, res
	    brasl %r14,  print_int_256
	    lghi %r2, 10
	    brasl %r14,  putchar
	    j main_next
	multiplication:
	    larl %r6, operand1
	    larl %r7, operand2
	    larl %r8, res
	    brasl %r14,  mul_256
	    larl %r6, res
	    brasl %r14,  print_int_256
	    lghi %r2, 10
	    brasl %r14,  putchar
	    j main_next
	division:
	    larl %r6, operand1
	    larl %r7, operand2
	    larl %r8, res
	    brasl %r14,  idiv_256
	    larl %r6, res
	    brasl %r14,  print_int_256
	    lghi %r2, 10
	    brasl %r14,  putchar
	    j main_next
	modulo:
	    larl %r6, operand1
	    larl %r7, operand2
	    larl %r8, res
	    brasl %r14,  mod_256
	    larl %r6, res
	    brasl %r14,  print_int_256
	    lghi %r2, 10
	    brasl %r14,  putchar
	    j main_next


	done_all:
	lay %r15, 200(%r15)
	lmg %r6, %r14, -72(%r15)
	br %r14
