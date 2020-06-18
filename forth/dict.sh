DICT['return']='EIP="${#EVAL_EXPR[@]}"'
DICT['jump']='EIP=$(($EIP + ${STACK[0]})); fpop'
DICT['if-jump']='if [[ "${STACK[1]}" != "0" ]]; then EIP=$(($EIP + ${STACK[0]})); fi; fpop 2'
DICT['unless-jump']='if [[ "${STACK[1]}" == "0" ]]; then EIP=$(($EIP + ${STACK[0]})); fi; fpop 2'

DICT['not']='STACK[0]=$(($STACK[0] == 0))'
DICT['equals']='if [[ "${STACK[0]}" == "${STACK[1]}" ]]; then fpop 2; fpush 1; else fpop 2; fpush 0; fi'

DICT['quit']='STACK=()'
DICT['abort']='exit 0'

DICT['drop']='fpop 1'
DICT['dropn']='fpop $((1 + ${STACK[0]}))'
DICT['dup']='STACK=("${STACK[0]}" "${STACK[@]}")'
DICT['over']='STACK=("${STACK[1]}" "${STACK[@]}")'
DICT['overn']='STACK=("${STACK[${STACK[0]}]}" "${STACK[@]}")'
DICT['swap']='STACK=("${STACK[1]}" "${STACK[0]}" "${STACK[@]:2}")'
DICT['roll']='STACK=("${STACK[2]}" "${STACK[0]}" "${STACK[1]}" "${STACK[@]:3}")'
DICT['rot']='STACK=("${STACK[2]}" "${STACK[1]}" "${STACK[0]}" "${STACK[@]:3}")'

DICT["'"]='next_token; fpush "${TOKEN}"'
DICT['set-word!']='DICT["${STACK[0]}"]="${STACK[1]}"; STACK=( "${STACK[@]:2}" )'
DICT['get-word']='STACK=( "${DICT[${STACK[0]}]}" "${STACK[@]:1}" )'

DICT['next-token']='next_token && fpush "$TOKEN"'
DICT['intern-tokens-until']='term="${STACK[0]}"; fpop; fpush "$DHERE"; while next_token && [[ "${TOKEN}" != "$term" ]]; do fpush "${TOKEN}"; feval dpush; done'
DICT['tokens-until']='term="${STACK[0]}"; fpop; fpush ""; while next_token && [[ "${TOKEN}" != "$term" ]]; do fpush " ${TOKEN}"; feval swap ++; done'
DICT['[']="feval ']' tokens-until"

DICT['read-until']='term="${STACK[0]}"; fpop; read_until "$term"; fpush "$TOKEN"'
DICT['"']='read_until \" && fpush "$TOKEN"'
DICT['(']='read_until ")"'
DICT['read-file']='fpush "$(cat ${STACK[0]})"'
DICT['load']='INPUT="$(cat ${STACK[0]}) $INPUT" && fpop'

DICT['words']='echo "${!DICT[@]}"'
DICT[':']='feval next-token ";" tokens-until "feval" ++ swap set-word!'
DICT['const>']='v="fpush \"${STACK[0]}\""; fpop; fpush "$v"; feval next-token set-word!'
DICT['var>']='VALUE="${STACK[0]}";
fpop; next_token;
fpush "fpush \"$VALUE\"";
fpush "$TOKEN";
feval set-word!;
fpush "fpush \"fpush \\\"\${STACK[0]}\\\"\"; fpush \"$TOKEN\"; feval set-word!; fpop";
fpush "set-$TOKEN";
feval set-word!'

DICT[',+']='fpush $((${STACK[0]} + ${STACK[1]}))'
DICT['+']='feval ,+ rot drop drop'
DICT['++']='v="${STACK[0]}${STACK[1]}"; fpop 2; fpush "$v"'

DICT[".s"]='echo Stack ${#STACK[@]}: ${STACK[@]}'
DICT[","]='echo -e "${STACK[0]}"'
DICT['.']='feval , drop'
DICT['write-string']='echo -n -e "${STACK[0]}"; fpop'
DICT['write-line']='echo -e "${STACK[0]}"; fpop'
DICT['error-line']='echo -e "${STACK[0]}" 1>&2; fpop'

DICT['boot']='feval "Hello." error-line'
