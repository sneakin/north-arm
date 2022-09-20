struct: PriorityLock
inherits: Lock

def priority-lock-locked?
  arg0 PriorityLock -> hole @ 0 uint> 1 return1-n
end

def priority-lock-ours?
  arg0 PriorityLock -> hole @ FUTEX_TID_MASK logand
  cached-gettid equals? 1 return1-n
end

def priority-lock-wait-for/2 ( seconds lock -- true | error false )
  arg0 priority-lock-locked? not
  arg0 priority-lock-ours? or
  IF true 2 return1-n
  ELSE
    arg1 timeout->abs-timespec value-of arg0 PriorityLock -> hole futex-lock-pi/2
    dup 0 equals? IF
      arg0 priority-lock-ours? UNLESS drop-locals repeat-frame THEN
      true 2 return1-n
    ELSE false 2 return2-n
    THEN
  THEN
end

def priority-lock-wait-for
  arg0 -1 set-arg0 ' priority-lock-wait-for/2 tail+1
end

def priority-lock-acquire
  arg0 priority-lock-wait-for IF
    cached-gettid arg0 PriorityLock -> hole !
  THEN 1 return0-n
end

def priority-lock-release
  arg0 priority-lock-ours? IF
    arg0 PriorityLock -> hole @ FUTEX_WAITERS logand IF
      1 arg0 PriorityLock -> hole futex-unlock-pi
    ELSE
      0 arg0 PriorityLock -> hole !
    THEN
  THEN 1 return0-n
end
