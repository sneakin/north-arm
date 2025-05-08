tmp" Loading cross compiling words..." error-line/2

s" src/interp/boot/cross/sys-aliases.4th" load/2

SYS:DEFINED? NORTH-COMPILE-TIME UNLESS
  alias> exec-cs exec
  alias> exec exec-abs
THEN

DEFINED? ,uint32 UNLESS
  tmp" src/lib/byte-data.4th" load/2
THEN

DEFINED? out-origin UNLESS
  tmp" src/interp/boot/cross/addressing.4th" load/2
THEN

DEFINED? cross-immediate UNLESS
  tmp" src/interp/boot/cross/immediate.4th" load/2
THEN

DEFINED? out-dictionary UNLESS
  tmp" src/interp/boot/cross/words.4th" load/2
THEN

SYS:DEFINED? NORTH-COMPILE-TIME UNLESS
  tmp" src/interp/boot/cross/owords.4th" load/2
THEN

DEFINED? out' UNLESS
  tmp" src/interp/boot/cross/quote.4th" load/2
THEN

SYS:DEFINED? NORTH-COMPILE-TIME UNLESS
  DEFINED? out-dq-string UNLESS
    tmp" src/interp/boot/cross/readers.4th" load/2
  THEN
THEN
