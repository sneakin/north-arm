( More convenient cpio functions with only a single state object to pass around and that print their results. )

s[ src/lib/cpio.4th src/lib/time.4th ] load-list

( Struct to wrap the state needed to read a cpio archive. )
struct: cpio-archive
pointer<any> field: path
value        field: fd
value        field: size
pointer<any> field: headers

def cpio-open ( path ++ cpio-archive ok? )
  ( Open a cpio archive and return an object that packages up the data to read. )
  0 cpio-archive make-instance set-local0
  arg0 local0 cpio-archive -> path poke
  arg0 open-input-file negative? IF null set-arg0 false return1 THEN
  dup local0 cpio-archive -> fd poke
  cpio-read-headers UNLESS null set-arg0 false return1 THEN
  local0 cpio-archive -> size poke
  local0 cpio-archive -> headers poke
  local0 true exit-frame
end

def cpio-close
  ( Close an opened cpio archive. )
  arg0 cpio-archive -> fd peek close
  -1 arg0 cpio-archive -> fd poke
  0 arg0 cpio-archive -> size poke
  1 return0-n
end

def cpio-print-header
  ( Print a cpio header on a single line. )
  arg0 cpio-loaded-header -> filesize peek write-int tab
  s" @ " write-string/2
  arg0 cpio-loaded-header -> offset peek write-int tab
  arg0 cpio-loaded-header -> mtime peek write-time-stamp tab
  arg0 cpio-loaded-header -> name peek
  arg0 cpio-loaded-header -> namesize peek write-string/2 nl
end

def cpio-list
  ( List the files in a cpio archive. )
  arg0 cpio-archive -> path peek write-string space
  arg0 cpio-archive -> size peek write-uint nl
  arg0 cpio-archive -> headers peek ' cpio-print-header map-car
end

def cpio-stat ( path length cpio-archive -- )
  ( Print the full header for cpio archive's file. )
  arg2 arg1 arg0 cpio-archive -> headers peek cpio-find-file
  dup IF print-instance
      ELSE s" Not found." error-line/2
      THEN 3 return0-n
end

def cpio-open?
  ( Check if a cpio archive still has an open file descriptor. )
  arg0 cpio-archive -> fd peek -1 int> 1 return1-n
end

def cpio-read ( path length cpio-archive -- ptr data-size )
  ( Read a cpio archive's file into a nemly allocated buffer. )
  arg0 cpio-open? UNLESS s" Not opened to read." error-line/2 false 3 return1-n THEN
  arg2 arg1 arg0 cpio-archive -> headers peek cpio-find-file
  dup IF arg0 cpio-archive -> fd peek cpio-read-file
      ELSE s" Not found." error-line/2 null 0
      THEN set-arg1 set-arg2 1 return0-n
end
