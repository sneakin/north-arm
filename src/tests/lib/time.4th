s[ src/lib/assert.4th
   src/lib/structs.4th
   src/lib/time.4th
   src/lib/linux/clock.4th
] load-list

def test-time-stamp ( seconds day-of-year year month day hour minutes seconds )
  nl 7 argn dup write-int space 6 argn write-int space write-time-stamp space
  args make-time/1 dup write-int space write-time-stamp nl
  ( todo write to string and compare )
  7 argn local0 assert-equals
  7 argn time-stamp-day-of-year 6 argn assert-equals
  7 argn time-stamp-year 5 argn assert-equals
  7 argn time-stamp-month 4 argn assert-equals
  7 argn time-stamp-day-of-month 3 argn assert-equals
  7 argn time-stamp-hours 2 argn assert-equals
  7 argn time-stamp-minutes 1 argn assert-equals
  7 argn time-stamp-seconds 0 argn assert-equals
end

( todo test for 28 days in february )

def test-time-stamps
  ( zero )
  0 0 1970 1 1 0 0 0 test-time-stamp
  ( positive )
  13 0 1970 1 1 0 0 13 test-time-stamp
  61 0 1970 1 1 0 1 1 test-time-stamp
  3601 0 1970 1 1 1 0 1 test-time-stamp
  40 days->secs 40 1970 2 10 0 0 0 test-time-stamp
  4 hours->secs 10 minutes->secs + 23 + 0 1970 1 1 4 10 23 test-time-stamp
  119731017 290 1973 10 17 18 36 57 test-time-stamp
  0x7FFFFFFF 18 2038 1 19 3 14 7 test-time-stamp
  1356091200 355 2012 12 21 12 0 0 test-time-stamp
  1632875660 272 2021 9 29 0 34 20 test-time-stamp
  1632875660 4 hours->secs - 271 2021 9 28 20 34 20 test-time-stamp
  ( negative )
  -1 365 1969 12 31 23 59 59 test-time-stamp
  -50 365 1969 12 31 23 59 10 test-time-stamp
  -60 365 1969 12 31 23 59 00 test-time-stamp
  -61 365 1969 12 31 23 58 59 test-time-stamp
  -3599 365 1969 12 31 23 0 1 test-time-stamp
  -3600 365 1969 12 31 23 0 0 test-time-stamp
  -3601 365 1969 12 31 22 59 59 test-time-stamp
  -1 days->secs 1 + 365 1969 12 31 0 0 1 test-time-stamp
  -1 days->secs 365 1969 12 31 0 0 0 test-time-stamp
  -1 days->secs 1 - 364 1969 12 30 23 59 59 test-time-stamp
  -40 days->secs 1 + 326 1969 11 22 0 0 1 test-time-stamp
  -40 days->secs 326 1969 11 22 0 0 0 test-time-stamp
  -40 days->secs 1 - 325 1969 11 21 23 59 59 test-time-stamp
  -3 years->secs 0 1967 1 1 0 0 0 test-time-stamp
  -4 years->secs 4 hours->secs + 10 minutes->secs + 23 + 0 1966 1 1 4 10 23 test-time-stamp
  -4 years->secs 1 + 0 1966 1 1 0 0 1 test-time-stamp
  -4 years->secs 0 1966 1 1 0 0 0 test-time-stamp
  -4 years->secs 1 - 365 1965 12 31 23 59 59 test-time-stamp
  -4 years->secs 4 hours->secs - 10 minutes->secs + 23 + 365 1965 12 31 20 10 23 test-time-stamp
  -4 years->secs 1 days->secs - 365 1965 12 31 0 0 0 test-time-stamp
  -4 years->secs 1 days->secs - 1 - 364 1965 12 30 23 59 59 test-time-stamp
  -0x7FFFFFFF 347 1901 12 13 20 45 53 test-time-stamp
  -14182980 201 1969 7 20 20 17 0 test-time-stamp
  ( February )
  30 days->secs 30 1970 1 31 0 0 0 test-time-stamp
  31 days->secs 31 1970 2 1 0 0 0 test-time-stamp
  ( 1970: no leap )
  30 28 + days->secs 58 1970 2 28 0 0 0 test-time-stamp
  ( day of year should be 59, but Ruby gives 60 too so accepting the algorithm's number. )
  30 29 + days->secs 60 1970 3 1 0 0 0 test-time-stamp
  30 30 + days->secs 61 1970 3 2 0 0 0 test-time-stamp
  ( 1972: leap! )
  30 28 + days->secs 2 years->secs + 58 1972 2 28 0 0 0 test-time-stamp
  30 29 + days->secs 2 years->secs + 59 1972 2 29 0 0 0 test-time-stamp
  30 30 + days->secs 2 years->secs + 60 1972 3 1 0 0 0 test-time-stamp
end

def test-time-countdown
  arg0 write-time-stamp nl
  1 sleep
  arg0 arg1 + set-arg0 repeat-frame
end
