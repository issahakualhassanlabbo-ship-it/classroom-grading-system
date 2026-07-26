; grading_system.asm
; 64-bit NASM Assembly for Linux - V2

section .data
    menu_msg db 10, "--- Classroom Grading System ---", 10
             db "1. Add Student Record", 10
             db "2. Search Student & Display Result", 10
             db "3. Exit", 10
             db "Enter choice: ", 0
    menu_len equ $ - menu_msg

    prompt_id db "Enter Student ID (exactly 8 digits): ", 0
    prompt_id_len equ $ - prompt_id

    prompt_search db "Enter Student ID to search: ", 0
    prompt_search_len equ $ - prompt_search

    msg_err_id db "Error: ID must be exactly 8 digits and numeric.", 10, 0
    msg_err_id_len equ $ - msg_err_id

    msg_err_dup db "Error: Student ID already exists.", 10, 0
    msg_err_dup_len equ $ - msg_err_dup

    msg_not_found db "Student not found.", 10, 0
    msg_not_found_len equ $ - msg_not_found

    msg_success db 10, "Student added successfully. Results:", 10, 0
    msg_success_len equ $ - msg_success

    msg_res_id db "Student ID: ", 0
    msg_res_id_len equ $ - msg_res_id

    msg_res_cwa db "CWA: ", 0
    msg_res_cwa_len equ $ - msg_res_cwa

    msg_res_grade db "Overall Grade: ", 0
    msg_res_grade_len equ $ - msg_res_grade

    grade_A db "A (Excellent)", 10, 0
    grade_A_len equ $ - grade_A
    grade_B db "B (Very Good)", 10, 0
    grade_B_len equ $ - grade_B
    grade_C db "C (Good)", 10, 0
    grade_C_len equ $ - grade_C
    grade_D db "D (Pass)", 10, 0
    grade_D_len equ $ - grade_D
    grade_F db "F (Fail)", 10, 0
    grade_F_len equ $ - grade_F

    newline db 10

    ; Course Prompts
    prompt_csm252 db "Enter Mark for CSM 252 (0-100): ", 0
    prompt_csm252_len equ $ - prompt_csm252
    prompt_csm254 db "Enter Mark for CSM 254 (0-100): ", 0
    prompt_csm254_len equ $ - prompt_csm254
    prompt_csm258 db "Enter Mark for CSM 258 (0-100): ", 0
    prompt_csm258_len equ $ - prompt_csm258
    prompt_csm260 db "Enter Mark for CSM 260 (0-100): ", 0
    prompt_csm260_len equ $ - prompt_csm260
    prompt_csm264 db "Enter Mark for CSM 264 (0-100): ", 0
    prompt_csm264_len equ $ - prompt_csm264
    prompt_csm266 db "Enter Mark for CSM 266 (0-100): ", 0
    prompt_csm266_len equ $ - prompt_csm266
    prompt_csm292 db "Enter Mark for CSM 292 (0-100): ", 0
    prompt_csm292_len equ $ - prompt_csm292
    prompt_engl264 db "Enter Mark for ENGL 264 (0-100): ", 0
    prompt_engl264_len equ $ - prompt_engl264

    prompts dq prompt_csm252, prompt_csm254, prompt_csm258, prompt_csm260, prompt_csm264, prompt_csm266, prompt_csm292, prompt_engl264
    prompt_lens dq prompt_csm252_len, prompt_csm254_len, prompt_csm258_len, prompt_csm260_len, prompt_csm264_len, prompt_csm266_len, prompt_csm292_len, prompt_engl264_len

    ; Course Names for Results
    name_csm252 db "CSM 252 Grade: ", 0
    name_csm252_len equ $ - name_csm252
    name_csm254 db "CSM 254 Grade: ", 0
    name_csm254_len equ $ - name_csm254
    name_csm258 db "CSM 258 Grade: ", 0
    name_csm258_len equ $ - name_csm258
    name_csm260 db "CSM 260 Grade: ", 0
    name_csm260_len equ $ - name_csm260
    name_csm264 db "CSM 264 Grade: ", 0
    name_csm264_len equ $ - name_csm264
    name_csm266 db "CSM 266 Grade: ", 0
    name_csm266_len equ $ - name_csm266
    name_csm292 db "CSM 292 Grade: ", 0
    name_csm292_len equ $ - name_csm292
    name_engl264 db "ENGL 264 Grade: ", 0
    name_engl264_len equ $ - name_engl264

    course_names dq name_csm252, name_csm254, name_csm258, name_csm260, name_csm264, name_csm266, name_csm292, name_engl264
    name_lens dq name_csm252_len, name_csm254_len, name_csm258_len, name_csm260_len, name_csm264_len, name_csm266_len, name_csm292_len, name_engl264_len

    ; Fixed Credit Hours Array
    course_credits dq 2, 3, 3, 2, 3, 3, 2, 1

