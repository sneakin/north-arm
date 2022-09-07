" ( fpush -1; finterp ); fpush $?" ' fg-fork set-word!
" fpush $BASHPID" ' getpid set-word!
" fpush $$" ' getppid set-word!
	       
: os-shell-command
  " ( " ++ "  ); fpush $?" swap ++ sys-exec
;

: fg-fork/1
  " feval " ++ os-shell-command
;
