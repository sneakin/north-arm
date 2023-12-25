( Variables: )

( Variables stored directly in the dictionary: )

: does-inplace-var ( init-value word -- )
  dup out' do-inplace-var does
  dict-entry-data uint32!
;

: def-inplace-var> ( init-value : name ++ )
  create> does-inplace-var
;

( Variables stored in the data segmunt: )

0 var> *next-def-data-var-slot* 

NORTH-STAGE 0 equals? IF
: next-def-data-var-slot
  *next-def-data-var-slot* 1 + dup set-*next-def-data-var-slot*
;
: peek-next-def-data-var-slot
  *next-def-data-var-slot*
;

: data-var-slot ;
: data-var-init-value cell-size + ;
ELSE
: next-def-data-var-slot
  *next-def-data-var-slot* inc!
;

: peek-next-def-data-var-slot
  *next-def-data-var-slot* @
;
THEN

: does-def-data-var ( init-value word -- )
  dup out' do-data-var does
  dhere to-out-addr swap dict-entry-data uint32!
  next-def-data-var-slot ,uint32
  ,uint32
;

: def-data-var> ( init-value ++ )
  create> does-def-data-var
;

alias> defvar> def-data-var>
