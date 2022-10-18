( Tests of cpio reading: uses cpio files created by `make test-cpio` which archives the source into archives under "misc/cpio/". )

s[ src/lib/cpio.4th
src/lib/linux/types.4th
src/lib/linux/io.4th
src/lib/assert.4th
src/lib/assertions/io.4th
] load-list

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

def test-cpio
  test-cpio-binary
  test-cpio-odc
  test-cpio-newc
end
