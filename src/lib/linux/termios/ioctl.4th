def tcgetattr ( termios fd -- status )
  arg1 TCGETS arg0 ioctl 2 return1-n
end

def tcsetattr ( termios cmd fd -- status )
  arg2 arg1 arg0 ioctl 3 return1-n
end
