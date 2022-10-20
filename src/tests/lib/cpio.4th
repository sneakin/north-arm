( Tests of cpio reading: uses cpio files created by `make test-cpio` which archives the source into archives under "misc/cpio/". )

s[ src/lib/cpio.4th
src/lib/linux/types.4th
src/lib/linux/io.4th
src/lib/assert.4th
src/lib/assertions/io.4th
] load-list

( CPIO Reading: )

60 const> TEST-CPIO-ARCHIVE-SIZE
" misc/cpio/binary.cpio" string-const> TEST-CPIO-BINARY-ARCHIVE
" misc/cpio/odc.cpio" string-const> TEST-CPIO-ODC-ARCHIVE
" misc/cpio/newc.cpio" string-const> TEST-CPIO-NEWC-ARCHIVE

def print-cpio-header
  arg0 write-hex-uint space
  arg0 cpio-loaded-header -> name peek write-string space
  arg0 cpio-loaded-header -> filesize uint32@ write-int
  s"  @ " write-string/2
  arg0 cpio-loaded-header -> data uint32@ write-int space
  arg0 cpio-loaded-header -> mtime uint32@ write-time-stamp space
  arg0 cpio-loaded-header -> mode uint32@ write-hex-uint space
  arg0 cpio-loaded-header -> magic uint32@ write-hex-uint
  nl
  1 return0-n
end

def assert-cpio-header ( header magic -- )
  arg1 cpio-loaded-header kind-of? assert
  arg1 cpio-loaded-header -> magic uint32@ arg0 assert-equals
  arg1 cpio-loaded-header -> name peek assert-file-exists
  ( todo assert other stats? )
  2 return0-n
end

def assert-cpio-file-contents
  0 0
  debug? IF s" find header" write-line/2 THEN
  arg3 arg2 arg1 cpio-find-file set-local0
  local0 assert
  debug? IF local0 print-instance .s THEN
  local0 UNLESS s" File not in archive." write-line/2 return0 THEN
  local0 cpio-loaded-header -> name peek arg3 arg2 assert-byte-string-equals/3
  local0 cpio-loaded-header -> filesize uint32@ set-local1

  debug? IF s" read file" write-line/2 THEN
  local0 arg0 cpio-read-file negative? IF s" Error reading." error-line/2 arg3 arg2 write-line/2 return0 THEN
  dup local1 assert-equals
  arg3 assert-file-contents

  debug? IF s" ready file" write-line/2 THEN
  0 local0 arg0 cpio-ready-file negative? assert-not
  SEEK-CUR 0 arg0 lseek
  local0 cpio-loaded-header -> data peek assert-equals
end

def assert-cpio-lacks
  arg2 arg1 arg0 cpio-find-file 0 assert-equals
end

def test-cpio-read ( expected-magic path )
  0 0
  arg0 open-input-file set-local0
  local0 negative? IF s" Error opening archive." write-line/2 return0 THEN
  ( header reading )
  local0 cpio-read-headers
  UNLESS s" Error reading headers." write-line/2 return0 THEN
  TEST-CPIO-ARCHIVE-SIZE assert-equals
  set-local1
  ( local1 car print-instance )
  debug? IF local1 ' print-cpio-header map-car THEN
  ' assert-cpio-header arg1 partial-first local1 over map-car
  ( archived file reading )
  s" src/runner/copy.4th" local1 local0 assert-cpio-file-contents
  s" src/runner/frames.4th" local1 local0 assert-cpio-file-contents
  s" src/bad-things.4th" local1 assert-cpio-lacks
  
  local0 close
end

def test-cpio-binary
  0x71C7 TEST-CPIO-BINARY-ARCHIVE test-cpio-read
end

def test-cpio-odc
  0x71C7 TEST-CPIO-ODC-ARCHIVE test-cpio-read
end

def test-cpio-newc
  0x70701 TEST-CPIO-NEWC-ARCHIVE test-cpio-read
end

( CPIO Writing: )

def test-cpio-write-string/6
  0 0 here pipe drop
  0 1024 stack-allot-zero set-local2
  0 cpio-header make-instance set-local3
  ( write the cpio to the pipe )
  s" Hello world!!" s" hello.txt" local0 arg0 cpio-write-string/6 assert
  ( read the pipe )
  local2 1024 local1 read-bytes
  dup
  ( verify amount wrote )
  arg0 cpio-format-header-size 10 + 13 +
  arg0 cpio-format-padder assert-equals
  ( verify file name )
  arg0 cpio-format-header-size local2 + s" hello.txt" assert-byte-string-equals/3
  ( verify the contents )
  arg0 cpio-format-header-size local2 + 10 + s" Hello world!!" assert-byte-string-equals/3
  ( verify the mode indicates file )
  local2 arg0 cpio-format-funs -> header-type @ make-typed-pointer
  local3 arg0 cpio-format->cpio-header
  local3 cpio-header -> mode @ CPIO-MODE-TYPE-MASK logand CPIO-MODE-TYPE-FILE assert-equals
  ( clean up )
  local0 close
  local1 close
  1 return0-n
end

def test-cpio-newc-write-string/6
  cpio-newc-format ' test-cpio-write-string/6 tail+1
end

