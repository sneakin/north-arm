#!/bin/bash

echo '<html><body>'
echo '<h1>Git Status</h1>'
echo '<pre>'
git status
echo '</pre>'

for path in $*; do
    echo "<h1>$path</h1>"
    echo "<pre>"
    cat "$path" || echo "Not found."
    echo "</pre>"
done

echo '</body></html>'