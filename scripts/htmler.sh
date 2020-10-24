#!/bin/bash

echo '<html><body>'
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
    (cat "$path" | sed -e 's:&:\&amp;:g' -e 's:<:\&lt;:g' -e 's:>:\&gt;:g') || echo "Not found."
    echo "</pre>"
done

echo '</body></html>'
