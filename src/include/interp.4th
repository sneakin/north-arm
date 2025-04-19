( Interpreter )
s[
   src/interp/strings.4th
   src/lib/seq.4th
   src/lib/list.4th
   src/interp/messages.4th
   src/interp/dictionary.4th
   src/lib/fun.4th
   src/interp/strings/partition.4th
   src/lib/seq-fun.4th
   src/lib/assoc.4th
   src/interp/output/strings.4th
   src/interp/output/hex.4th
   src/interp/output/dec.4th
   src/interp/output/bool.4th
   src/interp/characters.4th
   src/interp/reader.4th
   src/interp/numbers.4th
   src/lib/linux/constants.4th
   src/interp/linux/program-args.4th
   src/interp/linux/auxvec.4th
   src/interp/linux/hwcaps.4th
   src/lib/time.4th
   src/interp/data-stack.4th
   src/interp/interp.4th
] load-list

( Compiling )
s[ src/interp/list.4th
   src/interp/compiler.4th
   src/interp/proper.4th
] load-list

( Math: )
s[ src/lib/math/int32.4th
] load-list
   
( Optional features: )
NORTH-STAGE 0 int> IF
s[ src/lib/math/int64.4th
   src/interp/output/int64.4th
   src/interp/debug.4th
   src/interp/decompiler.4th
] load-list
THEN

s[ src/interp/loaders.4th ] load-list

( todo imports.4th interfers with C interop. )
NORTH-STAGE 1 int> IF
  s[ src/interp/imports.4th ] load-list
THEN

( Extra fun )
( s[ src/lib/list.4th
   src/interp/dynlibs.4th
   src/interp/libc.4th ] load-list
)
( tmp" src/cross/defining/proper.4th" drop load )
( tmp" src/interp/cross.4th" drop load )
(
tmp" src/lib/stack-marker.4th" drop load
tmp" src/lib/strings.4th" drop load
)
