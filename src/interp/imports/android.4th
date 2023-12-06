library> libc.so
import> cputs 0 puts 1
import> cgets 1 gets 1
import> crand 1 rand 0
import> csrand 0 srand 1

NORTH-STAGE 3 int> [IF]
  ( todo needs libc to init )
  import-var> c:stdout stdout
  import> c:fputs 1 fputs 2
  ( import-var> c:errno errno )

  library> ffi-test-lib.so
  import-var> n-test-var n_test_var
  import-const> n-test-const n_test_var
  import-value> n-test-value n_test_var
[THEN]
