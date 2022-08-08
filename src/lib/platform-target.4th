( Architecture predicates: )

def platform-target-thumb?
  arg0 " thumb" contains? set-arg0
end

def platform-target-aarch32?
  arg0 " aarch32" contains? set-arg0
end

def platform-target-aarch64?
  arg0 " aarch64" contains? set-arg0
end

def platform-target-x86?
  arg0 " x86" contains? set-arg0
end

def platform-target-amd64?
  arg0 " amd64" contains? set-arg0
end

( Kernel / OS predicates: )
def platform-target-linux?
  arg0 " linux" contains? set-arg0
end

def platform-target-win32?
  arg0 " win32" contains? set-arg0
end

def platform-target-none?
  arg0 " none" contains? set-arg0
end

( Linker predicates: )

def platform-target-android?
  arg0 " android" contains? set-arg0
end

def platform-target-gnueabi?
  arg0 " gnueabi" contains? set-arg0
end

def platform-target-static?
  arg0 " static" contains? set-arg0
end
