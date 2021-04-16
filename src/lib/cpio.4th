( cpio archive reading: )
s[ src/lib/structs.4th
src/lib/time.4th
] load-list

def read-bytes ( ptr len fd -- ptr len )
  arg1 arg2 arg0 read 2 return1-n
end

def allot-read-bytes
  arg0 open-input-file negative? IF 0 set-arg1 0 set-arg0 return0 THEN
  arg1 cell-size + stack-allot arg1 local0 read-bytes
  negative? UNLESS 2dup null-terminate THEN ( todo byte-string-equals? needs? )
  local0 close drop
  exit-frame
end

def cpio-uint32@
  arg0 uint16@ 16 bsl arg0 2 + uint16@ logior set-arg0
end

def cpio-uint32!
  arg1 16 bsl
  arg1 16 bsr logior
  arg0 uint32!
  2 return0-n
end

( todo better switching between formats )
true var> *cpio-binary*

def cpio-pad arg0 1 logand IF arg0 1 + set-arg0 THEN end

( Binary old format headers: )

struct: cpio-old-header
uint<16> field: magic
uint<16> field: dev
uint<16> field: inode
uint<16> field: mode
uint<16> field: uid
uint<16> field: gid
uint<16> field: nlink
uint<16> field: rdev
uint<32> field: mtime
uint<16> field: namesize
uint<32> field: filesize

def cpio-read-old-header ( header fd -- header ok? )
  arg1 value-of cpio-old-header struct -> byte-size peek arg0 read-bytes set-arg0
end

( Octal ascii headers: )

struct: cpio-odc-header
uint<8> 6 seq-field: magic
uint<8> 6 seq-field: dev
uint<8> 6 seq-field: inode
uint<8> 6 seq-field: mode
uint<8> 6 seq-field: uid
uint<8> 6 seq-field: gid
uint<8> 6 seq-field: nlink
uint<8> 6 seq-field: rdev
uint<8> 11 seq-field: mtime
uint<8> 6 seq-field: namesize
uint<8> 11 seq-field: filesize

def cpio-decode-octals ( ptr length )
  arg1 arg0 8 0 0 parse-uint-loop drop 2 return1-n
end

def cpio-translate-odc-short ( out-header odc-header field length -- )
  arg2 arg1 arg0 cpio-odc-header struct-get-field-ptr/4 6 cpio-decode-octals
  arg3 arg1 arg0 cpio-old-header struct-get-field-ptr/4 uint16!
  4 return0-n
end

def cpio-translate-odc-long ( out-header odc-header field length -- )
  arg2 arg1 arg0 cpio-odc-header struct-get-field-ptr/4 11 cpio-decode-octals
  arg3 arg1 arg0 cpio-old-header struct-get-field-ptr/4 cpio-uint32!
  4 return0-n
end

( A Lisp style back quoted macro of the following would be ideal for the field translators:
  arg0 cpio-odc-header -> filesize 11 cpio-decode-octals
  arg1 cpio-old-header -> filesize cpio-uint32!
)

def cpio-translate-odc-header ( out-header odc-header -- out-header )
  arg1 arg0 s" magic" cpio-translate-odc-short
  arg1 arg0 s" dev" cpio-translate-odc-short
  arg1 arg0 s" inode" cpio-translate-odc-short
  arg1 arg0 s" mode" cpio-translate-odc-short
  arg1 arg0 s" uid" cpio-translate-odc-short
  arg1 arg0 s" gid" cpio-translate-odc-short
  arg1 arg0 s" nlink" cpio-translate-odc-short
  arg1 arg0 s" rdev" cpio-translate-odc-short
  arg1 arg0 s" mtime" cpio-translate-odc-long
  arg1 arg0 s" namesize" cpio-translate-odc-short
  arg1 arg0 s" filesize" cpio-translate-odc-long
  arg0 2 return1-n
end

def cpio-read-odc-header
  0
  cpio-odc-header make-instance set-local0
  local0 value-of cpio-odc-header struct -> byte-size peek arg0 read-bytes
  negative? IF set-arg0 return0 THEN
  ( local0 print-instance )
  arg1 local0 cpio-translate-odc-header
  1 set-arg0