def test-cpio-odc-write-string/6
  cpio-odc-format ' test-cpio-write-string/6 tail+1
end

def test-cpio-old-write-string/6
  cpio-old-format ' test-cpio-write-string/6 tail+1
end

( todo remove unused format fun fields )

def test-cpio-write-file
  0 0 here pipe drop
  0 4096 stack-allot-zero set-local2
  0 cpio-header make-instance set-local3
  ( write the README )
  " README.org" local0 arg0 cpio-write-file assert
  ( read the pipe )
  local2 4096 local1 read-bytes
  ( verify amount writen = header + name + contents )
  dup
  " README.org" dup string-length 1 +
  arg0 cpio-format-header-size +
  arg0 cpio-format-padder
  swap file-size32 arg0 cpio-format-padder +
  4096 min assert-equals
  ( verify mode indicates a file )
  local2 arg0 cpio-format-funs -> header-type @ make-typed-pointer
  local3 arg0 cpio-format->cpio-header
  local3 cpio-header -> mode @ CPIO-MODE-TYPE-MASK logand CPIO-MODE-TYPE-FILE assert-equals
  ( clean up )
  local0 close
  local1 close
  1 return0-n
end

def test-cpio-newc-write-file
  cpio-newc-format ' test-cpio-write-file tail+1
end

def test-cpio-odc-write-file
  cpio-odc-format ' test-cpio-write-file tail+1
end

def test-cpio-old-write-file
  cpio-old-format ' test-cpio-write-file tail+1
end

def test-cpio-write-directory
  0 0 here pipe drop
  0 4096 stack-allot-zero set-local2
  0 cpio-header make-instance set-local3
  ( write a directory entry )
  s" doc" local0 arg0 cpio-write-directory assert
  ( read the pipe )
  local2 4096 local1 read-bytes debug? IF ,i enl 2dup memdump THEN
  ( verify amount writen = header + name )
  dup
  " doc" string-length 1 +
  arg0 cpio-format-header-size +
  arg0 cpio-format-padder
  4096 min assert-equals
  ( verify mode indicates a directory )
  local2 arg0 cpio-format-funs -> header-type @ make-typed-pointer
  local3 arg0 cpio-format->cpio-header
  local3 cpio-header -> mode @ CPIO-MODE-TYPE-MASK logand CPIO-MODE-TYPE-DIRECTORY assert-equals
  ( clean up )
  local0 close
  local1 close
  1 return0-n
end

def test-cpio-newc-write-directory
  cpio-newc-format ' test-cpio-write-directory tail+1
end

def test-cpio-odc-write-directory
  cpio-odc-format ' test-cpio-write-directory tail+1
end

def test-cpio-old-write-directory
  cpio-old-format ' test-cpio-write-directory tail+1
end

def test-cpio-write-link
  0 0 here pipe drop
  0 4096 stack-allot-zero set-local2
  0 cpio-header make-instance set-local3
  ( write an entry for a symlink )
  s" ../readme.txt" s" doc/readme.txt" local0 arg0 cpio-write-link assert
  ( read the pipe )
  local2 4096 local1 read-bytes debug? IF .s enl ,i enl 2dup memdump THEN
  ( verify amount writen = header + name + link target )
  " doc/readme.txt" string-length 1 +
  arg0 cpio-format-header-size +
  arg0 cpio-format-padder
  dup
  " ../readme.txt" string-length
  arg0 cpio-format-padder +
  4096 min 3 overn assert-equals
  ( verify the link's target )
  local2 + s" ../readme.txt" assert-byte-string-equals/3
  ( verify the mode indicates a link )
  local2 arg0 cpio-format-funs -> header-type @ make-typed-pointer
  local3 arg0 cpio-format->cpio-header
  local3 cpio-header -> mode @ CPIO-MODE-TYPE-MASK logand CPIO-MODE-TYPE-LINK assert-equals
  ( cleanup )
  local0 close
  local1 close
  1 return0-n
end

def test-cpio-newc-write-link
  cpio-newc-format ' test-cpio-write-link tail+1
end

def test-cpio-odc-write-link
  cpio-odc-format ' test-cpio-write-link tail+1
end

def test-cpio-old-write-link
  cpio-old-format ' test-cpio-write-link tail+1
end

def cpio-write-test-file ( path fmt -- )
  0
  arg1 open-output-file set-local0
  s" doc" local0 arg0 cpio-write-directory
  s" Hello" s" hello.txt" local0 arg0 cpio-write-string/6
  s" It works." s" readme.txt" local0 arg0 cpio-write-string/6
  s" ../readme.txt" s" doc/readme.txt" local0 arg0 cpio-write-link
  local0 arg0 cpio-write-trailer
  local0 close
  2 return0-n
end

def test-cpio
  test-cpio-binary
  test-cpio-odc
  test-cpio-newc
  test-cpio-old-write-string/6
  test-cpio-old-write-file
  test-cpio-old-write-directory
  test-cpio-old-write-link
  test-cpio-odc-write-string/6
  test-cpio-odc-write-file
  test-cpio-odc-write-directory
  test-cpio-odc-write-link
  test-cpio-newc-write-string/6
  test-cpio-newc-write-file
  test-cpio-newc-write-directory
  test-cpio-newc-write-link
end
