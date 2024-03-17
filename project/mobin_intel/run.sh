#!/bin/bash
x86_64-linux-gnu-gcc -static -fno-pie -no-pie driver.c main.S asm_io.S