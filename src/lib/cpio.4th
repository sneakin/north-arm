( cpio archive reading: see `man 5 cpio` for a description of the format. )

s[ src/lib/case.4th
   src/lib/structs.4th
   src/lib/time.4th
   src/lib/io.4th
   src/lib/cpio/common.4th
   src/lib/cpio/old.4th
   src/lib/cpio/odc.4th
   src/lib/cpio/newc.4th
] load-list

( Full archive scanning into lists: )

( Memory mapping would allow whole the file to be slurped into the struct and string pointers. In memory processing would be what "in binary" loaded with the ELF archive would need, or an IO stream abstraction. IO abstraction necesary for transparent opening. Passing [cloned] FD would fake reading. )


def cpio-read-header-name ( header fd fmt ++ name len )
  arg2 cpio-header -> namesize uint32@
  dup cell-size int-add stack-allot-zero
  dup
  local0 arg0 cpio-format-funs -> name-padder peek ?exec-abs
  arg1 read-bytes negative? IF null set-arg2 set-arg1 return0 THEN
  drop local0
  2dup null-terminate
  exit-frame
end

def cpio-skip-to-next-header ( header fd fmt -- ok? )
  ( from the end of a name, seek past the data to the next header )
  arg2 cpio-header -> filesize uint32@
  arg0 cpio-format-funs -> file-padder peek ?exec-abs
  SEEK-CUR swap arg1 lseek
  3 return1-n
end

def cpio-magic?
  arg1 arg0 cpio-format-funs -> magic peek equals? 2 return1-n
end

def cpio-read-headers/4 ( result counter fd fmt ++ assoc-list number ok? )
  0 
  cpio-loaded-header make-instance set-local0
  ( todo detect format from magic )
  ( store file offset )
  SEEK-CUR 0 arg1 lseek negative? IF arg2 arg3 rot exit-frame THEN
  local0 cpio-loaded-header -> offset poke
  ( read header )
  local0 arg1 arg0 cpio-format-funs -> header-reader peek exec-abs
  negative? IF arg2 arg3 rot exit-frame THEN
  local0 cpio-header -> magic peek arg0 cpio-magic? UNLESS arg3 arg2 false exit-frame THEN
  ( read name )
  local0 arg1 arg0 cpio-read-header-name negative? IF arg2 arg3 rot exit-frame THEN
  drop local0 cpio-loaded-header -> name poke
  ( local0 cpio-loaded-header -> name peek write-line )
  ( if entry is last: return list )
  local0 cpio-loaded-header -> name peek s" TRAILER!!!" string-equals?/3 IF
    arg3 arg2 1 int-add 1 exit-frame
  THEN
  ( store offset )
  SEEK-CUR 0 arg1 lseek negative? IF arg2 arg3 rot exit-frame THEN
  local0 cpio-loaded-header -> data poke
  ( add header to list )
  arg3 local0 cons set-arg3
  ( skip data, & repeat )
  local0 arg1 arg0 cpio-skip-to-next-header negative? IF arg2 arg3 rot exit-frame THEN
  arg2 1 int-add set-arg2
  repeat-frame
end

def cpio-read-headers/2 ( fd fmt ++ headers )
  ( Read cpio headers using the given format. )
  null 0 arg1 arg0 cpio-read-headers/4 exit-frame
end

def cpio-detect-format ( fd -- fmt ok? )
  ( Determine if the file descriptor readkcpio's old, odc, or newc formats. )
  0 8 stack-allot-zero set-local0
  local0 6 arg0 read-bytes 6 int< IF
    null set-arg0 false return1
  ELSE
    local0 uint16@ cpio-old-format cpio-format-funs -> magic peek equals?
    IF cpio-old-format
    ELSE local0 s" 070707" byte-string-equals?/3
	 IF cpio-odc-format
	 ELSE local0 s" 070701" byte-string-equals?/3
	      IF cpio-newc-format
	      ELSE null
	      THEN
	 THEN
    THEN
  THEN
  ( rewind the file )
  SEEK-CUR -6 arg0 lseek negative?
  ( return function set w/ status )
  IF drop null false
  ELSE drop true
  THEN swap set-arg0 return1
end

( Read a cpio file archive's headers after detecting the archive type. )
def cpio-read-headers
  arg0 cpio-detect-format UNLESS s" Unknown format" error-line/2 null 1 return1-n THEN
  null 0 arg0 local0 cpio-read-headers/4 exit-frame
end

( Archived file data access: )

def cpio-ready-file ( offset header fd -- ok? )
  ( Position the file to read from header.offset+offset. )
  SEEK-SET
  arg1 cpio-loaded-header -> data peek
  arg2 int-add
  arg0 lseek
  3 return1-n
end

def cpio-read-file/4 ( out-ptr max offset header fd -- out-ptr len )
  ( seek to offset+header.offset )
  arg2 arg1 arg0 cpio-ready-file negative? IF 4 return1-n THEN
  ( read into out-ptr )
  4 argn arg3 arg0 read-bytes
  negative? UNLESS 4 argn over null-terminate THEN
  4 return1-n
end

def cpio-read-file ( header fd ++ ptr len )
  ( Read a cpio archived file's contents into a newly allocated buffer. )
  arg1 cpio-header -> filesize uint32@ dup stack-allot-zero
  local0 0 arg1 arg0 cpio-read-file/4 negative? IF null set-arg1 set-arg0 ELSE exit-frame THEN
end

def cpio-loaded-header-name@ ( header -- name  )
  arg0 null? IF return0 THEN
  arg0 cpio-loaded-header -> name peek
  set-arg0
end

def cpio-find-file ( name length header-list -- header )
  ( Find in a list the cpio header by name. )
  ' string-equals?/3 arg1 partial-first arg2 partial-first
  arg0 over ' cpio-loaded-header-name@ assoc-fn/3 3 return1-n
end
