( Interpreter )
tmp" src/interp/messages.4th" drop load
tmp" src/interp/strings.4th" drop load
tmp" src/interp/dictionary.4th" drop load
tmp" src/interp/output.4th" drop load
tmp" src/interp/reader.4th" drop load
tmp" src/interp/interp.4th" drop load

( Compiling )
tmp" src/interp/compiler.4th" drop load
tmp" src/interp/debug.4th" drop load

( Used by core.4th )
tmp" src/interp/data-stack.4th" drop load

( Standand Forth colons )
tmp" src/runner/thumb/proper.4th" drop load
tmp" src/runner/proper.4th" drop load

( Extra fun )
tmp" src/lib/list.4th" drop load
tmp" src/interp/dynlibs.4th" drop load
tmp" src/interp/libc.4th" drop load

( tmp" src/cross/defining/proper.4th" drop load )
( tmp" src/interp/cross.4th" drop load )
(
tmp" src/lib/stack-marker.4th" drop load
tmp" src/lib/strings.4th" drop load
)
