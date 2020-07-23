def assembler-boot
  int32 64 int32 1024 * data-init-stack
  int32 64 cell-size * proper-init
  interp-boot
end
