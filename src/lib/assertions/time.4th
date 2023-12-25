' time-on-under? defined? UNLESS
  s" src/lib/time.4th" load/2
THEN

def assert-time-on-under ( time seconds -- )
  arg1 arg0 time-on-under? assert
  2 return0-n
end

def assert-time-on-over ( time seconds -- )
  arg1 arg0 time-on-over? assert
  2 return0-n
end
