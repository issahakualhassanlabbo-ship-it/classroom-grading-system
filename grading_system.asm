; grading_system.asm
; 64-bit NASM Assembly for Linux - V3 (Role-Based Access Control)

section .data
    login_menu_msg db 10, "--- Login Menu ---", 10      ; db (Define Byte): Stores ASCII chars in memory. 10 is ASCII for newline
                   db "1. Login as Admin", 10           ; and 0 is the null terminator marking the end of the string.
                   db "2. Continue as Guest", 10        ; The subsequent admin and guest menu blocks do the exact same thing
                   db "3. Exit", 10                     ; for the other application states.
                   db "Enter choice: ", 0
    login_menu_len equ $ - login_menu_msg               ; Calculates the length of the string dynamically.

    admin_menu_msg db 10, "--- Admin Menu ---", 10
                   db "1. Add Student Record", 10
                   db "2. Update Student Record", 10
                   db "3. Search Student & Display Result", 10
                   db "4. Logout", 10
                   db "Enter choice: ", 0
    admin_menu_len equ $ - admin_menu_msg

    guest_menu_msg db 10, "--- Guest Menu ---", 10
                   db "1. Search Student & Display Result", 10
                   db "2. Logout", 10
                   db "Enter choice: ", 0
    guest_menu_len equ $ - guest_menu_msg

    admin_pass db "assembly254", 0                      ; Stores the hardcoded administrator password. Because it ends with a 0,
    prompt_pass db "Enter Admin Password: ", 0          ; the custom strcmp function later can loop through it character by 
    prompt_pass_len equ $ - prompt_pass                 ; character until it hits the 0 to know it has reached the end.
    msg_wrong_pass db "Error: Incorrect Password.", 10, 0
    msg_wrong_pass_len equ $ - msg_wrong_pass

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
    msg_update_success db 10, "Student updated successfully. Results:", 10, 0
    msg_update_success_len equ $ - msg_update_success

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

    ; Update Mod Prompts
    pmod_csm252 db "Modify CSM 252? (Y/N): ", 0
    pmod_csm252_len equ $ - pmod_csm252
    pmod_csm254 db "Modify CSM 254? (Y/N): ", 0
    pmod_csm254_len equ $ - pmod_csm254
    pmod_csm258 db "Modify CSM 258? (Y/N): ", 0
    pmod_csm258_len equ $ - pmod_csm258
    pmod_csm260 db "Modify CSM 260? (Y/N): ", 0
    pmod_csm260_len equ $ - pmod_csm260
    pmod_csm264 db "Modify CSM 264? (Y/N): ", 0
    pmod_csm264_len equ $ - pmod_csm264
    pmod_csm266 db "Modify CSM 266? (Y/N): ", 0
    pmod_csm266_len equ $ - pmod_csm266
    pmod_csm292 db "Modify CSM 292? (Y/N): ", 0
    pmod_csm292_len equ $ - pmod_csm292
    pmod_engl264 db "Modify ENGL 264? (Y/N): ", 0
    pmod_engl264_len equ $ - pmod_engl264

    mod_prompts dq pmod_csm252, pmod_csm254, pmod_csm258, pmod_csm260, pmod_csm264, pmod_csm266, pmod_csm292, pmod_engl264
    mod_lens dq pmod_csm252_len, pmod_csm254_len, pmod_csm258_len, pmod_csm260_len, pmod_csm264_len, pmod_csm266_len, pmod_csm292_len, pmod_engl264_len

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
    course_credits dq 2, 3, 3, 2, 3, 3, 2, 1            ; dq (Define Quadword): Stores 8-byte integers for our fixed credits

section .bss
    MAX_STUDENTS equ 100                                ; equ (Equals): Defines a constant. Acts like #define in C++.
    STUDENT_SIZE equ 96                                 ; Tells the assembler to replace this everywhere, consuming no memory space.

    students resb MAX_STUDENTS * STUDENT_SIZE           ; resb (Reserve Bytes): Instructs OS to carve out a contiguous memory block.
    num_students resq 1                                 ; resq (Reserve Quadword): Reserves 8 bytes for our student counter.
    input_buf resb 64

section .text
    global _start

_start:
    mov qword [num_students], 0                         ; Initializes the global student counter to 0 upon startup

; ---------------------------------------------------------
; MENU LOOPS
; ---------------------------------------------------------

login_loop:
    mov rax, 1                                          ; Setting rax to 1 specifies the "sys_write" system call
    mov rdi, 1                                          ; Setting rdi to 1 specifies standard output (the terminal)
    mov rsi, login_menu_msg                             ; rsi holds the pointer to the string we want to print
    mov rdx, login_menu_len                             ; rdx holds the length of the string to print
    syscall                                             ; Triggers the kernel to execute the system call we prepared

    mov rax, 0                                          ; Setting rax to 0 specifies the "sys_read" system call
    mov rdi, 0                                          ; Setting rdi to 0 specifies standard input (keyboard)
    mov rsi, input_buf                                  ; Tells the kernel to store what the user types into input_buf
    mov rdx, 64                                         ; Allows up to 64 bytes to be read
    syscall

    cmp byte [input_buf], '1'                           ; cmp (Compare): Checks if the first typed character is '1'
    je login_admin                                      ; je (Jump if Equal): If it was '1', jump to the login_admin label
    cmp byte [input_buf], '2'
    je guest_loop
    cmp byte [input_buf], '3'
    je exit_program
    jmp login_loop                                      ; jmp (Unconditional Jump): If invalid input, restart loop

