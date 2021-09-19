( s[ src/lib/case.4th src/lib/assert.4th ] load-list )
" src/lib/assert.4th" load
" src/lib/case.4th" load

def test-case-printed
  arg0 CASE
  1 WHEN " one" error-line ;;
  2 WHEN " two" error-line ;;
  3 WHEN " three" error-line ;;
  " idk" error-line
  ESAC
  drop " done" error-line
end

def test-case-fn0
  arg0 CASE
    ( leaves the value on stack )
    arg0 assert-equals
    " idk"
  ESAC return1
end

def test-case0
  1 test-case-fn0 s" idk" assert-byte-string-equals/3 4 dropn
  -1 test-case-fn0 s" idk" assert-byte-string-equals/3 4 dropn
end

def test-case-fn1
  arg0 CASE
  1 WHEN ( value gets used )
    dup arg0 assert-not-equals " one" ;;
  arg0 assert-equals
  " idk"
  ESAC return1
end

def test-case1
  1 test-case-fn1 s" one" assert-byte-string-equals/3 4 dropn
  -1 test-case-fn1 s" idk" assert-byte-string-equals/3 4 dropn
end

def test-case-fn4
  arg0 CASE
  1 WHEN dup arg0 assert-not-equals " one" ;;
  2 WHEN dup arg0 assert-not-equals " two" ;;
  3 WHEN dup arg0 assert-not-equals " three" ;;
  arg0 assert-equals
  " idk"
  ESAC return1
end

def test-case4
  1 test-case-fn4 s" one" assert-byte-string-equals/3 4 dropn
  2 test-case-fn4 s" two" assert-byte-string-equals/3 4 dropn
  3 test-case-fn4 s" three" assert-byte-string-equals/3 4 dropn
  4 test-case-fn4 s" idk" assert-byte-string-equals/3 4 dropn
  -1 test-case-fn4 s" idk" assert-byte-string-equals/3 4 dropn
end

def test-case
  test-case0
  test-case1
  test-case4
end
