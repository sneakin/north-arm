dict_lookup()
{
    local tip="${1}"
    local -n d="${2}"
    echo "${d[$tip]:-}"
}

dict_set() # dict word def
{
    local -n d="${1}"
    local k="${2}"
    d["$k"]="${3}"
}

dict_list()
{
    local -n d="${1}"
    echo "${!d[@]}"
}
