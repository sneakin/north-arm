# Any compiled code needs to populate a dictionary
# on the data stack. Each word needs to point to the entry's cell on the data stack.
COMPDICT=0
DICT['dict']='fpush "$COMPDICT"'
DICT['set-dict']='COMPDICT="${STACK[0]}"; fpop'

DICT['create']='feval dhere swap dpush 0 dpush dict dpush dup set-dict'
DICT['def']='feval next-token create read-def-to-data swap set-dict-entry-data'
