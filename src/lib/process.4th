( Child processes controlled by pipes: )

( todo [e]poll based reactor )

s[ src/lib/linux/process.4th
] load-list

( Children replace stdio but may want to use them. )

standard-input var> parent-input
standard-output var> parent-output

( Container for pipe2's argument: )

struct: fd-pair
value field: output
value field: input

def fd-pair-close
  ( Closes both sides of the pair. )
  arg0 fd-pair . output peek close
  arg0 fd-pair . input peek close
end  

( Processes have a pair of pipes and a process ID: )

struct: process
fd-pair field: input
fd-pair field: output
value field: pid

def process-do-stdio
  ( copy stdio )
  standard-input fd-dup parent-input poke
  standard-output fd-dup parent-output poke
  ( Take over stdio with the process' pipes. )
  standard-input arg0 process -> input fd-pair . output peek fd-dup2
  standard-output arg0 process -> output fd-pair . input peek fd-dup2
  1 return0-n
end

def process-open-pipes
  ( Create new input and output pipes for a process. )
  0 arg0 process -> input pipe2 0 equals?
  O_NONBLOCK arg0 process -> output pipe2 0 equals?
  and 1 return1-n
end

def process-fork ( fn process -- running? )
  ( Start a new system process that calls fn with IO going to the process' pipes. )
  fork dup IF
    dup arg0 process -> pid poke
    negative? not 2 return1-n
  ELSE
    drop
    arg0 process-do-stdio
    arg0 arg1 exec-abs
    abort
  THEN
end

def process-close-input
  ( Close the process' input pipe. )
  arg0 process -> input fd-pair-close
  1 return0-n
end

def process-close-output
  ( Close the process' output pipe. )
  arg0 process -> output fd-pair-close
  1 return0-n
end

def process-close
  ( Close the process' pipes. )
  arg0 process-close-input
  arg0 process-close-output
  1 return0-n
end

def process-check-status
  ( Check's a process' status. )
  arg0 process -> pid peek pid-status 1 return1-n
end

def process-wait
  ( Wait for a process' status. )
  arg0 process -> pid peek waitpid 1 return1-n
end

def process-start-word ( fn process -- ok? )
  ( Open new pipes and fork a new process. )
  arg0 process-open-pipes IF
    arg1 arg0 process-fork IF
      true
    ELSE
      arg0 process-close
      false
    THEN
  ELSE
    false ( todo error )
  THEN 2 return1-n
end

def process-spawn-word/1 ( fn ++ process )
  ( Allocates a new process and starts it interpreting. )
  0
  process make-instance set-local0
  arg0 local0 process-start-word IF
    local0 exit-frame
  ELSE 0 set-arg0
  THEN
end

def process-spawn-interp ( ++ process )
  ' interp process-spawn-word/1 dup IF exit-frame ELSE 0 return1 THEN
end

def process-spawn-cmd ( cmdline ++ process )
  ' os-shell-exec arg0 partial-first process-spawn-word/1
  dup IF exit-frame ELSE 0 set-arg0 THEN
end

def process-write ( str length process -- bytes-wrote )
  ( Write a string to a process' input. )
  arg1 arg2
  arg0 process -> input fd-pair . input peek
  write 3 return1-n
end

def process-write-line ( str length process -- bytes-wrote )
  arg2 arg1 arg0 process-write
  negative? IF 3 return1-n THEN
  nl-s 1 arg0 process-write
  negative? UNLESS drop 1 + THEN 3 return1-n
end

( todo return str & bytes read )

def process-read ( str length process -- bytes-read )
  ( Reads into string the ouput a process has writen to the output pipe. )
  arg1 arg2
  arg0 process -> output fd-pair . output peek
  read 3 return1-n
end

( Could use the reader for buffered processing. )

def process-read-until-loop ( str length process char n -- bytes-read )
  1 arg3 arg0 - uint< IF
    0 here 1 arg2 process-read
    negative? UNLESS
      local0 arg1 equals? UNLESS
	local0 4 argn arg0 poke-off-byte
	arg0 1 + set-arg0
	drop-locals repeat-frame
      THEN
    THEN
  THEN
  4 argn arg0 null-terminate
  arg0 5 return1-n
end

def process-read-until ( str length process char -- bytes-read )
  0 ' process-read-until-loop tail+1
end

def process-read-line ( str length process -- bytes-read )
  0x0A ' process-read-until tail+1
end

def process-print-loop
  arg2 arg1 arg0 process-read
  dup 0 int> IF
    arg2 swap write-string/2
    repeat-frame
  THEN
end

def process-print
  ( Prints out a process' pending output. )
  1024 stack-allot 1024 arg0 process-print-loop
  1 return0-n
end

def process-signal ( signal process -- -errno )
  ( Terminates a process and closes the pipes returning the exit status. )
  arg1 arg0 process -> pid peek kill
  2 return1-n
end  

def process-term
  ( Terminates a process with TERM signal and closes the pipes returning the exit status. )
  SIGTERM arg0 process-signal
  arg0 process-close 1 return1-n
end  

def process-kill
  ( Terminates a process with KILL signal and closes the pipes returning the exit status. )
  SIGKILL arg0 process-signal
  arg0 process-close 1 return1-n
end  
