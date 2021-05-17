load-core

s[ src/lib/process.4th
   src/lib/time.4th
   src/lib/assert.4th
] load-list

def test-process-happy
  ( Basic process usage: )
  0 0
  1024 stack-allot set-local1
  ( start up )
  process process-spawn set-local0
  local0 process -> pid peek assert
  1 sleep
  ( sending commands )
  s" hello-s write-line 2 3 3 + + ,i enl " local0 process-write
  2 sleep
  ( reading output )
  local1 1024 local0 process-read
  dup 5 int> assert
  local1 over null-terminate
  local1 " Hello" assert-contains
  ( process status )
  local0 process-wait 0 assert-equals
  ( clean exit and wait )
  s" 3 sysexit " local0 process-write
  local0 process-wait 0x0 assert-equals
  2 sleep
  local0 process-wait 0x300 assert-equals
end

def test-process-kill
  ( Forceful kill )
  0
  process process-spawn set-local0
  1 sleep
  s" hello " local0 process-write
  1 sleep
  local0 process-print
  local0 process-kill
  local0 process-wait 0 assert-equals
  1 sleep
  local0 process-wait 0xF assert-equals
  local0 process-wait 0 assert-equals
end

def test-process-print
  ( Fuller exercise of printing. )
  0
  process process-spawn set-local0
  1 sleep
  s" hello " local0 process-write
  local0 process-print
  s" hello hello words " local0 process-write
  1 sleep
  local0 process-print
  local0 process-kill
  1 sleep
  local0 process-wait 0xF assert-equals
  local0 process-wait 0 assert-equals
end
