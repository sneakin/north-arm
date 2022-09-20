( Integer temporal offsets in seconds: )

36525 const> days-per-year-100x
days-per-year-100x 12 int-div const> days-per-month-100x

36525 defconst> days-per-year-100x
days-per-year-100x 12 int-div defconst> days-per-month-100x

def secs->hours
  arg0 3600 floored-div set-arg0
end

def hours->secs
  arg0 3600 int-mul set-arg0
end

def minutes->secs
  arg0 60 int-mul set-arg0
end

def secs->minutes
  arg0 60 floored-div set-arg0
end

def secs->days
  arg0 secs->hours 24 floored-div set-arg0
end

def days->secs
  arg0 24 int-mul hours->secs set-arg0
end

def days->years
  arg0 100 int-mul days-per-year-100x floored-div set-arg0
end

def secs->years
  arg0 secs->days days->years set-arg0
end

def years->days
  arg0 days-per-year-100x int-mul 100 floored-div set-arg0
end

def years->secs
  arg0 years->days days->secs set-arg0
end

def years->months
  arg0 12 int-mul set-arg0
end

( Time stamps are the number of seconds since the start of the Unix epoch: 1970/01/01 0:00:00. )

1970 const> nix-epoch-year
719468 const> date-stamp-days-to-1970
400 const> date-stamp-years-in-era
399 const> date-stamp-years-in-era-1
146097 const> date-stamp-days-in-era
146096 const> date-stamp-days-in-era-1

1970 defconst> nix-epoch-year
719468 defconst> date-stamp-days-to-1970
400 defconst> date-stamp-years-in-era
399 defconst> date-stamp-years-in-era-1
146097 defconst> date-stamp-days-in-era
146096 defconst> date-stamp-days-in-era-1

def time->date arg0 secs->days set-arg0 end
def date->time arg0 days->secs set-arg0 end  

def make-date-stamp ( year month day -- days )
  ( Taken from http://howardhinnant.github.io/date_algorithms.html
    y -= m <= 2;
    const Int era = [y >= 0 ? y : y-399] / 400;
    const unsigned yoe = static_cast<unsigned>[y - era * 400];      // [0, 399]
    const unsigned doy = [153*[m > 2 ? m-3 : m+9] + 2]/5 + d-1;  // [0, 365]
    const unsigned doe = yoe * 365 + yoe/4 - yoe/100 + doy;         // [0, 146096]
    return era * 146097 + static_cast<Int>[doe] - 719468;
  )
  ( local0 => y )
  arg2 arg1 2 int<= IF 1 - THEN
  ( local1 => era )
  local0 0 int>= IF local0 ELSE local0 date-stamp-years-in-era-1 - THEN date-stamp-years-in-era floored-div
  ( local2 => yoe )
  local0 local1 date-stamp-years-in-era * -
  ( local3 => doy )
  arg1 2 int> IF arg1 3 - ELSE arg1 9 + THEN 153 * 2 + 5 floored-div arg0 + 1 -
  ( local4 => doe )
  local2 365 * local2 4 floored-div + local2 100 floored-div - local3 +
  local1 date-stamp-days-in-era * over + date-stamp-days-to-1970 -
  3 return1-n
end

def date-stamp-parts-inner ( days -- year-ish day-of-year )
  ( Taken from http://howardhinnant.github.io/date_algorithms.html
    z += 719468;
    const Int era = [z >= 0 ? z : z - 146096] / 146097;
    const unsigned doe = static_cast<unsigned>[z - era * 146097];          // [0, 146096]
    const unsigned yoe = [doe - doe/1460 + doe/36524 - doe/146096] / 365;  // [0, 399]
    const Int y = static_cast<Int>[yoe] + era * 400;
    const unsigned doy = doe - [365*yoe + yoe/4 - yoe/100];                // [0, 365]
  )
  ( local0 => z)
  arg0 date-stamp-days-to-1970 +
  ( local1 => era )
  dup dup 0 int>= UNLESS date-stamp-days-in-era-1 - THEN date-stamp-days-in-era floored-div
  ( local2 => doe )
  local0 local1 date-stamp-days-in-era * -
  ( local3 => yoe )
  local2 local2 1460 floored-div - local2 36524 floored-div + local2 date-stamp-days-in-era-1 floored-div - 365 floored-div
  ( local4 => year-ish )
  local3 local1 date-stamp-years-in-era * +
  ( local5 => doy )
  local2 local3 365 * local3 4 floored-div + local3 100 floored-div - -
  swap set-arg0 return1
