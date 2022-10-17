( todo Use atomic compare and exchange ops prior to the futex call. )

struct: Lock
value field: latch
value field: count

def lock-locked? ( lock -- yes? )
  arg0 Lock -> latch @ 0 uint> 1 return1-n
end

def lock-ours? ( lock -- yes? )
  arg0 Lock -> latch @ cached-gettid equals? 1 return1-n
end

def lock-wait-for/2 ( seconds lock -- true | error false )
  arg0 lock-locked? IF
    arg0 lock-ours? UNLESS
      arg1 0 arg0 Lock -> latch futex-wait-for-equals/3
      UNLESS false 2 return2-n THEN
    THEN
  THEN true 2 return1-n
end

def lock-wait-for ( lock -- true | error false )
  arg0 -1 set-arg0 ' lock-wait-for/2 tail+1
end

def lock-acquire/2 ( timeout lock -- true | error false )
  arg0 lock-ours? IF
    arg0 Lock -> count inc!
    true 2 return1-n
  ELSE
    arg1 arg0 lock-wait-for/2 IF
      cached-gettid arg0 Lock -> latch !
      1 arg0 Lock -> count !
      true 2 return1-n
    ELSE false 2 return2-n
    THEN
  THEN
end

def lock-acquire ( lock -- )
  -1 arg0 lock-acquire/2 1 return0-n
end

def lock-release ( lock -- )
  arg0 lock-ours? IF
    arg0 Lock -> count dec! 0 int<= IF
      0 arg0 Lock -> latch !
      1 arg0 Lock -> latch futex-wake
    THEN
  THEN 1 return0-n
end

def lock-release-op ( futex-op value-place lock -- )
  arg0 lock-ours? IF
    arg0 Lock -> count dec! 0 int<= IF
      0 arg0 Lock -> latch !  
      arg2 0x7FFFFFFF arg1 1 arg0 Lock -> latch futex-wake-op
    THEN
  THEN 3 return0-n
end
