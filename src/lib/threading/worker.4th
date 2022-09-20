s[ src/lib/threading/lock.4th
   src/lib/threading/priority-lock.4th
   src/lib/ring-buffer.4th
   src/lib/threading/mailbox.4th
] load-list

( todo preallocate results and requests? the enqueing thread could drop the stack before the worker gets to it, or vice versa with the results. Though zero copy [there is one to the thread stack] is nice. )

( todo error handling? supervision that'll restart? )

struct: Worker
pointer<any> field: thread
pointer<any> field: input
       value field: busy

struct: WorkerTicket
pointer<any> field: return-box
       value field: size
pointer<any> field: words

struct: WorkerResult
pointer<any> field: worker
pointer<any> field: ticket
pointer<any> field: data

def init-worker
  make-mailbox arg0 Worker -> input !
  arg0 exit-frame
end

def make-worker
  Worker make-instance init-worker exit-frame
end

def worker-running?
  arg0 Worker -> thread @
  dup IF thread-alive? ELSE false THEN 1 return1-n
end

def worker-idle?
  arg0 Worker -> input @
  dup IF mailbox-empty? ELSE false THEN 1 return1-n
end

def worker-wait-to-start/2
  arg1 arg0 Worker -> thread @ thread-wait-to-start/2
  IF true 2 return1-n ELSE false 2 return2-n THEN
end

def worker-wait-to-start
  arg0 -1 set-arg0 ' worker-wait-to-start/2 tail+1
end

def worker-enqueue-ticket
  arg1 arg0 Worker -> input @ mailbox-push
  arg0 2 return1-n
end

def worker-enqueue ( ...args word num-args+1 mbox worker ++ ticket )
  WorkerTicket make-instance
  args cell-size 3 * + over WorkerTicket -> words !
  arg2 over WorkerTicket -> size !
  arg1 over WorkerTicket -> return-box !
  dup arg0 worker-enqueue-ticket swap exit-frame
end

def worker-reply ( result-seqn ticket worker ++ )
  arg1 WorkerTicket -> return-box @ IF
    WorkerResult make-instance
    arg2 over WorkerResult -> data !
    arg1 over WorkerResult -> ticket !
    arg0 over WorkerResult -> worker !
    arg1 WorkerTicket -> return-box @ mailbox-push
    arg0 exit-frame
  ELSE arg0 3 return1-n
  THEN
end

def worker-exec ( ticket worker ++ )
  debug? IF s" Worker exec: " error-string/2 arg1 print-instance drop THEN
  arg1 WorkerTicket -> size @ cell-size * stack-allot
  arg1 WorkerTicket -> words @ swap arg1 WorkerTicket -> size @ cell-size * copy
  debug? IF s" Executing: " error-string/2 dump-stack THEN
  exec-abs locals here - cell/ here
  arg1 arg0 worker-reply exit-frame
end

def worker-fn
  debug? IF s" Worker waiting " error-string/2 gettid .i enl THEN
  false arg0 Worker -> busy !
  arg0 Worker -> input @ mailbox-pop IF
    true arg0 Worker -> busy !
    arg0 worker-exec repeat-frame
  THEN
end

def thread-startable?
  arg0 Thread -> state @ THREAD-INITIATED equals?
  arg0 Thread -> state @ THREAD-EXITED equals? or
  1 return1-n
end

def worker-start
  arg0 Worker -> thread @
  local0 IF
    local0 thread-startable? IF
      arg0 ' worker-fn local0 thread-start/3
      arg0 true exit-frame
    THEN
  THEN drop
  arg0 ' worker-fn thread-start IF
    arg0 Worker -> thread !
    arg0 true exit-frame
  ELSE false return1
  THEN
end

def worker-stop
  arg0 worker-running? IF
    ' bye 1 0 arg0 worker-enqueue
    true exit-frame
  ELSE false 1 return1-n
  THEN
end

def destroy-worker/2 ( timeout worker -- )
  arg0 worker-stop IF
    arg1 arg0 Worker -> thread @ thread-join/2
  THEN
  arg0 Worker -> thread @ destroy-thread
  2 return0-n
end