login_admin:
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_pass
    mov rdx, prompt_pass_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 64
    syscall

    mov rcx, rax                                        ; rax holds the number of bytes read. We move this to rcx to use as a counter
    test rcx, rcx                                       ; test: Checks if rcx is 0 (meaning nothing was read)
    jz .do_compare                                      ; jz (Jump if Zero): Skip replacing newline if nothing was read
    dec rcx
    cmp byte [input_buf + rcx], 10
    jne .do_compare
    mov byte [input_buf + rcx], 0

.do_compare:
    mov rsi, input_buf                                  ; Set up string pointers for strcmp function
    mov rdi, admin_pass
    call strcmp                                         ; call: Pushes return address to stack and jumps to strcmp function
    test rax, rax
    jz admin_loop                                       ; strcmp returns 0 in rax if strings match. If so, jump to admin_loop

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_wrong_pass
    mov rdx, msg_wrong_pass_len
    syscall
    jmp login_loop

admin_loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, admin_menu_msg
    mov rdx, admin_menu_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 64
    syscall

    cmp byte [input_buf], '1'
    jne .ch2                                            ; jne (Jump if Not Equal): If not '1', check next option
    call add_student
    jmp admin_loop
.ch2:
    cmp byte [input_buf], '2'
    jne .ch3
    call update_student
    jmp admin_loop
.ch3:
    cmp byte [input_buf], '3'
    jne .ch4
    call search_student
    jmp admin_loop
.ch4:
    cmp byte [input_buf], '4'
    je login_loop
    jmp admin_loop

guest_loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, guest_menu_msg
    mov rdx, guest_menu_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 64
    syscall

    cmp byte [input_buf], '1'
    jne .ch2
    call search_student
    jmp guest_loop
.ch2:
    cmp byte [input_buf], '2'
    je login_loop
    jmp guest_loop


; ---------------------------------------------------------
; FEATURE ROUTINES
; ---------------------------------------------------------

add_student:
    mov rax, [num_students]
    cmp rax, MAX_STUDENTS
    jge .done

    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_id
    mov rdx, prompt_id_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 64
    syscall

    cmp rax, 9                                          ; Validation Block: Checks if exactly 9 bytes were read (8 digits + 1 Enter key)
    jne .invalid_id                                     ; Rejects if less or more than 8 digits were typed
    cmp byte [input_buf + 8], 10
    jne .invalid_id

    mov byte [input_buf + 8], 0

    mov rcx, 0
.check_digits:                                          ; Loop that traverses the input string character by character
    mov al, [input_buf + rcx]
    cmp al, '0'                                         ; Compares character to ASCII '0'
    jl .invalid_id                                      ; jl (Jump if Less): Rejects if it's a special char or letter below '0'
    cmp al, '9'
    jg .invalid_id                                      ; jg (Jump if Greater): Rejects letters above '9'
    inc rcx
    cmp rcx, 8
    jl .check_digits

    mov r12, [num_students]
    test r12, r12
    jz .valid_id_no_dups
    
    lea r13, [students]                                 ; lea (Load Effective Address): Grabs the start address of our memory block
.check_dup_loop:
    mov rsi, input_buf
    mov rdi, r13
    call strcmp
    test rax, rax
    jz .duplicate_found

    add r13, STUDENT_SIZE                               ; Moves pointer forward by 96 bytes to point to the next student record
    dec r12
    jnz .check_dup_loop                                 ; jnz (Jump if Not Zero): Continues loop until r12 hits 0

.valid_id_no_dups:
    mov rax, [num_students]
    mov rbx, STUDENT_SIZE
    mul rbx                                             ; mul (Multiply): rax = num_students * 96 to find byte offset for new student
    lea r12, [students + rax]                           ; r12 now securely points to the exact memory location for this new student

    mov rsi, input_buf
    mov rdi, r12
    call strcpy

    mov rcx, 0
.read_marks_loop:
    push rcx                                            ; push: Temporarily saves our loop counter (rcx) on the stack
    mov rsi, [prompts + rcx*8]                          ; Dynamically loads the specific course prompt using pointer arithmetic
    mov rdx, [prompt_lens + rcx*8]
    mov rax, 1
    mov rdi, 1
    syscall

    call read_int
    pop rcx                                             ; pop: Restores our loop counter from the stack after the function call
    mov [r12 + 16 + rcx*8], rax                         ; Saves the integer mark to memory (16 byte offset past the ID)
    
    inc rcx
    cmp rcx, 8
    jl .read_marks_loop

    mov r13, r12
    call calculate_cwa

    inc qword [num_students]                            ; qword: Tells assembler to increment a full 64-bit value in memory

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_success
    mov rdx, msg_success_len
    syscall

    mov r13, r12
    call print_student_details
    ret                                                 ; ret (Return): Jumps execution back to the caller (admin_loop)

