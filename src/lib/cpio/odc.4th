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

def cpio-encode-octals ( number ptr length -- )
  arg2 arg1 arg0 8 arg0 48 uint->string/6 3 return0-n
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

def cpio-untranslate-odc-short ( out-header odc-header field length -- )
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32@
  arg2 arg1 arg0 cpio-odc-header struct-get-field-ptr/4 6 cpio-encode-octals
  4 return0-n
end

def cpio-translate-odc-long ( out-header odc-header field length -- )
  arg2 arg1 arg0 cpio-odc-header struct-get-field-ptr/4 11 cpio-decode-octals
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32!
  4 return0-n
end

def cpio-untranslate-odc-long ( out-header odc-header field length -- )
  arg3 arg1 arg0 cpio-header struct-get-field-ptr/4 uint32@
  arg2 arg1 arg0 cpio-odc-header struct-get-field-ptr/4 11 cpio-encode-octals
  4 return0-n
end

def cpio-translate-odc-header ( odc-header cpio-header -- cpio-header )
  arg0 arg1 s" magic" cpio-translate-odc-short
  arg0 arg1 s" inode" cpio-translate-odc-short
  arg0 arg1 s" mode" cpio-translate-odc-short
  arg0 arg1 s" uid" cpio-translate-odc-short
  arg0 arg1 s" gid" cpio-translate-odc-short
  arg0 arg1 s" nlink" cpio-translate-odc-short
  arg0 arg1 s" rdev-major" cpio-translate-odc-short
  arg0 arg1 s" mtime" cpio-translate-odc-long
  arg0 arg1 s" namesize" cpio-translate-odc-short
  arg0 arg1 s" filesize" cpio-translate-odc-long

  arg1 cpio-odc-header -> dev-major 6 cpio-decode-octals
  arg0 cpio-header -> dev-major uint32!
  arg1 cpio-odc-header -> rdev-major 6 cpio-decode-octals
  arg0 cpio-header -> rdev-major uint32!

  arg0 2 return1-n
end

def cpio-read-odc-header
  0
  cpio-odc-header make-instance set-local0
  local0 value-of cpio-odc-header sizeof arg0 read-bytes
  negative? IF set-arg0 return0 THEN
  ( local0 print-instance )
  local0 arg1 cpio-translate-odc-header
  1 set-arg0
end

def cpio-header->odc-header ( cpio-header odc-header -- odc-header )
  0x71C7 arg0 cpio-odc-header -> magic 6 cpio-encode-octals
  arg1 arg0 s" inode" cpio-untranslate-odc-short
  arg1 arg0 s" mode" cpio-untranslate-odc-short
  arg1 arg0 s" uid" cpio-untranslate-odc-short
  arg1 arg0 s" gid" cpio-untranslate-odc-short
  arg1 arg0 s" nlink" cpio-untranslate-odc-short
  arg1 arg0 s" rdev-major" cpio-untranslate-odc-short
  arg1 arg0 s" mtime" cpio-untranslate-odc-long
  arg1 arg0 s" namesize" cpio-untranslate-odc-short
  arg1 arg0 s" filesize" cpio-untranslate-odc-long

  arg1 cpio-header -> dev-major uint32@
  arg0 cpio-odc-header -> dev-major 6 cpio-encode-octals
  arg1 cpio-header -> rdev-major uint32@
  arg0 cpio-odc-header -> rdev-major 6 cpio-encode-octals

  arg0 2 return1-n
end

def cpio-write-odc-header ( cpio-header fd -- true | error false )
  0
  cpio-odc-header make-instance set-local0
  arg1 local0 cpio-header->odc-header
  local0 value-of cpio-odc-header sizeof arg0 write-bytes
  negative? IF false 2 return2-n THEN
  true 2 return1-n
end

' cpio-translate-odc-header
cpio-odc-header
' cpio-write-odc-header
' cpio-read-odc-header
null
null
0x71C7
here cpio-format-funs cons const> cpio-odc-format
