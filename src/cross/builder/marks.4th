DEFINED? push-mark IF
  DEFINED? asm-thumb UNLESS : asm-thumb s" No thumb support." error-line/2 ; THEN
  DEFINED? asm-aarch32-thumb UNLESS : asm-aarch32-thumb s" No aarch32 support." error-line/2 ; THEN
  DEFINED? asm-x86 UNLESS : asm-x86 s" No x86 support." error-line/2 ; THEN

  : push-asm-mark
    target-thumb?
    IF asm-thumb
    ELSE
      target-aarch32?
      IF asm-aarch32-thumb
      ELSE target-x86? IF asm-x86 ELSE proper-exit THEN
      THEN
    THEN push-mark
  ;
ELSE
  NORTH-STAGE 0 equals? IF
    : push-mark> next-token 2 dropn ;
  ELSE
    : push-mark> next-token 3 dropn ;
  THEN
  : push-mark drop ;
  : pop-mark ( stub ) ;
  : top-pop-mark ( stub ) ;
  : push-asm-mark ( stub ) ;
THEN
