: assertion-passed s" ." write-string/2 ;
: assertion-failed s" F" write-string/2 ;

: assert
  IF assertion-passed
  ELSE assertion-failed
  THEN
;

: assert-equals
  2dup equals dup assert IF
    2 dropn
  ELSE
    space write-hex-uint space write-hex-uint nl
  THEN
;

def assert-byte-string-equals/3
  arg2 arg1 arg0 byte-string-equals?/3
  IF assertion-passed
  ELSE assertion-failed
    arg2 arg0 error-string/2
    s" != " error-string/2
    arg1 arg0 error-string/2
  THEN
end

def assert-byte-string-equals/4
  arg2 arg0 equals?
  IF arg3 arg1 arg0 assert-byte-string-equals/3
  ELSE assertion-failed
  THEN
end
