( Architecture predicates: )

def platform-target-bash?
  arg0 " bash" string-contains? set-arg0
end

def platform-target-thumb?
  arg0 " thumb" string-contains? set-arg0
end

def platform-target-thumb2?
  arg0 " thumb2" string-contains? set-arg0
end

def platform-target-aarch32?
  arg0 " aarch32" string-contains? set-arg0
end

def platform-target-aarch64?
  arg0 " aarch64" string-contains? set-arg0
end

def platform-target-x86?
  arg0 " x86" string-contains? set-arg0
end

def platform-target-amd64?
  arg0 " amd64" string-contains? set-arg0
end

( Kernel / OS predicates: )
def platform-target-linux?
  arg0 " linux" string-contains? set-arg0
end

def platform-target-win32?
  arg0 " win32" string-contains? set-arg0
end

def platform-target-none?
  arg0 " none" string-contains? set-arg0
end

def platform-target-raspi?
  arg0 " raspi" string-contains? set-arg0
end

( Linker predicates: )

def platform-target-android?
  arg0 " android" string-contains? set-arg0
end

def platform-target-gnueabi?
  arg0 " gnueabi" string-contains? set-arg0
end

def platform-target-static?
  arg0 " static" string-contains? set-arg0
end
