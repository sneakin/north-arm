( OS thread tests: )

s[ src/lib/linux/process.4th
   src/lib/linux/mmap.4th
   src/lib/linux/threads.4th
   src/lib/sleepers.4th
   src/lib/assert.4th
] load-list

0 var> test-thread-flag

def test-thread-fn
  debug? IF 0xabcdef hello space getpid gettid .s THEN
  true test-thread-flag poke
end

def test-thread-start
  0
  ' test-thread-fn thread-start set-local0
  local0 0 int> assert
  test-thread-flag 10 sleep-until-true/2 true assert-equals
  ( todo cleanup )
end

( todo test abnormal exit, signals to child )
