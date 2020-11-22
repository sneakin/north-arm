" src/cross/builder.4th" load

s[ src/interp/messages.4th
   src/interp/strings.4th
   src/interp/dictionary.4th
   src/interp/output.4th
   src/interp/reader.4th
   src/interp/interp.4th
   src/interp/compiler.4th
   src/interp/data-stack.4th
   src/interp/data-stack-list.4th
   src/runner/thumb/proper.4th
   src/runner/proper.4th
   src/interp/debug.4th
   src/interp/decompiler.4th
   src/cross/defining/proper.4th
   src/interp/cross.4th
   src/lib/stack-marker.4th
   src/lib/strings.4th
   src/lib/assert.4th
   src/runner/tests.4th
   src/interp/tests/write-hex-uint.4th
   src/interp/tests/write-hex-int.4th
   src/runner/tests/rot.4th
   src/interp/tests/reader.4th
   src/runner/tests/overn.4th
   src/runner/tests/math.4th
   src/runner/tests/lognot.4th
   src/runner/tests/logior.4th
   src/runner/tests/logand.4th
   src/runner/tests/dropn.4th
   src/cross/tests/case.4th
   src/runner/tests/bsr.4th
   src/runner/tests/bsl.4th
   src/runner/tests/2dup.4th
   src/runner/tests/proper.4th
   src/runner/tests/float.4th
   src/tests/lib/strings.4th
] const> sources

s" interp-boot" sources builder-run
