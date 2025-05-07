DEFINED? assert UNLESS
  s[ src/lib/assert.4th ] load-list
THEN

DEFINED? require UNLESS
  s[ src/interp/require.4th ] load-list
THEN

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

  local0 *loaded-files* !
end

def test-requires
  test-find-file
  test-load-once
  test-require
end
