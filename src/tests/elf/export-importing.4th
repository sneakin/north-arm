' alias defined? [UNLESS] load-core [THEN]
s[ src/lib/assert.4th ] load-list

( todo needs imports for words, variables, and functions that follow our op abi )

library> ./bin/interp.android.3.elf
import> n-init 1 init 3 ( an op )
import> n-ret 1 return-stack 1 ( a variable )
import> n-exec 1 exec-abs 1 ( a word )

' n-ret dict-entry-data @ return-stack assert-equals
' n-init dict-entry-data @ ' init dict-entry-code @ cs + assert-equals
' n-exec dict-entry-data @ ' exec-abs assert-equals
