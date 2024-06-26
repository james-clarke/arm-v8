// C standard library header
#include  <stdio.h>

.section  ".rodata"
dev_urandom:    .asciz  "/dev/urandom"
format_string:  .string "%5d"
tab_string:     .string "\t"
newline_string: .string "\n"

.section  ".bss"
array:        .skip   212
array_copy:   .skip   212

.section  .data
a:  .word   10
b:  .word   20
prompt:   .asciz  "Enter TCU ID number: \n"
          .align  2
output:   .asciz  "Creating 2 arrays of size 53\n"
          .align  2
orig:     .asciz  "The original array is: \n"
          .align
dup:      .asciz  "The sorted duplicate array is: \n"
          .align 2
average_p: .asciz  "The averige of the duplicate array is: \n"

.section  .text

.global   main
main:
  // Prolog
  sub   sp,   sp,   256
  str   x29,  [sp]

  // Prompt for id
  adr   x0,   prompt
  bl    printf

  // Output size of n
  adr   x0,   output
  bl    printf

  // Call init_array
  adr   x0,   array
  mov   x1,   #53
  bl    init_array

  // Original
  adr   x0,   orig
  bl    printf

  // Call print_array
  adr   x0,   array
  mov   x1,   #53
  bl    print_array

  // Call copy_array
  adr   x0,   array_copy
  adr   x1,   array
  mov   x2,   #53
  bl    copy_array

  // Sorted Duplicate
  adr   x0,   dup
  bl    printf

  // Call selection_sort
  adr   x0,   array_copy
  mov   x1,   #53
  bl    selection_sort
  // Print sorted array to verify
  adr   x0,   array_copy
  mov   x1,   #53
  bl    print_array

  // Call sum_array
  adr   x0,   array_copy
  mov   x1,   #0
  mov   x2,   #52
  bl    sum_array

  // Call average
  adr   x0,   array_copy
  mov   x1,   #10
  bl    average
  
  // Average
  adr   x0,   average_p
  bl    printf

  // Epilog
  mov   x8,   #93
  svc   0


