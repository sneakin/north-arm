( String tests: )

: assert-string-equals/2
  2dup str-equals IF
    2 dropn
    " ." write-string/2
  ELSE
    " F" write-string/2
    space dup string-length write-hex-uint space write-str
    space dup string-length write-hex-uint space write-str nl
  THEN
;

def assert-string-equals/3
  arg1 arg0 make-indirect-string
  arg2 swap assert-string-equals/2
end

def test-indirect-string
  " hello" make-indirect-string
  dup string-length 5 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 104 assert-equals
  dup 4 string-peek 111 assert-equals
  dup 5 string-peek 0 assert-equals ( todo raise an error )
end

def test-direct-string
  " what" drop speek 4 make-direct-string
  dup string-length 4 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 119 assert-equals
  dup 3 string-peek 116 assert-equals
  dup 4 string-peek 0 assert-equals ( todo raise an error )
end

def test-joined-string
  " hello" make-indirect-string dup join-strings
  dup string-length 10 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 104 assert-equals
  dup 4 string-peek 111 assert-equals
  dup 5 string-peek 104 assert-equals
  dup 9 string-peek 111 assert-equals
  dup 10 string-peek 0 assert-equals ( todo raise an error )
end

def test-partial-string
  " hello" make-indirect-string
  2 2 3 overn make-partial-string
  dup string-length 2 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 108 assert-equals
  dup 1 string-peek 108 assert-equals
  dup 2 string-peek 0 assert-equals ( todo raise an error )
end

def test-str-equals
  0 0
  " helloworld" make-indirect-string set-local0
  " helloworld" make-indirect-string set-local1
  local0 local0 str-equals 1 assert-equals
  local0 local1 str-equals 1 assert-equals
  local1 local0 str-equals 1 assert-equals
  empty-string empty-string str-equals 1 assert-equals
  local0 empty-string str-equals 0 assert-equals
  empty-string local0 str-equals 0 assert-equals
  " hello" make-indirect-string local0 str-equals 0 assert-equals
end

def test-split-string-before
  " hello" make-indirect-string
  0 split-string
  " hello" assert-string-equals/3 3 dropn
  empty-string assert-string-equals/2
end

def test-split-string-middle
  " helloworld" make-indirect-string
  5 split-string
  " world" assert-string-equals/3 3 dropn
  " hello" assert-string-equals/3 3 dropn
end

def test-split-string-after
  " hello" make-indirect-string
  5 split-string
  empty-string assert-string-equals/2
  " hello" assert-string-equals/3 3 dropn
end

def test-insert-string-before
  0 0
  " hello" make-indirect-string set-local0
  " hey " make-indirect-string set-local1
  local1 local0 0 insert-string
  " hey hello" assert-string-equals/3
end

def test-split-string
  test-split-string-before
  test-split-string-middle
  test-split-string-after
end

def test-insert-string-middle
  0 0
  " hello" make-indirect-string set-local0
  " y ye" make-indirect-string set-local1
  local1 local0 2 insert-string
  " hey yello" assert-string-equals/3
end

def test-insert-string-after
  0 0
  " hello" make-indirect-string set-local0
  "  world" make-indirect-string set-local1
  local1 local0 5 insert-string
  " hello world" assert-string-equals/3
end

def test-insert-string
  test-insert-string-before
  test-insert-string-middle
  test-insert-string-after
end

def test-delete-substring-none-zero
  " hello" make-indirect-string
  2 0 3 overn delete-substring
  dup string-length 5 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 104 assert-equals
  dup 4 string-peek 111 assert-equals
  dup 5 string-peek 0 assert-equals ( todo raise an error )
end

def test-delete-substring-none-before
  " hello" make-indirect-string
  -8 4 3 overn delete-substring
  dup string-length 5 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 104 assert-equals
  dup 4 string-peek 111 assert-equals
  dup 5 string-peek 0 assert-equals ( todo raise an error )
end

def test-delete-substring-none-after
  " hello" make-indirect-string
  6 4 3 overn delete-substring
  dup string-length 5 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 104 assert-equals
  dup 4 string-peek 111 assert-equals
  dup 5 string-peek 0 assert-equals ( todo raise an error )
end

def test-delete-substring-after
  " hello" make-indirect-string
  8 4 3 overn delete-substring
  dup string-length 5 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 104 assert-equals
  dup 4 string-peek 111 assert-equals
  dup 5 string-peek 0 assert-equals ( todo raise an error )
end

def test-delete-substring-all
  " hello" make-indirect-string
  0 8 3 overn delete-substring
  dup empty-string assert-equals
  dup string-length 0 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 0 assert-equals
end

def test-delete-substring-before
  " hello" make-indirect-string
  -2 4 3 overn delete-substring
  dup string-length 3 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 108 assert-equals
  dup 1 string-peek 108 assert-equals
  dup 2 string-peek 111 assert-equals
  dup 3 string-peek 0 assert-equals ( todo raise an error )
end

def test-delete-substring-beginning
  " hello" make-indirect-string
  0 2 3 overn delete-substring
  dup string-length 3 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 108 assert-equals
  dup 1 string-peek 108 assert-equals
  dup 2 string-peek 111 assert-equals
  dup 3 string-peek 0 assert-equals ( todo raise an error )
end

def test-delete-substring-ending
  " hello" make-indirect-string
  3 2 3 overn delete-substring
  dup string-length 3 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 104 assert-equals
  dup 1 string-peek 101 assert-equals
  dup 2 string-peek 108 assert-equals
  dup 3 string-peek 0 assert-equals ( todo raise an error )
end

def test-delete-substring-middle
  " hello" make-indirect-string
  2 2 3 overn delete-substring
  dup string-length 3 assert-equals
  dup -1 string-peek 0 assert-equals ( todo raise an error )
  dup 0 string-peek 104 assert-equals
  dup 1 string-peek 101 assert-equals
  dup 2 string-peek 111 assert-equals
  dup 3 string-peek 0 assert-equals ( todo raise an error )
end

def test-delete-substring
  test-delete-substring-none-zero
  test-delete-substring-none-before
  test-delete-substring-none-after
  test-delete-substring-after
  test-delete-substring-all
  test-delete-substring-beginning
  test-delete-substring-middle
  test-delete-substring-ending
end

def test-compact-string
  0
  " hey" make-indirect-string dup join-strings compact-string
  dup set-local0
  " heyhey" assert-string-equals/3
end

def test-string
  test-indirect-string
  test-direct-string
  test-joined-string
  test-partial-string
  test-str-equals
  test-split-string
  test-insert-string
  test-delete-substring
  test-compact-string
end