end

def date-stamp-day-of-year ( days -- day-of-year )
  ( Taken from http://howardhinnant.github.io/date_algorithms.html
    z += 719468;
    const Int era = [z >= 0 ? z : z - 146096] / 146097;
    const unsigned doe = static_cast<unsigned>[z - era * 146097];          // [0, 146096]
    const unsigned yoe = [doe - doe/1460 + doe/36524 - doe/146096] / 365;  // [0, 399]
    const Int y = static_cast<Int>[yoe] + era * 400;
    const unsigned doy = doe - [365*yoe + yoe/4 - yoe/100];                // [0, 365]
  )
  arg0 date-stamp-parts-inner
  ( adjust back from the March origin )
  dup 306 int< IF 60 + ELSE 306 - THEN set-arg0
end

def date-stamp-parts ( days -- year month day )
  ( Taken from http://howardhinnant.github.io/date_algorithms.html
    z += 719468;
    const Int era = [z >= 0 ? z : z - 146096] / 146097;
    const unsigned doe = static_cast<unsigned>[z - era * 146097];          // [0, 146096]
    const unsigned yoe = [doe - doe/1460 + doe/36524 - doe/146096] / 365;  // [0, 399]
    const Int y = static_cast<Int>[yoe] + era * 400;
    const unsigned doy = doe - [365*yoe + yoe/4 - yoe/100];                // [0, 365]
    const unsigned mp = [5*doy + 2]/153;                                   // [0, 11]
    const unsigned d = doy - [153*mp+2]/5 + 1;                             // [1, 31]
    const unsigned m = mp < 10 ? mp+3 : mp-9;                            // [1, 12]
    return std::tuple<Int, unsigned, unsigned>[y + [m <= 2], m, d];
  )
  ( local0 => year-ish, local1 => doy )
  arg0 date-stamp-parts-inner
  ( local2 => mp )
  dup 5 * 2 + 153 floored-div
  ( local3 => d )
  over over 153 * 2 + 5 floored-div - 1 +
  ( local4 => m )
  over dup 10 int< IF 3 + ELSE 9 - THEN
  ( returning... )
  local0 over 2 int<= IF 1 + THEN set-arg0 swap return2
end

def time-stamp-year
  arg0 time->date date-stamp-parts 2 dropn set-arg0
end

def time-stamp-month
  arg0 time->date date-stamp-parts drop set-arg0
end

def time-stamp-day-of-month
  arg0 time->date date-stamp-parts set-arg0
end

def time-stamp-day-of-year
  arg0 time->date date-stamp-day-of-year set-arg0
end

def time-stamp-hours
  arg0 secs->hours 24 floored-mod set-arg0
end

def time-stamp-minutes
  arg0 secs->minutes 60 floored-mod set-arg0
end

def time-stamp-seconds
  arg0 60 floored-mod set-arg0
end

def time-stamp-date
  arg0 time->date date-stamp-parts rot set-arg0 swap return2
end

def make-time/1 ( fields -- time )
  arg0 5 seq-peek arg0 4 seq-peek arg0 3 seq-peek make-date-stamp days->secs
  arg0 2 seq-peek hours->secs +
  arg0 1 seq-peek minutes->secs +
  arg0 0 seq-peek +
  set-arg0
end

def make-time/6 ( year month day hours minutes secs -- time )
  args make-time/1 6 return1-n
end

def time-on-under? ( time seconds -- yes? )
  get-time-secs arg1 - arg0 int<= 2 return1-n
end

def time-on-over? ( time seconds -- yes? )
  get-time-secs arg1 - arg0 int>= 2 return1-n
end

( Output: )

def write-time
  arg0 time-stamp-hours write-int
  s" :" write-string/2
  arg0 time-stamp-minutes 2 write-padded-uint
  s" :" write-string/2
  arg0 time-stamp-seconds 2 write-padded-uint
  1 return0-n
end

( todo refactor )
def write-date-stamp
  arg0 date-stamp-parts
  rot write-int
  s" /" write-string/2
  2 write-padded-uint
  s" /" write-string/2
  2 write-padded-uint
  1 return0-n
end

def write-date
  arg0 time->date write-date-stamp
  1 return0-n
end

def write-time-stamp
  arg0 write-date space arg0 write-time
end
