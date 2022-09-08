0 defconst> AT-NULL
1 defconst> AT-IGNORE
2 defconst> AT-EXECFD
3 defconst> AT-PHDR
4 defconst> AT-PHENT
5 defconst> AT-PHNUM
6 defconst> AT-PAGESZ
7 defconst> AT-BASE
8 defconst> AT-FLAGS
9 defconst> AT-ENTRY
10 defconst> AT-NOTELF
11 defconst> AT-UID
12 defconst> AT-EUID
13 defconst> AT-GID
14 defconst> AT-EGID
15 defconst> AT-PLATFORM
16 defconst> AT-HWCAP
17 defconst> AT-CLKTCK
23 defconst> AT-SECURE
24 defconst> AT-BASE-PLATFORM
25 defconst> AT-RANDOM
26 defconst> AT-HWCAP2
31 defconst> AT-EXECFN

def auxvec->string
  arg0 ' AT-NULL ' AT-EXECFN cs bound-dict-lookup-by-value
  IF dict-entry-name peek cs int-add ELSE " Unknown" THEN set-arg0
end
