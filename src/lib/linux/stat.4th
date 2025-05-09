( s[ src/lib/structs.4th src/lib/linux/clock.4th ] load-list )

' timespec UNLESS
  s[ src/lib/linux/clock.4th ] load-list
THEN

DEFINED? defconst> IF
  00170000 defconst> S_IFMT
  0140000 defconst> S_IFSOCK
  0120000 defconst> S_IFLNK
  0100000 defconst> S_IFREG
  0060000 defconst> S_IFBLK
  0040000 defconst> S_IFDIR
  0020000 defconst> S_IFCHR
  0010000 defconst> S_IFIFO
  0004000 defconst> S_ISUID
  0002000 defconst> S_ISGID
  0001000 defconst> S_ISVTX
  00700 defconst> S_IRWXU
  00400 defconst> S_IRUSR
  00200 defconst> S_IWUSR
  00100 defconst> S_IXUSR
  00070 defconst> S_IRWXG
  00040 defconst> S_IRGRP
  00020 defconst> S_IWGRP
  00010 defconst> S_IXGRP
  00007 defconst> S_IRWXO
  00004 defconst> S_IROTH
  00002 defconst> S_IWOTH
  00001 defconst> S_IXOTH

  def S_ISLNK ( m -- yes? )
    arg0 S_IFMT logand S_IFLNK equals? set-arg0
  end

  def S_ISCHR ( m -- yes? )
    arg0 S_IFMT logand S_IFCHR equals? set-arg0
  end

  def S_ISBLK ( m -- yes? )
    arg0 S_IFMT logand S_IFBLK equals? set-arg0
  end

  def S_ISFIFO ( m -- yes? )
    arg0 S_IFMT logand S_IFIFO equals? set-arg0
  end

  def S_ISSOCK ( m -- yes? )
    arg0 S_IFMT logand S_IFSOCK equals? set-arg0
  end

ELSE
  00170000 const> S_IFMT
  0100000 const> S_IFREG
  0040000 const> S_IFDIR
THEN

def S_ISREG ( m -- yes? )
  arg0 S_IFMT logand S_IFREG equals? set-arg0
end

def S_ISDIR ( m -- yes? )
  arg0 S_IFMT logand S_IFDIR equals? set-arg0
end

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
  local0 value-of arg0 fstat negative? IF 0 return1-1 THEN
  local0 exit-frame
end

def stat-path ( path ++ file-stat )
  0 file-stat64 make-instance set-local0
  local0 value-of arg0 stat negative? IF 0 return1-1 THEN
  local0 exit-frame
end

def fd-size64 ( fd -- size-lsb size-msb )
  arg0 stat-fd
  dup IF file-stat64 -> size uint64@ ELSE 0 0 THEN
  swap set-arg0 return1
end

def file-size64 ( path -- size64-lsb size64-msb )
  arg0 stat-path
  dup IF file-stat64 -> size uint64@ ELSE 0 0 THEN
  swap set-arg0 return1
end

def fd-size32
  arg0 fd-size64 drop return1-1
end

def file-size32
  arg0 file-size64 drop return1-1
end

( todo better 32 and 64 bit detection at compile time )
cell-size 8 equals? IF
  alias> fd-size fd-size64
  alias> file-size file-size64
ELSE
  alias> fd-size fd-size32
  alias> file-size file-size32
THEN

( Check if a pathname exists. )
def pathname-exists? ( path -- yes? )
  arg0 stat-path IF true ELSE false THEN return1-1
end

( Check if a pathname is a file. )
def file-exists? ( path -- yes? )
  arg0 stat-path dup IF
    file-stat64 -> mode @ S_ISREG
  ELSE false
  THEN return1-1
end

( Check if a pathname is a directory. )
def directory-exists? ( path -- yes? )
  arg0 stat-path dup IF
    file-stat64 -> mode @ S_ISDIR
  ELSE false
  THEN return1-1
end
