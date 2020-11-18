load-core

: load-builder
  NORTH-STAGE IF
    " ./src/cross/builder/interp.4th" load
  ELSE
    " ./src/cross/builder/bash.4th" load
  THEN
;

load-builder