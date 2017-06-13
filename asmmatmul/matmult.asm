;
; ***************************************************************
;       SKELETON: INTEL ASSEMBLER MATRIX MULTIPLY (LINUX)
; ***************************************************************
;
;
; --------------------------------------------------------------------------
; class matrix {
;     int ROWS              // ints are 64-bit
;     int COLS
;     int elem [ROWS][COLS]
;
;     void print () {
;         output.newline ()
;         for (int row=0; row < this.ROWS; row++) {
;             for (int col=0; col < this.COLS; cols++) {
;                 output.tab ()
;                 output.int (this.elem[row, col])
;             }
;             output.newline ()
;         }
;     }
;
;     void mult (matrix A, matrix B) {
;         for (int row=0; row < this.ROWS; row++) {
;             for (int col=0; col < this.COLS; cols++) {
;                 int sum = 0
;                 for (int k=0; k < A.COLS; k++)
;                     sum = sum + A.elem[row, k] * B.elem[k, col]
;                 this.elem [row, col] = sum
;             }
;         }
;     }
; }
; ---------------------------------------------------------------------------
; main () {
;     matrix matrixA, matrixB, matrixC  ; Declare and suitably initialise
;                                         matrices A, B and C
;     matrixA.print ()
;     matrixB.print ()
;     matrixC.mult (matrixA, matrixB)
;     matrixC.print ()
; }
; ---------------------------------------------------------------------------
;
; Notes:
; 1. For conditional jump instructions use the form 'Jxx NEAR label'  if label
;    is more than 127 bytes from the jump instruction Jxx.
;    For example use 'JGE NEAR end_for' instead of 'JGE end_for', if the
;    assembler complains that the label end_for is more than 127 bytes from
;    the JGE instruction with a message like 'short jump is out of  range'
;
;
; ---------------------------------------------------------------------------

segment .text
        global  _start
_start:

main:
          mov  rax, matrixA     ; matrixA.print ()
          push rax
          call matrix_print
          add  rsp, 8

          mov  rax, matrixB     ; matrixB.print ()
          push rax
          call matrix_print
          add  rsp, 8

          mov  rax, matrixB     ; matrixC.mult (matrixA, matrixB)
          push rax
          mov  rax, matrixA
          push rax
          mov  rax, matrixC
          push rax
          call matrix_mult
          add  rsp, 24          ; pop parameters & object reference

          mov  rax, matrixC     ; matrixC.print ()
          push rax
          call matrix_print
          add  rsp, 8

          call os_return                ; return to operating system

; ---------------------------------------------------------------------

matrix_print:                   ; void matrix_print ()
         push rbp               ; setup base pointer
         mov  rbp, rsp          ; setup frame pointer
 
         push rbx               ; rbx for matrix
         push rcx               ; rcx for row
         push rdx               ; rdx for col
         push r8                ; r8 for element

         mov rbx, [rbp+16]      ; rbx = @matrix
         call output_newline    ; print new line

  forRow:
         mov rcx, 0             ; row = 0
  nextRow:
         cmp rcx, [rbx]         ; compares the row to matrix.rows
         jge endforRow          ; ends for if row >= matrix.rows 
    
    forCol:
           mov rdx, 0           ; col = 0
    nextCol:
           cmp rdx, [rbx+8]     ; compare col to matrix.col
           jge endforCol        ; end for if col >= matrix.col
           
           call output_tab      ; print tab
      
           mov r8, rcx           ; r8 = row
           imul r8, [rbx+8]      ; r8 = row * matrix.columns()
           add r8, rdx           ; r8 += col

           push qword [rbx+r8*8+16] ; push @matrix[row][col]
           call output_int      ; calls output_int(matrix[row][col])
           add rsp, 8           ; removes parameter

           inc rdx              ; col++
           jmp nextCol          ; next interation of forCol
    endforCol:
         
         call output_newline    ; print new line
         inc rcx                ; row++
         jmp nextRow            ; next interation forRow
  endforRow:  

         pop r8                  ; restore r8
         pop rdx                 ; restore rdx
         pop rcx                 ; restore rcx
         pop rbx                 ; restore rbx
         pop rbp                 ; restore base pointer & return
         ret

;  --------------------------------------------------------------------------

