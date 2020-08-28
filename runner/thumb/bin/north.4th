4 const> cell-size
4 const> -op-size
( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

runner/thumb/builder.4th load

' north-boot
../north/src/00/compiler.4th
../north/src/00/core.4th
runner/thumb/north.4th
runner/thumb/data-stack.4th
runner/thumb/output.4th
runner/thumb/strings.4th
5 builder-run/2