end

( Full archive scanning into lists: )

( todo better switching between formats )
' cpio-read-old-header var> cpio-header-reader

( Memory mapping would allow whole the file to be slurped into the struct and string pointers. In memory processing would be what "in binary" loaded with the ELF archive would need, or an IO stream abstraction. IO abstraction necesary for transparent opening. Passing [cloned] FD would fake reading. )

def cpio-read-header-name ( header fd ++ name len )
  arg1 cpio-old-header -> namesize uint16@
  dup cell-size int-add stack-allot-zero
  dup
  local0 *cpio-binary* peek IF cpio-pad THEN
  arg0 read-bytes negative? IF null set-arg1 set-arg0 return0 THEN
  drop local0
  2dup null-terminate
  exit-frame
end

struct: cpio-loaded-header
inherits: cpio-old-header
pointer<any> field: name
uint<32> field: offset
uint<32> field: data

def cpio-skip-to-next-header ( header fd -- ok? )
  ( from the end of a name, seek past the data to the next header )
  arg1 cpio-old-header -> filesize cpio-uint32@
  SEEK-CUR swap *cpio-binary* peek IF cpio-pad THEN arg0 lseek
  2 return1-n
end

def cpio-read-headers/3 ( result counter fd ++ assoc-list number ok? )
  0 
  cpio-loaded-header make-instance set-local0
  ( store file offset )
  SEEK-CUR 0 arg0 lseek negative? IF arg1 arg2 rot exit-frame THEN
  local0 cpio-loaded-header -> offset poke
  ( read header )
  local0 arg0 cpio-header-reader peek exec-abs
  negative? IF arg1 arg2 rot exit-frame THEN
  ( read name )
  local0 arg0 cpio-read-header-name negative? IF arg1 arg2 rot exit-frame THEN
  drop local0 cpio-loaded-header -> name poke
  ( local0 cpio-loaded-header -> name peek write-line )
  ( if entry is last: return list )
  local0 cpio-loaded-header -> name peek s" TRAILER!!!" string-equals?/3 IF
    arg2 arg1 1 int-add 1 exit-frame
  THEN
  ( store offset )
  SEEK-CUR 0 arg0 lseek negative? IF arg1 arg2 rot exit-frame THEN
  local0 cpio-loaded-header -> data poke
  ( add header to list )
  arg2 local0 cons set-arg2
  ( skip data, & repeat )
  local0 arg0 cpio-skip-to-next-header negative? IF arg1 arg2 rot exit-frame THEN
  arg1 1 int-add set-arg1
  repeat-frame
end

def cpio-read-headers
  null 0 arg0 cpio-read-headers/3 exit-frame
end

( Archived file data access: )

def cpio-ready-file ( offset header fd -- ok? )
  ( Position the file to read from header.offset+offset. )
  SEEK-SET
  arg1 cpio-loaded-header -> data peek
  arg2 int-add
  arg0 lseek
  3 return1-n
end

def cpio-read-file/4 ( out-ptr max offset header fd -- out-ptr len )
  ( seek to offset+header.offset )
  arg2 arg1 arg0 cpio-ready-file negative? IF 4 return1-n THEN
  ( read into out-ptr )
  4 argn arg3 arg0 read-bytes
  negative? UNLESS 4 argn over null-terminate THEN
  4 return1-n
end

def cpio-read-file ( header fd ++ ptr len )
  arg1 cpio-old-header -> filesize cpio-uint32@ dup stack-allot-zero
  local0 0 arg1 arg0 cpio-read-file/4 exit-frame
end

def cpio-loaded-header-name@ ( header -- name  )
  arg0 null? IF return0 THEN
  arg0 cpio-loaded-header -> name peek
  set-arg0
end

def cpio-find-file ( name length header-list -- header )
  ' string-equals?/3 arg1 partial-first arg2 partial-first
  arg0 over ' cpio-loaded-header-name@ assoc-fn/3 3 return1-n
end
