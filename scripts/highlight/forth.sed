s:\(" [^"]*"\):<span class="string">\1</span>:Mg
t
s:\(end-frame\):<span class="end-delimiting">\1</span>:g
t
s:\(( [^)]*\()\|\$\)\):<span class="comment">\1</span>:Mg
s,\(^[:]\+\|def\S*\|\S\+&gt[;]\)\s\+\(\S\+\),<span class="defining">\1</span> <span class="name">\2</span>,g
s:\(begin\|begin-frame\):<span class="delimiting">\1</span>:g
s:\(' \|literal\|int[0-9]\+\+\|float[0-9]\+\|pointer\|offset[0-9]\+\):<span class="type">\1</span>:g
s:\(,\w\+\):<span class="comma word">\1</span>:g
s:\(^[;]\|[;]$\|end\S*\):<span class="end-defining">\1</span>:g
s:\(IF\|UNLESS\|ELSE\|THEN\|CASE\|WHEN\|ESAC\|;;\|loop\|repeat-frame\|\(if\|unless\)-jump\):<span class="immed">\1</span>:g
s:\(\(^\|\s\)\(-\)\?\(0x\|#x\)[0-9a-fA-F]\+\):<span class="number">\1</span>:g
s:\(\(^\|\s\)\(-\)\?[0-9]\+\):<span class="number">\1</span>:g

