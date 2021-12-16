O_CLOEXEC const> EPOLL-CLOEXEC 
1 const> EPOLL-CTL-ADD 
2 const> EPOLL-CTL-DEL 
3 const> EPOLL-CTL-MOD 
0x00000001 const> EPOLLIN 
0x00000002 const> EPOLLPRI 
0x00000004 const> EPOLLOUT 
0x00000008 const> EPOLLERR 
0x00000010 const> EPOLLHUP 
0x00000020 const> EPOLLNVAL 
0x00000040 const> EPOLLRDNORM 
0x00000080 const> EPOLLRDBAND 
0x00000100 const> EPOLLWRNORM 
0x00000200 const> EPOLLWRBAND 
0x00000400 const> EPOLLMSG 
0x00002000 const> EPOLLRDHUP 
0x10000000 const> EPOLLEXCLUSIVE 
0x20000000 const> EPOLLWAKEUP 
0x40000000 const> EPOLLONESHOT 
0x80000000 const> EPOLLET 

struct: EpollEvent
uint<32> field: events
int<32> field: data ( todo union of 32 and 64 bit values )
int<32> field: data-high

NORTH-PLATFORM tmp" linux" drop contains?
NORTH-PLATFORM tmp" thumb" drop contains? and [IF]
  tmp" src/lib/linux/arm32/epoll.4th" load/2
[ELSE]
  tmp" Unsupported platform" error-line ( todo raise an error )
[THEN]
