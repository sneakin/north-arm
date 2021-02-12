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
  0x34 swap .s ( ffi-return )
endcol

create> test-ffi-callback-cb-0
does> do-fficall-0-0
' test-ffi-callback-cb-0-inner 0 0 ffi-callback
dict dict-entry-data poke

create> test-ffi-callback-cb-1
does> do-fficall-1-1
' test-ffi-callback-cb-1-inner 1 1 ffi-callback
dict dict-entry-data poke

( todo need ffi-callback with number of returns )

def test-ffi-callback
  12 test-ffi-callback-cb-0
  12 assert-equals

  0x13 0x56 test-ffi-callback-cb-1
  0x34 assert-equals
  0x13 assert-equals
end
