( CASE for cross compiled programs: )

" case-start-marker" string-const> case-start-marker
" case-marker" string-const> case-marker

' CASE cross-immediate/1

: out-WHEN
  ( load the value )
  literal over
  ( compare values )
  literal equals?
  ( start IF )
  POSTPONE out-IF
  literal drop
; cross-immediate-as WHEN

: out-WHEN-STR
  ( load the value )
  literal int32 int32 3
  literal overn
  literal rot literal swap
  ( compare values )
  literal string-equals?/3
  literal int32 int32 3 literal set-overn
  literal int32 int32 2 literal dropn
  ( start IF )
  POSTPONE out-IF ( fixme postpone needed, or is there a cross POSTPONE? )
  literal drop
; cross-immediate-as WHEN-STR

: out-;;
  ( skip to ESAC )
  literal int32
  literal case-marker
  literal jump-rel
  ( finish IF with THEN )
  POSTPONE out-THEN
; cross-immediate-as ;;

: out-esac-patcher ( start-ptr stack-ptr )
  dup speek literal case-start-marker equals IF
    literal nop over spoke
    2 dropn
  ELSE
    dup speek literal case-marker equals IF
      2dup swap stack-delta 1 - -op-size mult over spoke
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
