' alias defined? UNLESS load-core THEN

s[ src/lib/linux.4th
   src/lib/threading/lock.4th
   src/lib/sleepers.4th
   src/lib/assert.4th
] load-list

def test-lock-fn
  arg0 0 seq-peek lock-acquire
  arg0 1 seq-peek arg0 2 seq-peek inc!/2
  arg0 0 seq-peek lock-release
end

def test-lock-usage
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

def test-lock-count
  0
  Lock make-instance set-local0
  local0 lock-locked? assert-not
  local0 lock-acquire
  local0 lock-acquire
  local0 lock-locked? assert
  local0 lock-ours? assert
  local0 Lock -> count @ 2 assert-equals
  local0 lock-release
  local0 lock-locked? assert
  local0 lock-ours? assert
  local0 Lock -> count @ 1 assert-equals
  local0 lock-release
  local0 lock-locked? assert-not
  local0 lock-ours? assert-not
  local0 Lock -> count @ 0 assert-equals
end

def test-lock
  test-lock-usage
  test-lock-count
end
