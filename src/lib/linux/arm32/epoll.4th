def epoll-create ( size -- epfd )
  args 1 250 syscall 1 return1-n
end

def epoll-create1 ( flags -- epfd )
  args 1 357 syscall 1 return1-n
end

def epoll-ctl ( event-ptr fd op epfd -- result )
  args 4 251 syscall 4 return1-n
end

def epoll-wait ( timeout max-events events epfd -- result )
  args 4 252 syscall 4 return1-n
end

def epoll-pwait ( segsetsize sigset timeout max-events events epfd -- result )
  args 6 syscall 6 return1-n
end
