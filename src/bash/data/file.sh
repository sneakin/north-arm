#
# Data stack backed by a file for lower memory usage.
#

DATA=$(mktemp)
DHERE=0

data_file_cleanup()
{
  rm "${DATA}"
}

trap data_file_cleanup EXIT

data_file_read_byte()
{
  local where="${1:-${DHERE}}"
  dd if=${DATA} bs=1 skip=${where} count=1 2>/dev/null | od -An -vtd1 | tr -d ' '
}

data_file_read_long()
{
  local where="${1:-${DHERE}}"
  dd if=${DATA} bs=1 skip=${where} count=4 2>/dev/null | od -An -vtd4 | tr -d ' '
}

data_file_write_byte()
{
  local where="${1}"
  local what="${2}"
  echo -e "\x$(printf %.2x "$what")" | \
    dd of=$DATA obs=1 seek=${where} count=1 conv=notrunc 2>/dev/null
}

data_file_write_long()
{
  local where="${1}"
  local what="${2}"
  local a=$(printf %.2x "$((($what >> 0) & 255))")
  local b=$(printf %.2x "$((($what >> 8) & 255))")
  local c=$(printf %.2x "$((($what >> 16) & 255))")
  local d=$(printf %.2x "$((($what >> 24) & 255))")
  echo -e "\x$a\x$b\x$c\x$d" | \
    dd of=$DATA obs=1 seek=${where} count=4 conv=notrunc 2>/dev/null
}

data_file_append_byte()
{
  data_file_write_byte "$DHERE" "$1"
}

data_file_append_long()
{
  data_file_write_long "$DHERE" "$1"
}

DICT['data-cell-size']='fpush 4'
DICT['dhere']='fpush "$DHERE"'
DICT['dmove']='DHERE=$((${STACK[0]} + 0)); fpop'

DICT['dpush']='data_file_append_long "${STACK[0]}"; DHERE=$(($DHERE + 4)); fpop'
DICT['dpop']='DHERE=$(($DHERE - 4)); fpush "$(data_file_read_long)"'
DICT['dpeek']='STACK=( "$(data_file_read_long "${STACK[0]}")" "${STACK[@]:1}" )'
DICT['dpoke']='data_file_write_long "${STACK[0]}" "${STACK[1]}"; fpop; fpop'

DICT['dpush-byte']='data_file_append_byte "${STACK[0]}"; DHERE=$(($DHERE + 1)); fpop'
DICT['dpop-byte']='DHERE=$(($DHERE - 1)); fpush "$(data_file_read_byte)"'
DICT['dpeek-byte']='STACK=( "$(data_file_read_byte "${STACK[0]}")" "${STACK[@]:1}" )'
DICT['dpoke-byte']='data_file_write_byte "${STACK[0]}" "${STACK[1]}"; fpop; fpop'

DICT['ddump/2']='LEN="${STACK[0]}"; X="${STACK[1]}"; dd if=${DATA} bs=1 offset=${X} count=${LEN} 1>&2; fpop 2'
DICT['ddump']='cat ${DATA} 1>&2'
DICT['dsize']='fpush "$(stat -c %s ${DATA})"'
DICT['dallot']='feval dhere + dhere swap dmove'

DICT['dpeek-off']='feval + dpeek'
DICT['dpoke-off']='feval + dpoke'

# def f arg0 0 equals? IF return0 THEN arg0 dpush arg0 1 - set-arg0 repeat-frame end
# def g arg0 0 equals? IF return0 THEN dpop . arg0 1 - set-arg0 repeat-frame end
