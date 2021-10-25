1 dup write-int
1 int-add dup write-int
1 int-add dup write-int
1 int-add dup write-int
1 int-add write-int

0 0 0 0 here cell-size 4 int-mul read-token create>
over cputs
drop dict swap 0 swap docol swap dup cputs here set-dict
' return0 ' peek ' rpop
' set-dict ' here ' swap ' doconst ' swap 0 ' literal ' swap ' dict
' cputs ' dup
' drop ' read-token cell-size 4 int-mul ' literal ' here 0 ' literal 0 ' literal 0 ' literal 0 ' literal
' rpush ' here
here dict dict-entry-data poke

create> does>
' return0 ' move ' rpop
' poke ' dict-entry-code ' dict
' peek ' dict-entry-data
' unlessjump 1 1 int-add dup int-add 1 int-add ' literal ' lookup ' dict
' read-token cell-size 4 int-mul ' literal ' here 0 ' literal 0 ' literal 0 ' literal 0 ' literal
' rpush ' here
here dict dict-entry-data poke
docol dict dict-entry-code poke

create> ]r
does> docol
' return0 ' swap ' int-add ' cell-size ' here
' poke ' istate ' exec ' literal
here dict dict-entry-data poke

create> compiling-exec
does> docol
' return0 ' rpop
' exec ' unlessjump 1 ' literal
' equals? ' ]r ' literal ' dup
' rpush
here dict dict-entry-data poke

create> r[
does> docol
' return0
' poke ' istate ' compiling-exec ' literal
here dict dict-entry-data poke

dump-stack

r[ 0 1 1 int-add 0 0 0 ]r dump-stack
r[ 1 1 int-add 1 1 1 1 ]r dump-stack

create> double
does> docol
r[ return0 swap int-add dup swap ]r
dict dict-entry-data poke

create> square
does> docol
r[ return0 swap int-mul dup swap ]r
dict dict-entry-data poke

create> ]
does> docol
r[ return0 swap dump-stack
   reverse write-int dup swap
   roll dup int-add cell-size int-add cell-size here
   swap
   poke istate exec literal
]r dict dict-entry-data poke

create> 3
does> doconst
4 1 int-sub dict dict-entry-data poke

create> compiling-exec
does> docol
r[ return0 rpop
   int-add 1 swap
   jumprel 3 exec unlessjump 3
   equals? ] literal dup
   rpush
]r dict dict-entry-data poke

create> [
does> docol
r[ return0 swap 0
   poke istate compiling-exec literal
]r dict dict-entry-data poke

[ 0 1 1 int-add 0 0 0 ] dump-stack

create> a-test
does> docol
[ 1 write-int
  2 write-int
  4 1 int-sub write-int
  4 write-int
  4 1 int-add write-int
  return0
] dict dict-entry-data poke

create> b-test
does> docol
[
  a-test
  1 write-int
  2 write-int
  4 1 int-sub write-int
  4 write-int
  4 1 int-add write-int
  return0
] dict dict-entry-data poke

words

1 double double write-int
1 double square square write-int

a-test
b-test
