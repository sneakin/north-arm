#!/bin/bash

set -euo pipefail
ROOT=$(dirname "$BASH_SOURCE")
ARGV=("$@")

html_escape()
{
    sed -e 's:&:\&amp;:g' \
	-e 's:<:\&lt;:g' \
	-e 's:>:\&gt;:g'
}

highlight()
{
    if [[ "$1" =~ 4th$ ]]; then
	sed -f "$ROOT"/highlight/forth.sed
    elif [[ "$1" =~ sh$ ]]; then
	sed -f "$ROOT"/highlight/bash.sed
    else
	cat
    fi
}

echo '<html>'
echo '<head>'
echo '<style type="text/css" media="screen">'
cat doc/style.css
echo '</style>'
echo '<style type="text/css" media="print">'
cat doc/white.css
echo '</style>'
#echo '<style type="text/css">@import "style.css";</style>'
#echo '<style type="text/css" media="print">@import "white.css";</style>'
echo '</head>'
echo '<body>'
echo '<h1>Git Status</h1>'
echo '<pre>'
git status
echo '</pre>'

echo '<h1>Files</h1>'
echo '<ul>'
for path in $*; do
    echo "<li><a href=\"#$path\">$path</a></li>"
done
echo '</ul>'

for path in $*; do
    echo "<h1><a name=\"$path\">$path</a></h1>"
    echo "<pre>"
    (cat "$path" | html_escape | highlight "$path") || echo "Not found."
    echo "</pre>"
done

echo '</body></html>'
