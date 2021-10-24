1 dup write-int
1 int-add dup write-int
1 int-add dup write-int
1 int-add dup write-int
1 int-add write-int

0 0 here 16 read-token create>
over cputs
drop dict swap 0 swap docol swap dup cputs here set-dict
' return0 ' peek ' rpop
' set-dict ' here ' swap ' doconst ' swap 0 ' literal ' swap ' dict
' cputs ' dup
' drop ' read-token 16 ' literal ' here 0 ' literal 0 ' literal
' rpush ' here
here dict dict-entry-data poke

create> does>
' return0 ' move ' rpop
' poke ' dict-entry-code ' dict
' peek ' dict-entry-data
' unlessjump 1 1 int-add dup int-add 1 int-add ' literal ' lookup ' dict
' read-token 16 ' literal ' here 0 ' literal 0 ' literal
' rpush ' here
here dict dict-entry-data poke
docol dict dict-entry-code poke

create> ]
does> docol
' return0 ' swap ' int-add ' cell-size ' here
' poke ' istate ' exec ' literal
here dict dict-entry-data poke

create> compiling-exec
does> docol
' return0 ' rpop
' exec ' unlessjump 1 ' literal
' equals? ' ] ' literal ' dup
' rpush
here dict dict-entry-data poke

create> [
does> docol
' return0
' poke ' istate ' compiling-exec ' literal
here dict dict-entry-data poke

dump-stack

[ 0 1 1 int-add 0 0 0 ] dump-stack
[ 1 1 int-add 1 1 1 1 ] dump-stack

create> double
does> docol
[ return0 swap int-add dup swap ]
dict dict-entry-data poke

create> square
does> docol
[ return0 swap int-mul dup swap ]
dict dict-entry-data poke

words

1 double double write-int
1 double square square write-int
