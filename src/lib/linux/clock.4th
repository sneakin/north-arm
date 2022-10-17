( Constants: )

( The clock IDs: )
0 const> CLOCK-REALTIME                 
1 const> CLOCK-MONOTONIC                
2 const> CLOCK-PROCESS-CPUTIME-ID       
3 const> CLOCK-THREAD-CPUTIME-ID        
4 const> CLOCK-MONOTONIC-RAW            
5 const> CLOCK-REALTIME-COARSE          
6 const> CLOCK-MONOTONIC-COARSE         
7 const> CLOCK-BOOTTIME                 
8 const> CLOCK-REALTIME-ALARM           
9 const> CLOCK-BOOTTIME-ALARM           
11 const> CLOCK-TAI                      

( Timer flags: )
0 const> TIMER-DEFAULT
1 const> TIMER-ABSTIME

( 32 bit: )

( Data structures: )

struct: timespec
int<32> field: tv_sec
int<32> field: tv_nsec

def secs->timespec
  arg0 0 int>= IF
    timespec make-instance
    arg0 over timespec -> tv_sec !
    0 over timespec -> tv_nsec !
    exit-frame
  ELSE 0 1 return1-n
  THEN
end

def nanosecs->timespec
  arg0 0 int>= IF
    timespec make-instance
    arg0 1000000000 divmod 3 overn timespec -> tv_nsec !
    over timespec -> tv_sec !
    exit-frame
  ELSE 0 1 return1-n
  THEN
end

struct: timeval
int<32> field: sec
uint<64> field: usec

struct: timezone
int<32> field: minuteswest
int<32> field: dsttime

( System calls: )

def clock-gettime ( timespec clockid -- result )
  args 2 0x107 syscall 2 return1-n
end

def clock-nanosleep ( timespec-remain timespec-request flags clockid -- result )
  args 4 0x109 syscall 4 return1-n
end

( Convenience wrappers: )

def clock-get-secs ( clock-id -- timestamp )
  0 
  timespec make-instance set-local0
  local0 value-of arg0 clock-gettime
  local0 timespec -> tv_sec peek 1 return1-n
end

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

def timeout->abs-timespec
  arg0 0 int<
  IF 0 1 return1-n
  ELSE get-time-secs arg0 + secs->timespec exit-frame
  THEN
end

def sleep
  arg0 secs->timespec
  0 over value-of nanosleep
  1 return0-n
end

def nsleep
  arg0 nanosecs->timespec
  0 over value-of nanosleep
  1 return0-n
end

def sleep-until/2 ( time clock-id -- time )
  arg1 secs->timespec
  dup value-of dup TIMER-ABSTIME arg0 clock-nanosleep
  over timespec -> tv_sec peek 2 return1-n
end

def sleep-until ( time -- time )
  arg0 CLOCK-REALTIME sleep-until/2 1 return1-n
end


( 64 bit: )

( Data structures: )

struct: timespec64
int<64> field: tv_sec
int<32> field: tv_nsec

struct: timeval64
int<64> field: sec
uint<64> field: usec

( System calls: )

def clock64-gettime ( timespec64 clockid -- result )
  args 2 0x193 syscall 2 return1-n
end

def clock64-nanosleep ( timespec64-remain timespec64-request flags clockid -- result )
  args 4 0x197 syscall 4 return1-n
end

( 64 bit helpers: )

def clock64-get-secs ( clock-id -- timestamp-low timestamp-high )
  0 
  timespec64 make-instance set-local0
  local0 value-of arg0 clock64-gettime
  local0 timespec64 -> tv_sec uint64@
  swap 1 return2-n
end

def get-time64-secs
  CLOCK-TAI clock64-get-secs return2
end

def sleep-until-64/2 ( time-low time-high clock-id -- remaining-low remaining-high )
  0
  timespec64 make-instance set-local0
  arg2 arg1 local0 timespec -> tv_sec uint64!
  0 local0 timespec -> tv_nsec poke
  local0 value-of dup TIMER-ABSTIME arg0 clock64-nanosleep
  local0 timespec -> tv_sec uint64@
  3 return2-n
end

def sleep-until-64 ( time-low time-high -- remaining )
  arg1 arg0 CLOCK-REALTIME sleep-until/2 swap 2 return2-n
end
