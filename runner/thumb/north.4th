frame-byte-size defconst> frame-size

alias> doc( ( out-immediate
alias> args( ( out-immediate

defalias> equals equals?
defalias> < int<
defalias> <= int<=
defalias> uint< int<
defalias> uint<= int<=

defcol int>
  rot int<= IF int32 0 ELSE int32 1 THEN swap
endcol

defcol int>=
  rot int< IF int32 0 ELSE int32 1 THEN swap
endcol

defalias> > int>
defalias> >= int>=

def dpush
  return return
end

def dhere
  return return
end

def dmove
  return return
end

def ddrop
  return return
end

defcol dallot-seq
  exit exit
endcol

defcol swapdrop
  rot drop swap
endcol

defcol rotdrop2 ( a b c -- c )
  rot ( a ra c b )
  drop ( a ra c )
  rot drop ( c ra )
endcol

defcol returnN
  exit exit
endcol

defcol set-current-frame
  exit exit
endcol

c: defvar>
  exit exit
;

defvar> stack-top
defvar> *status*
defvar> *state*

c: out-char-code
  next-token char-code
; out-immediate-as char-code

defcol read-byte
  exit exit
endcol

defcol input-reset
  exit exit
endcol

defalias> ! poke
defalias> @ peek
defalias> exec-core-word exec

( read $hex )
( strings )
( recurse )
' repeat-frame ' RECURSE out-immediate/2

( : needs a def? )
( var? token-max-cell-size  tokenizer-error tokenizer-stack)
( roll
call-frame-size
base
not
eos
eval-tos
jump-entry-data
next-param
value-peeker
variable-peeker
code-segment
data-segment
binary-size
lit
*mark*
pointer
immediate-dictuonary
immediate-dict
builtin-dictionary
copyrev-loop
ifthenjump
exit-compiler
call-data-seq
)