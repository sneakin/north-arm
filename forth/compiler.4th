( Any compiled code needs to populate a dictionary
 on the data stack. Each word needs to point to the entry's cell on the data stack.
 )
0 var> dict

: create
  dhere swap dpush
  0 dpush
  dict dpush
  dup set-dict
;

: dict-entry-name 0 + ;
: dict-entry-data 1 + ;
: dict-entry-link 2 + ;

: def
  next-token create
  ';' intern-tokens-until
  over dict-entry-data dpoke
;

(
# initial code / header
# compile loop:
## relocate indexes but not data literals
## immediate / compiling words & dictionary
## compiler lookup
# extract strings from data into section
# jumps & loops
)