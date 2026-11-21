<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Kai 8-bit CPU is an 8-bit accumulator CPU. The first 3 bits of each 1-byte instruction is opcode and the last 5 bits specify a memory address (one of 32 8-bit registers). In order from 000 to 111 (in binary), the opcodes are ADD, MULT, NOR, STORE, LOADM, LOADI, JUMP and BEQ. These opcodes are defined as follows:

# ADD (000)
Adds the value in the accumulator to the value at the specified memory address. The result is stored in the accumulator.

# MULT (001)
Multiplies the value in the accumulator and the value at the specified memory address. The result is stored in the accumulator.

# NOR (010)
Performs bitwise NOR logic on the value in the accumulator and the value at the specified memory address. The result is stored in the accumulator.

# STORE (011)
Stores the value in the accumulator at the specified memory address.

# LOADM (100)
Replaces the value in the accumulator with the value at the specified memory address.

# LOADI (101)
Replaces the value in the accumulator with the value of the last 5 bits of the instruction. The first 3 bits of the 8-bit value will always be 000.

# JUMP (110)
Execute instructions starting from the specified memory address.

# BEQ (111)
If the value in the accumulator is 0, execute instructions starting from the specified memory address.

## How to test
Data is loaded into the registers, and the value in the accumulator is output each clock cycle.