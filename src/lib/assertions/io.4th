( Input and output assertions: )

( Assert a file exists. )
def assert-file-exists ( path -- )
  arg0 file-exists? assert
  1 return0-n
end

def assert-file-contents ( str len path -- )
  debug? IF s" read file" write-line/2 THEN
  0 0
  arg1 arg0 allot-read-bytes set-local1 set-local0
  local1 arg1 assert-equals
  local0 arg2 arg1 assert-byte-string-equals/3
  3 return0-n
end
