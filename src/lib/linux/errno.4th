1 const> EPERM
2 const> ENOENT
3 const> ESRCH
4 const> EINTR
5 const> EIO
6 const> ENXIO
7 const> E2BIG
8 const> ENOEXEC
9 const> EBADF
10 const> ECHILD
11 const> EAGAIN
12 const> ENOMEM
13 const> EACCES
14 const> EFAULT
15 const> ENOTBLK
16 const> EBUSY
17 const> EEXIST
18 const> EXDEV
19 const> ENODEV
20 const> ENOTDIR
21 const> EISDIR
22 const> EINVAL
23 const> ENFILE
24 const> EMFILE
25 const> ENOTTY
26 const> ETXTBSY
27 const> EFBIG
28 const> ENOSPC
29 const> ESPIPE
30 const> EROFS
31 const> EMLINK
32 const> EPIPE
33 const> EDOM
34 const> ERANGE

35 const> EDEADLK
36 const> ENAMETOOLONG
37 const> ENOLCK
38 const> ENOSYS
39 const> ENOTEMPTY
40 const> ELOOP
11 ( EAGAIN ) const> EWOULDBLOCK
42 const> ENOMSG
43 const> EIDRM
44 const> ECHRNG
45 const> EL2NSYNC
46 const> EL3HLT
47 const> EL3RST
48 const> ELNRNG
49 const> EUNATCH
50 const> ENOCSI
51 const> EL2HLT
52 const> EBADE
53 const> EBADR
54 const> EXFULL
55 const> ENOANO
56 const> EBADRQC
57 const> EBADSLT
35 ( EDEADLK ) const> EDEADLOCK
59 const> EBFONT
60 const> ENOSTR
61 const> ENODATA
62 const> ETIME
63 const> ENOSR
64 const> ENONET
65 const> ENOPKG
66 const> EREMOTE
67 const> ENOLINK
68 const> EADV
69 const> ESRMNT
70 const> ECOMM
71 const> EPROTO
72 const> EMULTIHOP
73 const> EDOTDOT
74 const> EBADMSG
75 const> EOVERFLOW
76 const> ENOTUNIQ
77 const> EBADFD
78 const> EREMCHG
79 const> ELIBACC
80 const> ELIBBAD
81 const> ELIBSCN
82 const> ELIBMAX
83 const> ELIBEXEC
84 const> EILSEQ
85 const> ERESTART
86 const> ESTRPIPE
87 const> EUSERS
88 const> ENOTSOCK
89 const> EDESTADDRREQ
90 const> EMSGSIZE
91 const> EPROTOTYPE
92 const> ENOPROTOOPT
93 const> EPROTONOSUPPORT
94 const> ESOCKTNOSUPPORT
95 const> EOPNOTSUPP
96 const> EPFNOSUPPORT
97 const> EAFNOSUPPORT
98 const> EADDRINUSE
99 const> EADDRNOTAVAIL
100 const> ENETDOWN
101 const> ENETUNREACH
102 const> ENETRESET
103 const> ECONNABORTED
104 const> ECONNRESET
105 const> ENOBUFS
106 const> EISCONN
107 const> ENOTCONN
108 const> ESHUTDOWN
109 const> ETOOMANYREFS
110 const> ETIMEDOUT
111 const> ECONNREFUSED
112 const> EHOSTDOWN
113 const> EHOSTUNREACH
114 const> EALREADY
115 const> EINPROGRESS
116 const> ESTALE
117 const> EUCLEAN
118 const> ENOTNAM
119 const> ENAVAIL
120 const> EISNAM
121 const> EREMOTEIO
122 const> EDQUOT
123 const> ENOMEDIUM
124 const> EMEDIUMTYPE
125 const> ECANCELED
126 const> ENOKEY
127 const> EKEYEXPIRED
128 const> EKEYREVOKED
129 const> EKEYREJECTED
130 const> EOWNERDEAD
131 const> ENOTRECOVERABLE
132 const> ERFKILL
133 const> EHWPOISON

def errno->string ( errno-num -- name )
  arg0 abs-int ' EPERM ' EHWPOISON cs bound-dict-lookup-by-value
  IF dict-entry-name peek cs + ELSE " Unknown" THEN set-arg0
end
