target-android? IF
  s[ src/interp/imports/android.4th ] load-list
THEN

target-gnueabi? IF
  s[ src/interp/imports/linux.4th ] load-list
THEN
