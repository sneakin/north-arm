target-android? [IF]
  s[ src/runner/imports/android.4th ] load-list
[THEN]

target-gnueabi? [IF]
  s[ src/runner/imports/linux.4th ] load-list
[THEN]
