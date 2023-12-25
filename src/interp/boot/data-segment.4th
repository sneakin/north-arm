' ds defined? UNLESS
  create> *ds* dict does> do-var
  128 stack-allot-zero dict dict-entry-data !
  *ds* cs - const> *ds-offset*
  def ds *ds* @ return1 end
  def set-ds arg0 *ds* ! 1 return0-n end
THEN

def data-segment-size
  ds @ return1
end

def ds-slot
  ds arg0 seq-nth set-arg0
end

def ds-clone/1 ( where -- )
  ds arg0 copy-seq-n 1 return0-n
end

def ds-reinit/1 ( where -- )
  *init-data* cs + arg0 copy-seq-n
  1 return0-n
end

def ds-reinit
  cs *ds-offset* + set-ds
  ds ds-reinit/1
end
