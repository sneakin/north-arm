( Interpreter )
s[ src/interp/messages.4th
   src/interp/strings.4th
   src/interp/dictionary.4th
   src/interp/output.4th
   src/interp/reader.4th
   src/interp/interp.4th ] load-list

( Compiling )
s[ src/interp/compiler.4th
   src/interp/debug.4th ] load-list

( Used by core.4th )
s[ src/interp/data-stack.4th ] load-list

( Standand Forth colons )
s[ src/runner/thumb/proper.4th
   src/runner/proper.4th ] load-list

( Extra fun )
s[ src/lib/list.4th
   src/interp/dynlibs.4th
   src/interp/libc.4th ] load-list

( tmp" src/cross/defining/proper.4th" drop load )
( tmp" src/interp/cross.4th" drop load )
(
tmp" src/lib/stack-marker.4th" drop load
tmp" src/lib/strings.4th" drop load
)