matrix_mult:                     ; void matix_mult (matrix A, matrix B)

         push rbp                ; setup base pointer
         mov  rbp, rsp           ; setup frame pointer
  
         push rax                ; rbx holds matrixB pointer
         push rbx                ; rcx holds matrixC pointer
         push rcx                ; rdx holds matrixA pointer
         push r8                 ; r8 holds i
         push r9                 ; r9 holds j
         push r10                ; r10 holds k
         push r11                ; r11 holds sum
         push r12                ; r12 holds the adress for matrixA[i][k]
         push r13                ; r13 holds  the address for matrixB[k][j]
         push r14                ; r14 holds matrixA[i][k] * matrixB[k][j]

         mov rcx, [rbp+16]       ; rcx = @matrixC
         mov rax, [rbp+24]       ; rdx = @matrixA
         mov rbx, [rbp+32]       ; rbx = @matrixB

   forI:
         mov r8, 0               ; i = 0
   nextI:
         cmp r8, [rcx]           ; compares i to matrixC.row
         jge endforI             ; ends for if i >= matrixC.row
         
     forJ:
         mov r9, 0               ; j = 0
     nextJ:
         cmp r9, [rcx+8]         ; compares j to matrixC.col
         jge endforJ             ; ends for if j >= matrixC.col

         mov r11, 0              ; sum = 0
         
       forK:
         mov r10, 0              ; k = 0
       nextK:
         cmp r10, [rax+8]        ; compares k to matrixA.col
         jge endforK             ; ends for if k >= matrixA.col

         mov r12, r8             ; r12 = i 
         imul r12, [rax+8]       ; r12 = i * matrixA.col
         add r12, r10            ; r12 = i * matrixA.col + k

         mov r13, r10            ; r13 = k
         imul r13, [rbx+8]       ; r13 = k * matrixB.col
         add r13, r9             ; r13 = k * matrixB.col + j

         mov r14, [rax+r12*8+16] ; r14 = a[i][k]
         imul r14, [rbx+r13*8+16]; r14 = a[i][k] * b[k][j]
         add r11, r14            ; sum += a[i][k] * b[k][j]
    
         inc r10
         jmp nextK 
       endforK:

       mov r12, r8             ; r12 = i
       imul r12, [rcx+8]       ; r12 = i * matrixC.col
       add r12, r9             ; r12 = i * matrixC.col + j
        
        ; push r11
        ; call output_int
        ; add rsp, 8

       mov [rcx+r12*8+16], r11 ; matrixC[i][j] = sum
           
       inc r9       
       jmp nextJ  
     endforJ:
     
     inc r8
     jmp nextI
   endforI:              
 
         pop r14                 ; restores r14
         pop r13                 ; restores r13
         pop r12                 ; restores r12
         pop r11                 ; restores r11
         pop r10                 ; restores r10
         pop r9                  ; restores r9
         pop r8                  ; restores r8
         pop rcx                 ; restores rcx
         pop rbx                 ; restores rbx
         pop rax                 ; restores rax
         pop rbp                 ; restore base pointer & return
         ret


; ---------------------------------------------------------------------
;                    ADDITIONAL METHODS

CR      equ     13              ; carriage-return
LF      equ     10              ; line-feed
TAB     equ     9               ; tab
MINUS   equ     '-'             ; minus

LINUX   equ     80H             ; interupt number for entering Linux kernel
EXIT    equ     1               ; Linux system call 1 i.e. exit ()
WRITE   equ     4               ; Linux system call 4 i.e. write ()
STDOUT  equ     1               ; File descriptor 1 i.e. standard output

; ------------------------

os_return:
        mov  rax, EXIT          ; Linux system call 1 i.e. exit ()
        mov  rbx, 0             ; Error code 0 i.e. no errors
        int  LINUX              ; Interrupt Linux kernel

output_char:                    ; void output_char (ch)
        push rax
        push rbx
        push rcx
        push rdx
        push r8                ; r8..r11 are altered by Linux kernel interrupt
        push r9
        push r10
        push r11
        push qword [octetbuffer] ; (just to make output_char() re-entrant...)

        mov  rax, WRITE         ; Linux system call 4; i.e. write ()
        mov  rbx, STDOUT        ; File descriptor 1 i.e. standard output
        mov  rcx, [rsp+80]      ; fetch char from non-I/O-accessible segment
        mov  [octetbuffer], rcx ; load into 1-octet buffer
        lea  rcx, [octetbuffer] ; Address of 1-octet buffer
        mov  rdx, 1             ; Output 1 character only
        int  LINUX              ; Interrupt Linux kernel

        pop qword [octetbuffer]
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        pop  rdx
        pop  rcx
        pop  rbx
        pop  rax
        ret

; ------------------------

output_newline:                 ; void output_newline ()
       push qword LF
       call output_char
       add rsp, 8
       ret

; ------------------------

output_tab:                     ; void output_tab ()
       push qword TAB
       call output_char
       add  rsp, 8
       ret

; ------------------------

output_minus:                   ; void output_minus()
       push qword MINUS
       call output_char
       add  rsp, 8
       ret

; ------------------------

output_int:                     ; void output_int (int N)
       push rbp
       mov  rbp, rsp

       ; rax=N then N/10, rdx=N%10, rbx=10

       push rax                ; save registers
       push rbx
       push rdx

       cmp  qword [rbp+16], 0 ; minus sign for negative numbers
       jge  L88

       call output_minus
       neg  qword [rbp+16]

L88:
       mov  rax, [rbp+16]       ; rax = N
       mov  rdx, 0              ; rdx:rax = N (unsigned equivalent of "cqo")
       mov  rbx, 10
       idiv rbx                ; rax=N/10, rdx=N%10

       cmp  rax, 0              ; skip if N<10
       je   L99

       push rax                ; output.int (N / 10)
       call output_int
       add  rsp, 8

L99:
       add  rdx, '0'           ; output char for digit N % 10
       push rdx
       call output_char
       add  rsp, 8

       pop  rdx                ; restore registers
       pop  rbx
       pop  rax
       pop  rbp
       ret


; ---------------------------------------------------------------------

segment .data

        ; Declare test matrices
matrixA DQ 2                    ; ROWS
        DQ 3                    ; COLS
        DQ 1, 2, 3              ; 1st row
        DQ 4, 5, 6              ; 2nd row

matrixB DQ 3                    ; ROWS
        DQ 2                    ; COLS
        DQ 1, 2                 ; 1st row
        DQ 3, 4                 ; 2nd row
        DQ 5, 6                 ; 3rd row

matrixC DQ 2                    ; ROWS
        DQ 2                    ; COLS
        DQ 0, 0                 ; space for ROWS*COLS ints
        DQ 0, 0                 ; (for filling in with matrixA*matrixB)

; ---------------------------------------------------------------------

        ; The following is used by output_char - do not disturb
        ;
        ; space in I/O-accessible segment for 1-octet output buffer
octetbuffer     DQ 0            ; (qword as choice of size on stack)  
