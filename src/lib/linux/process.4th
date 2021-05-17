1 const> W_NOHANG
2 const> W_UNTRACED
2 const> W_STOPPED
4 const> W_EXITED
8 const> W_CONTINUED
0x1000000 const> W_NOWAIT

def pid-status
  0
  0 W_NOHANG locals arg0 wait4
  local0 1 return1-n
end

def waitpid
  0
  0 0 locals arg0 wait4
  local0 1 return1-n
end
