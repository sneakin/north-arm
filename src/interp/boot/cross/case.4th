( CASE for cross compiled programs: )

symbol> case-start-marker
symbol> case-marker

: out-CASE
  ( mark the location of the test value )
  ( here CASE-STACK speek swap cons CASE-STACK poke )
  case-start-marker
; out-immediate-as CASE

: out-WHEN
  ( load the value )
  out-off' over
  ( compare values )
  out-off' equals?
  ( start IF )
  POSTPONE out-IF
  out-off' drop
; out-immediate-as WHEN

: out-;;
  ( skip to ESAC )
  out-off' int32
  case-marker
  out-off' jump-rel
  ( finish IF with THEN )
  POSTPONE out-THEN
; out-immediate-as ;;

: out-esac-patcher ( start-ptr stack-ptr )
  dup speek case-start-marker equals IF
    out-off' nop over spoke
    2 dropn
  ELSE
    dup speek case-marker equals IF
      2dup swap stack-delta 1 - cell-size mult over spoke
    THEN
    up-stack loop
  THEN
;

: out-ESAC
  ( patch the case-markers )
  here dup out-esac-patcher
; out-immediate-as ESAC
