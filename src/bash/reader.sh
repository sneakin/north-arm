#
# Input reading
#

INPUT=""
INPUT_BYTE=""
INPUT_STREAMED="1"
TOKEN=""

# Read a full of input into $INPUT.
read_input_line()
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
read_byte()
{
    if [[ "${INPUT}" == "" ]]; then
	if [[ "${INPUT_BYTE}" == "" ]]; then
	    read_input_line "${1:-}" || return 1
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
read_until()
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
isspace()
{
    case "$1" in
	"
"|" "|""|"\v"|"	"|"\t"|"\n"|"\r"|"") return 0 ;;
	*) return 1 ;;
    esac
}

# Read the next Forth token. Returned in $TOKEN.
next_token()
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
