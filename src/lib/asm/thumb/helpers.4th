( int32 loading: )

: emit-load-int32-shift-amount ( n shift -- nbits )
  dup 8 uint>= IF
    0xFF 2 overn 8 - bsl 3 overn logand IF
      2 dropn 8
    ELSE
      8 - emit-load-int32-shift-amount
      8 +
    THEN
  ELSE 2 dropn 0
  THEN
;

: emit-load-int32-byte ( n reg shift -- )
  3 overn 2 overn bsr 0xFF logand dup IF
    ( each non-zero byte gets added to the register
      and shifted up so the next byte can be added
      and shifted. )
    3 overn
    3 overn 24 uint>= IF
      mov# ( init reg with highest byte )
    ELSE
      ( add the byte if higher bytes are not zero,
        otherwise init reg )
      5 overn 0xFFFFFFFF 5 overn 8 + bsl logand
      IF add# ELSE mov# THEN
    THEN ,ins
    ( determine amount of shift )
    3 overn 2 overn emit-load-int32-shift-amount
    dup IF 3 overn dup mov-lsl ,ins ( reg<<shift ) ELSE drop THEN
  ELSE drop
  THEN 3 dropn
;

: emit-load-uint32 ( n reg -- )
  over 0xFF uint<= IF
    mov# ,ins
  ELSE
    2dup 24 emit-load-int32-byte
    2dup 16 emit-load-int32-byte
    2dup 8 emit-load-int32-byte
    2dup 0 emit-load-int32-byte
    2 dropn
  THEN
;

: emit-load-int32 ( n reg -- )
  over 0 int< IF
    over negate over emit-load-uint32
    dup neg ,ins
    drop
  ELSE
    emit-load-uint32
  THEN
;
