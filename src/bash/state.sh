#
# State storage
#

DICT['dump-dicts']='dump_dicts'
DICT['save-dict']='dump_dicts > "${STACK[0]}"; fpop'
DICT['load-dict']='source "${STACK[0]}"; fpop'
DICT['reload-dicts']='DICT=(); IDICT=(); source "${STACK[0]}"; fpop'

function quote_value()
{
    if [[ "$1" =~ "'" ]]; then
	printf %q "$1"
    else
	echo "'${1}'"
    fi
}

function dump_dicts()
{
    #echo -e "unset DICT; declare -A DICT\n"
    for i in "${!DICT[@]}"; do
	local v="${DICT["$i"]}"
	v=$(quote_value "$v")
	i=$(quote_value "$i")
	echo "DICT[$i]=$v"
    done
    for i in "${!IDICT[@]}"; do
	local v="${IDICT["$i"]}"
	v=$(quote_value "$v")
	i=$(quote_value "$i")
	echo "IDICT[$i]=$v"
    done
}
