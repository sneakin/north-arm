s[ src/interp/boot/core.4th
   src/interp/boot/data-segment.4th
   src/interp/boot/vars.4th
   src/interp/literalizers/int64.4th
   src/interp/dictionary/bound-lookup.4th
   src/lib/linux/errno.4th
   src/lib/byte-data.4th
   src/lib/case.4th
] load-list

NORTH-BUILD-TIME 1634096442 int<= IF
  s[ src/lib/fun.4th ] load-list
THEN

s[ src/lib/escaped-strings.4th
   src/interp/data-stack-list.4th
   src/runner/ffi.4th
] load-list

DEFINED? dlopen IF
  s" src/interp/dynlibs.4th" load/2
THEN

s[ src/interp/signals.4th
   src/interp/tty.4th
   src/interp/dictionary/revmap.4th
   src/interp/dictionary/dump.4th
   src/lib/math.4th
] load-list

SYS:DEFINED? NORTH-COMPILE-TIME UNLESS
  DEFINED? as-code-pointer UNLESS
    s[ src/lib/pointers.4th
       src/lib/list-cs.4th
    ] load-list
  THEN
  s[ src/lib/structs.4th ] load-list
THEN

s[ src/lib/linux.4th
   src/lib/io.4th
   src/lib/pathname.4th
   src/interp/require.4th
   src/interp/mark.4th
] load-list

def load-core true return1 end

def core-init
  math-init
  signals-init
  tty-init
  exit-frame
end ( todo at-start )
