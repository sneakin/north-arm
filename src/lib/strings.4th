" null-type" string-const> null-type
: type-of dup IF speek ELSE pointer null-type THEN ;

alias> cstring-peek string-peek
alias> cstring-length string-length

( Read only Strings: )

: empty-string
  0
;

( Indirect String: wraps a pointer to sequence of bytes. )

" indirect-string" string-const> indirect-string

: make-indirect-string ( buffer-ptr length ++ ptr )
  pointer indirect-string here
;

: indirect-string-length ( ptr -- length )
  up-stack speek
;

: indirect-string-src
  2 up-stack/2
;

: indirect-string-peek ( ptr index -- char )
  over indirect-string-length over int> IF
    swap indirect-string-src speek +
    speek-byte ( todo should be up-stack-bytes )
  ELSE 2 dropn 0 THEN
;

: indirect-string-poke ( new-char ptr index -- )
  over indirect-string-length over int> IF
    swap indirect-string-src speek +
    spoke-byte
  ELSE 3 dropn THEN
;

( Sized sequence strings: )

" direct-string" string-const> direct-string

: make-direct-string ( ...chars length ++ ptr )
  pointer direct-string here
;

: direct-string-length ( ptr -- length )
  up-stack speek
;

: direct-string-peek ( ptr index -- char )
  over direct-string-length over int> IF
    swap 2 up-stack/2 + speek-byte ( todo should be up-stack-bytes )
  ELSE 2 dropn 0 THEN
;

: direct-string-poke ( new-char ptr index -- )
  over direct-string-length over int> IF
    2 up-stack/2 + spoke-byte
  ELSE 3 dropn THEN
;


( Joined String: concatenates two strings into a string like object. )

" joined-string" string-const> joined-string

: joined-string-length
  up-stack speek
;

: joined-string-head
  3 up-stack/2
;

: joined-string-tail
  2 up-stack/2
;

( Partial string: a string like object that only provides access to a substring. )

" partial-string" string-const> partial-string

: make-partial-string ( offset length src ++ partial-string )
  pointer partial-string here
;

: partial-string-src
  1 up-stack/2
;

: partial-string-length
  2 up-stack/2 speek
;

: partial-string-offset
  3 up-stack/2
;

( Generic string length: )

: string-length
  dup type-of
  CASE
    pointer joined-string WHEN joined-string-length ;;
    pointer indirect-string WHEN indirect-string-length ;;
    pointer direct-string WHEN direct-string-length ;;
    pointer partial-string WHEN partial-string-length ;;
    3 dropn 0
  ESAC
;

( Generic character peeking: )

: string-peek
  ( defined later )
;

: joined-string-peek ( joined-string index -- char )
  dup 3 overn joined-string-head speek string-length int>= IF
    ( in tail )
    over joined-string-head speek string-length -
    over joined-string-tail speek
    swap string-peek
    swap drop
  ELSE
    ( in head )
    over joined-string-head speek
    over string-peek
    rot 2 dropn
  THEN
;

: partial-string-peek
  dup 0 int< IF
    2 dropn 0
  ELSE
    over partial-string-length over int<= IF
      2 dropn 0
    ELSE
      over partial-string-src speek
      3 overn partial-string-offset speek
      3 overn +
      string-peek
      rot 2 dropn
    THEN
  THEN
;

:: string-peek ( string offset )
  over type-of CASE
    pointer joined-string WHEN joined-string-peek ;;
    pointer indirect-string WHEN indirect-string-peek ;;
    pointer direct-string WHEN direct-string-peek ;;
    pointer partial-string WHEN partial-string-peek ;;
    4 dropn 0
  ESAC
;

( String operations: )

( Concatenates two string using a joined string. )
: join-strings ( a-str b-str ++ new-str )
  over string-length
  over string-length +
  pointer joined-string here
;

( Splits a string at an offset returning strings for the left and right substrings. )
def split-string ( str offset ++ ... left right )
  arg0 0 int>
  IF
    arg1 string-length arg0 int> IF
      0
      0 arg0 arg1 make-partial-string set-local0
      arg0
      arg1 string-length arg0 -
      arg1
      make-partial-string
      local0 swap exit-frame
    ELSE arg1 empty-string exit-frame
    THEN
  ELSE empty-string arg1 exit-frame
  THEN
end

( Inserts a string at an offset returning a joined string. )
def insert-string ( insert into offset )
  0 0
  ( split into at offset )
  arg1 arg0 split-string set-local1 set-local0
  ( join left, insert, right )
  local0 arg2 join-strings
  local1 join-strings
  exit-frame
end

( Removes a substring from within a string. )
def delete-substring ( chop-start chop-length string ++ ... joined-string )
  ( no chops )
  arg2 arg0 string-length int>= IF arg0 return1 THEN
  arg1 0 equals IF arg0 return1 THEN
  arg2 0 int< IF arg2 arg1 + set-arg1 0 set-arg2 THEN
  arg2 0 equals IF
    arg1 0 int<= IF arg0 return1 THEN
    ( all chop )
    arg1 arg0 string-length int>= IF empty-string return1 THEN
    ( chop beginning )
    arg1 arg0 string-length over - arg0 make-partial-string
    exit-frame
  ELSE
    ( chop the middle -> joined partials )
    0
    ( beginning: 0 to chop start )
    0 arg2 arg0 make-partial-string set-local0
    ( ending: chop start + length to end )
    arg2 arg1 +
    arg0 string-length over -
    ( only need the beginning when the chop goes to end )
    dup 0 int<= IF drop local0 exit-frame THEN
    arg0 make-partial-string
    local0 swap join-strings
    exit-frame
  THEN
end

( Calls a function with each character, index, and accumulator; at and after the index; of the string. )
def map-string/4 ( accum ptr fn index )
  arg2 string-length arg0 int> IF
    stack-marker
    arg2 arg0 string-peek
    arg3 swap arg0 swap arg1 exec-abs
    drop-to-marker
    arg0 1 + set-arg0
    repeat-frame
  ELSE return0
  THEN
end

( Calls a function with each character, at and after the index, of the string. )
: map-string/3 ( ptr fn index -- ptr )
  3 overn string-length over int> IF
    stack-marker
    4 overn 3 overn string-peek
    3 overn swap 5 overn exec-abs
    drop-to-marker
    1 + loop
  ELSE
    2 dropn
  THEN
;

: map-string ( ptr fn -- ptr ) 0 map-string/3 ;

( Compacting a string: )

def compact-string-copier
  arg0 arg2 arg1 indirect-string-poke
  return0
end

( Copies as much of the source string into the destination string. )
def compact-string/2 ( src-string dest-string )
  arg0 arg1 pointer compact-string-copier 0 map-string/4
end

( Copy a complete string into a newly allocated buffer. )
def compact-string
  arg0 string-length 1 + stack-allot
  arg0 string-length make-indirect-string
  arg0 over compact-string/2 2 dropn
  exit-frame
end


( Equality: )

: str-equals-loop ( a b length index )
  2dup int<=
  IF 4 dropn 1
  ELSE
    4 overn over string-peek
    4 overn 3 overn string-peek
    equals
    IF 1 + loop
    ELSE 4 dropn 0
    THEN
  THEN
;

( Compare two strings. )
: str-equals
  2dup equals
  IF 2 dropn 1
  ELSE
    over string-length over string-length
    equals
    IF dup string-length 0 str-equals-loop
    ELSE 2 dropn 0
    THEN
  THEN
;

( String IO: )

( Write a string to the current output. )
: write-str pointer write-byte map-string ;
