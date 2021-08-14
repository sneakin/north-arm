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

forth_words()
{
    awk -P '/^(:|def.*) +(.+)/ { print $2,FILENAME }' $*
}

echo '<html>'
echo '<head>'
echo '<style type="text/css" media="screen">'
cat "${ROOT}"/../doc/style.css
echo '</style>'
echo '<style type="text/css" media="print">'
cat "${ROOT}"/../doc/white.css
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

echo '<h1>Words</h1>'
echo '<table>'
forth_words $* | sort | awk -P '/./ { printf "<tr><td><a href=\"#%s\">%s</a></td><td>%s</td></tr>\n",$2,$1,$2 }'
echo '</table>'

for path in $*; do
    echo "<h1><a name=\"$path\">$path</a></h1>"
    echo "<pre>"
    (cat "$path" | html_escape | highlight "$path") || echo "Not found."
    echo "</pre>"
done

echo '</body></html>'
