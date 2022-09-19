def sigaction ( old-ptr sigaction signal -- result )
  args 3 67 syscall 3 return1-n
end

def setitimer
  args 3 104 syscall 3 return1-n
end

def getitimer
  args 2 105 syscall 2 return1-n
end

def sigreturn
  args 0 119 syscall return1
end

def sigprocmask
  args 3 126 syscall 3 return1-n
end
