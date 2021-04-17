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

def cpio-translate-old-short ( out-header old-header field length -- )
  arg2 arg1 arg0 cpio-old-header struct-get-field-ptr/4 uint16@
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32!
  4 return0-n
end

def cpio-translate-old-long ( out-header old-header field length -- )
  arg2 arg1 arg0 cpio-old-header struct-get-field-ptr/4 cpio-uint32@
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32!
  4 return0-n
end

def cpio-translate-old-header ( out-header old-header -- out-header )
  arg1 arg0 s" magic" cpio-translate-old-short
  arg1 arg0 s" inode" cpio-translate-old-short
  arg1 arg0 s" mode" cpio-translate-old-short
  arg1 arg0 s" uid" cpio-translate-old-short
  arg1 arg0 s" gid" cpio-translate-old-short
  arg1 arg0 s" nlink" cpio-translate-old-short
  arg1 arg0 s" mtime" cpio-translate-old-long
  arg1 arg0 s" namesize" cpio-translate-old-short
  arg1 arg0 s" filesize" cpio-translate-old-long

  arg0 cpio-old-header -> dev uint16@
  arg1 cpio-header -> dev-major uint32!
  arg0 cpio-old-header -> rdev uint16@
  arg1 cpio-header -> rdev-major uint32!

  arg0 2 return1-n
end

def cpio-read-old-header
  0
  cpio-old-header make-instance set-local0
  local0 value-of cpio-old-header struct -> byte-size peek arg0 read-bytes
  negative? IF set-arg0 return0 THEN
  arg1 local0 cpio-translate-old-header
  1 set-arg0
end

def cpio-read-old-header-0 ( header fd -- header ok? )
  arg1 value-of cpio-old-header struct -> byte-size peek arg0 read-bytes set-arg0
end

' cpio-read-old-header
' cpio-pad2
' cpio-pad2
0x71C7
here cpio-format-funs cons const> cpio-old-format
