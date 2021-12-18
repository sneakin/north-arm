load-core
s[ src/lib/linux/epoll.4th
   src/lib/assert.4th
] load-list

4 const> EPOLL-TEST-NUM-EVENTS

def test-epoll
  0 0 0 0 0
  EpollEvent make-instance set-local0
  EpollEvent EPOLL-TEST-NUM-EVENTS make-struct-seq set-local1
  ( make a pipe to write to and read from )
  locals 3 cell-size * - pipe 0 int>= assert
  ( create an epoll fd )
  0 epoll-create1 4 set-localn
  4 localn 0 int> assert
  ( add the read end of the pipe )
  EPOLLIN local0 EpollEvent -> event !
  12345 local0 EpollEvent -> data1 !
  67890 local0 EpollEvent -> data2 !
  local0 value-of local3 EPOLL-CTL-ADD 4 localn epoll-ctl 0 assert-equals
  ( add the write end of the pipe )
  EPOLLOUT local0 EpollEvent -> event !
  9876 54321 local0 EpollEvent -> data1 uint64!
  ( 9876 local0 EpollEvent -> data2 ! )
  local0 value-of local2 EPOLL-CTL-ADD 4 localn epoll-ctl 0 assert-equals
  ( check that the pipe has write event )
  1 EPOLL-TEST-NUM-EVENTS local1 4 localn epoll-wait 1 assert-equals
  local1 0 EpollEvent struct-seq-nth EpollEvent . event @ EPOLLOUT assert-equals
  local1 0 EpollEvent struct-seq-nth EpollEvent . data1 uint64@
  54321 assert-equals 9876 assert-equals
  ( write to the pipe )
  s" epoll works" swap local2 write 11 assert-equals
  ( poll )
  1 EPOLL-TEST-NUM-EVENTS local1 4 localn epoll-wait 2 assert-equals
  ( check that the pipe has an event )
  local1 0 EpollEvent struct-seq-nth EpollEvent . event @ EPOLLOUT assert-equals
  local1 0 EpollEvent struct-seq-nth EpollEvent . data1 uint64@
  54321 assert-equals 9876 assert-equals
  local1 1 EpollEvent struct-seq-nth EpollEvent . event @ EPOLLIN assert-equals
  local1 1 EpollEvent struct-seq-nth EpollEvent . data1 @ 12345 assert-equals
  local1 1 EpollEvent struct-seq-nth EpollEvent . data2 @ 67890 assert-equals
  ( read the pipe )
  32 stack-allot 32 over local3 read 11 assert-equals
  ( close the epfd and pipe )
  4 localn close 0 assert-equals
  local2 close 0 assert-equals
  local3 close 0 assert-equals
end
