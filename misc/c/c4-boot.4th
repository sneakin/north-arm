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

create> 41
does> doconst
4 1 int-add 4 int-mul 2 int-mul 1 int-add dict dict-entry-data poke

create> -15
does> doconst
16 1 int-sub -1 int-mul dict dict-entry-data poke

create> (
does> docol
' jumprel ' -15
' return0 ' unlessjump ' 1 ' equals? ' 41
' return0 ' drop ' unlessjump ' 2 ' int<= ' 0 ' dup
' read-byte
here dict dict-entry-data poke

( Whew! Comments can now be made. )

(
create> (
does> docol
[ read-byte
  dup 0 int<= 2 unlessjump drop return0
  41 equals? 1 unlessjump return0
  -15 jumprel
] dict dict-entry-data poke
)

( Using reverse, we can have properly ordered definitions: )

create> ]
does> docol
' return0 ' swap
' reverse ' swap
' roll ' dup ' int-add ' cell-size ' int-add ' cell-size ' here
' swap
' poke ' istate ' exec ' literal
here dict dict-entry-data poke

create> 3
does> doconst
4 1 int-sub dict dict-entry-data poke

create> compiling-exec
does> docol
' return0 ' rpop
' int-add ' 1 ' swap
' jumprel ' 3 ' exec ' unlessjump ' 3
' equals? ' ] ' literal ' dup
' rpush
here dict dict-entry-data poke

create> [
does> docol
' return0 ' swap ' 0
' poke ' istate ' compiling-exec ' literal
here dict dict-entry-data poke

[ 0 1 1 int-add 0 0 0 ] dump-stack

( More demonstration functions: )

create> double
does> docol
[ swap dup int-add swap return0 ]
dict dict-entry-data poke

create> square
does> docol
[ swap dup int-mul swap return0 ]
dict dict-entry-data poke

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

create> immediates
does> dovar
0 dict exec poke

create> copy-entry
does> docol
[ rpush
  dup dict-entry-next peek
  swap dup dict-entry-data peek
  swap dup dict-entry-code peek
  swap dup dict-entry-name peek
  swap drop here rpop return0
] dict dict-entry-data poke

create> immediate
does> docol
[ rpush
  dict copy-entry
  immediates peek over dict-entry-next poke
  immediates poke
  rpop return0
] dict dict-entry-data poke

create> postpone
[ rpush
  0 0 0 0 here cell-size 4 int-mul read-token over cputs
  0 int<= 2 unlessjump rpop return0
  immediates peek lookup
  2 unlessjump rpop return0
  rpop swap return0
] dict dict-entry-data poke
immediate

create> ']
does> docol
' ] dict-entry-data peek dict dict-entry-data poke

create> ;
does> docol
[ rpush '] dict dict-entry-data poke rpop return0
] dict dict-entry-data poke
immediate

create> does
does> docol
[ swap dict-entry-data peek dict dict-entry-code poke return0
] dict dict-entry-data poke

create> 5
does> doconst
4 1 int-add dict dict-entry-data poke
create> 7
does> doconst
5 2 int-add dict dict-entry-data poke
create> 9
does> doconst
5 4 int-add dict dict-entry-data poke
create> 10
does> doconst
5 2 int-mul dict dict-entry-data poke
create> -35
does> doconst
4 10 int-mul 5 int-sub -1 int-mul dict dict-entry-data poke

create> ihey
does> docol
[ 10 write-int return0
] dict dict-entry-data poke
immediate

create> lookup-by-copy ( word dict -- copy yes? )
does> docol
[ over 9 ifjump
  swap drop swap drop
  0 swap over swap return0
  over dict-entry-name peek 3 pick dict-entry-name peek equals?
  7 unlessjump
  roll swap drop swap 1 swap return0
  swap dict-entry-next peek swap -35 jumprel
] dict dict-entry-data poke

create> iwords
does> docol
[ immediates peek words/1 return0
] dict dict-entry-data poke

0 0
' postpone immediates peek lookup-by-copy
dup write-hex-int 2 unlessjump peek cputs
0 write-int ' cputs immediates peek lookup-by-copy write-int write-int
0 write-int

create> immediate-exec
does> docol
[ rpush
  dup immediates peek lookup-by-copy
  5 unlessjump swap drop exec 4 jumprel
  drop swap 1 int-add
  rpop return0
] dict dict-entry-data poke

create> colon[
does> docol
[ literal immediate-exec istate poke
  0 swap return0
] dict dict-entry-data poke

create> :
does> docol
[ rpush
  create>
  literal docol does 
  colon[ rpop return0
] dict dict-entry-data poke

create> jhey
does> docol
[ 8 write-int return0
] dict dict-entry-data poke
immediate

: c-test
  10 write-hex-int
  2 write-int
  ihey
  return0
;

: d-test
  16 write-hex-int
  3 write-int
  return0
;

iwords
c-test
d-test
