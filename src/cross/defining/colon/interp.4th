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
  cross-immediates peek cs + compiling-immediates poke
  out-dictionary peek compiling-dict poke
  out-origin peek compiling-offset poke
  ' out-literalizes? compiling-literalizes-fn poke
;

: defcol-cb
  ,op 1 +
;

DEFINED? reverse-into IF
  : defcol-copy-to-data ( ...ops num-ops ++ )
    op-size cell-size equals? IF
      ( use the new reverse )
      here cell-size + dhere 3 overn reverse-into
      ( here over dup shift op-size * + dhere 3 overn reverse-cells 3 dropn )
      dup cell-size * dhere + dmove
    ELSE
      read-terminator over 2 + set-overn
      here 0 ' defcol-cb revmap-stack-seq/3 drop
    THEN
  ;
ELSE
  : defcol-copy-to-data ( ...ops num-ops ++ )
    read-terminator over 2 + set-overn
    here 0 ' defcol-cb revmap-stack-seq/3 drop
  ;
THEN

: defcol-read
  defcol-read-init compiling-read
  ( todo write the sequence's length. needs update to enter. )
  defcol-copy-to-data
  5 + dropn ( drops the frame left by compiling-read )
;

: endcol
  0 compiling poke
; cross-immediate

: does-col
  dup out' do-col does
  4 align-data
  dhere to-out-addr over dict-entry-data uint32!
  drop
;
