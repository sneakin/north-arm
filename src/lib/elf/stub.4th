alias> write-elf-header write-elf32-header
alias> write-elf-ending write-elf32-ending
alias> elf-data-segment-offset elf32-data-segment-offset
alias> elf-data-segment-size elf32-data-segment-size

: elf32-stub
  ' write-elf32-header ' write-elf-header dict-entry-clone-fields
  ' write-elf32-ending ' write-elf-ending dict-entry-clone-fields
  ' elf32-data-segment-offset ' elf-data-segment-offset dict-entry-clone-fields
  ' elf32-data-segment-size ' elf-data-segment-size dict-entry-clone-fields
;

: elf64-stub
  ' write-elf64-header ' write-elf-header dict-entry-clone-fields
  ' write-elf64-ending ' write-elf-ending dict-entry-clone-fields
  ' elf64-data-segment-offset ' elf-data-segment-offset dict-entry-clone-fields
  ' elf64-data-segment-size ' elf-data-segment-size dict-entry-clone-fields
;

NORTH-STAGE 0 equals UNLESS
  : elf32-dynamic-stub
    ' write-elf32-dynamic-header ' write-elf-header dict-entry-clone-fields
    ' write-elf32-dynamic-ending ' write-elf-ending dict-entry-clone-fields
  ;

(
  : elf64-dynamic-stub
    ' write-elf64-dynamic-header ' write-elf-header dict-entry-clone-fields
    ' write-elf64-dynamic-ending ' write-elf-ending dict-entry-clone-fields
  ;
)

THEN
