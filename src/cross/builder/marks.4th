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
