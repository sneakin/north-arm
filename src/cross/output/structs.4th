( todo type and every super needs to be updated. gets the live sys pointer or crashes checking the manipulated type hierachy. two passes. select and update passes?)
( todo factor )

: map-sys-type-to-out ( sys-type -- out-type ok? )
  dup UNLESS drop false proper-exit THEN
  type-name @ ( ,h enl )
  dup string-length ( 2dup error-line/2 ) 2dup cross-lookup IF
    2 set-overn drop dict-entry-data @ from-out-addr true
  ELSE
    drop s" System type not found: " error-string/2 error-line/2
    false
  THEN
;

def copy-type-to-data ( type-ptr -- data-ptr )
  dhere
  ( copy name to data )
  arg0 value-of type-name @ ,byte-string
  ( copy type struct )
  dhere
  local0 to-out-addr ,uint32 ( name )
  arg0 value-of type-byte-size @ ,uint32
  arg0 value-of type-super @ dup IF value-of map-sys-type-to-out IF to-out-addr ELSE 0 THEN THEN ,uint32
  arg0 value-of type-data @ ,uint32
  local1 to-out-addr
  arg0 type-of value-of map-sys-type-to-out UNLESS type THEN to-out-addr
  dcons 1 return1-n
end

def copy-struct-field-to-data ( field-list sys-struct-field -- out-field-list )
  espace espace arg0 struct-field -> name @ error-string espace
  dhere
  arg0 struct-field -> name @ ,byte-string
  dhere
  over to-out-addr ,uint32
  arg0 struct-field -> type @ value-of map-sys-type-to-out IF to-out-addr ELSE 0 THEN ,uint32
  arg0 struct-field -> offset @ ,uint32
  arg0 struct-field -> byte-size @ ,uint32
  local1 to-out-addr
  struct-field value-of map-sys-type-to-out IF to-out-addr ELSE 0 THEN
  dcons to-out-addr ,h enl
  arg1 swap dcons to-out-addr 1 return1-n
end

def copy-struct-fields-to-data ( sys-struct out-struct -- )
  arg1 value-of struct-fields @ ' copy-struct-field-to-data map-car
  arg0 cdr from-out-addr struct-fields !
  2 return0-n
end

def update-out-struct ( state word -- state )
  arg0 dict-entry-name @ from-out-addr error-line
  arg0 dict-entry-data @
  dup copy-type-to-data
  dup to-out-addr arg0 dict-entry-data !
  over struct kind-of? IF ( todo LUT of types? )
    copy-struct-fields-to-data
  THEN
  arg1 2 return1-n
end

def select-out-type ( [ const-fn count data-cons-accum ] word ++ state )
  arg0 dict-entry-code @ arg1 2 seq-peek equals? IF
    arg0 dict-entry-data @ stack-pointer? IF
      arg0 dict-entry-data @ type kind-of? IF
	arg0 dict-entry-name @ from-out-addr error-line
	arg0 arg1 0 seq-nth push-onto
	arg1 exit-frame
      THEN
    THEN
  THEN
  arg1 2 return1-n
end

def update-structs ( out-dict -- )
  s" Selecting structs:" error-line/2
  out' do-const-offset dict-entry-code @
  0 0 here
  arg0 out-origin @ roll ' select-out-type dict-map/4
  s" Updating structs:" error-line/2
  0 seq-peek ' update-out-struct map-car
  1 return0-n
end

