0 const> null

( Returns the type of a structure reference. )
def type-of
  arg0 car set-arg0
end

( Returns the value of a structure reference. )
def value-of
  arg0 cdr set-arg0
end

( Boot strap types: )

( Base structure to define a type: )
( struct: type
field: name pointer<string>
field: byte-size value
field: super type
)

" type"
null swap
3 cell-size * swap
here 0 here swap drop dup const> type

def type-name arg0 cell-size 0 * + set-arg0 end
def type-byte-size arg0 cell-size 1 * + set-arg0 end
def type-super arg0 cell-size 2 * + set-arg0 end

def type-super-of?
  arg1 arg0 equals? IF true 2 return1-n THEN
  arg1 UNLESS false 2 return1-n THEN
  arg1 value-of type-super peek set-arg1 repeat-frame
end

def kind-of?
  arg1 type-of arg0 type-super-of? 2 return1-n
end

def byte-size
  arg0 type-of value-of IF type-byte-size ELSE 0 THEN set-arg0
end
