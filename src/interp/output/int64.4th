' builder-target-bits defined? IF
  builder-target-bits
  NORTH-PLATFORM platform-target-bash? UNLESS peek THEN
  dup 32 equals? IF
    drop s[ src/interp/output/32/int64.4th ] load-list
  ELSE
    64 equals? IF
      s[ src/interp/output/64/int64.4th ] load-list
    THEN
  THEN
ELSE  
  s[ src/interp/output/32/int64.4th ] load-list
THEN
