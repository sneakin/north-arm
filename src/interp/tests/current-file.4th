require[ assert ]

" src/interp/tests/current-file.4th" current-file swap string-contains? assert

def test-current-file-from-def
  current-file " src/interp/tests/current-file.4th" string-contains? assert
end

0 var> test-load-current-file

def test-load-sets-current-file
  0 test-load-current-file !
  s" src/interp/tests/load-sets-current-file.4th" load/2 assert
  test-load-current-file @ s" src/interp/tests/load-sets-current-file.4th" assert-byte-string-equals/3
end

def test-current-file
  test-current-file-from-def
  test-load-sets-current-file
end
