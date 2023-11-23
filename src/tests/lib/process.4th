' alias [UNLESS] load-core [THEN]

s[ src/lib/linux/errno.4th
   src/lib/process.4th
   src/lib/time.4th
   src/lib/linux/clock.4th
   src/lib/assert.4th
] load-list

( todo capture stderr too. explains the prompts. )
( todo sigchld handler )

def test-process-happy
  ( Basic process usage: )
  0 0
  1024 stack-allot set-local1
  ( start up )
  process-spawn-interp set-local0
  local0 process -> pid peek assert
  1 sleep
  ( sending commands )
  s" hello-s write-line 2 3 3 + + write-int nl " local0 process-write
  2 sleep
  ( reading output )
  local1 1024 local0 process-read
  dup 5 int> assert
  local1 over null-terminate
  local1 " Hello" assert-contains
  local1 " 8" assert-contains
  ( process status )
  local0 process-check-status 0 assert-equals
  ( clean exit and wait )
  s" 3 sysexit " local0 process-write
  local0 process-wait wexitstatus 3 assert-equals
  2 sleep
  local0 process-wait ECHILD negate assert-equals
end

def test-process-term
  ( Forceful termination )
  0
  process-spawn-interp set-local0
  1 sleep
  s" hello " local0 process-write
  1 sleep
  local0 process-check-status 0 assert-equals
  local0 process-term 0 int>= assert 
  local0 process-wait wtermsig SIGTERM assert-equals
  1 sleep
  local0 process-check-status ECHILD negate assert-equals
  local0 process-wait ECHILD negate assert-equals
end

def test-process-kill
  ( Forceful kill )
  0
  process-spawn-interp set-local0
  1 sleep
  s" hello " local0 process-write
  1 sleep
  local0 process-check-status 0 assert-equals
  local0 process-kill 0 int>= assert 
  local0 process-wait wtermsig SIGKILL assert-equals
  1 sleep
  local0 process-check-status ECHILD negate assert-equals
  local0 process-wait ECHILD negate assert-equals
end

def test-process-print
  ( Fuller exercise of printing. )
  0
  process-spawn-interp set-local0
  1 sleep
  s" hello space parent-input peek write-int space parent-output peek write-int space " local0 process-write
  local0 process-print
  s" hello hello words " local0 process-write
  1 sleep
  local0 process-print
  local0 process-term 0 int>= assert
  local0 process-check-status 0 assert-equals
  1 sleep
  local0 process-wait wtermsig SIGTERM assert-equals
  local0 process-wait ECHILD negate assert-equals
end

def test-process-cmd-happy
  ( Basic process usage: )
  0 0
  1024 stack-allot set-local1
  ( start up )
  " cat" process-spawn-cmd set-local0
  local0 process -> pid peek assert
  1 sleep
  ( sending commands )
  s" hello!
" local0 process-write
  2 sleep
  ( reading output )
  local1 1024 local0 process-read
  dup 5 int> assert
  local1 over null-terminate
  local1 " hello!" assert-contains
  ( process status )
  local0 process-check-status 0 assert-equals
  ( clean exit and wait ) ( fixme how to get cat to notice the closed pipe? )
  local0 process-close
  local0 process-check-status 0 assert-equals
  local0 process-term 0 int>= assert
  local0 process-wait wtermsig SIGTERM assert-equals
end

def test-process-cmd-not-found
  ( Basic process usage: )
  0
  ( start up )
  " not-gonna" process-spawn-cmd set-local0
  local0 process-wait 0x7F00 assert-equals
end

def test-process
  test-process-happy
  test-process-term
  test-process-kill
  test-process-print
  test-process-cmd-happy
  test-process-cmd-not-found
end
