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

( todo test abnormal exit, signals to child )

def test-threads
  test-thread-start
end
