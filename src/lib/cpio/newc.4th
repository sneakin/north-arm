( Newer hexadecimal ascii format: )
struct: cpio-newc-header
uint<8> 6 seq-field: magic
uint<8> 8 seq-field: inode
uint<8> 8 seq-field: mode
uint<8> 8 seq-field: uid
uint<8> 8 seq-field: gid
uint<8> 8 seq-field: nlink
uint<8> 8 seq-field: mtime
uint<8> 8 seq-field: filesize
uint<8> 8 seq-field: dev-major
uint<8> 8 seq-field: dev-minor
uint<8> 8 seq-field: rdev-major
uint<8> 8 seq-field: rdev-minor
uint<8> 8 seq-field: namesize
uint<8> 8 seq-field: check

def cpio-decode-hex ( ptr length )
  arg1 arg0 16 0 0 parse-uint-loop drop 2 return1-n
end

def cpio-translate-newc-magic ( out-header newc-header field length -- )
  arg2 arg1 arg0 cpio-newc-header struct-get-field-ptr/4 6 cpio-decode-hex
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32!
  4 return0-n
end

def cpio-translate-newc-field ( out-header newc-header field length -- )
  arg2 arg1 arg0 cpio-newc-header struct-get-field-ptr/4 8 cpio-decode-hex
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32!
  4 return0-n
end

def cpio-translate-newc-header ( out-header newc-header -- out-header )
( missing fields? )
  arg1 arg0 s" magic" cpio-translate-newc-magic
  arg1 arg0 s" inode" cpio-translate-newc-field
  arg1 arg0 s" mode" cpio-translate-newc-field
  arg1 arg0 s" uid" cpio-translate-newc-field
  arg1 arg0 s" gid" cpio-translate-newc-field
  arg1 arg0 s" nlink" cpio-translate-newc-field
  arg1 arg0 s" mtime" cpio-translate-newc-field
  arg1 arg0 s" filesize" cpio-translate-newc-field
  arg1 arg0 s" dev-major" cpio-translate-newc-field
  arg1 arg0 s" dev-minor" cpio-translate-newc-field
  arg1 arg0 s" rdev-major" cpio-translate-newc-field
  arg1 arg0 s" rdev-minor" cpio-translate-newc-field
  arg1 arg0 s" namesize" cpio-translate-newc-field
  arg1 arg0 s" check" cpio-translate-newc-field
  arg0 2 return1-n
end

def cpio-read-newc-header
  0
  cpio-newc-header make-instance set-local0
  local0 value-of cpio-newc-header struct -> byte-size peek arg0 read-bytes
  negative? IF set-arg0 return0 THEN
  ( local0 print-instance )
  arg1 local0 cpio-translate-newc-header
  ( arg1 print-instance )
  1 set-arg0
end

def cpio-pad-newc-name
  ( cpio pads the header and name to a four byte boundary. Since the header is not a multiple of four, this is needed: )
  arg0 cpio-newc-header struct -> byte-size peek int-add 4 int-mod
  dup IF 4 swap - arg0 + set-arg0 THEN
end

' cpio-read-newc-header
' cpio-pad4
' cpio-pad-newc-name
0x70701
here cpio-format-funs cons const> cpio-newc-format
