#
# Control flow
#
DICT['abort']='exit 0'
DICT['return']='EIP="${#EVAL_EXPR[@]}"'
DICT['loop']='EIP=-1'
DICT['jump-rel']='EIP=$(($EIP + ${STACK[0]})); fpop'
DICT['if-jump']='if [[ "${STACK[1]}" != "0" ]]; then EIP=$(($EIP + ${STACK[0]})); fi; fpop 2'
DICT['unless-jump']='if [[ "${STACK[1]}" == "0" ]]; then EIP=$(($EIP + ${STACK[0]})); fi; fpop 2'
DICT['eval']='tip="${STACK[0]}"; fpop; feval $tip'
DICT['exec']='tip="${STACK[0]}"; fpop; fexec "$tip"'
DICT['sys-exec']='tip="${STACK[0]}"; fpop; fsysexec "$tip"'

#
# Equality
#
DICT['not']='STACK[0]=$(($STACK[0] == 0))'
DICT['equals']='if [[ "${STACK[0]}" == "${STACK[1]}" ]]; then fpop 2; fpush 1; else fpop 2; fpush 0; fi'

DICT['null?']='if [[ "${STACK[0]}" == "" ]]; then fpush 1; else fpush 0; fi'
DICT['number?']='if [[ "${STACK[0]}" =~ -?[0-9]+(\.[0-9]+)? ]] || [[ "${STACK[0]}" =~ -?(0x)[0-9a-fA-F]+(\.[0-9a-fA-F]+)? ]]; then fpush 1; else fpush 0; fi'

DICT['int<']='a="${STACK[1]}"; b="${STACK[0]}"; fpop 2; if [[ "$a" < "$b" ]]; then fpush 1; else fpush 0; fi'

#
# Stack ops
#
DICT['quit']='STACK=()'
DICT['drop']='fpop 1'
DICT['dropn']='fpop $((1 + ${STACK[0]}))'
DICT['dup']='STACK=("${STACK[0]}" "${STACK[@]}")'
DICT['over']='STACK=("${STACK[1]}" "${STACK[@]}")'
DICT['overn']='STACK=("${STACK[${STACK[0]}]}" "${STACK[@]:1}")'
DICT['set-overn']='STACK[$((1 + ${STACK[0]}))]="${STACK[1]}"; fpop 2'
DICT['swap']='STACK=("${STACK[1]}" "${STACK[0]}" "${STACK[@]:2}")'
DICT['roll']='STACK=("${STACK[2]}" "${STACK[0]}" "${STACK[1]}" "${STACK[@]:3}")'
DICT['rot']='STACK=("${STACK[2]}" "${STACK[1]}" "${STACK[0]}" "${STACK[@]:3}")'

DICT['here']='fpush "${#STACK[@]}"'
DICT['speek']='i="${STACK[0]}"; fpop; fpush "${STACK[$((${#STACK[@]} - $i))]}"'
DICT['spoke']='i="${STACK[0]}"; v="${STACK[1]}"; fpop 2; STACK[$(("${#STACK[@]}" - $i))]="$v"'

#
# Dictionary ops
#
DICT["'"]='next_token; fpush "${TOKEN}"'
DICT['set-word!']='DICT["${STACK[0]}"]="${STACK[1]}"; STACK=( "${STACK[@]:2}" )'
DICT['get-word']='STACK=( "${DICT[${STACK[0]}]}" "${STACK[@]:1}" )'
DICT['words']='echo "${!DICT[@]}"'

DICT['dict-lookup']='d="${STACK[0]}"; tip="${STACK[1]}"; fpop 2; fpush "$(dict_lookup "$tip" "$d")"'
DICT['dict-set!']='dict_set "${STACK[0]}" "${STACK[1]}" "${STACK[2]}"; fpop 3'
DICT['dict-list']='d="${STACK[0]}"; fpop; dict_list "$d"'

declare -A IDICT
DICT['immediate-lookup']='feval literal IDICT dict-lookup'
DICT['set-immediate!']='feval literal IDICT dict-set!'
DICT['iwords']='feval literal IDICT dict-list'

declare -A out_immediates

