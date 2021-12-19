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
uint<32> field: padding ( todo may not be needed on all platforms )
int<32> field: data1 ( todo union of 32 and 64 bit values )
int<32> field: data2

NORTH-PLATFORM tmp" linux" drop contains?
NORTH-PLATFORM tmp" thumb" drop contains? and [IF]
  tmp" src/lib/linux/arm32/epoll.4th" load/2
[ELSE]
  tmp" Unsupported platform" error-line ( todo raise an error )
[THEN]

( epoll wrappers forksinglemfile descriptors: )

def poll-fd/3 ( events fd timeout -- ready? || err )
  0 0
  EpollEvent make-instance set-local0
  0 epoll-create1 set-local1
  ( register fd )
  arg2 local0 EpollEvent -> event !
  arg1 local0 EpollEvent -> data1 !
  0 local0 EpollEvent -> data2 !
  local0 value-of arg1 EPOLL-CTL-ADD local1 epoll-ctl
  dup 0 int>= IF
    drop
    ( poll fd )
    arg0 1 local0 value-of local1 epoll-wait
    dup 0 int> IF
      drop
      local0 EpollEvent -> data1 @ arg1 equals? IF 1 THEN
    THEN
  THEN
  local1 close drop
  3 return1-n
end

def poll-fd-in
  EPOLLIN arg1 arg0 poll-fd/3 2 return1-n
end

def poll-fd-out
  EPOLLOUT arg1 arg0 poll-fd/3 2 return1-n
end

def poll-fd
  EPOLLIN EPOLLOUT logior arg1 arg0 poll-fd/3 2 return1-n
end

def polled-read-fd ( buffer max fd timeout -- buffer length )
  arg1 arg0 poll-fd-in
  dup 0 int<= IF 3 return1-n ELSE drop THEN
  ( read fd )
  arg2 arg3 arg1 read
  dup 0 int< IF 3 return1-n THEN
  arg3 over null-terminate
  3 return1-n
end
