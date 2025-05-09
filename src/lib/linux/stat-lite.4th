DEFINED? defconst> IF
  00170000 defconst> S_IFMT
  0100000 defconst> S_IFREG
  0040000 defconst> S_IFDIR

  def S_ISREG ( m -- yes? )
    arg0 S_IFMT logand S_IFREG equals? set-arg0
  end

  def S_ISDIR ( m -- yes? )
    arg0 S_IFMT logand S_IFDIR equals? set-arg0
  end
THEN

104 defconst> file-stat64-byte-size

def make-file-stat64
  file-stat64-byte-size stack-allot-zero exit-frame
end

def file-stat64-mode arg0 16 + return1-1 end
def file-stat64-size arg0 48 + return1-1 end

def stat-path-value ( path ++ file-stat )
  0 make-file-stat64 set-local0
  local0 arg0 stat negative? IF 0 return1-1 THEN
  local0 exit-frame
end

( Check if a pathname exists. )
def pathname-exists? ( path -- yes? )
  arg0 stat-path-value IF true ELSE false THEN return1-1
end

( Check if a pathname is a file. )
def file-exists? ( path -- yes? )
  arg0 stat-path-value dup IF
    file-stat64-mode @ S_ISREG
  ELSE false
  THEN return1-1
end

( Check if a pathname is a directory. )
def directory-exists? ( path -- yes? )
  arg0 stat-path-value dup IF
    file-stat64-mode @ S_ISDIR
  ELSE false
  THEN return1-1
end
