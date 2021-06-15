s[ src/lib/linux/stat.4th ] load-list

4096 const> PAGE-SIZE

0x1 const> PROT-READ
0x2 const> PROT-WRITE
0x4 const> PROT-EXEC
0x8 const> PROT-SEM
0x0 const> PROT-NONE
0x01000000 const> PROT-GROWSDOWN
0x02000000 const> PROT-GROWSUP

1 const> MAP-SHARED
2 const> MAP-PRIVATE
3 const> MAP-SHARED-VALIDATE
0x0f const> MAP-TYPE
0x10 const> MAP-FIXED
0x20 const> MAP-ANONYMOUS
0x20 const> MAP-ANON
0x0100 const> MAP-GROWSDOWN
0x0800 const> MAP-DENYWRITE
0x1000 const> MAP-EXECUTABLE
0x2000 const> MAP-LOCKED
0x4000 const> MAP-NORESERVE
0x008000 const> MAP-POPULATE
0x010000 const> MAP-NONBLOCK
0x020000 const> MAP-STACK
0x040000 const> MAP-HUGETLB
0x080000 const> MAP-SYNC
0x100000 const> MAP-FIXED-NOREPLACE
0x4000000 const> MAP-UNINITIALIZED

0xFFFFFFD0 const> MMAP-ERRORS

( todo mmap errors have a range )

def mmap-error?
  arg0 MMAP-ERRORS uint> return1
end

def mmap-allot ( size -- ptr size )
  0 -1 MAP-PRIVATE MAP-ANON logior PROT-READ PROT-WRITE logior arg0 0 mmap2
  mmap-error? IF false ELSE arg0 THEN
  swap set-arg0 return1
end

MAP-PRIVATE MAP-ANON logior MAP-STACK logior MAP-GROWSDOWN logior const> MAP-STACK-FLAGS
PROT-READ PROT-WRITE logior ( PROT-GROWSDOWN logior ) const> PROT-STACK-FLAGS

def mmap-stack ( size -- ptr size )
  0 -1 MAP-STACK-FLAGS PROT-STACK-FLAGS arg0 0 mmap2
  mmap-error? IF false ELSE arg0 THEN
  swap set-arg0 return1
end

def mmap-file ( offset size fd prot -- ptr ok? )
  arg3 arg1 MAP-PRIVATE arg0 arg2 0 mmap2
  mmap-error? IF false ELSE true THEN
  set-arg2 set-arg3 2 return0-n
end

def mmap-input-file ( path -- ptr size )
  arg0 open-input-file negative?
  UNLESS
    dup fd-size32
    0 local1 local0 PROT-READ mmap-file
    local0 close drop
    IF set-arg0 local1 return1 THEN
  THEN 0 set-arg0 0 return1
end
