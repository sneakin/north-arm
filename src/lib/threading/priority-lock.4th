struct: PriorityLock
value field: latch
value field: count

def priority-lock-locked?
  arg0 PriorityLock -> latch @ 0 uint> 1 return1-n
end

def priority-lock-ours?
  arg0 PriorityLock -> latch @ FUTEX_TID_MASK logand
  cached-gettid equals? 1 return1-n
end

def priority-lock-wait-for/2 ( seconds lock -- true | error false )
  arg0 priority-lock-locked? IF
    arg0 priority-lock-ours? UNLESS
      arg1 timeout->abs-timespec value-of arg0 PriorityLock -> latch futex-lock-pi/2
      dup 0 equals? UNLESS false 2 return2-n THEN
      arg0 priority-lock-ours? UNLESS drop-locals repeat-frame THEN
    THEN
  THEN true 2 return1-n
end

def priority-lock-wait-for
  arg0 -1 set-arg0 ' priority-lock-wait-for/2 tail+1
end

def priority-lock-acquire/2 ( timeout lock -- true | error false )
  arg0 priority-lock-ours? IF
    arg0 PriorityLock -> count inc!
  ELSE
    arg1 arg0 priority-lock-wait-for/2 UNLESS false 2 return2-n THEN
    cached-gettid arg0 PriorityLock -> latch !
    1 arg0 PriorityLock -> count !
  THEN true 2 return1-n
end

def priority-lock-acquire
  arg0 -1 set-arg0 ' priority-lock-acquire/2 tail+1
end

def priority-lock-release
  arg0 priority-lock-ours? IF
    arg0 PriorityLock -> count dec! 0 int<= IF
      arg0 PriorityLock -> latch @ FUTEX_WAITERS logand IF
        1 arg0 PriorityLock -> latch futex-unlock-pi
      ELSE
        0 arg0 PriorityLock -> latch !
      THEN
    THEN
  THEN 1 return0-n
end
