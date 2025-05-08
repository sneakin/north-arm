require[ assert linux/stat ]

def test-pathname-exists
  " README.org" pathname-exists? assert
  " README.md" pathname-exists? assert-not
  " src" pathname-exists? assert
end

def test-file-exists
  " README.org" file-exists? assert
  " README.md" file-exists? assert-not
  " src" file-exists? assert-not
end

def test-directory-exists
  " README.org" directory-exists? assert-not
  " README.md" directory-exists? assert-not
  " src" directory-exists? assert
end

def test-stat
  test-pathname-exists
  test-file-exists
  test-directory-exists
end
