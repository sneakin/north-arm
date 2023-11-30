( CASE expression to have a series of conditional expressions. Uses a syntax similiar to Bash.
  Example:
    value CASE
      1 WHEN " one" ;;
      2 WHEN " two" ;;
      drop " not 1 or 2"
    ESAC

    value CASE
      1 OF " one" ENDOF
      2 OF " two" ENDOF
      drop " not 1 or 2"
    ENDCASE
)

( fixme empty else clause [?] generates a ~0 jump-rel~ that can be eliminated )

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

: WHEN-STR
  ( load the value )
  literal int32 int32 3
  literal overn
  literal rot literal swap
  ( compare values )
  literal string-equals?/3
  literal int32 int32 3 literal set-overn
  literal int32 int32 2 literal dropn
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
      2dup swap stack-delta 1 - op-size * over spoke
    THEN
    up-stack loop
  THEN
;

: ESAC
  ( patch the case-markers )
  here dup esac-patcher
; immediate

( More standard words: )
alias> OF WHEN immediate
alias> OF-STR WHEN-STR immediate
alias> ENDOF ;; immediate
alias> ENDCASE ESAC immediate
