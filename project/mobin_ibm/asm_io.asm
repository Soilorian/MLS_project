.data
    print_int_format:  .asciz "%d"
    print_uint_format: .asciz "%u"
    read_int_format:   .asciz "%d"
    read_uint_format:  .asciz "%u"

.text
.globl print_int
.globl print_char
.globl print_nl
.globl print_string
.globl read_int
.globl read_uint
.globl read_char

    print_int:
	stg     %r14, -4(%r15)
        lay     %r15, -8(%r15)
        lr      %r3,  %r2
        larl    %r2,  print_int_format
        brasl   %r14, printf
	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
        br      %r14


    print_uint:
	stg     %r14, -4(%r15)
        lay     %r15, -8(%r15)
        lr      %r3,  %r2
        larl    %r2,  print_uint_format
        brasl   %r14, printf
	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
        br      %r14


     print_char:
	stg     %r14, -4(%r15)
        lay     %r15, -8(%r15)
        brasl   %r14, putchar
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
	stg     %r14, -4(%r15)
        lay     %r15, -8(%r15)
        lay     %r3,  0(%r15)
        larl    %r2,  read_int_format
        brasl   %r14, scanf
	l       %r2,  0(%r15)
	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
        br      %r14


     read_uint:
	stg     %r14, -4(%r15)
        lay     %r15, -8(%r15)
        lay     %r3,  0(%r15)
        larl    %r2,  read_uint_format
        brasl   %r14, scanf
	l       %r2,  0(%r15)
	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)


     read_char:
	stg     %r14, -4(%r15)
        lay     %r15, -8(%r15)
        brasl   %r14, getchar
	lay     %r15, 8(%r15)
	lg      %r14, -4(%r15)
        br      %r14
 

