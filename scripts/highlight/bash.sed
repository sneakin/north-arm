s:\("[^"]*"\):<span class="string">\1</span>:Mg
s:\('[^']*'\):<span class="string">\1</span>:Mg
s:\($\w+\|${.\+\}\):<span class="subst">\1</span>:g
t idents
s:\(#.*$\):<span class="comment">\1</span>:g
: idents
s:\(\(^\|\s\)\(-\)\?\(0x\)[0-9a-fA-F]\+\):<span class="number">\1</span>:g
s:\(\(^\|\s\)\(-\)\?[0-9]\+\):<span class="number">\1</span>:g
s:\(^\|\s\)\(if\|elif\|else\|then\|fi\|case\|when\|esac\|;;\|for\|while\|do\|done\|\[\]\|\[\[\|\]\]\):\1<span class="immed">\2</span>:g
s,\(^\(function\s\+\)\?\(\w\+()\)\),<span class="defining">\2</span> <span class="name">\3</span>,g
s:\(local\|declare\):<span class="defining">\1</span>:g
