#
# Stack
#

declare -a STACK

# Pushes the argument onto the Forth stack.
function fpush()
{
    STACK=( "$@" "${STACK[@]}" )
}

# Pops 1 or more values from the Forth stack.
function fpop()
{
    local n="${1:-1}"
    STACK=( "${STACK[@]:$n}" )
}

#
# Evaluation
#

declare -A DICT # the dictionary
EVAL_EXPR=() # current expression being evaluated
EIP=0 # current evaluated word's index

# Execute the word passed as an argument.
function fsysexec()
{
    local entry="${1}"
    # echo "fexec $1 -> '$entry'" 1>&2
    eval "${entry}" || return $?
}

# Lookup and execute the word passed as an argument.
function fexec()
{
    local entry=""
    if [[ "${1:-}" != "" ]]; then
	entry="${DICT[$1]:-}"
    fi
    if [[ "${entry}" == "" ]]; then
	fpush "$1"
	#echo "Warning: not found '${1:-}'" 1>&2
    else
	fsysexec "${entry}"
    fi
}

# Execute each token of read input.
function finterp()
{
    local fin=0
    local input_streamed="${INPUT_STREAMED}"
    local saved_input
    if [[ "${1:-}" != "" ]]; then
	INPUT_STREAMED=0
	INPUT="${1} ${INPUT}"
    fi
    
    # Execute tokens until one does not `return 0`
    while [[ "$fin" != "1" ]] && next_token
    do
	fexec "$TOKEN" || fin=1
    done

    INPUT_STREAMED="${input_streamed}"
    
    return $fin
}

# Execute all the arguments.
function feval()
{
    # Save caller state
    local last_expr=( "${EVAL_EXPR[@]}" )
    local last_eip="$EIP"
    # Set the evaluation state
    EVAL_EXPR=( "$@" )
    EIP=0
    # Evaluate each word:
    while [[ "$EIP" -lt "${#EVAL_EXPR[@]}" ]]; do
	fexec "${EVAL_EXPR[$EIP]}"
	EIP=$(($EIP + 1))
    done
    # Restore caller state
    EVAL_EXPR=( "${last_expr[@]}" )
    EIP="$last_eip"
}
