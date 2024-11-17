0 const> FUTEX_WAIT
1 const> FUTEX_WAKE
2 const> FUTEX_FD
3 const> FUTEX_REQUEUE
4 const> FUTEX_CMP_REQUEUE
5 const> FUTEX_WAKE_OP
6 const> FUTEX_LOCK_PI
7 const> FUTEX_UNLOCK_PI
8 const> FUTEX_TRYLOCK_PI
9 const> FUTEX_WAIT_BITSET
10 const> FUTEX_WAKE_BITSET
11 const> FUTEX_WAIT_REQUEUE_PI
12 const> FUTEX_CMP_REQUEUE_PI
13 const> FUTEX_LOCK_PI2
128 const> FUTEX_PRIVATE_FLAG
256 const> FUTEX_CLOCK_REALTIME

FUTEX_PRIVATE_FLAG FUTEX_CLOCK_REALTIME logior lognot const> FUTEX_CMD_MASK
FUTEX_WAIT FUTEX_PRIVATE_FLAG logior const> FUTEX_WAIT_PRIVATE
FUTEX_WAKE FUTEX_PRIVATE_FLAG logior const> FUTEX_WAKE_PRIVATE
FUTEX_REQUEUE FUTEX_PRIVATE_FLAG logior const> FUTEX_REQUEUE_PRIVATE
FUTEX_CMP_REQUEUE FUTEX_PRIVATE_FLAG logior const> FUTEX_CMP_REQUEUE_PRIVATE
FUTEX_WAKE_OP FUTEX_PRIVATE_FLAG logior const> FUTEX_WAKE_OP_PRIVATE
FUTEX_LOCK_PI FUTEX_PRIVATE_FLAG logior const> FUTEX_LOCK_PI_PRIVATE
FUTEX_LOCK_PI2 FUTEX_PRIVATE_FLAG logior const> FUTEX_LOCK_PI2_PRIVATE
FUTEX_UNLOCK_PI FUTEX_PRIVATE_FLAG logior const> FUTEX_UNLOCK_PI_PRIVATE
FUTEX_TRYLOCK_PI FUTEX_PRIVATE_FLAG logior const> FUTEX_TRYLOCK_PI_PRIVATE
FUTEX_WAIT_BITSET FUTEX_PRIVATE_FLAG logior const> FUTEX_WAIT_BITSET_PRIVATE
FUTEX_WAKE_BITSET FUTEX_PRIVATE_FLAG logior const> FUTEX_WAKE_BITSET_PRIVATE
FUTEX_WAIT_REQUEUE_PI FUTEX_PRIVATE_FLAG logior const> FUTEX_WAIT_REQUEUE_PI_PRIVATE
FUTEX_CMP_REQUEUE_PI FUTEX_PRIVATE_FLAG logior const> FUTEX_CMP_REQUEUE_PI_PRIVATE

0x80000000 const> FUTEX_WAITERS
0x40000000 const> FUTEX_OWNER_DIED
0x3fffffff const> FUTEX_TID_MASK
2048 const> ROBUST_LIST_LIMIT
0xffffffff const> FUTEX_BITSET_MATCH_ANY
0 const> FUTEX_OP_SET
1 const> FUTEX_OP_ADD
2 const> FUTEX_OP_OR
3 const> FUTEX_OP_ANDN
4 const> FUTEX_OP_XOR
8 const> FUTEX_OP_OPARG_SHIFT
0 const> FUTEX_OP_CMP_EQ
1 const> FUTEX_OP_CMP_NE
2 const> FUTEX_OP_CMP_LT
3 const> FUTEX_OP_CMP_LE
4 const> FUTEX_OP_CMP_GT
5 const> FUTEX_OP_CMP_GE

' futex defined? UNLESS
  def futex ( val3 uaddr2 utime val op uaddr -- result )
    args 6 0xf0 syscall 6 return1-n
  end
end

def futex-op ( cmp-arg cmp op-arg op ++ futex-op )
  arg0 0xf logand 28 bsl
  arg2 0xf logand 24 bsl logior
  arg1 0xfff logand 12 bsl logior
  arg3 0xfff logand logior
  4 return1-n
end


def futex-wait/3 ( timespec value where -- result )
  0 0 arg2 arg1 FUTEX_WAIT arg0 futex
  3 return1-n
end

def futex-wait/2 ( timespec where -- result )
  arg1 arg0 peek arg0 futex-wait/3 2 return1-n
end

def futex-wake ( num-to-wake where -- result )
  0 0 0 arg1 FUTEX_WAKE arg0 futex
  2 return1-n
end

def futex-wake-op ( op num-to-wake-2 where-2 num-to-wake where -- result )
  4 argn arg2 arg3 arg1 FUTEX_WAKE_OP arg0 futex
  5 return1-n
end

def futex-lock-pi/3 ( timespec value where -- result )
  0 0 arg2 arg1 FUTEX_LOCK_PI arg0 futex
  3 return1-n
end
  
def futex-lock-pi/2 ( timespec where -- result )
  arg1 arg0 peek arg0 futex-lock-pi/3
  2 return1-n
end
  
def futex-unlock-pi ( num-to-wake where -- result )
  0 0 0 arg1 FUTEX_UNLOCK_PI arg0 futex
  2 return1-n
end

def futex-wait-bitset ( timespec bit-mask value where -- result )
  arg2 0 arg3 arg1 FUTEX_WAIT_BITSET arg0 futex
  4 return1-n
end

def futex-wake-bitset ( bit-mask num-to-wake where -- result )
  arg2 0 0 arg1 FUTEX_WAKE_BITSET arg0 futex
  3 return1-n
end

def futex-wait-for-fun/3 ( fn timeout where -- true | error false )
  get-time-secs
  arg0 @ arg2 exec-abs IF true 3 return1-n THEN
  arg1 secs->timespec value-of arg0 futex-wait/2
  dup 0 equals? IF
    arg0 @ arg2 exec-abs IF true 3 return1-n THEN
    arg1 0 int> IF
      get-time-secs local0 - dup arg1 int>=
      IF ETIMEDOUT false 2 return2-n
      ELSE arg1 swap - set-arg1
      THEN
    THEN drop-locals repeat-frame
  ELSE
    dup ETIMEDOUT equals? IF
      get-time-secs local0 - dup arg1 int<
      IF arg1 swap - set-arg1 drop-locals repeat-frame THEN
    THEN false 3 return2-n
  THEN
end

def futex-wait-for-equals/3 ( timeout value where -- true | error false )
  ' equals? arg1 partial-first
  arg2 arg0 futex-wait-for-fun/3
  IF true 3 return1-n ELSE false 3 return2-n THEN
end
