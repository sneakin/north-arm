0 defvar> *return-stack-size*

def proper-init
  arg0 stack-allot return-stack poke
  arg0 *return-stack-size* poke
  exit-frame
end
