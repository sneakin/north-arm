: defcol-cb
  cross-lookup
  CASE
    LOOKUP-INT WHEN ,uint32 ;;
    LOOKUP-STRING WHEN ,byte-string ;;
    LOOKUP-NOT-FOUND WHEN not-found drop ;;
    drop ,op
  ESAC
  1 +
;

: defcol-state-fn
  over literalizes? UNLESS
    number? IF ' int32 swap THEN
  THEN
;

: defcol-read-init
  literal cross_immediates set-compiling-immediates
  ' defcol-state-fn set-compiling-state
;
  
: defcol-read
  defcol-read-init
  read-terminator compiling-read
  here down-stack 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
;

: endcol
  0 set-compiling
; cross-immediate

: does-col
  dup out' do-col does
  4 align-data
  dhere over dict-entry-data uint32!
  drop
;
