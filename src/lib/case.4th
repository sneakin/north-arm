( CASE expression to have a series of conditional expressions. Uses a syntax similiar to Bash.
  Example:
    x CASE
      1 WHEN " one" ;;
      2 WHEN " two" ;;
      drop " not 1 or 2"
    ESAC
)

( todo fix up a CASE for the interpreter; or make jump-rel & if-jump consistent on cell-size multiplier )

symbol> case-start-marker
symbol> case-marker

: CASE
  ( mark the location of the test value )
  ( here CASE-STACK speek swap cons CASE-STACK poke )
  case-start-marker
; immediate

: WHEN
  ( load the value )
  literal over
  ( compare values )
  literal equals
  ( start IF )
  POSTPONE IF
  literal drop
; immediate

: ;;
  ( skip to ESAC )
  literal int32
  case-marker
  literal jump-rel
  ( finish IF with THEN )
  POSTPONE THEN
; immediate

: esac-patcher ( start-ptr stack-ptr )
  dup speek case-start-marker equals IF
    literal nop over spoke
    2 dropn
  ELSE
    dup speek case-marker equals IF
      2dup swap stack-delta 1 - over spoke
    THEN
    up-stack loop
  THEN
;

: ESAC
  ( patch the case-markers )
  here dup esac-patcher
; immediate
