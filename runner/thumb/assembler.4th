def assembler-boot
  int32 64 int32 1024 * data-init-stack
  interp-boot
end
