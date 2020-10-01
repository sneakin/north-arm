function dict_lookup()
{
    local tip="${1}"
    local -n d="${2}"
    echo "${d[$tip]}"
}

function dict_set() # dict word def
{
    local -n d="${1}"
    local k="${2}"
    d["$k"]="${3}"
}

function dict_list()
{
    local -n d="${1}"
    echo "${!d[@]}"
}
