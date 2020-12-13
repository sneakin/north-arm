load-core
" src/lib/case.4th" load
" src/runner/ffi.4th" load
" src/lib/assert.4th" load

defcol test-ffi-callback-cb-0-inner
  what .s
endcol

defcol test-ffi-callback-cb-1-inner
  what .s
  swap drop
  34 swap .s ( ffi-return )
endcol

create> test-ffi-callback-cb-0
does> do-fficall-0-1
' test-ffi-callback-cb-0-inner 0 0 ffi-callback
dict dict-entry-data poke

create> test-ffi-callback-cb-1
does> do-fficall-1-1
' test-ffi-callback-cb-1-inner 1 0 ffi-callback
dict dict-entry-data poke

( todo need ffi-callback with number of returns )

def test-ffi-callback
  12 test-ffi-callback-cb-0 .s
  12 assert-equals

  13 56 test-ffi-callback-cb-1 .s
  34 assert-equals
  13 assert-equals
end
