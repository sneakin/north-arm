load-core
" src/lib/case.4th" load
" src/runner/ffi.4th" load
" src/lib/assert.4th" load

(
def test-ffi-callback-cb-0-inner
  hello
  34 return1
end
)
defcol test-ffi-callback-cb-0-inner
  hello .s
  swap drop
  34 rot swap .s ffi-return
  ( a regular return would need to return to an op that pops lr )
endcol

defcol test-ffi-callback-cb-1-inner
  what .s
  swap drop
  34 rot swap .s ffi-return
endcol

create> test-ffi-callback-cb-0
does> do-fficall-0-1
' test-ffi-callback-cb-0-inner 0 ffi-callback
' test-ffi-callback-cb-0 dict-entry-data poke

create> test-ffi-callback-cb-1
does> do-fficall-1-1
' test-ffi-callback-cb-1-inner 1 ffi-callback
' test-ffi-callback-cb-1 dict-entry-data poke

def test-ffi-callback
  12 test-ffi-callback-cb-0 .s
  34 assert-equals
  12 assert-equals

  13 56 test-ffi-callback-cb-1 .s
  34 assert-equals
  13 assert-equals
end
