def test-reader-read-more
  int32 128 stack-allot
  int32 128 make-stdin-reader
  dup reader-read-more write-hex-int nl
  dup reader-buffer over reader-length write-string/2
  nl
end

def test-reader-top-up
  int32 128 stack-allot
  int32 128 make-stdin-reader
  dup reader-top-up write-hex-int nl
  dup reader-buffer int32 128 write-string/2
  nl
end

def test-reader-read-byte
  int32 128 stack-allot
  int32 128 make-stdin-reader
  dup reader-read-byte write-hex-int nl
  dup reader-read-byte write-hex-int nl
  dup reader-read-byte write-hex-int nl
  dup reader-read-byte write-hex-int nl
end

def test-reader-skip-until
  int32 128 stack-allot
  int32 128 make-stdin-reader
  literal whitespace? over reader-skip-until
  write-hex-int nl
  write-hex-int nl
end

def test-reader-read-until
  int32 128 stack-allot
  int32 0
  begin-frame
    int32 128 stack-allot
    int32 128 make-stdin-reader
    arg0 int32 128 literal whitespace? int32 4 overn reader-read-until
    write-hex-int nl
    write-string/2 nl
    arg0 int32 128 literal not-whitespace? int32 4 overn reader-read-until
    write-hex-int nl
    write-string/2 nl
    arg0 int32 128 literal whitespace? int32 4 overn reader-read-until
    write-hex-int nl
    write-string/2 nl
  end-frame
end

def test-reader-next-token
  int32 128 stack-allot
  int32 0
  begin-frame
    int32 128 stack-allot
    int32 128 make-stdin-reader
    arg0 int32 128 int32 3 overn reader-next-token
    write-hex-int nl
    write-string/2 nl
    arg0 int32 128 int32 3 overn reader-next-token
    write-hex-int nl
    write-string/2 nl
  end-frame
end
