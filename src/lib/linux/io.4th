( IO functions that build from Linux syscalls. )

( Check if a file exists. )
def file-exists? ( path -- yes? )
  0
  Stat64 make-instance set-local0
  local0 value-of arg0 stat 0 int< IF false ELSE true THEN 1 return1-n
end