section .bss
    ; Memory layout for a student (96 bytes total):
    ; Offset 0-15:  Student ID (string, null-terminated)
    ; Offset 16-79: Marks for 8 courses (8 bytes each, 64 bytes total)
    ; Offset 80-87: Calculated CWA (8 bytes)
    ; Offset 88-95: Padding
    MAX_STUDENTS equ 100
    STUDENT_SIZE equ 96

    students resb MAX_STUDENTS * STUDENT_SIZE
    num_students resq 1
    input_buf resb 64

section .text
    global _start

_start:
    mov qword [num_students], 0

menu_loop:
    ; Print menu
    mov rax, 1
    mov rdi, 1
    mov rsi, menu_msg
    mov rdx, menu_len
    syscall

    ; Read choice
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 64
    syscall

    cmp byte [input_buf], '1'
    je add_student
    cmp byte [input_buf], '2'
    je search_student
    cmp byte [input_buf], '3'
    je exit_program

    jmp menu_loop

add_student:
    mov rax, [num_students]
    cmp rax, MAX_STUDENTS
    jge menu_loop

    ; Prompt for ID
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_id
    mov rdx, prompt_id_len
    syscall

    ; Read ID
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 64
    syscall

    ; Validate exactly 8 digits + newline
    cmp rax, 9
    jne .invalid_id
    cmp byte [input_buf + 8], 10
    jne .invalid_id

    mov byte [input_buf + 8], 0 ; Null terminate the 8-digit ID

    ; Validate all characters are numeric digits
    mov rcx, 0
.check_digits:
    mov al, [input_buf + rcx]
    cmp al, '0'
    jl .invalid_id
    cmp al, '9'
    jg .invalid_id
    inc rcx
    cmp rcx, 8
    jl .check_digits

    ; Check for duplicates
    mov r12, [num_students]
    test r12, r12
    jz .valid_id_no_dups
    
    lea r13, [students]
.check_dup_loop:
    mov rsi, input_buf
    mov rdi, r13
    call strcmp
    test rax, rax
    jz .duplicate_found

    add r13, STUDENT_SIZE
    dec r12
    jnz .check_dup_loop

.valid_id_no_dups:
    ; ID is valid and unique. Calculate memory offset for new student
    mov rax, [num_students]
    mov rbx, STUDENT_SIZE
    mul rbx
    lea r12, [students + rax]

    ; Store ID
    mov rsi, input_buf
    mov rdi, r12
    call strcpy

    ; Prompt and Read 8 Marks
    mov rcx, 0
.read_marks_loop:
    push rcx
    mov rsi, [prompts + rcx*8]
    mov rdx, [prompt_lens + rcx*8]
    mov rax, 1
    mov rdi, 1
    syscall

    call read_int
    pop rcx
    mov [r12 + 16 + rcx*8], rax
    
    inc rcx
    cmp rcx, 8
    jl .read_marks_loop

    ; Immediately Calculate CWA
    xor r14, r14 ; sum of weighted marks
    xor rcx, rcx
.calc_cwa_loop:
    mov rax, [r12 + 16 + rcx*8]
    mov rbx, [course_credits + rcx*8]
    mul rbx
    add r14, rax
    inc rcx
    cmp rcx, 8
    jl .calc_cwa_loop

    ; Divide by 19 (total fixed credits)
    mov rax, r14
    xor rdx, rdx
    mov rbx, 19
    div rbx
    mov [r12 + 80], rax ; Store CWA

    ; Increment global student count
    inc qword [num_students]

    ; Print success
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_success
    mov rdx, msg_success_len
    syscall

    ; Display Results right away
    mov r13, r12
    call print_student_details
    jmp menu_loop


.invalid_id:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_err_id
    mov rdx, msg_err_id_len
    syscall
    jmp menu_loop

.duplicate_found:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_err_dup
    mov rdx, msg_err_dup_len
    syscall
    jmp menu_loop

search_student:
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_search
    mov rdx, prompt_search_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 64
    syscall

    mov rcx, rax
    test rcx, rcx
    jz .do_search
    dec rcx
    cmp byte [input_buf + rcx], 10
    jne .do_search
    mov byte [input_buf + rcx], 0

.do_search:
    mov r12, [num_students]
    test r12, r12
    jz .not_found

    lea r13, [students]
.search_loop:
    mov rsi, input_buf
    mov rdi, r13
    call strcmp
    test rax, rax
    jz .found

    add r13, STUDENT_SIZE
    dec r12
    jnz .search_loop

.not_found:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_not_found
    mov rdx, msg_not_found_len
    syscall
    jmp menu_loop

