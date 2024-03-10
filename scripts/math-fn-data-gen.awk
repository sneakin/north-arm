#!/bin/env -S awk -f

function pow2(n) { return 2**n; }
function log2(n) { return log(n) / log(2); }

BEGIN {
    if(!fn) fn="log";
}

/^mode/ { fn=$2; }
/^[-+]?[0-9]+/ { print($1, @fn($1)); fflush(); }
