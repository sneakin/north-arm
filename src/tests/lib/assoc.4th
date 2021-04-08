tmp" src/lib/fun.4th" load/2
tmp" src/lib/assoc.4th" load/2
tmp" src/lib/assert.4th" load/2

def test-compose-1
  0
  ' string-equals?/3 3 partial-first " hey" partial-first
  ' car swap compose set-local0
  3 " hey" cons local0 exec-abs assert
  3 " what" cons local0 exec-abs not assert
end

def test-assoc
  0
  0x45 4 cons locals push-onto
  0x55 5 cons locals push-onto
  0x66 6 cons locals push-onto
  ( last item )
  local0 4 ' equals? assoc
  dup assert
  dup car 4 assert-equals
  dup cdr 0x45 assert-equals
  ( first item )
  local0 6 ' equals? assoc
  dup assert
  dup car 6 assert-equals
  dup cdr 0x66 assert-equals
  ( no item )
  local0 10 ' equals? assoc
  dup not assert
  ( different key fn )
  ' equals? 0x55 partial-first
  local0 over ' cdr assoc-fn/3
  dup assert
  dup car 5 assert-equals
  dup cdr 0x55 assert-equals
end

def test-assoc-string
  0
  0x4 " four" cons locals push-onto
  0x5 " five" cons locals push-onto
  0x6 " six" cons locals push-onto
  ( last item )
  s" four" local0 assoc-string-2
  dup assert
  dup car s" four" assert-byte-string-equals/3 3 dropn
  dup cdr 4 assert-equals
  ( first item )
  s" six" local0 assoc-string-2
  dup assert
  dup car s" six" assert-byte-string-equals/3 3 dropn
  dup cdr 6 assert-equals
  ( no item )
  " three" local0 assoc-string-2
  dup not assert
  ( different key fn )
  ' equals? 4 partial-first
  local0 over ' cdr assoc-fn/3
  dup assert
  dup car s" four" assert-byte-string-equals/3 3 dropn
  dup cdr 4 assert-equals
end
