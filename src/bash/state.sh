#
# State storage
#

DICT['dump-dict']='dump_dict'
DICT['save-dict']='dump_dict > "${STACK[0]}"; fpop'
DICT['load-dict']='source "${STACK[0]}"; fpop'

function quote_value()
{
    if [[ "$1" =~ "'" ]]; then
	printf %q "$1"
    else
	echo "'${1}'"
    fi
}

function dump_dict()
{
    #echo -e "unset DICT; declare -A DICT\n"
    for i in "${!DICT[@]}"; do
	local v="${DICT["$i"]}"
	v=$(quote_value "$v")
	i=$(quote_value "$i")
	echo "DICT[$i]=$v"
    done
}
