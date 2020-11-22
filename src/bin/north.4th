" src/cross/builder.4th" load

(
src/interp/data-stack.4th
src/interp/strings.4th
src/interp/messages.4th
src/interp/output.4th
../north/src/00/shorthand.4th
)

s[ src/interp/data-stack.4th
   src/runner/thumb/proper.4th
   src/runner/proper.4th
   src/north/north.4th
   ../north/src/00/core.4th
   ../north/src/00/output.4th
   ../north/src/00/shorthand.4th
   ../north/src/00/list.4th
   ../north/src/00/compiler.4th
   ../north/src/00/assert.4th
   ../north/src/00/about.4th
   ../north/src/00/init.4th
] const> sources

s" boot" sources builder-run
