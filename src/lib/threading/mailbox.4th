struct: Mailbox
pointer<any> field: queue
pointer<any> field: read-lock
pointer<any> field: write-lock

32 var> MAILBOX-SIZE

def init-mailbox
  MAILBOX-SIZE @ make-ring-buffer arg0 Mailbox -> queue !
  PriorityLock make-instance arg0 Mailbox -> read-lock !
  PriorityLock make-instance arg0 Mailbox -> write-lock !
  arg0 exit-frame
end

def make-mailbox
  Mailbox make-instance init-mailbox exit-frame
end

def mailbox-empty?
  arg0 Mailbox -> queue @ ring-buffer-empty? 1 return1-n
end

def mailbox-full?
  arg0 Mailbox -> queue @ ring-buffer-full? 1 return1-n
end

def mailbox-push/3 ( msg timeout mailbox -- true | error false )
  arg1 arg0 Mailbox -> queue @ ring-buffer-wait-for-space/2 IF
    arg0 Mailbox -> write-lock @ priority-lock-acquire
    arg2 arg0 Mailbox -> queue @ ring-buffer-push
    arg0 Mailbox -> write-lock @ priority-lock-release
    IF true 3 return1-n THEN
  THEN false 3 return2-n
end

def mailbox-push
  arg0 -1 set-arg0 ' mailbox-push/3 tail+1
end

def mailbox-pop/2 ( tiweout mailbox -- msg true | error false )
  arg1 arg0 Mailbox -> queue @ ring-buffer-wait-for-msg/2 IF
    arg0 Mailbox -> read-lock @ priority-lock-acquire
    arg0 Mailbox -> queue @ ring-buffer-pop
    arg0 Mailbox -> read-lock @ priority-lock-release
  ELSE false
  THEN 2 return2-n
end

def mailbox-pop
  arg0 -1 set-arg0 ' mailbox-pop/2 tail+1
end
