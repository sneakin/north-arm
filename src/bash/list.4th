: cons here ;
: car speek ;
: cdr up-stack speek ;

def map-car/3 ( cons state fn ++ )
  arg2 null? swap 0 equals logior IF arg1 exit-frame THEN
  arg1 arg2 car arg0 exec set-arg1
  arg2 cdr set-arg2 repeat-frame
end

def map-seq-n ( ptr number state fn ++ state )
  0 arg2 int< IF
    arg1 arg3 speek arg0 exec set-arg1
    arg3 up-stack set-arg3
    arg2 1 - set-arg2 repeat-frame
  ELSE arg1 exit-frame
  THEN
end

def reverse->seq-n ( cons ++ seq n )
  arg0 null? swap 0 equals logior IF
    here locals over stack-delta 1 + exit-frame
  ELSE
    arg0 car
    arg0 cdr set-arg0 repeat-frame
  THEN
end

def revmap-car/3 ( cons state fn ++ state )
  arg2 reverse->seq-n arg1 arg0 map-seq-n exit-frame
end

alias> revmap-cons/3 revmap-car/3

def load-1
  arg0 load true exit-frame
end

def load-list
  arg0 0 ' load-1 revmap-car/3
  exit-frame
end

: read-list ( last-token result ++ result )
  next-token null? IF drop swap drop return THEN
  dup q" (" equals? IF q" )" read-until drop drop loop THEN
  3 overn over equals IF drop swap drop return THEN
  ( last result token => result token last here-1 )
  swap rot here up-stack loop
;

: s[
  q" ]" 0 read-list
;

: read-literal-list
  next-token null? IF drop return THEN
  dup q" ]" equals IF drop return THEN
  dup q" (" equals IF q" )" read-until drop drop loop THEN
  literal literal rot
  literal cons swap
  1 + loop
;

: [s[]
  literal int32 0
  0 read-literal-list drop
; immediate-as s[
