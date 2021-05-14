s[ src/lib/structs.4th src/lib/time.4th ] load-list

alias> dev_t uint<64>
alias> ino_t uint<64>
alias> mode_t int<32>
alias> nlink_t int<32>
alias> uid_t int<32>
alias> gid_t int<32>
alias> off_t int<64>
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
timespec field: atime
timespec field: mtime
timespec field: ctime
ino_t field: inode

def fd-size
  0 file-stat64 make-instance set-local0
  local0 value-of arg0 fstat
  negative? IF 0 1 return1-n THEN
  local0 file-stat64 -> size uint64@
  swap set-arg0 return1
end

def fd-size32
  arg0 fd-size 1 return1-n
end

def file-size
  0 file-stat64 make-instance set-local0
  local0 value-of arg0 stat
  negative? IF 0 1 return1-n THEN
  local0 file-stat64 -> size uint64@
  swap set-arg0 return1
end

def file-size32
  arg0 file-size 1 return1-n
end
