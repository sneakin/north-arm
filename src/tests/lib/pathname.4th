require[ pathname assert ]

128 var> assert-max-pathname

def test-pathname-dirname
  s" hello" pathname-dirname s" ." assert-byte-string-equals/4
  s" hello/world" pathname-dirname s" hello" assert-byte-string-equals/4
  s" hello/hello/world" pathname-dirname s" hello/hello" assert-byte-string-equals/4
end

def test-pathname-basename
  s" world" pathname-basename s" world" assert-byte-string-equals/4
  s" hello/world" pathname-basename s" world" assert-byte-string-equals/4
  s" hello/there/world" pathname-basename s" world" assert-byte-string-equals/4
end

def test-pathname-join
  0 128 stack-allot set-local0
  local0 128 s" hello" s" world" pathname-join/6 true assert-equals
  2dup s" hello/world" assert-byte-string-equals/4
  local0 128 2swap s" 123" pathname-join/6 true assert-equals
  2dup s" hello/world/123" assert-byte-string-equals/4
  local0 128 2swap s" X" pathname-join/6 true assert-equals
  2dup s" hello/world/123/X" assert-byte-string-equals/4
  ( output maxed out )
  2dup 2dup s" YZ" pathname-join/6 false assert-equals
  ( assert output unchanged )
  local0 128 s" hello/" s" world" pathname-join/6 true assert-equals
  2dup s" hello/world" assert-byte-string-equals/4
  local0 128 s" hello" s" /world" pathname-join/6 true assert-equals
  2dup s" hello/world" assert-byte-string-equals/4
  local0 128 s" hello/" s" /world" pathname-join/6 true assert-equals
  2dup s" hello/world" assert-byte-string-equals/4
end

def test-pathname-absolute?
  s" /" pathname-absolute? assert
  s" /hello" pathname-absolute? assert
  s" /a/b" pathname-absolute? assert
  s" " pathname-absolute? assert-not
  s" hello" pathname-absolute? assert-not
  s" .." pathname-absolute? assert-not
  s" a/b" pathname-absolute? assert-not
end

def assert-pathname-expand ( str length expecting exp-length -- )
  assert-max-pathname @ stack-allot
  assert-max-pathname @ arg3 arg2 pathname-expand
  true assert-equals
  ( 2dup error-line/2 )
  arg1 arg0 assert-byte-string-equals/4
  4 return0-n
end

def assert-not-pathname-expand ( str length -- )
  assert-max-pathname @ stack-allot
  assert-max-pathname @ arg1 arg0 pathname-expand
  false assert-equals
  2 return0-n
end

def test-pathname-expand
  s" pathname-expand" error-line/2
  0 0 0
  128 stack-allot set-local0
  128 stack-allot set-local1
  ( craft the expected result for ./hello )
  128 local1 getcwd 1 - set-local2 ( why linux? )
  local2 local1 string-length assert-equals
  local1 128 local1 local2 s" /hello" string-append/6 set-local2

  ( expand hello )
  s" hello" local1 local2 assert-pathname-expand
  ( expand ./hello )
  s" ./hello" local1 local2 assert-pathname-expand
  ( expand ./hello in place )
  s" ./hello" local0 swap copy-byte-string/3 3 dropn
  local0 128 local0 7 pathname-expand true assert-equals
  local1 local2 assert-byte-string-equals/4

  ( craft the expected result for ../hello )
  128 local1 getcwd 1 -
  local1 swap pathname-dirname set-local2
  local1 128 local1 local2 s" /hello" string-append/6 set-local2
  ( expand ../hello )
  s" ../hello" local1 local2 assert-pathname-expand
  ( expand ../hello in place )
  s" ../hello" local0 swap copy-byte-string/3 3 dropn
  local0 128 local0 8 pathname-expand true assert-equals
  local1 local2 assert-byte-string-equals/4

  ( craft the expected result for .hello )
  128 local1 getcwd 1 - set-local2
  local1 128 local1 local2 s" /.hello" string-append/6 set-local2
  ( expand .hello )
  s" .hello" local1 local2 assert-pathname-expand

  ( craft the expected result for ..hello )
  128 local1 getcwd 1 - set-local2
  local1 128 local1 local2 s" /..hello" string-append/6 set-local2
  ( expand ..hello )
  s" ..hello" local1 local2 assert-pathname-expand

  ( absolute paths )
  s" /hello" s" /hello" assert-pathname-expand
  s" /hello/" s" /hello" assert-pathname-expand
  s" /hello//world" s" /hello/world" assert-pathname-expand
  s" /../hello" s" /../hello" assert-pathname-expand
  s" /hello/./" s" /hello"  assert-pathname-expand
  s" /hello/../" s" /" assert-pathname-expand
  s" /hello/." s" /hello" assert-pathname-expand
  s" /hello/.." s" /"  assert-pathname-expand
  s" /hello/world/../../foo" s" /foo" assert-pathname-expand
  s" /hello/world/././foo" s" /hello/world/foo" assert-pathname-expand
  s" /hello/./../hello/./world/.././bar/../foo/./." s" /hello/foo" assert-pathname-expand
  s" /he/w/." s" /he/w" assert-pathname-expand

  ( expand into a tiny buffer )
  assert-max-pathname @

  4 assert-max-pathname !
  s" /hello/." assert-not-pathname-expand
  s" /hello/.." assert-not-pathname-expand
  ( expand /hello/.. into a not as tiny buffer: does copy /hello )
  8 assert-max-pathname !
  s" /hello/.." s" /" assert-pathname-expand

  ( restore... )
  assert-max-pathname !
end

def test-pathname
  test-pathname-dirname
  test-pathname-basename
  test-pathname-absolute?
  test-pathname-join
  test-pathname-expand
end
