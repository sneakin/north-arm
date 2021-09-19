#
# Stack
#

declare -a STACK

# todo try using a variable to track here. with zeroing out on pop. no quoting truncation. 

# Pushes the argument onto the Forth stack.
fpush()
{
    STACK=( "$@" "${STACK[@]}" )
}

# Pops 1 or more values from the Forth stack.
fpop()
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
fsysexec()
{
    local entry="${1}"
    [[ "${DICT['*trace*']}" != "" ]] && echo "fexec '$1' -> '$entry'" 1>&2
    eval "${entry}"
    return $?
}

# Lookup and execute the word passed as an argument.
fexec()
{
    local entry=""
    if [[ "${1:-}" != "" ]]; then
	entry="${DICT[$1]:-}"
    fi
    [[ "${DICT['*trace*']}" != "" ]] && echo "fexec '$1' -> '${entry}'" 1>&2
    if [[ "${entry}" == "" ]]; then
	fpush "$1"
    else
	fsysexec "${entry}"
        return $?
    fi
}

# Execute each token of read input.
finterp()
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

    if [[ "$fin" == 1 ]]; then
        fexec .s
    fi

    INPUT_STREAMED="${input_streamed}"
    
    return $fin
}

# Execute all the arguments.
feval()
{
    # Save caller state
    local last_expr=( "${EVAL_EXPR[@]}" )
    local last_eip="$EIP"
    # Set the evaluation state
    EVAL_EXPR=( "$@" )
    EIP=0
    [[ "${DICT['*trace*']}" != "" ]] && echo "feval '${EVAL_EXPR}'"
    # Evaluate each word:
    while [[ "$EIP" -lt "${#EVAL_EXPR[@]}" ]]; do
	if fexec "${EVAL_EXPR[$EIP]}"; then
	    EIP=$(($EIP + 1))
        else
            echo "Error evaling at ${EIP}: ${EVAL_EXPR[@]}" 1>&2
            echo "Caller at ${last_eip}: ${last_expr[@]}"
            return -1
        fi
    done
    # Restore caller state
    EVAL_EXPR=( "${last_expr[@]}" )
    EIP="$last_eip"
}
