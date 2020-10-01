4 const> cell-size
4 const> -op-size
( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

src/cross/builder.4th load

' north-boot
../north/src/00/compiler.4th
../north/src/00/core.4th
src/north/north.4th
src/interp/data-stack.4th
src/interp/output.4th
src/interp/messages.4th
src/interp/strings.4th
6 builder-run/2
