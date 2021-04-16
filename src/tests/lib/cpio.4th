s[ src/lib/cpio.4th
src/lib/linux/types.4th
src/lib/linux/io.4th
src/lib/assert.4th
] load-list

def assert-file-exists
  arg0 file-exists? assert
end

def assert-file-contents ( str len path )
  debug? IF s" read file" write-line/2 THEN
  0 0
  arg1 arg0 allot-read-bytes set-local1 set-local0
  local1 arg1 assert-equals
  local0 arg2 arg1 assert-byte-string-equals/3
end

def print-cpio-header
  arg0 write-hex-uint space
  arg0 cpio-loaded-header -> name peek write-string space
  arg0 cpio-loaded-header -> filesize cpio-uint32@ write-int
  s"  @ " write-string/2
  arg0 cpio-loaded-header -> data uint32@ write-int space
  arg0 cpio-loaded-header -> mtime cpio-uint32@ write-time-stamp space
  arg0 cpio-loaded-header -> mode cpio-uint32@ write-hex-uint space
  arg0 cpio-loaded-header -> magic uint16@ write-hex-uint
  nl
  1 return0-n
end

def assert-cpio-header
  arg0 cpio-loaded-header kind-of? assert
  arg0 cpio-loaded-header -> magic uint16@ 0x71C7 assert-equals
  arg0 cpio-loaded-header -> name peek assert-file-exists

  1 return0-n
end

def assert-cpio-file-contents
  0 0
  debug? IF s" find header" write-line/2 THEN
  arg3 arg2 arg1 cpio-find-file set-local0
  local0 assert
  debug? IF local0 print-instance .s THEN
  local0 UNLESS s" File not in archive." write-line/2 return0 THEN
  local0 cpio-loaded-header -> name peek arg3 arg2 assert-byte-string-equals/3
  local0 cpio-loaded-header -> filesize cpio-uint32@ set-local1

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

57 const> TEST-CPIO-ARCHIVE-SIZE

def test-cpio-read
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
  local1 ' assert-cpio-header map-car
  ( archived file reading )
  s" src/interp/interp.4th" local1 local0 assert-cpio-file-contents
  s" src/lib/list.4th" local1 local0 assert-cpio-file-contents
  s" src/bad-things.4th" local1 assert-cpio-lacks
  
  local0 close
  boom
end

def test-cpio-binary
  ' cpio-read-old-header cpio-header-reader poke
  true *cpio-binary* poke
  " ./misc/cpio/binary.cpio" test-cpio-read
end

def test-cpio-odc
  ' cpio-read-odc-header cpio-header-reader poke
  false *cpio-binary* poke
  " ./misc/cpio/ascii.cpio" test-cpio-read
end

def test-cpio
  test-cpio-binary
  test-cpio-odc
end
