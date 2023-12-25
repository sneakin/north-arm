' NORTH-COMPILE-TIME defined? IF
  s[ src/cross/defining/proper.4th ] load-list
THEN

s[
  src/lib/structs/typing.4th
  src/lib/structs/types.4th
  src/lib/structs/struct.4th
  src/lib/structs/struct-field.4th
  src/lib/structs/defining.4th
  src/lib/structs/pair.4th
  src/lib/structs/array-type.4th
  src/lib/structs/seq-field.4th
  src/lib/structs/writer.4th
  src/lib/structs/seq.4th
] load-list
