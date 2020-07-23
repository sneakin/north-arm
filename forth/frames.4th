( Frame construction & destruction: )

: begin-frame
  current-frame here set-current-frame
;

: end-frame
  current-frame
  0 over int< IF speek set-current-frame ELSE drop THEN
;

: drop-locals
  here current-frame - dropn
;

: forget-frame
  drop-locals end-frame drop
;

( Frame argument accessors: )

: args current-frame 1 - ;
: argn args swap - speek ;
: set-argn args swap - spoke ;
: arg0 args speek ;
: arg1 args 1 - speek ;
: arg2 args 2 - speek ;
: arg3 args 3 - speek ;
: set-arg0 args spoke ;
: set-arg1 args 1 - spoke ;
: set-arg2 args 2 - spoke ;
: set-arg3 args 3 - spoke ;

( Framed definitions: )

: def
  next-token dup error-line
  dup set-this-word
  compile " feval begin-frame " ++ "  return0" swap ++
  swap set-word!
;

' ; immediate-lookup ' end set-immediate!
