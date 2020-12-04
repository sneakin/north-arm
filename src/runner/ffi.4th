def ffi-callback-for ( num-args -- calling-word )
  (
  arg0 CASE
    0 WHEN ' ffi-callback-0 ;;
    1 WHEN ' ffi-callback-1 ;;
    2 WHEN ' ffi-callback-2 ;;
    drop ' ffi-callback-3
  ESAC
  )
  ( todo fix up a CASE for the interpreter; or make jump-rel & if-jump consistent on cell-size multiplier )
  arg0 0 equals? IF ' ffi-callback-0
  ELSE
    arg0 1 equals? IF ' ffi-callback-1
    ELSE
      arg0 2 equals? IF ' ffi-callback-2
      ELSE ' ffi-callback-3
      THEN
    THEN
  THEN set-arg0
end

defcol ffi-callback ( word arity -- ...assembly ptr )
  ( allot 5 less args+return cells )
  0 rot 0 rot
  0 rot 0 rot
  0 rot
  here cell-size 2 * + rot
  ( needs to return a call to an op that'll push args & jump to the next word. )
  .s
  swap ffi-callback-for .s dict-entry-code peek cs + 1 -
  3 overn cell-size 5 * copy-byte-string/3 3 dropn
  swap 1 + swap .s
endcol
