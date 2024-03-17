.data
dc:
    n: .zero 8
    matrix: .zero 8
    .align 2
    print_float_format: .string "%lf "
    .align 2
    read_float_format: .string "%lf"
    .align 2
    print_int_format: .string  "%d\n"
    .align 2
    read_int_format:   .string "%d"
    .align 2
    impossible: .string "Impossible"
    n_times_npo: .zero 8
    save_two: .zero 8
    counter: .zero 8
    i: .zero 8
    j: .zero 8
    temp: .zero 8
    c:  .zero 8
    fzero: .zero 8
    master_i: .zero 8
    reduce_i: .zero 8
    reduce_counter: .zero 8
    saved_area: .zero 800

.text
.globl asm_main

    
    asm_main:
    larl %r10, dc               # sets r10 as base register
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
	

	brasl %r14, read_int
    stg %r2, n - dc(%r10)              

    lgr %r5, %r2                        # calculating n(n+1)
    aghi %r5, 1
    lghi %r4, 0                 
    mr %r4, %r2
    stg %r5, n_times_npo - dc(%r10)

    lghi %r7, 8
    mr %r4, %r7                         # r5 = n(n+1) * 8

    lgr %r2, %r5                        # result in r2
    brasl   %r14, malloc@PLT            # calls malloc(n(n+1) * 8)
    stg %r2, matrix - dc(%r10)          # saves the result in matrix


    lg %r3, n_times_npo - dc(%r10)
    xgr %r5, %r5                        # r3: counter, r5: i
    input:                              # for i in range(n(n+1))
        stg %r3, counter - dc(%r10)     # saves counter and i
        stg %r5, i - dc(%r10)

        brasl %r14, read_float
        
        lg %r2, i - dc(%r10)
        brasl %r14, set_at_index       # set_at_index(i)

        lg %r5, i - dc(%r10)            # i++
        aghi %r5, 1

        lg %r3, counter - dc(%r10)      # counter--
        aghi %r3, -1

        chi %r3, 0
        jh input  



    brasl %r14, rref
    


    lg %r0, n - dc(%r10)
    cr %r2, %r0
    jne answer_found

    larl %r2, impossible
    brasl %r14, print_string
    j end

    answer_found:
    xr %r5, %r5
    print_ans:
        stg %r0, counter - dc(%r10)     # saves counter and i
        stg %r5, i - dc(    %r10)

        lgr %r2, %r5
        lg %r3, n - dc(%r10)
        brasl %r14, twoDToOneD
        brasl %r14, get_at_index
        brasl %r14, print_float

        lg %r5, i - dc(%r10)            # i++
        aghi %r5, 1

        lg %r0, counter - dc(%r10)      # counter--
        aghi %r0, -1

        chi %r0, 0
        jh print_ans         
    
    brasl %r14, print_nl

    end:

    l %r2, matrix - dc(%r10)
    brasl %r14, free@PLT        # free(matrix)

    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14



              











func:               # func(): tmplate
    larl %r10, dc
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
	


    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14


rref:               # rref(): preforms row reduce echelen form on matrix
    larl %r10, dc
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
	

    xr      %r5, %r5
    rows:
        stg     %r5, master_i - dc(%r10)

        lgr     %r2, %r5
        brasl   %r14, find_non_zero

        lg      %r7, n - dc(%r10)
        cr      %r2, %r7
        je no_answer


        lg      %r5, master_i - dc(%r10)
        lgr     %r3, %r2
        lgr     %r2, %r5
        lghi    %r4, 1
        cdfbr   %f0, %r4
        brasl   %r14, add_row

        lg      %r5, master_i - dc(%r10)
        lgr     %r2, %r5
        lgr     %r3, %r5
        brasl   %r14, twoDToOneD
        brasl   %r14, get_at_index

        lg      %r5, master_i - dc(%r10)
        lgr     %r2, %r5
        brasl   %r14, div_row

        lg      %r5, master_i - dc(%r10)
        lgr     %r2, %r5
        brasl   %r14, reduce_cols


        lg      %r5, master_i - dc(%r10)
        aghi    %r5, 1

        lg      %r7, n - dc(%r10)
        cr      %r5, %r7
        jl      rows


    no_answer:


    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14


