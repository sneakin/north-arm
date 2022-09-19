( OS thread tests: )

s[ src/lib/linux/threads.4th
   src/lib/threading/lock.4th
   src/lib/threading/priority-lock.4th
   src/lib/sleepers.4th
   src/lib/assert.4th
] load-list

0 var> test-thread-flag

def test-thread-fn
  debug? IF 0xabcdef hello space getpid gettid .s THEN
  arg0 cdr 1 - test-thread-flag poke ( changes the thread local var )
  5 sleep
  arg0 cdr arg0 car poke ( the real variable gets changed here )
end

false var> *test-thread-sleeper*

def test-thread-start
  0 get-time-secs 0
  here 123 swap cons ' test-thread-fn thread-start assert set-local0
  local0 Thread kind-of? assert
  *test-thread-sleeper* @ IF
    locals cell-size 2 * - 10 sleep-until-true/2 123 assert-equals
  ELSE
    ( 1 sleep )
    local0 thread-wait-to-start assert
    local0 thread-join assert
  THEN
  test-thread-flag @ 0 assert-equals
  local2 123 assert-equals
  get-time-secs local1 - 3 int>= assert
  ( clean up )
  local0 destroy-thread
end

def test-lock-fn
  arg0 0 seq-peek lock-acquire
  arg0 1 seq-peek arg0 2 seq-peek inc!/2
  arg0 0 seq-peek lock-release
end

def test-lock
  0 0 0
  Lock make-instance set-local0
  local0 lock-acquire
  local0 lock-locked? assert
  local0 lock-ours? assert
  ( hold two threads at bay )
  0 1 locals cell-size - local0 here
  ' test-lock-fn thread-start assert set-local2
  0 2 locals cell-size - local0 here
  ' test-lock-fn thread-start assert set-local3
  local1 0 assert-equals
  ( let the thteads run )
  local0 lock-release
  local0 lock-locked? assert-not
  local0 lock-ours? assert-not
  1 sleep
  local1 3 assert-equals
  ( clean up )
  local2 destroy-thread
  local3 destroy-thread
end

def test-priority-lock-fn
  arg0 0 seq-peek priority-lock-acquire
  arg0 1 seq-peek arg0 2 seq-peek inc!/2
  arg0 0 seq-peek priority-lock-release
end

( todo prioritize threads and check the run order )

def test-priority-lock
  0 0 0
  PriorityLock make-instance set-local0
  local0 priority-lock-acquire
  local0 priority-lock-locked? assert
  local0 priority-lock-ours? assert
  ( hold two threads at bay )
  0 1 locals cell-size - local0 here
  ' test-priority-lock-fn thread-start assert set-local2
  0 2 locals cell-size - local0 here
  ' test-priority-lock-fn thread-start assert set-local3
  0 sleep
  local1 0 assert-equals
  local0 PriorityLock -> hole @ FUTEX_WAITERS logand assert
  ( let the thteads run )
  local0 priority-lock-release
  local0 priority-lock-ours? assert-not
  3 sleep
  local1 3 assert-equals
  local0 priority-lock-locked? assert-not
  ( clean up )
  local2 destroy-thread
  local3 destroy-thread
end

( todo test abnormal exit, signals to child )

def test-threads
  test-thread-start
  test-lock
  test-priority-lock
end
