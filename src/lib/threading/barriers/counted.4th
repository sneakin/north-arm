( A thread safe counter with functions to wait for values and
  exclusive access. )
struct: CountedBarrier
pointer<any> field: lock ( fixme could use Lock instead of pointer, but the accessor provides no type cons )
int field: count

def make-counted-barrier
  CountedBarrier make-instance set-local0
  Lock make-instance local0 CountedBarrier -> lock !
  local0 exit-frame
end

def counted-barrier-inc ( barrier -- )
  arg0 CountedBarrier -> lock @ lock-acquire
  arg0 CountedBarrier -> count inc!
  arg0 CountedBarrier -> lock @ lock-release
  0x7FFFFFFF arg0 CountedBarrier -> count futex-wake
(
  0
  arg0 CountedBarrier -> count @ IF FUTEX_OP_CMP_NE ELSE FUTEX_OP_CMP_EQ THEN
  1 FUTEX_OP_ADD futex-op
  arg0 CountedBarrier -> count
  arg0 CountedBarrier -> lock @ lock-release-op
)
  1 return0-n
end

def counted-barrier-dec ( barrier -- )
  arg0 CountedBarrier -> lock @ lock-acquire
  arg0 CountedBarrier -> count dec!
  arg0 CountedBarrier -> lock @ lock-release
  0x7FFFFFFF arg0 CountedBarrier -> count futex-wake
( fails to trigger on negative numbers )
(
  0
  arg0 CountedBarrier -> count @ IF FUTEX_OP_CMP_NE ELSE FUTEX_OP_CMP_EQ THEN
  -1 FUTEX_OP_ADD futex-op
  arg0 CountedBarrier -> count
  arg0 CountedBarrier -> lock @ lock-release-op
)
  1 return0-n
end

def counted-barrier-wait-for ( timeout value barrier -- true | error false )
  arg2 arg1 arg0 CountedBarrier -> count futex-wait-for-equals/3
  IF true 3 return1-n ELSE false 3 return2-n THEN
end

def counted-barrier-wait-to-zero ( timeout barrier -- true | error false )
  arg1 0 arg0 counted-barrier-wait-for
  IF true 2 return1-n ELSE false 2 return2-n THEN
end