reduce_cols:               # reduce_cols(int i): makes all elements in col i, zero, using row operations
    larl %r10, dc
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)

    lg      %r0, n - dc(%r10)
    xgr     %r5, %r5
    lgr     %r8, %r2
    reduce_loop:
        stg %r0, reduce_counter - dc(%r10)     # saves counter and i
        stg %r5, reduce_i - dc(%r10)

        cr %r8, %r5
        je no_reducing_needed

        lgr     %r2, %r5
        lgr     %r3, %r8
        brasl   %r14, twoDToOneD
        brasl   %r14, get_at_index

        cdb     %f0, fzero - dc(%r10)
        je      no_reducing_needed

        lg %r5, reduce_i - dc(%r10)        
        lgr     %r2, %r5
        lgr     %r3, %r8
        lcdbr   %f0, %f0
        brasl   %r14, add_row


        no_reducing_needed:
        lg %r5, reduce_i - dc(%r10)            # i++
        aghi %r5, 1

        lg %r0, reduce_counter - dc(%r10)      # counter--
        aghi %r0, -1

        chi %r0, 0
        jh reduce_loop 
	


    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14




div_row:               # div_row(int i, double c): matrix[i] /= c
    larl    %r10, dc
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
	
    
    std     %f0, c - dc(%r10)
    lg      %r0, n - dc(%r10)
    aghi    %r0, 1
    xr      %r5, %r5
    lgr     %r6, %r2
    dividing_loop:
        stg %r0, counter - dc(%r10)     # saves counter and i
        stg %r5, i - dc(%r10)

        lgr %r2, %r6
        lgr %r3, %r5
        brasl %r14, twoDToOneD
        stg   %r2, saved_area - dc(%r10)

        brasl %r14, get_at_index
        ddb %f0, c - dc(%r10)

        lg      %r2, saved_area - dc(%r10)
        brasl   %r14, set_at_index

        lg %r5, i - dc(%r10)            # i++
        aghi %r5, 1

        lg %r0, counter - dc(%r10)      # counter--
        aghi %r0, -1

        chi %r0, 0
        jh dividing_loop

    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14




add_row:               # add_row(int i, int j, double c): matrix[i] = matrix[i] + c * matrix[j]
    larl %r10, dc
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
	
    std     %f0, c - dc(%r10)
    lg      %r0, n - dc(%r10)
    aghi    %r0, 1
    xr      %r5, %r5
    lgr     %r6, %r2
    lgr     %r7, %r3
    add_row_loop:
        stg %r0, counter - dc(%r10)     # saves counter and i
        stg %r5, i - dc(%r10)


        lgr     %r2, %r7
        lgr     %r3, %r5
        brasl   %r14, twoDToOneD
        brasl   %r14, get_at_index

        mdb     %f0, c - dc(%r10)
        std     %f0, temp - dc(%r10)

        lg      %r5, i - dc(%r10)
        lgr     %r2, %r6
        lgr     %r3, %r5
        brasl   %r14, twoDToOneD
        stg     %r2, saved_area - dc(%r10)
        brasl   %r14, get_at_index

        adb     %f0, temp - dc(%r10)

        lg      %r2, saved_area - dc(%r10)
        brasl   %r14, set_at_index

        lg %r5, i - dc(%r10)            # i++
        aghi %r5, 1

        lg %r0, counter - dc(%r10)      # counter--
        aghi %r0, -1


        chi %r0, 0
        jh add_row_loop 



    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14


find_non_zero:               # find_non_zero(int i): looks for the first non zero element from matrix[i][i] downward
    larl %r10, dc
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
	
    lg      %r0, n - dc(%r10)
    sgr     %r0, %r2
    lgr     %r5, %r2
    lgr     %r6, %r2
    stg     %r6, j - dc(%r10)

    
    find_first_non_zero:
        stg     %r0, counter - dc(%r10)
        stg     %r5, i - dc(%r10)



        lgr     %r3, %r6

        stg     %r2, saved_area - dc(%r10)
        brasl   %r14, twoDToOneD
        brasl   %r14, get_at_index
        lg      %r2, saved_area - dc(%r10)
        
        cdb     %f0, fzero - dc(%r10)
        jne     end_find_non_zero

        lg      %r0, counter - dc(%r10)
        lg      %r5, i - dc(%r10)
        aghi    %r0, -1
        aghi    %r5, 1


        lgr     %r2, %r5

        chi     %r0, 0
        jh      find_first_non_zero




    end_find_non_zero:

    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14


