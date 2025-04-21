NORTH-STAGE 0 equals? IF
  0 var> out-immediates
ELSE
  DEFINED? output-immediates UNLESS
    0 var> output-immediates
  THEN

  : out-immediates output-immediates @ ;
  : set-out-immediates output-immediates ! ;
THEN

: out-immediate/1 ( word )
  out-immediates swap copies-entry set-out-immediates
;

: out-immediate
  out-dict out-immediate/1
;

: out-immediate-only out-immediate drop-out-dict ;

: out-immediate-as
  out-immediates out-dict copies-entry-as> set-out-immediates
;

DEFINED? oword-printer UNLESS
  : oword-printer
    dict-entry-name peek from-out-addr write-string space
    1 +
  ;
THEN

DEFINED? oiwords UNLESS
  NORTH-STAGE 0 equals? IF
    : oiwords
      out-immediates out-origin 0 ' oword-printer dict-map/4 enl
      5 + dropn
    ;
  ELSE
    : oiwords
      out-immediates out-origin peek 0 ' oword-printer dict-map/4 enl
      5 + dropn
    ;
  THEN
THEN
