DEFINED? require UNLESS
  s[ src/interp/require.4th ] load-list
THEN

require[ assert ]

def test-find-file
  s" find-file" error-line/2
  0 128 stack-allot set-local0
  *load-paths* @ as-code-pointer s" ." assert-list-has-string
  *load-paths* @ as-code-pointer s" src/lib" assert-list-has-string
  *north-file-exts* @ as-code-pointer s" .4th" assert-list-has-string
  
  local0 128 s" README.org" *load-paths* @ *north-file-exts* @ find-file/6
  assert
  s" ./README.org" assert-byte-string-equals/4

  local0 128 s" README.md" *load-paths* @ *north-file-exts* @ find-file/6
  assert-not

  local0 128 s" fun" *load-paths* @ *north-file-exts* @ find-file/6
  assert
  s" src/lib/fun.4th" assert-byte-string-equals/4
end

0 var> *test-load-once-flag*

def test-load-once
  *loaded-files* @
  0 0 s" src/interp/tests/data/load-once-0.4th" set-local2 set-local1
  
  0 *test-load-once-flag* !
  null *loaded-files* !

  ( existing file )
  local1 load-once assert
  *loaded-files* @ cons-count 1 assert-equals
  *loaded-files* @ local1 local2 assert-list-has-string
  ( 2nd time for naught )
  local1 load-once assert
  *loaded-files* @ cons-count 1 assert-equals
  *test-load-once-flag* @ assert

  ( not found )
  " wut" load-once assert-not
  *loaded-files* @ cons-count 1 assert-equals
  ( directories )
  " src/lib" load-once assert-not
  *loaded-files* @ cons-count 1 assert-equals
  
  local0 *loaded-files* !
end

def test-require
  *loaded-files* @
  0 0 128 stack-allot set-local1
  local1 128 s" src/interp/tests/data/load-once-0.4th" pathname-expand
  UNLESS s" Error expanding path." error-line/2 return0 THEN
  dup set-local2

  0 *test-load-once-flag* !
  null *loaded-files* !

  ( existing file under . )
  " src/interp/tests/data/load-once-0" require assert
  *loaded-files* @ cons-count 1 assert-equals
  *loaded-files* @ local1 local2 assert-list-has-string
  *test-load-once-flag* @ assert
  ( 2nd time )
  " src/interp/tests/data/load-once-0" require assert
  *loaded-files* @ cons-count 1 assert-equals

  " src/lib" require assert-not
  *loaded-files* @ cons-count 1 assert-equals
  " boo-who" require assert-not
  *loaded-files* @ cons-count 1 assert-equals
  
  local0 *loaded-files* !
end

0 var> require-relative-loaded
0 var> require-relative-from-path

def test-require-relative-bad
  *loaded-files* @
  0 require-relative-loaded !
  s" src/interp/tests/require-relative/acks.4th" load/2 assert
  require-relative-loaded @ assert-not
  local0 *loaded-files* !
end

def test-require-relative-from-file
  *loaded-files* @
  0 require-relative-loaded !
  s" src/interp/tests/require-relative/top.4th" load/2 assert
  require-relative-loaded @ assert
  128 stack-allot-zero 128 s" src/interp/tests/require-relative/setter.4th" pathname-expand
  IF *loaded-files* @ 3 overn 3 overn assert-list-has-string THEN
  local0 *loaded-files* !
end

def test-require-relative-from-nested-file
  *loaded-files* @
  0 require-relative-loaded !
  s" src/interp/tests/require-relative/nested.4th" load/2 assert
  require-relative-loaded @ assert
  128 stack-allot-zero 128 s" src/interp/tests/require-relative/setter.4th" pathname-expand
  IF *loaded-files* @ 3 overn 3 overn assert-list-has-string THEN
  local0 *loaded-files* !
end

def test-require-relative-from-def
  *loaded-files* @
  0 require-relative-loaded !
  " require-relative/setter.4th" require-relative assert
  require-relative-loaded @ assert
  128 stack-allot-zero 128 s" src/interp/tests/require-relative/setter.4th" pathname-expand
  IF *loaded-files* @ 3 overn 3 overn assert-list-has-string THEN
  local0 *loaded-files* !
end

def test-require-relative-from-def-bad
  *loaded-files* @
  0 require-relative-loaded !
  " require-relative/badbad" require-relative assert-not
  require-relative-loaded @ assert-not
  local0 *loaded-files* !
end

def test-require-relative-from-def-without-ext
  *loaded-files* @
  0 require-relative-loaded !
  " require-relative/setter" require-relative assert
  require-relative-loaded @ assert
  128 stack-allot-zero 128 s" src/interp/tests/require-relative/setter.4th" pathname-expand
  IF *loaded-files* @ 3 overn 3 overn assert-list-has-string THEN
  local0 *loaded-files* !
end

def test-require-relative
  test-require-relative-bad
  test-require-relative-from-def
  test-require-relative-from-def-bad
  test-require-relative-from-def-without-ext
  test-require-relative-from-file
  test-require-relative-from-nested-file
end

def test-requires
  test-find-file
  test-load-once
  test-require
  test-require-relative
end
