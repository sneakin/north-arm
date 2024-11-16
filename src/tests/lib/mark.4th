' mark> defined? UNLESS
  s[ src/lib/mark.4th ] load-list
THEN

' assert defined? UNLESS
  s[ src/lib/assert.4th ] load-list
THEN

( Mark the initial dictionaries. )

mark> pre-test

( Define a new word: )

: sq dup * ;

( Switch to init mark. )
pre-test push-mark> geo

' sq defined? assert-not
' geo defined? assert

( Try the new mark: )

geo use-mark

' sq defined? assert
' geo defined? assert-not

3 sq 9 assert-equals

( Add a word for a new mark: )

: mag2 sq swap sq + ;

( Switch back: )
pre-test push-mark> geo2

' sq defined? assert-not
' mag2 defined? assert-not
' geo defined? assert-not
' geo2 defined? assert

( Try the new mark: )
geo2 use-mark

' sq defined? assert
' mag2 defined? assert
' geo defined? assert-not
' geo2 defined? assert-not

3 4 mag2 25 assert-equals

( Switch back to the initial mark: )
pre-test use-mark

' sq defined? assert-not
' mag2 defined? assert-not
' geo defined? assert-not
' geo2 defined? assert-not
