DEFINED? NORTH-COMPILE-TIME IF
  alias> early-const> defconst>
  alias> early-var> defvar>
ELSE
  alias> early-const> const>
  alias> early-var> var>
THEN

-1 early-const> LOG-ALL
0 early-const> LOG-NONE

1 early-const> INTERP-LOG-ERROR
2 early-const> INTERP-LOG-WARN
4 early-const> INTERP-LOG-INFO
8 early-const> INTERP-LOG-DEBUG
0x10 early-const> INTERP-LOG-WORDS
0x20 early-const> INTERP-LOG-LOADS
0x40 early-const> INTERP-LOG-DETAILS
0xFF early-const> INTERP-LOG-ALL

0x010000 early-const> LOG-USER-ERROR
0x020000 early-const> LOG-USER-WARN
0x040000 early-const> LOG-USER-INFO
0x080000 early-const> LOG-USER-DEBUG
0xFFFF0000 early-const> LOG-USER-ALL

DEFINED? NORTH-COMPILE-TIME IF false ELSE DEFINED? *interp-log-level* THEN
UNLESS
  INTERP-LOG-ERROR
  INTERP-LOG-WARN logior
  INTERP-LOG-LOADS logior
  LOG-USER-ERROR logior
  LOG-USER-WARN logior
  early-var> *interp-log-level*
THEN

def interp-logs? ( feature -- yes? )
  *interp-log-level* @ arg0 logand 0 uint> set-arg0
end
