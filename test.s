// C standard library header
#include  <stdio.h>

.section  ".rodata"
dev_urandom:    .asciz  "/dev/urandom"
format_string:  .string "%5d"
tab_string:     .string "\t"
newline_string: .string "\n"

.section  ".bss"
array:        .skip   40
array_copy:   .skip   40

.section  .data
a:  .word   10
b:  .word   20

.section  .text

.global   main
main:
  // Prolog
  sub   sp,   sp,   256
  str   x30,  [sp]

  // Call init_array
  adr   x0,   array
  mov   x1,   #10
  bl    init_array

  // Call print_array
  adr   x0,   array
  mov   x1,   #10
  bl    print_array

  // Call copy_array
  adr   x0,   array_copy
  adr   x1,   array
  mov   x2,   #10
  bl    copy_array
  // Print copy to verify
  adr   x0,   array_copy
  mov   x1,   #10
  bl    print_array

  // Call selection_sort


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
//     arr: x0 -> x19
//       n: x1 -> x20
// counter: x21, x22
//  output: void
.global   selection_sort
selection_sort:
  // Prolog
  stp   x29,  x30,  [sp, #-16]!
  sub   sp,   sp,   16

  str   x19,  [sp, 8]
  str   x20,  [sp, 16]

  // Store data
  mov 	x19,  x0
  mov   x20,  x1

  // Initialize counters to 0
  mov   x21,  #0

  // Compare n, 1
  cmp   x20,  #1
  ble   sort_end

sort_loop:
  // Check to see if end of array is reached
  cmp   x21,  x20
  bge   sort_end

  // Setting i, j
  mov   x22,  x21
  mov   x23,  x21

  // Get current element in array
  ldr   w22,  [x19, x21, lsl 2]

sort_inner_loop:
  // Check to see if end of array is reached
  cmp   x23,  x20
  bge   sort_end

  // Grab j
  ldr   w18,  [x19, x23, lsl 2]

  // Compare arr[1] and arr[0]
  cmp   w18,  w22
  bge   sort_inner_end
  
  // Set min index to the next index in array
  mov   x22,  x23

sort_inner_end:
  // j++, compare with n
  add   x23,  x23,  #1
  cmp   x23,  x20
  b     sort_inner_loop

  // Get address of array indexes of i, min
  add   x24,  x19,  x21,  lsl 2
  add   x25,  x19,  x22,  lsl 2

  // Grab data, make swap between indexes
  ldr   w23,  [x24]
  ldr   w17,  [x25]
  str   w17,  [x24]
  str   w23,  [x25]
  b     sort_loop

sort_end:
  // Epilog
  ldr   x19,  [sp]
  ldr   x20,  [sp, 8]
  add   sp,   sp,   16
  ldp   x29,  x30,  [sp],   #16
  ret
