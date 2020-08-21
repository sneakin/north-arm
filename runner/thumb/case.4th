( CASE for cross compiled programs: )

" case-start-marker" string-const> case-start-marker
" case-marker" string-const> case-marker

' CASE out-immediate/1

: out-WHEN
  ( load the value )
  literal over
  ( compare values )
  literal equals
  ( start IF )
  POSTPONE out-IF
  literal drop
; out-immediate-as WHEN

: out-;;
  ( skip to ESAC )
  literal int32
  literal case-marker
  literal jump-rel
  ( finish IF with THEN )
  POSTPONE out-THEN
; out-immediate-as ;;

: out-esac-patcher ( start-ptr stack-ptr )
  dup speek literal case-start-marker equals IF
    literal nop over spoke
    2 dropn
  ELSE
    dup speek literal case-marker equals IF
      2dup - 1 - cell-size mult over spoke
    THEN
    up-stack loop
  THEN
;

: out-ESAC
  ( patch the case-markers )
  here dup out-esac-patcher
; out-immediate-as ESAC
