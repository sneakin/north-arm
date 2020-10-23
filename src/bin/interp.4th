4 const> cell-size
4 const> -op-size
( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

src/cross/builder.4th load

' interp-boot
src/lib/strings.4th
src/lib/stack-marker.4th
src/interp/cross.4th
src/cross/defining/proper.4th
src/runner/proper.4th
src/runner/thumb/proper.4th
src/interp/data-stack.4th
src/interp/debug.4th
src/interp/compiler.4th
src/interp/interp.4th
src/interp/reader.4th
src/interp/output.4th
src/interp/dictionary.4th
src/interp/strings.4th
src/interp/messages.4th
15 builder-run/2
