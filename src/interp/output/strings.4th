( String and byte output: )

0 defvar> *debug*
defcol debug? *debug* peek swap endcol

def write-string/3 ( string length fd -- )
  arg1 arg2 arg0 write
end

defcol write-string/2 ( string length -- )
  rot current-output peek write drop
endcol

defcol write-string
  swap dup string-length write-string/2
endcol

defcol write-line/2
  rot swap write-string/2 nl
endcol

defcol write-line
  swap write-string nl
endcol

defcol write-byte ( byte )
  swap here int32 1 write-string/2
  drop
endcol

defcol error-string/2
  rot current-error peek write drop
endcol

defcol error-string
  swap dup string-length error-string/2
endcol

defcol error-byte
  swap here int32 1 error-string/2
  drop
endcol

defcol error-line/2
  rot swap error-string/2 enl
endcol

defcol error-line
  swap dup string-length error-line/2
endcol
