' alias> defined? [UNLESS] load-core [THEN]

s[ src/lib/threading/worker.4th
   src/lib/assert.4th
   src/lib/assertions/time.4th
] load-list

def test-worker-slow-fn arg1 arg0 + dup sleep 2 return1-n end

2 var> TEST-WORKER-TIMEOUT ( the minimum before zeroing )

def test-worker
  ( Starts a worker, queue's two tickets, and collects the results while making assertions along the way. )
  0 0 0 0 0 ( worker mailbox start-time ticket1 ticket2 )
  ( the worker )
  make-worker set-local0
  local0 worker-running? assert-not
  ( a mailbox for replies )
  4 make-mailbox set-local1
  local1 mailbox-empty? assert
  local1 mailbox-full? assert-not
  ( start the worker )
  local0 worker-start
  10 local0 worker-wait-to-start/2 IF
    ( running! queue up two tasks )
    local0 worker-running? assert
    TEST-WORKER-TIMEOUT @ 1 - 3 - 3 ' test-worker-slow-fn 3 local1 local0 worker-enqueue set-local3
    TEST-WORKER-TIMEOUT @ dup 2 / + 5 - 5 ' test-worker-slow-fn 3 local1 local0 worker-enqueue 4 set-localn
    local0 worker-idle? assert-not
    ( first result )
    get-time-secs set-local2
    TEST-WORKER-TIMEOUT @ local1 mailbox-pop/2 IF
      dup WorkerResult -> worker @ local0 assert-equals
      dup WorkerResult -> ticket @ local3 assert-equals
      dup WorkerResult -> data @ seqn-size 1 assert-equals
      dup WorkerResult -> data @ 0 seqn-peek TEST-WORKER-TIMEOUT @ 1 - assert-equals
      drop
    ELSE
      s" No result." error-line/2
      false assert
    THEN
    local2 TEST-WORKER-TIMEOUT @ assert-time-on-under
    ( second? nope! it takes too long. )
    get-time-secs set-local2
    TEST-WORKER-TIMEOUT @ local1 mailbox-pop/2 IF
      s" Second result!" error-line/2
      false assert
    ELSE
      negate ETIMEDOUT assert-equals
    THEN
    local2 TEST-WORKER-TIMEOUT @ assert-time-on-over
    ( this'll get it )
    get-time-secs set-local2
    TEST-WORKER-TIMEOUT @ local1 mailbox-pop/2 IF
      dup WorkerResult -> worker @ local0 assert-equals
      dup WorkerResult -> ticket @ 4 localn assert-equals
      dup WorkerResult -> data @ seqn-size 1 assert-equals
      dup WorkerResult -> data @ 0 seqn-peek TEST-WORKER-TIMEOUT @ dup 2 / + assert-equals      
      drop
    ELSE
      s" No second result." error-line/2
      false assert
    THEN
    local2 TEST-WORKER-TIMEOUT @ assert-time-on-under
  ELSE
    s" Worker failed to start." error-line/2
    dup errno->string error-line .i enl
    local0 print-instance
    local0 Worker -> thread @ print-instance
    false assert
  THEN
  ( cleanup )
  10 local0 destroy-worker/2
  local0 worker-running? assert-not
  local0 Worker -> thread @ Thread -> state @ THREAD-DESTROYED assert-equals
end
