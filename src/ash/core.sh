# The stack is a multiline string. Each line is a single item.
# Newline characters are escaped.

set -e

STACK=""
STACK_SIZE=0

fstack_init()
{
    STACK=""
    STACK_SIZE=0
}

fpush()
{
    local V
    for i in "${@}"; do
        STACK="${i//$'\n'/\\n}
${STACK}"
        STACK_SIZE=$(($STACK_SIZE + 1))
    done
}

ftos()
{
    local IFS=""
    echo "${STACK}" | (read -r WORD && echo -e "${WORD}") # //\\n/$'\n'
}

ftos_raw()
{
    local IFS=""
    echo "${STACK}" | (read -r WORD && echo "${WORD}")
}

fpop1()
{
    local LEN=0
    local WORD="$(ftos_raw)"
    local LINES=0
    LEN=$((${#WORD} + 1)) # + newline
    STACK="${STACK:${LEN}}"
    STACK_SIZE=$(($STACK_SIZE - 1))
    if [ "${STACK_SIZE}" -lt 0 ]; then
        echo "Warning: stack underflow" 1>&2
        STACK_SIZE=0
    fi
    echo -e "${WORD}"
}

fpop()
{
    local N="${1:-1}"
    local I=0
    while [ $I -lt $N ]; do
        fpop1
        I=$(($I + 1))
    done
}

op_drop()
{
    fpop "${1:-1}" > /dev/null
}

op_dropn()
{
    local N="$(ftos)"
    op_drop $(($N + 1))
}

op_dump()
{
    local IFS=""
    local WORD
    local N=0
    echo "${STACK}" | while [ "$N" -lt "${STACK_SIZE}" ] && read -r WORD; do
        printf "%4i  '%s'\n" "${N}" "${WORD}"
        N=$((${N} + 1))
    done
    printf "%i cells\n" "${STACK_SIZE}"
}

op_print()
{
    echo "$(ftos)"
    op_drop
}

op_dup()
{
    fpush "$(ftos_raw)"
}

fovern_raw()
{
    local N="${1:-1}"
    (op_drop $N && ftos_raw)
}

fovern()
{
    local N="${1:-1}"
    (op_drop $N && ftos)
}

op_overn()
{
    local N="$(ftos_raw)"
    local V="$(fovern_raw "$N")"
    op_drop
    fpush "$V" 
}

op_setovern()
{
    local N=$(($(ftos) - 1))
    local VALUE="$(fovern 1)"
    local priors=""
    local I=0
    local tos
    
    op_drop 2

    while [ "$I" -lt "$N" ]; do
        tos="$(ftos_raw)"
        op_drop
        priors="${priors}${tos}
"
        I=$(($I + 1))
    done
    op_drop
    fpush "$VALUE"
    STACK="${priors}${STACK}"
    STACK_SIZE=$(($STACK_SIZE + $I))
}

op_swap()
{
    local tip="$(ftos_raw)"
    local next="$(fovern_raw 1)"
    op_drop 2
    fpush "${tip}" "${next}"
}

fexec()
{
    local WORD="${1//-/_}"
    local op="op_${WORD}"
    echo "exec ${WORD}" 1>&2
    if [[ "$(type "${op}" 2>/dev/null)" =~ "function" ]]; then
        eval "${op}"
    else
	if [[ $(printf "%i" "${WORD}" 2>/dev/null) != "${WORD}" ]]; then
	    echo "Warning: ${WORD} not found." 1>&2
	fi
        fpush "${WORD}"
    fi
}

feval()
{
    echo "eval ${1}" 1>&2
    while [ "$1" != "" ]; do
	echo "feval ${1}" 1>&2
        fexec "$1"
        shift
    done
}

finterp()
{
    local IFS=" "
    while read -r -p "OK> " LINE; do
	echo "read ${LINE}" 2>&1
        feval $LINE
    done
}

FCOMP=0

fcompexec()
{
    local WORD="${1//-/_}"
    local op="im_${WORD}"
    if [[ "$(type "${op}" 2>/dev/null)" =~ "function" ]]; then
        eval "${op}"
    else
        fpush "${WORD}"
    fi
}

im_end()
{
    FCOMP=0
}

# fails to process input on the same line as COMP. May need a classic interp.
op_comp()
{
    local IFS=" "
    local N=0
    FCOMP=1
    echo "Compiling" 1>&2
    while [ "$FCOMP" = 1 ] && read -r -p "COMP> " LINE; do
        echo "Read ${LINE}" 1>&2
        echo "${LINE}" | tr " " "\n" | while read -r WORD; do
            fcompexec "$WORD"
            N=$(($N + 1))
        done
    done
    fpush "$N"
}

op_int_add()
{
    local A="$(ftos)"
    local B="$(fovern 1)"
    op_drop 2
    fpush $(($B + $A))
}

op_int_sub()
{
    local A="$(ftos)"
    local B="$(fovern 1)"
    op_drop 2
    fpush $(($B - $A))
}

op_space()
{
    fpush " "
}

op_nl()
{
    fpush '\n'
}

op_nil()
{
    fpush ""
}

op_concat()
{
    local A="$(ftos_raw)"
    local B="$(fovern_raw 1)"
    op_drop 2
    fpush "${B}${A}"
}

op_join()
{
    # args: ...parts n spacer accum
    # anything left?
    fpush 3
    op_overn
    if [ "$(ftos)" -lt 1 ]; then
        op_drop
        # set last part, drop all args
        return
    fi
    # decrement the counter N
    fpush 1
    op_int_sub
    op_dup
    fpush 4
    op_setovern
    # grab the Nth argument
    fpush 4
    op_int_add
    op_overn
    op_dump
    # concat with the accumulator
    op_concat
    # if not the last item
    fpush 3
    op_overn
    op_dump
    if [ "$(ftos)" -gt 0 ]; then
        # concat the spacer
        op_drop
        fpush 2
        op_overn
        op_dump
        op_concat
        # loop
        op_dump
        echo "Looping" 1>&2
        op_join
    else
        op_drop
    fi
}

op_speek()
{
    local N=$(($(ftos) + 1))
    op_drop
    fpush "$(fovern $(($STACK_SIZE - $N)))"
}

op_here()
{
    fpush "$STACK_SIZE"
}

# fixme goes on too far
op_compile()
{
    op_comp
    fpush 1
    op_int_sub
    fpush " "
    fpush ""
    op_join
}

op_define()
{
    local NAME="$(ftos)"
    local VALUE="$(fovern 1)"
    op_drop 2
    eval "op_${NAME}()
{
  feval ${VALUE}
}"
    echo "$NAME" 1>&2
}

op_write_byte()
{
    local V="$(ftos)"
    op_drop
    printf "\\x$(printf %x "${V}")"
}

op_write_line()
{
    local LINE="$(ftos)"
    op_drop
    echo "$LINE"
}

op_error_line()
{
    local LINE="$(ftos)"
    op_drop
    echo "$LINE" 1>&2
}

op_readline()
{
    local IFS=""
    read -r -p "..> " LINE
    fpush "$LINE"
}

op_sysexit()
{
    local V="$(ftos)"
    exit "$V"
}
