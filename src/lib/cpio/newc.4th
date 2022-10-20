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

def cpio-decode-hex ( ptr length -- n )
  arg1 arg0 16 0 0 parse-uint-loop drop 2 return1-n
end

def cpio-encode-hex ( number ptr length -- )
  arg2 arg1 arg0 16 arg0 48 uint->string/6 3 return0-n
end

def cpio-translate-newc-magic ( out-header newc-header field length -- )
  arg2 arg1 arg0 cpio-newc-header struct-get-field-ptr/4 6 cpio-decode-hex
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32!
  4 return0-n
end

def cpio-untranslate-newc-magic ( cpio-header newc-header field length -- )
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32@
  arg2 arg1 arg0 cpio-newc-header struct-get-field-ptr/4 6 cpio-encode-hex
  4 return0-n
end

def cpio-translate-newc-field ( out-header newc-header field length -- )
  arg2 arg1 arg0 cpio-newc-header struct-get-field-ptr/4 8 cpio-decode-hex
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32!
  4 return0-n
end

def cpio-untranslate-newc-field ( cpio-header newc-header field length -- )
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32@
  arg2 arg1 arg0 cpio-newc-header struct-get-field-ptr/4 8 cpio-encode-hex
  4 return0-n
end

def cpio-translate-newc-header ( newc-header cpio-header -- cpio-header )
( missing fields? )
  arg0 arg1 s" magic" cpio-translate-newc-magic
  arg0 arg1 s" inode" cpio-translate-newc-field
  arg0 arg1 s" mode" cpio-translate-newc-field
  arg0 arg1 s" uid" cpio-translate-newc-field
  arg0 arg1 s" gid" cpio-translate-newc-field
  arg0 arg1 s" nlink" cpio-translate-newc-field
  arg0 arg1 s" mtime" cpio-translate-newc-field
  arg0 arg1 s" filesize" cpio-translate-newc-field
  arg0 arg1 s" dev-major" cpio-translate-newc-field
  arg0 arg1 s" dev-minor" cpio-translate-newc-field
  arg0 arg1 s" rdev-major" cpio-translate-newc-field
  arg0 arg1 s" rdev-minor" cpio-translate-newc-field
  arg0 arg1 s" namesize" cpio-translate-newc-field
  arg0 arg1 s" check" cpio-translate-newc-field
  arg0 2 return1-n
end

def cpio-read-newc-header ( cpio-header fd -- cpio-header ok? )
  0
  cpio-newc-header make-instance set-local0
  local0 value-of cpio-newc-header sizeof arg0 read-bytes
  negative? IF set-arg0 return0 THEN
  ( local0 print-instance )
  local0 arg1 cpio-translate-newc-header
  ( arg1 print-instance )
  1 set-arg0
end

def cpio-pad-newc-name
  ( cpio pads the header and name to a four byte boundary. Since the header is not a multiple of four, this is needed: )
  arg0 cpio-newc-header sizeof int-add 4 int-mod
  dup IF 4 swap - arg0 + set-arg0 THEN
end

def cpio-header->newc-header ( cpio-header newc-header -- newc-header )
  ( arg1 arg0 s" magic" cpio-untranslate-newc-magic )
  0x70701 arg0 cpio-newc-header -> magic 6 cpio-encode-hex
  arg1 arg0 s" inode" cpio-untranslate-newc-field
  arg1 arg0 s" mode" cpio-untranslate-newc-field
  arg1 arg0 s" uid" cpio-untranslate-newc-field
  arg1 arg0 s" gid" cpio-untranslate-newc-field
  arg1 arg0 s" nlink" cpio-untranslate-newc-field
  arg1 arg0 s" mtime" cpio-untranslate-newc-field
  arg1 arg0 s" filesize" cpio-untranslate-newc-field
  arg1 arg0 s" dev-major" cpio-untranslate-newc-field
  arg1 arg0 s" dev-minor" cpio-untranslate-newc-field
  arg1 arg0 s" rdev-major" cpio-untranslate-newc-field
  arg1 arg0 s" rdev-minor" cpio-untranslate-newc-field
  arg1 arg0 s" namesize" cpio-untranslate-newc-field
  arg1 arg0 s" check" cpio-untranslate-newc-field
  arg0 2 return1-n
end

def cpio-write-newc-header ( cpio-header fd -- true | error false )
  0
  cpio-newc-header make-instance set-local0
  arg1 local0 cpio-header->newc-header value-of
  cpio-newc-header sizeof arg0 write-bytes
  negative? IF false 2 return2-n THEN
  true 2 return1-n
end

' cpio-translate-newc-header
cpio-newc-header
' cpio-write-newc-header
' cpio-read-newc-header
' cpio-pad4
' cpio-pad-newc-name
0x70701
here cpio-format-funs cons const> cpio-newc-format
