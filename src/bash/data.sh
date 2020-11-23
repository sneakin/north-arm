#
# Data stack
#

declare -a DATA
DHERE=0

DICT['dhere']='fpush "$DHERE"'
DICT['dmove']='DHERE=$((${STACK[0]} + 0)); fpop'
DICT['dpush']='DATA[$DHERE]="${STACK[0]}"; DHERE=$(($DHERE + 1)); fpop'
DICT['dpop']='DHERE=$(($DHERE - 1)); fpush "${DATA[$DHERE]}"'
DICT['dpeek']='STACK=( "${DATA[${STACK[0]}]}" "${STACK[@]:1}" )'
DICT['dpoke']='DATA[${STACK[0]}]="${STACK[1]}"; fpop; fpop'
DICT['ddump/2']='LEN="${STACK[0]}"; X="${STACK[1]}"; echo "${DATA[@]:$X:$LEN}" 1>&2; fpop 2'
DICT['ddump']='echo "${DATA[@]}" 1>&2'
DICT['dsize']='fpush "${#DATA[@]}"'
DICT['dallot']='feval dhere + dhere swap dmove'

DICT['dpeek-byte']='feval dpeek'
DICT['dpoke-byte']='feval swap 255 logand swap dpoke'
DICT['dpop-byte']='feval dpop 255 logand'
DICT['dpush-byte']='feval 255 logand dpush'
