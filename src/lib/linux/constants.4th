( Constants used as syscall arguments: )

0 defconst> O_RDONLY
1 defconst> O_WRONLY
2 defconst> O_RDWR
3 defconst> O_ACCMODE
64 defconst> O_CREAT
128 defconst> O_EXCL
256 defconst> O_NOCTTY
512 defconst> O_TRUNC
1024 defconst> O_APPEND
2048 defconst> O_NONBLOCK
defalias> O_NDELAY O_NONBLOCK
4096 defconst> O_SYNC
defalias> O_FSYNC O_SYNC
8192 defconst> O_ASYNC
0x20000 defconst> O_LARGEFILE
0x4000 defconst> O_DIRECT
0x8000 defconst> O_LARGEFILE
0x10000 defconst> O_DIRECTORY
0x20000 defconst> O_NOFOLLOW
0x40000 defconst> O_NOATIME
0x80000 defconst> O_CLOEXEC

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

def S_ISREG ( m -- yes? )
  arg0 S_IFMT logand S_IFREG equals? set-arg0
end

def S_ISDIR ( m -- yes? )
  arg0 S_IFMT logand S_IFDIR equals? set-arg0
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
