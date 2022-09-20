( todo Use atomic compare and exchange ops prior to the futex call. )

struct: Lock
value field: hole

def lock-locked? ( lock -- yes? )
  arg0 Lock -> hole @ 0 uint> 1 return1-n
end

def lock-ours? ( lock -- yes? )
  arg0 Lock -> hole @ cached-gettid equals? 1 return1-n
end

def lock-wait-for/2 ( seconds lock -- true | error false )
  arg0 lock-locked? IF
    arg1 secs->timespec value-of arg0 Lock -> hole futex-wait/2
    dup 0 equals? IF
      arg0 Lock -> hole @ IF drop-locals repeat-frame THEN
      true 2 return1-n
    ELSE false 2 return2-n
    THEN
  ELSE true 2 return1-n
  THEN
end

def lock-wait-for ( lock -- true | error false )
  arg0 -1 set-arg0 ' lock-wait-for/2 tail+1
end

def lock-acquire ( lock -- )
  arg0 lock-wait-for IF
    cached-gettid arg0 Lock -> hole !
  THEN 1 return0-n
end

def lock-release ( lock -- )
  arg0 lock-ours? IF
    0 arg0 Lock -> hole !
    1 arg0 Lock -> hole futex-wake
  THEN 1 return0-n
end
