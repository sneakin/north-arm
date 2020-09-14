( Any compiled code needs to populate a dictionary
 on the data stack. Each word needs to point to the entry's cell on the data stack.
 )
0 var> dict

: create
  dhere swap dpush
  literal 0 dpush
  dict dpush
  dup set-dict
;

: dict-entry-name 0 + ;
: dict-entry-data 1 + ;
: dict-entry-link 2 + ;

: intern-seq-loop
  dup speek dpush
  2dup equals 1 unless-jump return
  1 + loop
;

: intern-seq
  ( local state )
  here dhere 0 rot
  ( find the end and loop down from it )
  read-terminator stack-find
  dup 4 set-overn
  1 + intern-seq-loop
  ( move results & clean up the stack )
  2 dropn
  over spoke
  here over - 1 -
  dup 3 overn 1 + spoke
  dropn
;

: def
  next-token create
  compiling-read intern-seq
  over dict-entry-data dpoke
;