.found:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    call print_student_details
    jmp menu_loop

exit_program:
    mov rax, 60
    xor rdi, rdi
    syscall


; =========================================================
; SUBROUTINES
; =========================================================

; print_student_details: Prints ID, individual course grades, CWA and overall grade
; Expects r13 to point to student struct
print_student_details:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    ; Print Student ID Label
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_res_id
    mov rdx, msg_res_id_len
    syscall

    ; Print Actual ID
    mov rsi, r13
    call strlen
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Loop to print 8 course grades
    xor rcx, rcx
.print_courses_loop:
    push rcx
    
    ; Course name
    mov rsi, [course_names + rcx*8]
    mov rdx, [name_lens + rcx*8]
    mov rax, 1
    mov rdi, 1
    syscall
    
    pop rcx
    push rcx

    ; Letter Grade for course
    mov rax, [r13 + 16 + rcx*8]
    call get_grade_string
    mov rax, 1
    mov rdi, 1
    syscall

    pop rcx
    inc rcx
    cmp rcx, 8
    jl .print_courses_loop

    ; Print CWA Label
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_res_cwa
    mov rdx, msg_res_cwa_len
    syscall

    ; Print Calculated CWA
    mov rax, [r13 + 80]
    call print_int

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Print Overall Grade Label
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_res_grade
    mov rdx, msg_res_grade_len
    syscall

    ; Overall Letter Grade
    mov rax, [r13 + 80]
    call get_grade_string
    mov rax, 1
    mov rdi, 1
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; get_grade_string: Evaluates mark in RAX, returns RSI (string ptr) and RDX (len)
get_grade_string:
    cmp rax, 70
    jge .grade_A
    cmp rax, 60
    jge .grade_B
    cmp rax, 50
    jge .grade_C
    cmp rax, 40
    jge .grade_D
    jmp .grade_F

.grade_A:
    mov rsi, grade_A
    mov rdx, grade_A_len
    ret
.grade_B:
    mov rsi, grade_B
    mov rdx, grade_B_len
    ret
.grade_C:
    mov rsi, grade_C
    mov rdx, grade_C_len
    ret
.grade_D:
    mov rsi, grade_D
    mov rdx, grade_D_len
    ret
.grade_F:
    mov rsi, grade_F
    mov rdx, grade_F_len
    ret

; strcpy: Copies null-terminated string from RSI to RDI
strcpy:
    push rax
    push rcx
    xor rcx, rcx
.loop:
    mov al, [rsi + rcx]
    mov [rdi + rcx], al
    cmp al, 0
    je .done
    inc rcx
    jmp .loop
.done:
    pop rcx
    pop rax
    ret

; read_int: Reads input from stdin and returns integer in RAX
read_int:
    push rbx
    push rcx
    push rdx
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 64
    syscall
    mov rsi, input_buf
    call atoi
    pop rdx
    pop rcx
    pop rbx
    ret

; atoi: Converts string pointer in RSI to integer in RAX
atoi:
    xor rax, rax
    xor rcx, rcx
.loop:
    mov cl, [rsi]
    cmp cl, 10
    je .done
    cmp cl, 0
    je .done
    cmp cl, '0'
    jl .done
    cmp cl, '9'
    jg .done
    sub cl, '0'
    push rdx
    mov rbx, 10
    mul rbx
    pop rdx
    add rax, rcx
    inc rsi
    jmp .loop
.done:
    ret

; print_int: Prints integer in RAX to stdout
print_int:
    push rax
    push rbx
    push rcx
    push rdx
    push r8

    test rax, rax
    jnz .start
    mov byte [input_buf], '0'
    mov rax, 1
    mov rdi, 1
    mov rsi, input_buf
    mov rdx, 1
    syscall
    jmp .done

.start:
    lea r8, [input_buf + 63]
    mov byte [r8], 0
    mov rbx, 10
.loop:
    test rax, rax
    jz .print
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec r8
    mov [r8], dl
    jmp .loop

.print:
    mov rsi, r8
    call strlen
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall

.done:
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; strlen: Returns string length of RSI in RAX
strlen:
    push rcx
    xor rax, rax
.loop:
    cmp byte [rsi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    pop rcx
    ret

; strcmp: Compares RSI and RDI, RAX=0 if equal
strcmp:
    push rdx
    push rbx
    push rcx
    xor rax, rax
    xor rcx, rcx
.loop:
    mov al, [rsi + rcx]
    mov bl, [rdi + rcx]
    cmp al, bl
    jne .diff
    cmp al, 0
    je .equal
    inc rcx
    jmp .loop
.diff:
    mov rax, 1
    pop rcx
    pop rbx
    pop rdx
    ret
.equal:
    xor rax, rax
    pop rcx
    pop rbx
    pop rdx
    ret
