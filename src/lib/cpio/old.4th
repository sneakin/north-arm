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

def cpio-untranslate-old-short ( out-header old-header field length -- )
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32@
  arg2 arg1 arg0 cpio-old-header struct-get-field-ptr/4 uint16!
  4 return0-n
end

def cpio-translate-old-long ( out-header old-header field length -- )
  arg2 arg1 arg0 cpio-old-header struct-get-field-ptr/4 cpio-uint32@
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32!
  4 return0-n
end

def cpio-untranslate-old-long ( out-header old-header field length -- )
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32@
  arg2 arg1 arg0 cpio-old-header struct-get-field-ptr/4 cpio-uint32!
  4 return0-n
end

def cpio-translate-old-header ( old-header cpio-header -- cpio-header )
  arg0 arg1 s" magic" cpio-translate-old-short
  arg0 arg1 s" inode" cpio-translate-old-short
  arg0 arg1 s" mode" cpio-translate-old-short
  arg0 arg1 s" uid" cpio-translate-old-short
  arg0 arg1 s" gid" cpio-translate-old-short
  arg0 arg1 s" nlink" cpio-translate-old-short
  arg0 arg1 s" mtime" cpio-translate-old-long
  arg0 arg1 s" namesize" cpio-translate-old-short
  arg0 arg1 s" filesize" cpio-translate-old-long

  arg1 cpio-old-header -> dev uint16@
  arg0 cpio-header -> dev-major uint32!
  arg1 cpio-old-header -> rdev uint16@
  arg0 cpio-header -> rdev-major uint32!

  arg0 2 return1-n
end

def cpio-read-old-header
  0
  cpio-old-header make-instance set-local0
  local0 value-of cpio-old-header sizeof arg0 read-bytes
  negative? IF set-arg0 return0 THEN
  local0 arg1 cpio-translate-old-header
  1 set-arg0
end

def cpio-read-old-header-0 ( header fd -- header ok? )
  arg1 value-of cpio-old-header sizeof arg0 read-bytes set-arg0
end

def cpio-header->old-header ( cpio-header old-header -- old-header )
  0x71C7 arg0 cpio-old-header -> magic uint16!
  arg1 arg0 s" inode" cpio-untranslate-old-short
  arg1 arg0 s" mode" cpio-untranslate-old-short
  arg1 arg0 s" uid" cpio-untranslate-old-short
  arg1 arg0 s" gid" cpio-untranslate-old-short
  arg1 arg0 s" nlink" cpio-untranslate-old-short
  arg1 arg0 s" mtime" cpio-untranslate-old-long
  arg1 arg0 s" namesize" cpio-untranslate-old-short
  arg1 arg0 s" filesize" cpio-untranslate-old-long

  arg1 cpio-header -> dev-major uint32@
  arg0 cpio-old-header -> dev uint16!
  arg1 cpio-header -> rdev-major uint32@
  arg0 cpio-old-header -> rdev uint16!

  arg0 2 return1-n
end

def cpio-write-old-header ( cpio-header fd -- true | error false )
  0
  cpio-old-header make-instance set-local0
  arg1 local0 cpio-header->old-header value-of
  cpio-old-header sizeof arg0 write-bytes
  negative? IF false 2 return2-n THEN
  true 2 return1-n
end

' cpio-translate-old-header
cpio-old-header
' cpio-write-old-header
' cpio-read-old-header
' cpio-pad2
' cpio-pad2
0x71C7
here cpio-format-funs cons const> cpio-old-format
