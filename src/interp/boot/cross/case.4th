( CASE for cross compiled programs: )

symbol> case-start-marker
symbol> case-marker

: out-CASE
  ( mark the location of the test value )
  ( here CASE-STACK speek swap cons CASE-STACK poke )
  case-start-marker
; cross-immediate-as CASE

: out-WHEN
  ( load the value )
  out-off' over
  ( compare values )
  out-off' equals?
  ( start IF )
  POSTPONE out-IF
  out-off' drop
; cross-immediate-as WHEN

: out-WHEN-STR
  ( load the value )
  out-off' int32 int32 3
  out-off' overn
  out-off' rot out-off' swap
  ( compare values )
  out-off' string-equals?/3
  out-off' int32 int32 3 out-off' set-overn
  out-off' int32 int32 2 out-off' dropn
  ( start IF )
  POSTPONE out-IF ( fixme postpone needed, or is there a cross POSTPONE? )
  out-off' drop
; cross-immediate-as WHEN-STR

: out-;;
  ( skip to ESAC )
  out-off' int32
  case-marker
  out-off' jump-rel
  ( finish IF with THEN )
  POSTPONE out-THEN
; cross-immediate-as ;;

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
; cross-immediate-as ESAC

( More standard words: )
alias> out-OF out-WHEN cross-immediate-as OF
alias> out-OF-STR out-WHEN-STR cross-immediate-as OF-STR
alias> out-ENDOF out-;; cross-immediate-as ENDOF
alias> out-ENDCASE out-ESAC cross-immediate-as ENDCASE
