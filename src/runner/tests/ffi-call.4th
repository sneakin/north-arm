load-core
" src/lib/case.4th" load
" src/runner/ffi.4th" load
" src/lib/assert.4th" load
" src/interp/dynlibs.4th" load

library> libc.so
import> cgetpid getpid 0
import> atoi atoi 1
import> puts puts 1
import> fputs fputs 2
import> strcmp strcmp 2
import> strncmp strncmp 3

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

def test-ffi-call
  ( no args )
  11
  cgetpid getpid assert-equals
  11 assert-equals

  ( 1 args )
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
