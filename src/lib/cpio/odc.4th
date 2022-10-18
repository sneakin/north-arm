( Octal ascii headers: )

struct: cpio-odc-header
uint<8> 6 seq-field: magic
uint<8> 6 seq-field: dev-major
uint<8> 6 seq-field: inode
uint<8> 6 seq-field: mode
uint<8> 6 seq-field: uid
uint<8> 6 seq-field: gid
uint<8> 6 seq-field: nlink
uint<8> 6 seq-field: rdev-major
uint<8> 11 seq-field: mtime
uint<8> 6 seq-field: namesize
uint<8> 11 seq-field: filesize

def cpio-decode-octals ( ptr length )
  arg1 arg0 8 0 0 parse-uint-loop drop 2 return1-n
end

( A Lisp style back quoted macro of the following would be ideal for the field translators:
  arg0 cpio-odc-header -> filesize 11 cpio-decode-octals
  arg1 cpio-old-header -> filesize cpio-uint32!
)

def cpio-translate-odc-short ( out-header odc-header field length -- )
  arg2 arg1 arg0 cpio-odc-header struct-get-field-ptr/4 6 cpio-decode-octals
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32!
  4 return0-n
end

def cpio-translate-odc-long ( out-header odc-header field length -- )
  arg2 arg1 arg0 cpio-odc-header struct-get-field-ptr/4 11 cpio-decode-octals
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32!
  4 return0-n
end

def cpio-translate-odc-header ( out-header odc-header -- out-header )
  arg1 arg0 s" magic" cpio-translate-odc-short
  arg1 arg0 s" inode" cpio-translate-odc-short
  arg1 arg0 s" mode" cpio-translate-odc-short
  arg1 arg0 s" uid" cpio-translate-odc-short
  arg1 arg0 s" gid" cpio-translate-odc-short
  arg1 arg0 s" nlink" cpio-translate-odc-short
  arg1 arg0 s" rdev-major" cpio-translate-odc-short
  arg1 arg0 s" mtime" cpio-translate-odc-long
  arg1 arg0 s" namesize" cpio-translate-odc-short
  arg1 arg0 s" filesize" cpio-translate-odc-long

  arg0 cpio-odc-header -> dev-major 6 cpio-decode-octals
  arg1 cpio-header -> dev-major uint32!
  arg0 cpio-odc-header -> rdev-major 6 cpio-decode-octals
  arg1 cpio-header -> rdev-major uint32!

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

' cpio-read-odc-header
null
null
0x71C7
here cpio-format-funs cons const> cpio-odc-format
