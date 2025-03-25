DEFINED? alias UNLESS load-core THEN
s[ src/lib/assert.4th ] load-list

( todo needs imports for functions that follow our op abi )

0 get-argv dup string-length library/2
dup IF
import> n-init 1 init 3 ( an op )
import-value> n-exec-addr exec-abs
import-value> n-op-size-val op-size
import-const> n-op-size op-size
import-var> n-ret return-stack ( a variable )
import-word> n-exec exec-abs ( a word )

' n-init dict-entry-data @ ' init dict-entry-code @ cs + assert-equals

' n-exec-addr dict-entry-code @ ' do-const dict-entry-code @ assert-equals
' n-exec-addr dict-entry-data @ ' exec-abs assert-equals
n-exec-addr ' exec-abs assert-equals

n-op-size op-size assert-equals

' n-ret dict-entry-code @ ' do-indirect-var dict-entry-code @ assert-equals
' n-ret dict-entry-data @ return-stack assert-equals
n-ret return-stack assert-equals

' n-exec dict-entry-code @ ' exec-abs dict-entry-code @ assert-equals
' n-exec dict-entry-data @ ' exec-abs dict-entry-data @ assert-equals
ELSE
  s" Failed to open the executable." error-line/2
THEN

library> ./lib/ffi-test-lib.so
dup IF
import-var> n-test-var n_test_var
import-const> n-test-const n_test_var
import-value> n-test-val n_test_var

n-test-var @ 0x1234 assert-equals
n-test-const 0x1234 assert-equals
n-test-value ' n-test-const dict-entry-data @ assert-equals
ELSE
s" Skipping ffi-test-lib linking" error-line/2
THEN
