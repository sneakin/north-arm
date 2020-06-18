declare -a STACK
declare -A DICT

function fpush()
{
    STACK=( "$1" "${STACK[@]}" )
}

function fpop()
{
    local n="${1:-1}"
    STACK=( "${STACK[@]:$n}" )
}

INPUT=""
INPUT_BYTE=""
TOKEN=""

function read_input_line()
{
    local prompt="$1"
    [[ "$prompt" == "" ]] && prompt="${#STACK[@]} > "
    if read -p "$prompt" INPUT; then
	return 0
    else
	return 1
    fi
}

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

function isspace()
{
    case "$1" in
	"
"|" "|"\t"|"\n"|"\r"|"") return 0 ;;
	*) return 1 ;;
    esac
}

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

function fexec()
{
    local entry="${DICT[$1]}"
    # echo "fexec $1 -> '$entry'" 1>&2
    if [[ "${entry}" == "" ]]; then
	fpush "$1"
    else
	eval "${entry}" || return $?
    fi
}

function finterp()
{
    local fin=0

    while [[ "$fin" != "1" ]] && next_token
    do
	fexec "$TOKEN" || fin=1
    done

    return $fin
}

EVAL_EXPR=()
EIP=0

function feval()
{
    local last_expr=( "${EVAL_EXPR[@]}" )
    local last_eip="$EIP"
    EVAL_EXPR=( "$@" )
    EIP=0
    while [[ "$EIP" -lt "${#EVAL_EXPR[@]}" ]]; do
	fexec "${EVAL_EXPR[$EIP]}"
	EIP=$(($EIP + 1))
    done

    EVAL_EXPR=( "${last_expr[@]}" )
    EIP="$last_eip"
}
