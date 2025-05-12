( todo type and every super needs to be updated. gets the live sys pointer or crashes checking the manipulated type hierachy. two passes. select and update passes?)
( todo factor )

DEFINED? dcons UNLESS
  tmp" src/interp/data-stack-list.4th" load/2
THEN

: map-sys-type-to-out ( sys-type -- out-type ok? )
  dup UNLESS drop false proper-exit THEN
  type-name @ as-code-pointer
  dup string-length 2dup cross-lookup IF
    2 set-overn drop dict-entry-data @ from-out-addr true
  ELSE
    drop s" System type not found: " error-string/2 error-line/2
    false
  THEN
;

def copy-type-to-data ( type-ptr -- data-ptr )
  dhere
  ( copy name to data )
  arg0 value-of type-name @ as-code-pointer ,byte-string
  ( copy type struct )
  dhere
  local0 to-out-addr ,uint32 ( name )
  arg0 value-of type-byte-size @ ,uint32
  arg0 value-of type-super @ dup IF value-of map-sys-type-to-out IF to-out-addr ELSE 0 THEN THEN ,uint32
  arg0 value-of type-data @ ,uint32
  local1 to-out-addr
  arg0 type equals? IF dhere ELSE arg0 type-of value-of map-sys-type-to-out UNLESS type THEN THEN to-out-addr
  dcons 1 return1-n
end

( todo copy fields in second pass to get type pointers right, or dallot types to on declaration so pointer is always out-addr )

def log-output-struct-field
  etab etab arg0 ,h espace struct-field -> name @ as-code-pointer error-string espace
  arg1 to-out-addr ,h espace
  arg0 struct-field -> type @ value-of map-sys-type-to-out IF to-out-addr ELSE 0 THEN ,h espace THEN
  arg0 struct-field -> offset @ ,h espace
  arg0 struct-field -> byte-size @ ,h enl
  2 return0-n
end

def copy-struct-field-to-data ( field-list sys-struct-field -- out-field-list )
  dhere
  arg0 struct-field -> name @ as-code-pointer ,byte-string
  dhere
  INTERP-LOG-DETAILS interp-logs? IF local0 arg0 log-output-struct-field THEN
  over to-out-addr ,uint32
  arg0 struct-field -> type @ value-of map-sys-type-to-out IF to-out-addr ELSE 0 THEN ,uint32
  arg0 struct-field -> offset @ ,uint32
  arg0 struct-field -> byte-size @ ,uint32
  local1 to-out-addr
  struct-field value-of map-sys-type-to-out IF to-out-addr ELSE 0 THEN
  dcons to-out-addr
  arg1 swap dcons to-out-addr 2 return1-n
end

( todo above needs to build a list, no initial null )

def copy-struct-fields-to-data ( out-struct -- )
  arg0 cdr from-out-addr struct-fields @ INTERP-LOG-DETAILS interp-logs? IF ,h enl THEN
  dup IF as-code-pointer 0 ' copy-struct-field-to-data map-car+cs/3 ELSE 0 THEN
  arg0 cdr from-out-addr struct-fields !
  1 return0-n
end

def update-out-struct ( word -- )
  INTERP-LOG-DETAILS interp-logs? IF
    arg0 dict-entry-name @ from-out-addr etab error-string espace
    arg0 dict-entry-data @ .h enl
  THEN
  arg0 dict-entry-data @ copy-type-to-data to-out-addr arg0 dict-entry-data !
  1 return0-n
end

def update-out-struct-fields ( word -- )
  INTERP-LOG-DETAILS interp-logs? IF
    arg0 dict-entry-name @ from-out-addr etab error-string espace
    arg0 dict-entry-data @ .h espace
  THEN
  ( todo structs only? general data values? )
  arg0 dict-entry-data @ from-out-addr copy-struct-fields-to-data
  1 return0-n
end

def select-out-type ( [ const-fn count data-cons-accum ] word ++ state )
  arg0 dict-entry-code @ arg1 2 seq-peek equals? IF
    arg0 dict-entry-data @
    dup type equals?
    IF drop true
    ELSE dup stack-pointer? IF type kind-of? ELSE drop false THEN
    THEN
    IF INTERP-LOG-DETAILS interp-logs? IF arg0 dict-entry-name @ from-out-addr error-line THEN
	     arg0 arg1 0 seq-nth push-onto
	     arg1 exit-frame
    THEN
  THEN
  arg1 2 return1-n
end

def update-structs ( out-dict -- )
  INTERP-LOG-DETAILS interp-logs? IF s" Selecting structs:" error-line/2 THEN
  0
  out' do-const-offset dict-entry-code @
  0 0 here arg0 out-origin @ roll ' select-out-type dict-map/4 set-local0
  INTERP-LOG-DETAILS interp-logs? IF s" Updating structs:" error-line/2 THEN
  local0 0 seq-peek ' update-out-struct map-car
  INTERP-LOG-DETAILS interp-logs? IF s" Updating fields:" error-line/2 THEN
  local0 0 seq-peek ' update-out-struct-fields map-car
  1 return0-n
end

