.section  .text

.global   main
.extern   printf
main:
  // Prolog
  stp   x29,  x30,  [sp,  #-16]!
  sub   sp,   sp,   256

  // Call init_array
  adr   x0,   array
  mov   x1,   #10
  bl    init_array

//   Call print_array
//   adr   x0,   array
//   mov   x1,   #10
//   bl    print_array

  // Call copy_array
  adr   x0,   array_copy
  adr   x1,   array
  mov   x2,   #10
  bl    copy_array

  // Call swap
  adr   x0,   a
  adr   x1,   b
  bl    swap

  // Epilog
  mov   x8,   #93
  svc   0

// Initialize array function
// x19 = pointer to first element of array
// x20 = number of elements in array
// x21 = counter
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

// Print array function
// x19 = pointer to first element of array
// x20 = number of elements in array
// x21 = counter
.global   print_array
print_array:
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

print_loop:
  // Compare counter, n
  cmp   x21,  x20
  bge   print_end

  // Load value from array
  ldr   w18,  [x19,   x21,  lsl 2]

  // Print value (w18)
  mov   x0,   x18
  adr   x1,   format_string
  bl    printf

  // Counter ++, check for newline
  add   x21,  x21,  #1
  and   x22,  x21,  #4
  cbz   x22,  newline

  // Print tab
  adr   x0,   tab_string
  bl    printf
  b     print_loop

newline:
  adr   x0,   newline_string
  bl    printf
  b     print_loop

print_end:
  // Epilog
  mov   x0,   x19
  ldr   x19,  [sp, 8]
  ldr   x20,  [sp, 16]
  ldr   x21,  [sp, 24]
  add   sp,   sp,   32
  ldp   x29,  x30,  [sp],   #16
  ret

// Copy array function
// x19 = pointer to destination array
// x20 = pointer to source  array
// x21 = number of elements in both arrays
// x22 = counter
.global  copy_array
copy_array:
  // Prolog
  stp   x29,  x30,  [sp, #-16]!
  sub   sp,   sp,   32

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
  b     copy_end

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
  add   sp,   sp,   32
  ldp   x29,  x30,  [sp],   #16
  ret

// Swap integers function
// x19 = pointer to a
// x20 = pointer to b
// x2,x3 = temp storage
.global  swap
swap:
  // Prolog
  stp   x29,  x30,  [sp, #-16]!
  sub   sp,   sp,   16

  str   x19,  [sp]
  str   x20,  [sp, 8]

  // Store data
  mov   x19,  x0
  mov   x20,  x1

  // Load value of a into x2
  ldr   x2,   [x19]
  ldr   x3,   [x20]

  str   x3,   [x19]
  str   x2,   [x20]

  // Epilog
  ldr   x19,  [sp]
  ldr   x20,  [sp, 8]
  add   sp,   sp,   16
  ldp   x29,  x30,  [sp],   #16
  ret

// Random number generator in range 0-255
// x19 = temporarily holds file descriptor info
// x20 = temporarily holds returned random integer
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

.section  ".rodata"
dev_urandom:
  .asciz  "/dev/urandom"
format_string:
  .string "%5d"
tab_string:
  .string "\t"
newline_string:
  .string "\n"

.section  ".bss"
array:
  .skip   40
array_copy:
  .skip   40

.section  .data
a:
  .word   10
b:
  .word   20
