s[ src/lib/assert.4th ] load-list

def assert-dict-entry ( entry link data code-word name length -- )
  5 argn dict-entry-name @ cs + arg1 arg0 assert-byte-string-equals/3
  5 argn dict-entry-code @ arg2 dict-entry-code @ assert-equals
  5 argn dict-entry-data @ arg3 assert-equals
  5 argn dict-entry-link @ cs + 4 argn assert-equals
  6 return0-n
end

def test-inplace-var>
  dict
  s" 1234 inplace-var> test-var-1" load-string/2
  ( adds a dictionary entry )
  dict local0 1234 ' do-inplace-var s" test-var-1" assert-dict-entry
  ( returns its data field's address )
  dict exec-abs dict dict-entry-data assert-equals
  ( drop dict )
  local0 set-dict
end

def test-data-var>
  dict
  s" 1234 data-var> test-var-1" load-string/2
  ( adds a dictionary entry )
  dict local0 over dict-entry-data @ ' do-data-var s" test-var-1" assert-dict-entry
  ( data is a pair of slot and initial value from the  ToS )
  dict dict-entry-data @ cs +
  dup 0 seq-peek *next-data-var-slot* @ assert-equals
  1 seq-peek 1234 assert-equals
  ( returns its address in the data segment )
  dict exec-abs
  dict dict-entry-data @ cs + 0 seq-peek ds-slot
  assert-equals
  ( drop dict )
  local0 set-dict
end

def test-var
  test-inplace-var>
  test-data-var>
end
