def eat-line
  string-buffer-max stack-allot string-buffer-max read-line
end

defalias> # eat-line
defalias> // eat-line

defalias> #!/bin/env eat-line
defalias> #!/usr/bin/env eat-line
defalias> #!/usr/local/bin/env eat-line

defalias> #!/usr/bin/north-interp eat-line
defalias> #!/bin/north-interp eat-line
defalias> #!/usr/local/bin/north-interp eat-line

