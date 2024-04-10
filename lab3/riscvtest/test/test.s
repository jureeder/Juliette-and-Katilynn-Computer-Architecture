.globl __start

.text

__start:

##sw##
test01:
  li a1, 1
  li x1, 0x00000060
  li x2, 0xdeadbeef
  sw x2, 0(x1)
  lw x30, 0(x1)
  li x29, 0xdeadbeef
  bne x30, x29, fail

##sh##
test02:
  li a1, 1
  li x1, 0x00000060
  li x2, 0xbeef
  sh x2, 0(x1)
  lh x30, 0(x1)
  li x29, 0xffffbeef
  bne x30, x29, fail

##sb##
test03:
  li a1, 1
  li x1, 0x00000060
  li x2, 0xef
  sb x2, 0(x1)
  lb x30, 0(x1)
  li x29, 0xffffffef
  bne x30, x29, fail

success:
  li a0, 10
  ecall

fail:
  li a0, 17
  ecall