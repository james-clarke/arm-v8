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

  // Call print_array
  adr   x0,   array
  mov   x1,   #10
  bl    print_array

  // Epilog
  mov   x0,   0
  ret

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
  mov   x0,   x19
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

// Random number generator in range 0-255
// x19 = temporarily holds file descriptor info
// x20 = temporarily holds returned random integer
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

.section  .rodata
dev_urandom:
  .asciz  "/dev/urandom"
format_string:
  .string "%5d"
tab_string:
  .string "\t"
newline_string:
  .string "\n"

.section  .bss
array:
  .skip   40