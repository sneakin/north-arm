' lock-acquire/2 defined? UNLESS
  s[ src/lib/threading/lock.4th ] load-list
THEN

struct: TtyDoubleBuffer
pointer<any> field: front
pointer<any> field: back
pointer<any> field: lock

def make-tty-double-buffer ( rows cols ++ double-buffer )
  0 TtyDoubleBuffer make-instance set-local0
  arg1 arg0 make-tty-buffer local0 TtyDoubleBuffer -> front !
  arg1 arg0 make-tty-buffer local0 TtyDoubleBuffer -> back !
  ( PriorityLock make-instance local0 TtyDoubleBuffer -> lock ! )
  Lock make-instance local0 TtyDoubleBuffer -> lock !
  local0 exit-frame
end

def tty-double-buffer-get ( double-buffer -- buffer )
  arg0 TtyDoubleBuffer -> back @ 1 return1-n
end

def tty-double-buffer-lock/2 ( timeout double-buffer -- true | error false )
  arg1 arg0 TtyDoubleBuffer -> lock @ lock-acquire/2
  IF true 2 return1-n ELSE false 2 return2-n THEN
end

def tty-double-buffer-lock ( double-buffer -- true | error false )
  arg0 -1 set-arg0 ' tty-double-buffer-lock/2 tail+1
end

def tty-double-buffer-unlock ( double-buffer -- )
  arg0 TtyDoubleBuffer -> lock @ lock-release
  1 return0-n
end

def tty-double-buffer-do-swap ( double-buffer -- old-front )
  arg0 TtyDoubleBuffer -> front @ dup
  arg0 TtyDoubleBuffer -> back @
  arg0 TtyDoubleBuffer -> front !
  arg0 TtyDoubleBuffer -> back !
  1 return1-n
end

def tty-double-buffer-swap/2 ( timeout double-buffer -- old-front )
  arg1 arg0 tty-double-buffer-lock/2 IF
    arg0 tty-double-buffer-do-swap
    arg0 tty-double-buffer-unlock
    true
  ELSE false
  THEN 2 return2-n
end

def tty-double-buffer-swap ( double-buffer -- old-front )
  arg0 -1 set-arg0 ' tty-double-buffer-swap/2 tail+1
end
