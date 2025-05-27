def dict-entry-equiv? ( word-a word-b -- yes? )
  ( Returns true when both words have the same code and data values. )
  arg1 arg0 equals?
  IF true
  ELSE arg1 dict-entry-code peek
       arg0 dict-entry-code peek equals?
       IF arg1 dict-entry-data peek
	  arg0 dict-entry-data peek equals?
       ELSE false
       THEN
  THEN 2 return1-n		    
end
