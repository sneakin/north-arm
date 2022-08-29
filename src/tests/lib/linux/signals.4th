load-core
" src/lib/linux/signals/constants.4th" load
" src/lib/linux/signals/types.4th" load
" src/lib/case.4th" load
" src/lib/assert.4th" load

0 var> test-signals-flag

defcol test-signal-usr1
  over test-signals-flag poke
  s" Caught signal " error-string/2
  over error-hex-uint enl
  s" From frame: " error-string/2
  current-frame write-hex-uint nl (  cell-size 4 * - 64 ememdump )
  s" Signal stack: " error-string/2
  here here 64 ememdump drop
  ( drop args, keep return addresses )
  3 set-overn 2 dropn
  what dump-stack
  ( ffi-return )
endcol

def test-signals
  0 0 0
  ( trap USR1 )
  make-sigaction set-local0
  make-sigaction set-local1
  ' test-signal-usr1 3 0 ffi-callback local0 sa-handler poke
  SA-SIGINFO local0 sa-flags poke
  local1 local0 SIGALRM sigaction
  0 assert-equals
  local1 local0 SIGUSR1 sigaction
  0 assert-equals
  ( check handler was changed )
  make-sigaction set-local2
  local2 0 SIGUSR1 sigaction
  0 assert-equals
  local2 sa-handler peek local0 sa-handler peek assert-equals
  local2 sa-flags peek SA-SIGINFO assert-equals
  ( send USR1 )
  123 SIGUSR1 getpid
  here here 64 ememdump drop
  kill 0 assert-equals
  123 assert-equals
  ( check result )
  test-signals-flag peek SIGUSR1 assert-equals
  ( restore trap )
  0 local1 SIGUSR1 sigaction
  0 assert-equals
  ( assert the change )
  local2 0 SIGUSR1 sigaction
  0 assert-equals
  local2 sa-handler peek local1 sa-handler peek assert-equals
  local2 sa-flags peek local1 sa-flags peek assert-equals
end
