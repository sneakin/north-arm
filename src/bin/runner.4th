4 const> cell-size
4 const> -op-size
( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

src/cross/builder.4th load

' interp-boot
src/interp/interp.4th
src/interp/reader.4th
src/interp/output.4th
src/interp/dictionary.4th
src/interp/strings.4th
src/interp/messages.4th
6 builder-run/2
