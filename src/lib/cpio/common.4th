( CPIO mode bits: )

0170000 const> CPIO-MODE-TYPE-MASK ( This masks the file type bits. )
0140000 const> CPIO-MODE-TYPE-SOCKET ( File type value for sockets. )
0120000 const> CPIO-MODE-TYPE-LINK ( File type value for symbolic links. For symbolic links, the link body is stored as file data. )
0100000 const> CPIO-MODE-TYPE-FILE ( File type value for regular files. )
0060000 const> CPIO-MODE-TYPE-BLOCKDEV ( File type value for block special devices. )
0040000 const> CPIO-MODE-TYPE-DIRECTORY ( File type value for directories. )
0020000 const> CPIO-MODE-TYPE-CHARDEV ( File type value for character special devices. )
0010000 const> CPIO-MODE-TYPE-FIFO ( File type value for named pipes or FIFOs. )
0004000 const> CPIO-MODE-SUID ( SUID bit. )
0002000 const> CPIO-MODE-SGID ( SGID bit. )
0001000 const> CPIO-MODE-STICKY ( Sticky bit. )
0000777 const> CPIO-MODE-UMASK ( The lower 9 bits specify read/write/execute permissions for world, group, and user following standard POSIX conventions. )

( Format independent struct for cpio headers: )
struct: cpio-header
uint<32> field: magic
uint<32> field: inode
uint<32> field: mode
uint<32> field: uid
uint<32> field: gid
uint<32> field: nlink
uint<32> field: mtime
uint<32> field: filesize
uint<32> field: dev-major
uint<32> field: dev-minor
uint<32> field: rdev-major
uint<32> field: rdev-minor
uint<32> field: namesize
uint<32> field: check

( Struct for a loaded header that includes the name and offsets into the arctive. )
struct: cpio-loaded-header
inherits: cpio-header
pointer<any> field: name
uint<32> field: offset
uint<32> field: data

( cpio stores 32 bit values with the least significant 16 bits at the lower memory address. ) 
def cpio-uint32@ ( addr - value )
  arg0 uint16@ 16 bsl arg0 2 + uint16@ logior set-arg0
end

( Poke a cpio 32 bit value. )
def cpio-uint32! ( value addr -- )
  arg1 16 bsl
  arg1 16 bsr logior
  arg0 uint32!
  2 return0-n
end

def cpio-pad2 arg0 1 logand IF arg0 1 + set-arg0 THEN end
def cpio-pad4 arg0 3 logand dup IF 4 swap - arg0 + set-arg0 THEN end

( Structure to hold cpio file format specialization functions. )
struct: cpio-format-funs
int<32> field: magic
pointer<any> field: name-padder
pointer<any> field: file-padder
pointer<any> field: header-reader
pointer<any> field: header-writer
pointer<any> field: header-type
pointer<any> field: to-cpio-header

def cpio-format-header-size
  arg0 cpio-format-funs -> header-type @ sizeof 1 return1-n
end

def cpio-format-header-writer ( cpio-header fd fmt -- true | error false )
  arg0 cpio-format-funs -> header-writer @
  dup IF droptail-1 ELSE true 3 return1-n THEN
end

def cpio-format-header-reader ( cpio-header fd fmt -- cpio-header ok? )
  arg0 cpio-format-funs -> header-reader @
  dup IF droptail-1 ELSE false 2 return1-n THEN
end

def cpio-format->cpio-header ( fmt-header cpio-header fmt -- cpio-header )
  arg0 cpio-format-funs -> to-cpio-header @
  dup IF droptail-1 ELSE arg2 3 return1-n THEN
end

def cpio-format-padder ( n fmt -- padded-n )
  arg0 cpio-format-funs -> file-padder @
  dup IF droptail-1 ELSE arg1 2 return1-n THEN
end

def cpio-format-name-padder ( n fmt -- padded-n )
  arg0 cpio-format-funs -> name-padder @
  dup IF droptail-1 ELSE arg1 2 return1-n THEN
end

