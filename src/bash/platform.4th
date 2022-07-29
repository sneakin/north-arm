( Bash shell platform constants )

0 const> NORTH-STAGE

0xFFFFFFFFFFFFFFFF 1 + 0 equals?
[IF] 0xFFFFFFFF 1 + 0 equals? [IF] 32 [ELSE] 64 [THEN]
[ELSE] 128
[THEN] const> NORTH-BITS

" " " uname -o" system-capture
" -" ++
" " " uname -s" system-capture ++
" -" ++
" " " basename $SHELL" system-capture ++
" tr '[:upper:]' '[:lower:]'" system-capture
const> NORTH-PLATFORM
