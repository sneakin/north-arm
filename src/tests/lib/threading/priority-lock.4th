s[ src/lib/linux/threads.4th
   src/lib/threading/priority-lock.4th
   src/lib/sleepers.4th
   src/lib/assert.4th
] load-list

def test-priority-lock-fn
  arg0 0 seq-peek priority-lock-acquire
  arg0 1 seq-peek arg0 2 seq-peek inc!/2
  arg0 0 seq-peek priority-lock-release
end

( todo prioritize threads and check the run order )

def test-priority-lock-usage
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
  local0 PriorityLock -> latch @ FUTEX_WAITERS logand assert
  ( let the threads run )
  local0 priority-lock-release
  local0 priority-lock-ours? assert-not
  3 sleep
  local1 3 assert-equals
  local0 priority-lock-locked? assert-not
  ( clean up )
  local2 destroy-thread
  local3 destroy-thread
end

def test-priority-lock-count
  0
  PriorityLock make-instance set-local0
  local0 priority-lock-acquire
  local0 priority-lock-locked? assert
  local0 priority-lock-ours? assert
  local0 PriorityLock -> count @ 1 assert-equals
  local0 priority-lock-acquire
  local0 priority-lock-locked? assert
  local0 priority-lock-ours? assert
  local0 PriorityLock -> count @ 2 assert-equals
  ( Releases )
  local0 priority-lock-release
  local0 priority-lock-locked? assert
  local0 priority-lock-ours? assert
  local0 PriorityLock -> count @ 1 assert-equals
  local0 priority-lock-release
  local0 priority-lock-locked? assert-not
  local0 priority-lock-ours? assert-not
  local0 PriorityLock -> count @ 0 assert-equals
end

def test-priority-lock
  test-priority-lock-usage
  test-priority-lock-count
end
