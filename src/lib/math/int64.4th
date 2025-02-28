' builder-target-bits defined? IF
  builder-target-bits
  NORTH-PLATFORM tmp" bash" drop string-contains? UNLESS peek THEN
  dup 32 equals? IF
    drop s[ src/lib/math/32/int64.4th ] load-list
  ELSE
    64 equals? IF
      s[ src/lib/math/64/int64.4th ] load-list
    THEN
  THEN
ELSE
  s[ src/lib/math/32/int64.4th ] load-list
THEN
