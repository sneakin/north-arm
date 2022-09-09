: assertion-passed s" ." write-string/2 ;
: assertion-failed s" F" write-string/2 ;

: assert
  IF assertion-passed
  ELSE assertion-failed
  THEN
;

: assert-not not assert ;

: write-binop-message
  swap write-int write-string write-int
;

: assert-equals
  2dup equals dup assert IF
    2 dropn
  ELSE
    space "  != " write-binop-message nl
  THEN
;

: assert-not-equals
  2dup equals lognot dup assert IF
    2 dropn
  ELSE
    space "  == " write-binop-message nl
  THEN
;

: assertion-message
  IF assertion-passed 2 dropn
  ELSE assertion-failed space
       write-string "  != " write-string write-string nl
  THEN
;

def assert-byte-string-equals/3
  arg2 null? arg1 null? or IF
    arg2 arg1 assert-equals
    arg0 0 assert-equals
  ELSE
    arg2 string-length arg0 assert-equals
    arg2 arg1 arg0 byte-string-equals?/3 swap drop
    assertion-message
  THEN
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

: assert-data ( data-ptr ...cells count -- )
  dup 0 equals?
  IF 2 dropn
  ELSE
    1 int-sub
    dup 3 int-add overn over seq-peek ,h
    3 overn assert-equals
    swap drop loop
  THEN
;
