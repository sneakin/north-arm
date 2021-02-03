library> ld-linux.so.3
library> libdl.so.2
import> dlopen 1 dlopen 2
import> dlsym 1 dlsym 2
import> dlclose 0 dlclose 1
import> dlerror 1 dlerror 0
library> libc.so.6
import> cputs 0 puts 1
import> cgets 1 gets 1
import> crand 1 rand 0
import> csrand 0 srand 1