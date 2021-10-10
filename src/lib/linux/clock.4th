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

0 const> TIMER-DEFAULT
1 const> TIMER-ABSTIME

struct: timespec
int<32> field: tv_sec
int<32> field: tv_nsec

struct: timeval
int<32> field: sec
uint<64> field: usec

struct: timezone
int<32> field: minuteswest
int<32> field: dsttime

def clock-get-secs ( clock-id -- timestamp )
  0 
  timeval make-instance set-local0
  local0 value-of arg0 clock-gettime
  local0 timeval -> sec peek set-arg0
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

def sleep
  0
  timespec make-instance set-local0
  arg0 local0 timespec -> tv_sec poke
  0 local0 timespec -> tv_nsec poke
  0 local0 value-of nanosleep
  1 return0-n
end

def sleep-until/2 ( time clock-id -- remaining )
  0
  timespec make-instance set-local0
  arg1 local0 timespec -> tv_sec poke
  0 local0 timespec -> tv_nsec poke
  local0 value-of dup TIMER-ABSTIME arg0 clock-nanosleep
  local0 timespec -> tv_sec peek 2 return1-n
end

def sleep-until ( time -- remaining )
  arg0 CLOCK-REALTIME sleep-until/2 set-arg0
end