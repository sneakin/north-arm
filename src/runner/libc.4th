library> libc.so
import> clibc-init 0 __libc_init 0
import> cexit 0 exit 1
import> cputs 0 puts 1
import> cprintf/1 0 printf 1
import> cprintf/2 0 printf 2
import> cprintf/3 0 printf 3
import> cprintf/4 0 printf 4
import> cstdin stdin 0 ( todo import-var> or extern> )
import> cstdout stdout 0
import> cstderr stderr 0
import> cfprintf/1 1 fprintf 1
import> cfprintf/2 1 fprintf 2
import> cfprintf/3 1 fprintf 3
import> cfprintf/4 1 fprintf 4
import> catoi 1 atoi 1
import> cgetenv 1 getenv 1
import> catof 1 atof 1
import> crand 1 rand 0
import> csrand 0 srand 1
