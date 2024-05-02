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
  add   w0,   w0,   #0xFF
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
  // Compare counter, n
  cmp   x21,  x20
  bge   print_end

  // Compare inner_counter, 5
  mov   x6,   #6
  cmp   x22,  x6
  bge   print_inner_end

  // Counters ++
  add   x21,  x21,  #1
  add   x22,  x22,  #1

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

  // Loop back to top
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

