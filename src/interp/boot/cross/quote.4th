( Output quote: )

def dallot-next-token
  next-token dup 0 int> IF
    over dhere 3 overn copy-byte-string/3 3 dropn
    dhere dup 3 overn + 1 + cell-size pad-addr dmove
    swap
  ELSE 0 0
  THEN return2
end

: dallot-next-token>
  literal literal
  dallot-next-token
  literal int32 swap
; immediate

( There's out' and out-off' which return the next token's output
address and relative offset. )

: out'
  ( Returns the address of the next token's output word. )
  next-token cross-lookup-or-break
; immediate-as [out']

: out''
  ( The immediate ~out'~ that delays the lookup of the next token until the containing definition is called. The output word's address will be on the stack. )
  POSTPONE dallot-next-token>
  literal cross-lookup-or-break
; immediate-as out'

: out-off'
  ( Returns the offset of the output word named by the next token. Doubles as POSTPONE when cross compiling. )
  next-token cross-lookup-offset-or-break
; immediate-as [out-off']

( fixme POSTPONE needs immediate lookup, but immediate support in the output is needed. )

( fixme word ends up in the binary. )
: out-out-off'
  ( The immediate ~out-off'~ that delays the lookup of the next token until the containing definition is called. The output word's offset will be on the stack. )
  POSTPONE dallot-next-token>
  literal cross-lookup-offset-or-break
; immediate-as out-off'
