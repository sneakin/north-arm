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
