DATA=()
DHERE=0

DICT['dhere']='fpush "$DHERE"'
DICT['dmove']='DHERE=$((${STACK[0]} + 0)); fpop'
DICT['dpush']='DATA[$DHERE]="${STACK[0]}"; DHERE=$(($DHERE + 1)); fpop'
DICT['dpop']='DHERE=$(($DHERE - 1)); fpush "${DATA[$DHERE]}"'
DICT['dpeek']='STACK=( "${DATA[${STACK[0]}]}" "${STACK[@]:1}" )'
DICT['dpoke']='DATA[${STACK[0]}]="${STACK[1]}"; fpop; fpop'
DICT['ddump']='echo "${DATA[@]}"'
