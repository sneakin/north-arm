s[ src/lib/platform-target.4th
] load-list

( Architecture predicates: )

def target-thumb?
  builder-target platform-target-thumb? return1
end

def target-thumb2?
  builder-target platform-target-thumb2? return1
end

def target-aarch32?
  builder-target platform-target-aarch32? return1
end

def target-aarch64?
  builder-target platform-target-aarch64? return1
end

def target-x86?
  builder-target platform-target-x86? return1
end

def target-amd64?
  builder-target platform-target-amd64? return1
end

( Kernel / OS predicates: )

def target-linux?
  builder-target platform-target-linux? return1
end

def target-win32?
  builder-target platform-target-win32? return1
end

( Linker predicates: )

def target-android?
  builder-target platform-target-android? return1
end

def target-gnueabi?
  builder-target platform-target-gnueabi? return1
end

def target-static?
  builder-target platform-target-static? return1
end
