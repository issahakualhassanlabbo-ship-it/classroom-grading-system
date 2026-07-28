# Classroom Grading System - Class Presentation Guide

*This document is designed to act as your presentation script and guide. It walks through the architecture, memory layout, and logical flow of the 64-bit NASM Assembly Classroom Grading System.*

---

## 1. Introduction
**"Good morning/afternoon everyone. Today, our group will be presenting our Classroom Grading System."**

Our goal was to build a secure, robust, and lightning-fast grading application. To truly demonstrate our understanding of low-level systems programming, we chose to write this entirely in **64-bit x86 NASM Assembly for Linux**. 

We purposefully **did not** use any standard C libraries (like `printf` or `scanf`). Every interaction in this program—from printing menus to reading user input—is done by interacting directly with the Linux kernel using system calls (`sys_read`, `sys_write`, and `sys_exit`).

---

## 2. Memory Organization: The `.data` and `.bss` Sections
**"In Assembly, how you manage memory is everything. Let's look at how we organized our data."**

### The `.data` Section
This section stores initialized data. In our code, it holds:
- **Menu Strings:** The text for our Login, Admin, and Guest menus.
- **System Prompts & Messages:** Error messages for invalid IDs, success messages, and course names.
- **Admin Password:** We securely hardcoded the password (`assembly254`) here for role-based authentication.
- **Fixed Arrays:** We utilized arrays of pointers (like `course_names` and `mod_prompts`) and an array of integers (`course_credits dq 2, 3, 3, 2, 3, 3, 2, 1`) to make our loops highly efficient. By hardcoding the credit hours, we save the user from typing them repeatedly.

### The `.bss` Section
This section reserves uninitialized memory space for our dynamic data. Since we don't use dynamic memory allocation (like `malloc`), we created an **in-memory array of structs** to hold up to 100 students natively.
- **Memory Chunk Allocation:** We reserved a total block of `100 * 96` bytes.
- **Student Struct Breakdown (96 Bytes per Student):**
  - `Offset 0-15`: Holds the 8-digit Student ID (string format).
  - `Offset 16-79`: Holds the raw integer marks for all 8 courses (8 bytes each).
  - `Offset 80-87`: Holds the final calculated Cumulative Weighted Average (CWA).
  - `Offset 88-95`: Serves as padding for 64-bit memory alignment.

---

## 3. Core Program Flow and Authentication
**"Let's walk through what happens when you run the program."**

When the program executes, it starts at the `_start` label in the `.text` section. It initializes our global `num_students` counter to `0` and immediately jumps into our **Role-Based Access Control** flow.

- **Login Menu (`login_loop`)**: Prompts the user to log in as an Admin or continue as a Guest. 
- **Authentication (`login_admin`)**: If Admin is selected, it takes password input and uses our custom string-compare function (`strcmp`) against `assembly254`.
  - **Admin Loop**: Grants access to Add, Update, and Search for records.
  - **Guest Loop**: Restricts access so users can **only** Search and view results.

---

## 4. Key Features & Logic Blocks

### A. Adding a Student and Validation (`add_student`)
When an Admin adds a student, we don't just blindly accept data. We implemented strict data validation:
1. **Length Check:** We check the number of bytes read by the `sys_read` kernel call. If it isn't exactly 9 (8 characters + 1 Enter key stroke), we reject it.
2. **Numeric Check:** We loop over the 8 characters, checking if their ASCII values fall between `'0'` and `'9'`.
3. **Duplicate Check:** We iterate through all existing students in the `.bss` section and compare IDs. If a match is found, the system rejects the input to prevent duplicates.

Once validated, we use a loop to prompt the Admin for the marks of all 8 courses, saving them into the 96-byte struct.

### B. Smart Record Updating (`update_student`)
To make the Admin's life easier, we built a smart update loop. Once an existing ID is found, the system loops through the 8 courses.
- It asks: *"Modify [Course Name]? (Y/N)"*
- It checks the first byte of the user's input. If they type `Y` or `y`, it allows them to enter a new score. If they type `N`, it jumps to the next course instantly, saving immense time.

### C. Calculating the CWA (`calculate_cwa`)
After a student is added or updated, we recalculate their CWA. 
- **The Math Loop:** We loop 8 times. In each iteration, we grab the student's mark from the struct and the corresponding credit hour from our `.data` array.
- We multiply them using the hardware `mul` instruction and add it to a running sum in the `r14` register.
- **Division:** Finally, we load the total fixed credits (19) into a register and use the `div` instruction to divide the weighted sum, giving us the integer CWA, which we store back into the student's memory block.

### D. Displaying Results (`print_student_details` & `get_grade_string`)
When a user searches for an ID, we print the ID, the individual course letter grades, and the overall CWA.
- To assign a letter grade, we load the integer mark into the `rax` register and use a series of sequential **Compare (`cmp`)** and **Jump if Greater than or Equal (`jge`)** instructions. 
- If `rax` >= 70, it jumps to `.grade_A`. If not, it drops down and checks if it's >= 60 for `.grade_B`, and so on down to an F.

---

## 5. Custom Helper Routines
**"Because we abandoned standard libraries, we had to write the low-level machinery ourselves."**

At the bottom of our code, you will find our custom utility subroutines:
- `atoi` (ASCII to Integer): Converts the user's string input on the terminal into raw binary integers so our CPU can do math on them. It does this by multiplying a running total by 10 and subtracting the ASCII value of `'0'`.
- `print_int`: Reverses `atoi`. It takes the raw integer CWA, uses the `div` instruction by 10 to extract individual digits, converts them to ASCII by adding `'0'`, and prints them to the terminal.
- `strcmp`, `strlen`, `strcpy`: Standard string manipulation routines we built from scratch using byte-by-byte loops and pointer arithmetic.

---

## 6. Conclusion
**"In conclusion..."**

This project pushed us to deeply understand memory addressing, system calls, registers, and hardware-level math. We successfully built a highly secure, role-based, and lightning-fast database system—all without relying on high-level language conveniences. 

**Thank you. We are open to any questions!**
