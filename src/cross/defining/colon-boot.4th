: defcol-cb
  ,op 1 +
;

: out-literalizes?
  dup out' int32 equals
  swap dup out' literal equals
  swap dup out' pointer equals
  swap dup out' cstring equals
  swap dup out' string equals
  swap out' offset32 equals
  logior logior logior logior logior
;

( todo an extra zero is padded between entries and first data )

: defcol-read-init
  out-immediates peek cs + compiling-immediates poke
  out-dictionary peek compiling-dict poke
  out-origin peek compiling-offset poke
  ' out-literalizes? compiling-literalizes-fn poke
;

: defcol-read
  defcol-read-init compiling-read
  ( todo get rid of the terminator )
  read-terminator over 2 + set-overn
  here 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
;

: endcol
  0 compiling poke
; out-immediate

: does-col
  out' do-col dict-entry-code uint32@
  over dict-entry-code uint32!
  4 align-data
  dhere to-out-addr over dict-entry-data uint32!
  drop
;
