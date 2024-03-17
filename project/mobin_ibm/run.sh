#!/bin/bash
s390x-linux-gnu-gcc -m64 -no-pie -std=c17 -c driver.c
s390x-linux-gnu-as -o $1.o $1.asm &&
s390x-linux-gnu-gcc -static -m64 -no-pie -std=c17 -o $1 driver.c $1.o asm_io.o &&
qemu-s390x ./$1

