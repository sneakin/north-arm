#!/usr/bin/env -S awk -f

function tan(x) { return sin(x) / cos(x); }
function asin(x) { return atan2(x, sqrt(1-x*x)) }
function acos(x) { return atan2(sqrt(1-x*x), x) }
function atan(x) { return atan2(x,1) }
function sinh(x) { return (exp(x)-exp(-x))/2; }
function cosh(x) { return (exp(x)+exp(-x))/2; }
function tanh(x) { return sinh(x)/cosh(x); }
function pow(b, e) { return b**e; }
function pow2(n) { return 2**n; }
function log2(n) { return log(n) / log(2); }

BEGIN {
    if(!fn) fn="log";
}

/^mode/ { fn=$2; }
/[0-9]+ +[-+0-9]+/ { printf("%.8f %.8f %.8f\n", $1, $2, @fn($1, $2)); fflush(); next; }
/^[-+]?[0-9]+/ { printf("%.8f %.8f\n", $1, @fn($1)); fflush(); }
