( A thread safe bit mask with functions to wait for specific
  bits and exclusive access. )
struct: BitMaskBarrier
pointer<any> field: lock
int field: bits

def make-bit-mask-barrier
  BitMaskBarrier make-instance set-local0
  Lock make-instance local0 BitMaskBarrier -> lock !
  local0 exit-frame
end

def bit-mask-barrier-bits
  arg0 BitMaskBarrier -> lock @ lock-acquire
  arg0 BitMaskBarrier -> bits @
  arg0 BitMaskBarrier -> lock @ lock-release
  1 return1-n
end

def bit-mask-barrier-set ( bit barrier -- )
  arg0 BitMaskBarrier -> lock @ lock-acquire
(
  arg0 BitMaskBarrier -> bits @ 0 int< IF 0 FUTEX_OP_CMP_LE ELSE 0 FUTEX_OP_CMP_GE THEN
  arg1 FUTEX_OP_OR FUTEX_OP_OPARG_SHIFT logior
  futex-op
  arg0 BitMaskBarrier -> bits
  arg0 BitMaskBarrier -> lock @ lock-release-op
)
  arg0 BitMaskBarrier -> bits
  dup @ 1 arg1 bsl logior swap !
  arg0 BitMaskBarrier -> lock @ lock-release
  0x7FFFFFFF arg0 BitMaskBarrier -> bits futex-wake
  2 return0-n
end

def bit-mask-barrier-clear ( bit barrier -- )
  arg0 BitMaskBarrier -> lock @ lock-acquire
  (
arg0 BitMaskBarrier -> bits @ 0 int< IF 0 FUTEX_OP_CMP_LE ELSE 0 FUTEX_OP_CMP_GE THEN
  arg1 FUTEX_OP_ANDN FUTEX_OP_OPARG_SHIFT logior
  futex-op
  arg0 BitMaskBarrier -> bits
  arg0 BitMaskBarrier -> lock @ lock-release-op
)
  arg0 BitMaskBarrier -> bits
  dup @ 1 arg1 bsl lognot logand swap !
  arg0 BitMaskBarrier -> lock @ lock-release
  0x7FFFFFFF arg0 BitMaskBarrier -> bits futex-wake
  2 return0-n
end

def masked-value
  arg1 0 equals?
  IF arg0 0 equals?
  ELSE arg0 arg1 logand
  THEN 2 return1-n
end

def bit-mask-barrier-wait-for ( timeout value barrier -- true | error false )
  ' masked-value arg1 partial-first
  arg2 arg0 BitMaskBarrier -> bits futex-wait-for-fun/3
  IF true 3 return1-n ELSE false 3 return2-n THEN
end

def bit-mask-barrier-wait-for-equals ( timeout value barrier -- true | error false )
  arg2 arg1 arg0 BitMaskBarrier -> bits futex-wait-for-equals/3
  IF true 3 return1-n ELSE false 3 return2-n THEN
end

def bit-mask-barrier-wait-to-zero ( timeout barrier -- true | error false )
  arg1 0 arg0 bit-mask-barrier-wait-for
  IF true 2 return1-n ELSE false 2 return2-n THEN
end