// init_array(int arr[], int n)
//     arr: x0 -> x19
//       n: x1 -> x20
// counter: x21
//  output: void
.global   init_array
init_array:
  // Prolog
  stp   x29,  x30,  [sp, #-16]!
  sub   sp,   sp,   32

  str   x19,  [sp, 8]
  str   x20,  [sp, 16]
  str   x21,  [sp, 24]

  // Store data
  mov   x19,  x0
  mov   x20,  x1

  // Initialize counter to 0
  mov   x21,  #0

init_loop:
  // Compare counter, n
  cmp   x21,   x20
  bge   init_end

  // Generate random value and store in array
  bl    rand
  and   w0,   w0,   #0xFF
  str   w0,   [x19,  x21,   lsl 2]

  // Counter ++
  add   x21,  x21,   #1

  // Loop back
  b     init_loop

init_end:
  // Epilog
  ldr   x19,  [sp, 8]
  ldr   x20,  [sp, 16]
  ldr   x21,  [sp, 24]
  add   sp,   sp,   32
  ldp   x29,  x30,  [sp],   #16
  ret

// rand()
// Using the /dev/urandom random number generator
.global  rand
  rand:
  // Prolog
  sub   sp,   sp,   32
  str   x30,  [sp]
  str   x19,  [sp, 8]
  str   x20,  [sp, 16]

  // Open /dev/urandom
  mov   x0,   #0
  ldr   x1,   =dev_urandom
  mov   x2,   #0
  mov   x8,   #56
  svc   #0

  mov   x19,  x0

  // Read byte from /dev/urandom
  mov   x0,   x19
  sub   sp,   sp,   #16
  mov   x1,   sp
  mov   x2,   #1
  mov   x8,   #63
  svc   #0

  ldr   x20,  [sp]
  add   sp,   sp,   #16

  // Close file
  mov   x0,   x19
  mov   x8,   #57
  svc   #0

  // Epilog
  mov   x0,   x20
  ldr   x30,  [sp]
  ldr   x19,  [sp, 8]
  ldr   x20,  [sp, 16]
  add   sp,   sp,   32
  ret

// print_array(int arr[], int n)
//           arr: x0 -> x19
//             n: x1 -> x20
//       counter: x21
// inner_counter: x22
//        output: formatted array
.global   print_array
print_array:
  // Prolog
  stp   x29,  x30,  [sp, #-16]!
  sub   sp,   sp,   48

  str   x19,  [sp, 8]
  str   x20,  [sp, 16]
  str   x21,  [sp, 24]
  str   x22,  [sp, 32]

  // Store data
  mov   x19,  x0
  mov   x20,  x1

  // Initialize counters to 0
  mov   x21,  #0
  mov   x22,  #0

print_loop:
  // Compare main counter with size n
  cmp   x21,  x20
  bge   print_end

  // Grab current element and store in x1 to print
  ldr   w1,   [x19, x21, lsl 2]
  adrp  x0,   format_string
  add   x0,   x0,   :lo12:format_string

  // Call printf function
  bl    printf

  // Print tab after every element
  adrp  x0,   tab_string
  add   x0,   x0,   :lo12:tab_string
  bl    printf

  // Increment main counter
  add   x21,  x21,  #1

  // Increment inner counter for formatting
  add   x22,  x22,  #1
  cmp   x22,  #5
  blt   continue_printing  // Continue if less than 5 elements have been printed

  // Print newline after every 5 elements, reset counter
  adrp  x0,   newline_string
  add   x0,   x0,   :lo12:newline_string
  bl    printf
  mov   x22,  #0

continue_printing:
  b     print_loop


print_inner_end:
  // After 5 elements, print a newline
  adrp  x0,   newline_string
  add   x0,   x0,   :lo12:newline_string
  bl    printf

  // Set innner_counter = 0
  mov   x22,  #0

  // Loop back to top
  b     print_loop

print_end:
  // End print_loop with newline_string
  adrp  x0,   newline_string
  add   x0,   x0,   :lo12:newline_string
  bl    printf

  // Epilog
  ldr   x19,  [sp, 8]
  ldr   x20,  [sp, 16]
  ldr   x21,  [sp, 24]
  ldr   x22,  [sp, 32]
  add   sp,   sp,   48
  ldp   x29,  x30,  [sp],   #16
  ret

// copy_array(int dest[], int src[], int n)
//    dest: x0 -> x19
//     src: x1 -> x20
//       n: x2 -> x21
// counter: x22
//  output: void
.global   copy_array
copy_array:
  // Prolog
  stp   x29,  x30,  [sp, #-16]!
  sub   sp,   sp,   48

  str   x19,  [sp, 8]
  str   x20,  [sp, 16]
  str   x21,  [sp, 24]
  str   x22,  [sp, 32]

  // Store data
  mov 	x19,  x0
  mov   x20,  x1
  mov   x21,  x2

  // Initialize counter to 0
  mov   x22,  #0

copy_loop:
  // Compare counter, n
  cmp   x22,  x21
  bge   copy_end

  // Load and store data
  ldr   w2,  [x20, x22, lsl 2]
  str   w2,  [x19, x22, lsl 2]

  // Increment counter
  add  x22,  x22,  #1
  b    copy_loop

copy_end:
  // Epilog
  ldr   x19,  [sp, 8]
  ldr   x20,  [sp, 16]
  ldr   x21,  [sp, 24]
  ldr   x22,  [sp, 32]
  add   sp,   sp,   48
  ldp   x29,  x30,  [sp],   #16
  ret

// swap(int *a, int *b)
//      a: x0 -> x19
//      b: x1 -> x20
// output: void
.global   swap
swap:
  // Prolog
  stp   x29,  x30,  [sp, #-16]!
  sub   sp,   sp,   16

  str   x19,  [sp]
  str   x20,  [sp, 8]

  // Store data
  mov   x19,  x0
  mov   x20,  x1

  // Load value of a, b into x2, x3
  ldr   x2,   [x19]
  ldr   x3,   [x20]

  // Make swap
  str   x3,   [x19]
  str   x2,   [x20]

  // Epilog
  ldr   x19,  [sp]
  ldr   x20,  [sp, 8]
  add   sp,   sp,   16
  ldp   x29,  x30,  [sp],   #16
  ret

// selection_sort(int arr[], int n)
//    arr: x0 -> x19
//      n: x1 -> x20
// output: void
.section  .text
.global   selection_sort

selection_sort:
    // Prolog
    stp   x29,  x30,  [sp, #-16]!
    sub   sp,   sp,   16

    str   x19,  [sp]
    str   x20,  [sp, 8]

    mov   x19,  x0
    mov   x20,  x1

    // Check if the array size is less than 2
    cmp   x20,  #2
    blt   end_sort

    // Initialize the index i for the outer loop
    mov   x2,   #0

sort_outer_loop:
    // Set the current minimum to the current i position
    mov   x3,   x2
    add   x4,   x19,  x2,   lsl #2

    // Initialize j = i + 1 for the inner loop
    add   x5,   x2,   #1

sort_inner_loop:
    // Compare j with n
    cmp   x5,   x20
    bge   check_end_outer

    // Calculate the address of arr[j] for comparison
    add   x6,   x19,  x5,   lsl #2

    // Load values of arr[min_idx] and arr[j]
    ldr   w7,   [x4]
    ldr   w8,   [x6]

    // Compare to find a new minimum
    cmp   w7,   w8
    bgt   update_min
    b     skip_update

update_min:
    // Update min_idx
    mov   x3,   x5
    mov   x4,   x6

skip_update:
    // Increment j and continue inner loop
    add   x5,   x5,   #1
    b     sort_inner_loop

check_end_outer:
    // Compare i with min_idx, if not the same, swap
    cmp   x2,   x3
    beq   skip_swap

    // Perform swap between arr[i] and arr[min_idx]
    ldr   w9,   [x4]
    ldr   w10,  [x19, x2, lsl #2]
    str   w9,   [x19, x2, lsl #2]
    str   w10,  [x4]

skip_swap:
    // Increment i and continue outer loop
    add   x2,   x2,   #1
    cmp   x2,   x20
    blt   sort_outer_loop

end_sort:
    // Epilog
    ldr   x19,  [sp]
    ldr   x20,  [sp, 8]
    add   sp,   sp,   16 
    ldp   x29,  x30,  [sp],   #16
    ret

// average(int arr[], int n)
//    arr: x0 -> x19
//      n: x1 -> x20
// output: int average
.section  .text
.global   average

average:
    // Prologue
    stp   x29,  x30,  [sp, #-16]!
    sub   sp,   sp,   16

    str   x19,  [sp]
    str   x20,  [sp, 8]

    // Prepare arguments for sum_array function
    mov   x19,  x0
    mov   x20,  x1
    mov   x0,   x19
    mov   x1,   #0
    sub   x2,   x20,  #1
    bl    sum_array

    // Calculate average by dividing the sum by the number of elements
    udiv  x0,   x0,   x20

    // Epilogue
    ldr   x19,  [sp]
    ldr   x20,  [sp, 8]
    add   sp,   sp,   16
    ldp   x29,  x30,  [sp],   #16
    ret

// sum_array(int arr[], int startidx, int stopidx)
//      arr: x0 -> x19
// startidx: x1 -> x20
//  stopidx: x2 -> x21
//   output: int sum of array
.section .text
.global sum_array

sum_array:
    // Prolog
    stp   x29,  x30,  [sp, #-16]!
    add   x29,  sp,   #0
    sub   sp,   sp,   #32
    
    str   x19,  [sp]
    str   x20,  [sp, 8]

    .equ  CUR_VAL,  16

    // Store function arguments in local variables
    mov   x19,  x0
    mov   x20,  x1
    mov   x21,  x2

    // Check if the recursive base case is met
    cmp   x20,  x21
    bgt   base_case

    // Load and store current array element
    ldr   w22,  [x19, x20, lsl #2]
    str   w22,  [sp, #CUR_VAL]

    // Setup for recursive call
    add   x1,   x20,  #1
    mov   x0,   x19
    mov   x2,   x21
    bl    sum_array

    // Combine current element with result from recursive call
    ldr   w22,  [sp, #CUR_VAL]
    add   x0,   x0,   x22

    // Exit function and restore registers
    b   exit_function

base_case:
    // Base case return
    mov   x0,   #0
    b     exit_function

exit_function:
    // Epilog
    ldr   x19,  [sp]
    ldr   x20,  [sp, 8]
    add   sp,   sp,   #32
    ldp   x29,  x30,  [sp],   #16
    ret

