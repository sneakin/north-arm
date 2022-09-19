struct: MmapStack
inherits: Stack

def init-mmap-stack ( stack-size stack ++ stack true | false )
  arg1 mmap-stack
  dup 0 int> IF arg0 init-stack true 2 return2-n
  ELSE false 2 return1-n ( todo throw error )
  THEN
end

def destroy-mmap-stack
  arg0 MmapStack -> size @ arg0 MmapStack -> base @ munmap
  arg0 destroy-stack
  1 return0-n
end
