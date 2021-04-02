: assertion-passed s" ." write-string/2 ;
: assertion-failed s" F" write-string/2 ;

: assert
  IF assertion-passed
  ELSE assertion-failed
  THEN
;

: assert-not lognot assert ;

: assert-equals
  2dup equals dup assert IF
    2 dropn
  ELSE
    space write-hex-uint space write-hex-uint nl
  THEN
;

: assertion-message
  IF assertion-passed 2 dropn
  ELSE assertion-failed
       write-string "  != " write-string write-string nl
  THEN
;

def assert-byte-string-equals/3
  arg2 string-length arg0 assert-equals
  arg2 arg1 arg0 byte-string-equals?/3 swap drop
  assertion-message
end

def assert-byte-string-equals/4
  arg2 arg0 equals?
  IF arg3 arg1 arg0 assert-byte-string-equals/3
  ELSE assertion-failed
  THEN
end

def assert-string-null-terminated
  arg1 arg0 string-peek 0 assert-equals
end

: assert-contains
  2dup contains? assertion-message
;

: assert-contains-not
  2dup contains? not assertion-message
;