#
# Reading tokens
#
DICT['next-token']='next_token && fpush "$TOKEN"'
DICT['intern-tokens-until']='term="${STACK[0]}"; fpop; fpush "$DHERE"; while next_token && [[ "${TOKEN}" != "$term" ]]; do fpush "${TOKEN}"; feval dpush; done'
DICT['tokens-until']='term="${STACK[0]}"; fpop; fpush ""; while next_token && [[ "${TOKEN}" != "$term" ]]; do fpush " ${TOKEN}"; feval swap ++; done'
DICT['[']="feval ']' tokens-until"
DICT['literal']='EIP=$(($EIP + 1)); i="$EIP"; fpush "${EVAL_EXPR[$i]}"'

#
# Readers
#
DICT['read-until']='term="${STACK[0]}"; fpop; read_until "$term"; fpush "$TOKEN"'
DICT['"']='read_until \" && fpush "${TOKEN}"'
DICT['(']='read_until ")"'
DICT['read-file']='fpush "$(cat ${STACK[0]})"'

DICT['load']='echo "Loading ${STACK[0]}" 1>&2; F="${STACK[0]}"; fpop && finterp "$(cat $F)"'

#
# Defining words
#
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

#
# Arithmetic
#
DICT[',+']='fpush $((${STACK[1]} + ${STACK[0]}))'
DICT['+']='feval ,+ rot drop drop'
DICT[',-']='fpush $((${STACK[1]} - ${STACK[0]}))'
DICT['-']='feval ,- rot drop drop'
DICT[',mult']='fpush $((${STACK[1]} * ${STACK[0]}))'
DICT['mult']='feval ,mult rot drop drop'
DICT[',/']='fpush $((${STACK[1]} / ${STACK[0]}))'
DICT['/']='feval ,/ rot drop drop'

DICT[',bsl']='fpush $((${STACK[1]} << ${STACK[0]}))'
DICT['bsl']='feval ,bsl rot drop drop'
DICT[',bsr']='fpush $((${STACK[1]} >> ${STACK[0]}))'
DICT['bsr']='feval ,bsr rot drop drop'

DICT[',logior']='fpush $((${STACK[1]} | ${STACK[0]}))'
DICT['logior']='feval ,logior rot drop drop'
DICT[',logand']='fpush $((${STACK[1]} & ${STACK[0]}))'
DICT['logand']='feval ,logand rot drop drop'
DICT[',lognot']='fpush $((~"${STACK[0]}"))'
DICT['lognot']='feval ,lognot swap drop'

DICT['int32']="${DICT[literal]}"

#
# String ops
#
DICT['++']='v="${STACK[0]}${STACK[1]}"; fpop 2; fpush "$v"'
DICT['string-length']='v="${STACK[0]}"; fpop; fpush "${#v}"'
DICT['string-peek']='v="${STACK[1]}"; n="${STACK[0]}"; fpop 2; fpush "${v:$n:1}"'
DICT['char-code']="v=\$(printf %d \"'\${STACK[0]}\"); fpop; fpush \$v"
DICT['has-spaces?']='if [[ "${STACK[0]}" == "" ]] || [[ "${STACK[0]}" =~ ([ \t\n\r\v]) ]]; then fpush 1; else fpush 0; fi'
DICT['quote-string']='v="${STACK[0]}"; fpop; fpush "$(printf %q "$v")"'

#
# Output
#
DICT[".s"]='echo "Stack ${#STACK[@]}: ${STACK[@]}" 1>&2'
DICT[","]='echo -e "${STACK[0]}"'
DICT['.']='feval , drop'
DICT[',h']='printf "%x\n" "${STACK[0]}"'
DICT[',,h']='printf "%x\n" "${STACK[0]}" 1>&2'
DICT['write-string']='echo -n -e "${STACK[0]}"; fpop'
DICT['write-line']='echo -e "${STACK[0]}"; fpop'
DICT['error-line']='echo -e "${STACK[0]}" 1>&2; fpop'
DICT['write-byte']='printf "\\x$(printf %x "${STACK[0]}")"; fpop'

#IDICT['"']="${DICT['\"']}"
#IDICT["\'"]="${DICT[\\\"\'\\\"]}"

IDICT["'"]='next_token; fpush literal && fpush "${TOKEN}"'
IDICT['"']='read_until \" && fpush literal && fpush "${TOKEN}"'
IDICT['q"']='read_until \" && fpush literal && fpush "\"${TOKEN}\""'
IDICT['s"']='read_until \" && fpush "${TOKEN}"'

#
# Startup
#
DICT['boot']='feval "Hello." error-line'
