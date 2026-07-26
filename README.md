# Classroom Grading System

A fast, complete, in-memory Classroom Grading System written in 64-bit NASM Assembly for Linux. This project is designed to run entirely using native Linux system calls without relying on the standard C library (no `printf`, `scanf`, etc.). 

## Features
- **In-Memory Storage**: Handles up to 100 students natively using `.bss` memory allocation.
- **Strict Validation**: Validates 8-digit Student IDs and ensures uniqueness (prevents duplicates).
- **Fixed Course Grading**: Pre-configured with 8 specific courses and their respective credit hours:
  - CSM 252 - Analogue and Digital Electronics (2 Credits)
  - CSM 254 - Programming with Assembly Language (3 Credits)
  - CSM 258 - Numerical Methods and Computation (3 Credits)
  - CSM 260 - Database Concepts and Technologies II (2 Credits)
  - CSM 264 - Programming with Visual Basic (3 Credits)
  - CSM 266 - Mobile Applications (3 Credits)
  - CSM 292 - Systems Analysis and Design II (2 Credits)
  - ENGL 264 - Literature in English II (1 Credit)
- **Instant CWA Calculation**: Dynamically computes the Cumulative Weighted Average (CWA) and determines corresponding letter grades instantaneously after entering marks.

## System Requirements
- Linux Environment (or WSL on Windows)
- NASM (Netwide Assembler)
- GNU Linker (`ld`)

## Build Instructions
Use the following commands to assemble and link the source code:

```bash
# Assemble the source file into an object file
nasm -f elf64 grading_system.asm -o grading_system.o

# Link the object file to create the executable
ld grading_system.o -o grading_system
```

## Running the Program
```bash
./grading_system
```

## Usage
Upon running the executable, you will be presented with a main menu. You can add student records (entering marks between 0-100), automatically calculate their CWA, or search for existing students using their 8-digit IDs to view their full grades breakdown.