twoDToOneD:               # twoDToOneD(int i, int j): converts a 2d index to 1d
    larl %r10, dc
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
    
    lgr     %r5, %r3
    lgr     %r3, %r2
    lg      %r4, n - dc(%r10)
    aghi    %r4, 1
    mr      %r2, %r4
    agr     %r3, %r5
    lgr     %r2, %r3


    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14



print_matrix:               # print_matrix(): prints the matrix
    larl %r10, dc
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
	
    lg %r3, n_times_npo - dc(%r10)
    stg %r3, counter - dc(%r10)
    xgr %r5, %r5
    output:
        stg %r3, counter - dc(%r10)

        stg %r5, i - dc(%r10)
        
        lg %r2, i - dc(%r10)
        brasl %r14, get_at_index
        brasl %r14, print_float

        lg %r5, i - dc(%r10)
        aghi %r5, 1

        lg %r3, counter - dc(%r10)
        lgr %r1, %r3
        aghi %r1, -1
        xgr %r0, %r0
        lg %r6, n - dc(%r10)
        aghi %r6, 1
        dsgr %r0, %r6
        chi %r0, 0
        jne no_enter
        brasl %r14, print_nl
        no_enter:

        lg %r5, i - dc(%r10)
        aghi %r5, 1
        lg %r3, counter - dc(%r10)
        aghi %r3, -1

        chi %r3, 0
        jh output  

    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14



set_at_index:               # set_at_index(double f, int i): matrix[i/(n+1)][i%(n+1)] = f
    larl %r10, dc
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
	
    lg %r1, matrix - dc(%r10)
    lgr %r3, %r2
    lhi %r4, 8
    mr %r2, %r4
    agr %r1, %r3
    std %f0, 0(%r1)

    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14


get_at_index:               # func(): tmplate
    larl %r10, dc
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
	
    lg %r1, matrix - dc(%r10)
    lgr %r3, %r2
    lhi %r4, 8
    mr %r2, %r4
    agr %r1, %r3
    ld %f0, 0(%r1)

    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14



print_nl:
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
	la      %r2,  10
    brasl   %r14, putchar
	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14

	
print_string:
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
    brasl   %r14, puts
	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14


read_int:
	stg     %r14, -8(%r15)
    lay     %r15, -168(%r15)
    lay     %r3,  0(%r15)
    larl    %r2,  read_int_format
    brasl   %r14, scanf
	l       %r2,  0(%r15)
	lay     %r15, 168(%r15)
	lg      %r14, -8(%r15)
    br      %r14


print_int:
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
    lr      %r3,  %r2
    larl    %r2,  print_int_format
    brasl   %r14, printf
	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14

read_float:     # moves double to f0
    stg      %r14, -8(%r15)
    lay      %r15, -168(%r15)
    lay      %r3,  0(%r15)

    larl     %r2,  read_float_format
    brasl    %r14, scanf

    ld       %f0,  0(%r15)

    lay      %r15, 168(%r15)
    lg       %r14, -8(%r15)
    br       %r14


print_float:   # print double in f0
        stg     %r14, -8(%r15)
        lay     %r15, -168(%r15)
        larl    %r2,  print_float_format
        brasl   %r14, printf
        lay     %r15, 168(%r15)
        lg      %r14, -8(%r15)
        br      %r14



safe_print_int:
	stg     %r14, -4(%r15)
    lay     %r15, -8(%r15)
    stmg    %r0, %r15, saved_area - dc(%r10)

    lr      %r3,  %r2
    larl    %r2,  print_int_format
    brasl   %r14, printf

    lmg     %r0, %r15, saved_area - dc(%r10)
    lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
    br      %r14
