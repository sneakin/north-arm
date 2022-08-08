64 defconst> return-stack-init-size
64 1024 mult defconst> data-stack-init-size

def assembler-boot
  data-stack-init-size data-init-stack
  return-stack-init-size cell-size int-mul proper-init
  interp-boot
end
