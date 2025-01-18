0 defvar> *return-stack-size*

def proper-init
  arg0 stack-allot
  dup return-stack poke
  *return-stack-base* poke
  arg0 *return-stack-size* poke
  exit-frame
end
