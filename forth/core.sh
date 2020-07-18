#
# Stack
#

declare -a STACK

# Pushes the argument onto the Forth stack.
function fpush()
{
    STACK=( "$1" "${STACK[@]}" )
}

# Pops 1 or more values from the Forth stack.
function fpop()
{
    local n="${1:-1}"
    STACK=( "${STACK[@]:$n}" )
}

#
# Input reading
#

INPUT=""
INPUT_BYTE=""
INPUT_STREAMED="1"
TOKEN=""

# Read a full of input into $INPUT.
function read_input_line()
{
    local prompt="$1"
    [[ "$prompt" == "" ]] && prompt="${#STACK[@]} > "
    if [[ "${INPUT_STREAMED}" == "1" ]] && read -p "$prompt" INPUT; then
	return 0
    else
	return 1
    fi
}

# Read one byte from the input line, possibly
# reading a new line when no input is available.
function read_byte()
{
    if [[ "${INPUT}" == "" ]]; then
	if [[ "${INPUT_BYTE}" == "" ]]; then
	    read_input_line "${1}" || return 1
	fi
    fi

    if [[ "$INPUT" == "" ]]; then
	INPUT_BYTE=""
    else
	INPUT_BYTE="${INPUT:0:1}"    
	INPUT="${INPUT:1}"
    fi

    return 0
}

# Read bytes into $TOKEN until the read byte
# matches the argument.
function read_until()
{
    TOKEN=""
    while read_byte "... > "; do
	if [[ "$INPUT_BYTE" == "" ]]; then
	    TOKEN="${TOKEN}
"
	elif [[ "$INPUT_BYTE" == "$1" ]]; then
	    return 0
	else
	    TOKEN="${TOKEN}${INPUT_BYTE}"
	fi
    done

    return 1
}

#
# Tokenizing
#

# Return success if the argument is whitespace.
function isspace()
{
    case "$1" in
	"
"|" "|""|"\v"|"	"|"\t"|"\n"|"\r"|"") return 0 ;;
	*) return 1 ;;
    esac
}

# Read the next Forth token. Returned in $TOKEN.
function next_token()
{
    TOKEN=""
    while read_byte; do
	if isspace "$INPUT_BYTE"; then
	    if [[ "${#TOKEN}" > 0 ]]; then
		return 0
	    fi
	else
	    TOKEN="${TOKEN}${INPUT_BYTE}"
	fi
    done

    return 1
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
    if [[ "$1" != "" ]]; then
	entry="${DICT[$1]}"
    fi
    if [[ "${entry}" == "" ]]; then
	fpush "$1"
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
    if [[ "$1" != "" ]]; then
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
