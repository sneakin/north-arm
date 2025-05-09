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
