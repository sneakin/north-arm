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

( todo compiling-read needs to use out-dict which needs out-dict based from cs, or dict relocated to absolute links; or have a token reader that calls cross-lookup and execs immediates. )

: defcol-read
  pointer out-immediates compiling-immediates poke
  compiling-read
  dup read-terminator swap set-overn
  here down-stack 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
;

: endcol
  0 set-compiling
; out-immediate
