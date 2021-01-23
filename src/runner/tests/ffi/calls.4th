load-core
" src/lib/case.4th" load
" src/runner/ffi.4th" load
" src/lib/assert.4th" load
" src/interp/dynlibs.4th" load

library> libc.so
import> cgetpid 1 getpid 0
import> atoi 1 atoi 1
import> puts 0 puts 1
import> fputs 1 fputs 2
import> strcmp 1 strcmp 2
import> strncmp 1 strncmp 3
import> crand 1 rand 0
import> csrand 0 srand 1

( Needs FFI support for floats. )
(
library> libm.so
import> sin sin 1
)

def test-ffi-imports
  ' atoi dict-entry-code peek ' do-fficall-1-1 dict-entry-code peek assert-equals
  ' puts dict-entry-code peek ' do-fficall-1-1 dict-entry-code peek assert-equals
  ' fputs dict-entry-code peek ' do-fficall-2-1 dict-entry-code peek assert-equals
end

def test-ffi-call-libc
  ( no args )
  11
  cgetpid getpid assert-equals
  11 assert-equals

  ( void, 1 arg )
  ( todo return nothing )
  11
  123 csrand
  11 assert-equals

  ( no args )
  11
  crand 0x7afc3a1 assert-equals
  11 assert-equals

  ( 1 arg )
  11
  " 123" atoi 123 assert-equals
  11 assert-equals

  ( 2 args )
  22
  " 123" " 123" strcmp 0 assert-equals
  " 123" " 12" strcmp -1 assert-equals
  " 12" " 123" strcmp 1 assert-equals
  22 assert-equals

  ( 3 args )
  37
  3 " 123" " 123" strncmp 0 assert-equals
  3 " 123" " 12" strncmp -51 assert-equals ( returns unequal char )
  3 " 12" " 123" strncmp 51 assert-equals
  2 " 123" " 12" strncmp 0 assert-equals
  37 assert-equals

  ( todo void returns? >=4 args, mixed with floats? )
end

library> lib/ffi-test-lib.so
import> test-lib-init 1 init_lib 1
import> test-lib-n-args 1 get_n_args 0
import> test-lib-arg-0 1 get_arg_0 0
import> test-lib-reset 0 reset_vars 0
import> test-lib-ffi-test-0-0 0 ffi_test_0_0 0
import> test-lib-ffi-test-0-1 1 ffi_test_0_1 0
import> test-lib-ffi-test-1-0 0 ffi_test_1_0 1
import> test-lib-ffi-cb-0-0 0 ffi_cb_0_0 1
import> test-lib-ffi-cb-1-0 0 ffi_cb_1_0 1
import> test-lib-ffi-cb-2-0 0 ffi_cb_2_0 1
import> test-lib-ffi-cb-0-1 0 ffi_cb_0_1 1
import> test-lib-ffi-cb-1-1 0 ffi_cb_1_1 1

defcol dbg-write-line
  .s
  swap write-line
endcol

defcol test-ffi-cb-0
  s" cb 0" write-line/2 .s print-regs
endcol

defcol test-ffi-cb-0-1
  s" cb 0 1" write-line/2 .s print-regs
  0x56 swap
endcol

defcol test-ffi-cb-1
  s" cb 1" write-line/2 .s swap write-hex-uint nl
endcol

defcol test-ffi-cb-2
  s" cb 2" write-line/2 .s
  swap write-hex-uint nl
  swap write-hex-uint nl
  print-regs
endcol

defcol test-ffi-cb-1-1
  s" cb 1 1" write-line/2 .s swap write-hex-uint nl
  0x55 swap .s
endcol

def test-ffi-ret-callbacks
  s" ffi-ret-callbacks" write-line/2 .s print-regs
  ' test-ffi-cb-1-1 1 1 ffi-callback 10 swap test-lib-ffi-cb-1-1 .s 10 assert-equals
  9 .s test-lib-arg-0 .s 0x55 assert-equals
  9 assert-equals
  ' test-ffi-cb-0-1 0 1 ffi-callback 11 swap .s test-lib-ffi-cb-0-1 11 .s assert-equals
  test-lib-arg-0 0x56 assert-equals
end

def test-ffi-void-callbacks
  s" ffi-void-callbacks" write-line/2 .s print-regs
  ' test-ffi-cb-2 2 0 ffi-callback 10 swap .s test-lib-ffi-cb-2-0 .s 10 assert-equals
  test-lib-arg-0 -2 assert-equals
  ' test-ffi-cb-1 1 0 ffi-callback 11 swap test-lib-ffi-cb-1-0 11 assert-equals
  test-lib-arg-0 -1 assert-equals
  ' test-ffi-cb-0 0 0 ffi-callback 12 swap test-lib-ffi-cb-0-0 12 assert-equals
  10 test-lib-n-args 9 assert-equals 10 assert-equals
end

def test-ffi-call-test-lib
  test-lib-reset
  test-lib-n-args -1 assert-equals
  test-lib-arg-0 -1 assert-equals
  
  test-lib-reset
  11 test-lib-ffi-test-0-0 11 assert-equals
  test-lib-n-args 0 assert-equals
  test-lib-arg-0 0 assert-equals

  test-lib-reset
  11 12 test-lib-ffi-test-1-0 11 assert-equals
  test-lib-n-args 1 assert-equals
  test-lib-arg-0 12 assert-equals

  test-lib-reset
  12 test-lib-ffi-test-0-1 123 assert-equals 12 assert-equals
  test-lib-n-args 0 assert-equals
  test-lib-arg-0 0 assert-equals
end

def test-ffi-call
  test-ffi-imports
  test-ffi-call-libc
  
  ' dbg-write-line 1 0 ffi-callback test-lib-init
  test-ffi-call-test-lib
  test-ffi-ret-callbacks
  test-ffi-void-callbacks
end
