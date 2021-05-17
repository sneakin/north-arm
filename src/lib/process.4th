( Child processes controlled by pipes: )

( todo [e]poll based reactor )

s[ src/lib/structs.4th
   src/lib/linux/process.4th
] load-list

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

def process-close
  ( Close the process' pipes. )
  arg0 process -> input fd-pair-close
  arg0 process -> output fd-pair-close
  1 return0-n
end

def process-start ( fn process -- ok? )
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

def process-spawn ( ++ process )
  ( Allocates a new process and starts it interpreting. )
  0
  process make-instance set-local0
  ' interp local0 process-start IF
    local0 exit-frame
  ELSE
    0 return1
  THEN
end

def process-write ( str length process -- bytes-wrote )
  ( Write a string to a process' input. )
  arg1 arg2
  arg0 process -> input fd-pair . input peek
  write 3 return1-n
end

def process-read ( str length proress -- bytes-read )
  ( Reads into string the ouput a process has writen to the output pipe. )
  arg1 arg2
  arg0 process -> output fd-pair . output peek
  read 3 return1-n
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

def process-wait
  ( Check's a process' status. )
  arg0 process -> pid peek pid-status 1 return1-n
end

def process-kill
  ( Terminates a process and closes the pipes returning the exit status. )
  SIGTERM arg0 process -> pid peek kill
  arg0 process-close
  arg0 process-wait
  1 return1-n
end  
