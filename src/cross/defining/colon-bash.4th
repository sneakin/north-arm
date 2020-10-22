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

(
: out-literalizes?
  dup out' int32 equals
  swap dup out' literal equals
  swap dup out' pointer equals
  swap dup out' offset32 equals
  logior logior logior
;
)

: defcol-state-fn
  over literalizes? UNLESS
    number? IF ' int32 swap THEN
  THEN
;

: defcol-read
  literal out_immediates set-compiling-immediates
  ' defcol-state-fn set-compiling-state
  read-terminator compiling-read
  here down-stack 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
;

: endcol
  0 set-compiling
; out-immediate

: does-col
  out' do-col dict-entry-code uint32@
  over dict-entry-code uint32!
  4 align-data
  dhere over dict-entry-data uint32!
  drop
;
