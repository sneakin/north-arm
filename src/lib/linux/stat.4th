( s[ src/lib/structs.4th src/lib/linux/clock.4th ] load-list )

alias> dev_t uint<64>
alias> ino_t uint<64>
alias> mode_t uint<32>
alias> nlink_t uint<32>
alias> uid_t uint<32>
alias> gid_t uint<32>
alias> off_t uint<64>
alias> blksize_t uint<64>
alias> blkcnt_t uint<64>

struct: file-stat64
dev_t field: dev
int<32> field: _padding1
uint<32> field: inode32
mode_t field: mode
nlink_t field: nlink
uid_t field: uid
gid_t field: gid
dev_t field: rdev
int<64> field: _padding2
off_t field: size
blksize_t field: blksize
blkcnt_t field: blocks
timespec field: atime ( fixme timespec64? )
timespec field: mtime
timespec field: ctime
ino_t field: inode

def stat-fd ( fd ++ file-stat )
  0 file-stat64 make-instance set-local0
  local0 value-of arg0 fstat negative? IF 0 1 return1-n THEN
  local0 exit-frame
end

def fd-size64 ( fd -- size-lsb size-msb )
  arg0 stat-fd
  dup IF file-stat64 -> size uint64@ ELSE 0 0 THEN
  swap set-arg0 return1
end

def fd-size32
  arg0 fd-size64 drop 1 return1-n
end

def stat-path ( path ++ file-stat )
  0 file-stat64 make-instance set-local0
  local0 value-of arg0 stat negative? IF 0 1 return1-n THEN
  local0 exit-frame
end

def file-size64 ( path -- size64-lsb size64-msb )
  arg0 stat-path
  dup IF file-stat64 -> size uint64@ ELSE 0 0 THEN
  swap set-arg0 return1
end

def file-size32
  arg0 file-size64 drop 1 return1-n
end

( todo better 32 and 64 bit detection at compile time )
cell-size 8 equals? IF
  alias> fd-size fd-size64
  alias> file-size file-size64
ELSE
  alias> fd-size fd-size32
  alias> file-size file-size32
THEN

( Check if a file exists. )
def file-exists? ( path -- yes? )
  arg0 stat-path IF true ELSE false THEN 1 return1-n
end
