( Output dictionary sanity check, load after thumb-asm: )

32 1024 * var> max-output-size

: entry-over? max-output-size peek int> ;

: write-out-word
  dict-entry-name peek from-out-addr write-string space
;

( Verifies output dictionary entry uses output offsets and not real pointers. )
: check-entry
  dup dict-entry-name peek entry-over? UNLESS
    dup dict-entry-code peek entry-over? UNLESS
      dup dict-entry-data peek entry-over? UNLESS
        dup dict-entry-link peek entry-over? UNLESS
          0 proper-exit
  THEN THEN THEN THEN
  write-out-word 1
;

( Checks every output word. )
: check-entries
  out-dict out-origin peek 0 ' check-entry dict-map/4
;
