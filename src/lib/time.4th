( Integer temporal offsets in seconds: )

def secs->years
  arg0 3600 int-div 24 int-div 365 int-div set-arg0
end

def years->secs
  arg0 3600 int-mul 24 int-mul 365 int-mul set-arg0
end

def secs->hours
  arg0 3600 int-div set-arg0
end

def hours->secs
  arg0 3600 int-mul set-arg0
end

def minutes->secs
  arg0 60 int-mul set-arg0
end

def secs->minutes
  arg0 60 int-div set-arg0
end

def secs->days
  arg0 secs->hours 24 int-div set-arg0
end

def days->secs
  arg0 24 int-mul hours->secs set-arg0
end

def secs->months
  arg0 3600 int-div 24 int-div set-arg0
end

def years->months
  arg0 12 int-mul set-arg0
end

( Time stamps indexed from 1970/01/01 0:00:00: )

1970 const> nix-epoch-year
365251 const> days-per-year-100x
days-per-year-100x 12 int-div const> days-per-month-100x

def time-stamp-year
  arg0 secs->years nix-epoch-year int-add set-arg0
end

def start-of-year
  arg0 nix-epoch-year - years->secs set-arg0
end

def time-stamp-day-of-year
  arg0 secs->days 1000 int-mul days-per-year-100x int-mod 1000 int-div set-arg0
end

( todo factor in the correct days of each month )

def time-stamp-month
  arg0 time-stamp-day-of-year 1000 int-mul days-per-month-100x int-div 1 + set-arg0
end

def time-stamp-day-of-month
  arg0 time-stamp-day-of-year 1000 int-mul days-per-month-100x int-mod 1000 int-div 1 + set-arg0
end

def time-stamp-hours
  arg0 arg0 secs->days days->secs int-sub secs->hours set-arg0
end

def time-stamp-minutes
  arg0 arg0 secs->hours hours->secs int-sub secs->minutes set-arg0
end

def time-stamp-seconds
  arg0 60 int-mod set-arg0
end

def write-time
  arg0 time-stamp-hours write-int
  s" :" write-string/2
  arg0 time-stamp-minutes 2 write-padded-uint
  s" :" write-string/2
  arg0 time-stamp-seconds 2 write-padded-uint
  1 return0-n
end

def write-date
  arg0 time-stamp-year write-int
  s" /" write-string/2
  arg0 time-stamp-month 2 write-padded-uint
  s" /" write-string/2
  arg0 time-stamp-day-of-month 2 write-padded-uint
  1 return0-n
end

def write-time-stamp
  arg0 write-date
  space
  arg0 write-time
end

struct: timespec
int<32> field: tv_sec
int<32> field: tv_nsec

struct: timeval
int<32> field: sec
uint<64> field: usec

struct: timezone
int<32> field: minuteswest
int<32> field: dsttime
						  
def get-time-secs
  0 
  timeval make-instance set-local0
  0 local0 value-of sys-get-time-of-day
  local0 timeval -> sec peek return1
end

def get-time-usecs
  0 
  timeval make-instance set-local0
  0 local0 value-of sys-get-time-of-day
  ( local0 timeval -> usec uint64@ return2 )
  local0 timeval -> usec uint32@
  local0 timeval -> usec 4 + uint32@ return2
end