.invalid_id:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_err_id
    mov rdx, msg_err_id_len
    syscall
    ret

.duplicate_found:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_err_dup
    mov rdx, msg_err_dup_len
    syscall
    ret
.done:
    ret


update_student:
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
    ret

.found:
    mov rcx, 0
.update_loop:                                           ; Smart Update Loop: Iterates over the 8 courses, skipping unmodified ones
    push rcx
    mov rsi, [mod_prompts + rcx*8]
    mov rdx, [mod_lens + rcx*8]
    mov rax, 1
    mov rdi, 1
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 64
    syscall

    mov al, [input_buf]
    cmp al, 'Y'                                         ; Checks if admin typed 'Y' or 'y'. If neither, it jumps to skip_modify
    je .do_modify
    cmp al, 'y'
    je .do_modify
    jmp .skip_modify

.do_modify:
    pop rcx
    push rcx
    
    mov rsi, [prompts + rcx*8]
    mov rdx, [prompt_lens + rcx*8]
    mov rax, 1
    mov rdi, 1
    syscall

    call read_int
    pop rcx
    push rcx
    mov [r13 + 16 + rcx*8], rax

.skip_modify:
    pop rcx
    inc rcx
    cmp rcx, 8
    jl .update_loop

    call calculate_cwa

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_update_success
    mov rdx, msg_update_success_len
    syscall

    call print_student_details
    ret


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
    ret

.found:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    call print_student_details
    ret


exit_program:
    mov rax, 60                                         ; 60 is the syscall code for sys_exit in Linux
    xor rdi, rdi                                        ; xor rdi, rdi: A fast way to set rdi to 0 (return code 0 means success)
    syscall


; =========================================================
; SUBROUTINES
; =========================================================

calculate_cwa:
    push rax
    push rbx
    push rcx
    push rdx
    push r14

    xor r14, r14                                        ; Zeros out r14 to use as our running weighted sum
    xor rcx, rcx
.calc_cwa_loop:
    mov rax, [r13 + 16 + rcx*8]                         ; Loads the student's integer mark for course (rcx)
    mov rbx, [course_credits + rcx*8]                   ; Loads the fixed credit hour for that same course
    mul rbx                                             ; Hardware multiply: Multiplies rax * rbx and stores result in rax
    add r14, rax                                        ; Adds the result to our running sum in r14
    inc rcx
    cmp rcx, 8
    jl .calc_cwa_loop

    mov rax, r14
    xor rdx, rdx                                        ; Zeros out rdx. The div instruction uses rdx:rax as a combined 128-bit dividend
    mov rbx, 19                                         ; 19 is the hardcoded sum of all 8 course credit hours
    div rbx                                             ; Hardware divide: Divides rdx:rax by rbx. The integer quotient goes into rax
    mov [r13 + 80], rax                                 ; Stores the final CWA quotient into memory at the 80-byte offset

    pop r14
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

print_student_details:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_res_id
    mov rdx, msg_res_id_len
    syscall

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

    xor rcx, rcx
.print_courses_loop:
    push rcx
    
    mov rsi, [course_names + rcx*8]
    mov rdx, [name_lens + rcx*8]
    mov rax, 1
    mov rdi, 1
    syscall
    
    pop rcx
    push rcx

    mov rax, [r13 + 16 + rcx*8]
    call get_grade_string
    mov rax, 1
    mov rdi, 1
    syscall

    pop rcx
    inc rcx
    cmp rcx, 8
    jl .print_courses_loop

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_res_cwa
    mov rdx, msg_res_cwa_len
    syscall

    mov rax, [r13 + 80]
    call print_int

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_res_grade
    mov rdx, msg_res_grade_len
    syscall

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

get_grade_string:
    cmp rax, 70                                         ; Grade Scale Block: Compares the integer CWA against boundaries
    jge .grade_A                                        ; jge (Jump if Greater/Equal): Jumps straight to .grade_A if it's 70 or higher
    cmp rax, 60
    jge .grade_B
    cmp rax, 50
    jge .grade_C
    cmp rax, 40
    jge .grade_D
    jmp .grade_F                                        ; Fails gracefully to F if no boundaries are hit

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

atoi:                                                   ; atoi (ASCII to Integer): Custom function since we can't use C libraries.
    xor rax, rax                                        ; Converts a typed string like "95" into the raw binary value 95.
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
    sub cl, '0'                                         ; Subtracts '0' ASCII offset to get the raw integer value of the digit
    push rdx
    mov rbx, 10
    mul rbx                                             ; Multiplies the running total by 10 to shift digits left (e.g. 9 -> 90)
    pop rdx
    add rax, rcx                                        ; Adds the newly parsed digit (e.g. 90 + 5 = 95)
    inc rsi
    jmp .loop
.done:
    ret

print_int:                                              ; print_int: Reverses atoi. Takes a raw binary integer and turns it into ASCII
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
    div rbx                                             ; Extracts the right-most digit by dividing by 10. Remainder goes to rdx
    add dl, '0'                                         ; Adds '0' ASCII offset to convert it back to printable text
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
