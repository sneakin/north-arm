( todo save mark before file loading to restore on failure )
( todo store data and stats on required files )
( todo this file to init loaded files list, full list when compiled )
( todo require-relative )
( todo stage0 )

SYS:DEFINED? require[ IF
  OUT:DEFINED? make-instance
  IF require[ linux/stat ]
  ELSE require[ linux/stat-lite ]
  THEN

  require[ list-cs pathname ]
ELSE
  
  SYS:DEFINED? OUT:DEFINED?
  IF OUT:DEFINED? find-first-result+cs
  ELSE DEFINED? find-first-result+cs
  THEN UNLESS s[ src/lib/list-cs.4th ] load-list THEN

  SYS:DEFINED? OUT:DEFINED?
  IF OUT:DEFINED? file-exists?
  ELSE DEFINED? file-exists?
  THEN UNLESS
    OUT:DEFINED? make-instance
    IF s[ src/lib/linux/stat.4th ] load-list
    ELSE s[ src/lib/linux/stat-lite.4th ] load-list
    THEN
  THEN

  SYS:DEFINED? OUT:DEFINED?
  IF OUT:DEFINED? pathname-join/6
  ELSE DEFINED? pathname-join/6
  THEN UNLESS s[ src/lib/pathname.4th ] load-list THEN

THEN

NORTH-STAGE 0 equals? IF
  s[ src/lib/list-cs.4th src/lib/linux/stat-lite.4th src/lib/pathname.4th ] load-list
THEN


SYS:DEFINED? defvar> IF
  0 defvar> *loaded-files*
ELSE  
  0 var> *loaded-files*
THEN

s[ /lib/north
   /usr/lib/north
   /usr/local/lib/north
   src/lib
   src
   .
]
SYS:DEFINED? defvar>
IF ,out-string-list to-out-addr defvar> *load-paths*
ELSE var> *load-paths*
THEN

s[ .4th .nth ]
SYS:DEFINED? defvar>
IF ,out-string-list to-out-addr defvar> *north-file-exts*
ELSE  var> *north-file-exts*
THEN
  
def find-file-ext-fn ( candidate-ext out-buffer out-max fn-length -- full-path true | false )
  arg3 string-length
  arg3 arg2 arg0 + local0 copy
  arg2 arg0 local0 + null-terminate
  arg2 file-exists?
  IF arg2 arg0 local0 + true 4 return2-n
  ELSE false 4 return1-n
  THEN
end

def find-file-fn ( candidate-dir out-buffer out-max file-name fn-length ext-list -- full-path true | false )
  ( append file name to the candidate )
  4 argn arg3 5 argn dup string-length arg2 arg1 pathname-join/6
  UNLESS false 6 return1-n THEN
  ( try the extensions )
  ' find-file-ext-fn 4 argn arg3 4 overn 3 partial-first-n
  arg0 as-code-pointer over find-first-result+cs
  IF 4 set-argn true 4 return1-n
  ELSE false 6 return1-n
  THEN
end

def write-line-list
  arg0 ' write-line map-car+cs
  1 return0-n
end

def error-line-list
  arg0 ' error-line map-car+cs
  1 return0-n
end

( Search for a file in a list of dirertories trying different file name extensions. The fdnal path name is copied into ~out~. )
def find-file/6 ( out out-len path path-len dir-list ext-list -- out out-len true | false )
  arg0 as-code-pointer " " cons ( s[ can not have empty strings so add one )
  ' find-file-fn 5 argn 4 argn arg3 arg2 6 overn 5 partial-first-n
  arg1 as-code-pointer over find-first-result+cs
  IF 4 set-argn true 4 return1-n
  ELSE false 6 return1-n
  THEN
end

DEFINED? OUT:DEFINED? IF OUT:DEFINED? string-equals? ELSE DEFINED? string-equals? THEN
UNLESS
  def string-equals?
    arg1 arg0
    arg1 string-length
    arg0 string-length
    2dup equals? IF drop byte-string-equals?/3 ELSE false THEN 2 return1-n
  end
THEN

def loaded?
  ' string-equals? arg0 partial-first
  *loaded-files* @ swap find-first IF true ELSE false THEN return1-1
end

SYS:DEFINED? OUT:DEFINED? IF OUT:DEFINED? pad-addr ELSE DEFINED? pad-addr THEN
UNLESS
  def pad-addr ( addr alignment )
    arg1 arg0 1 - + arg0 uint-div arg0 int-mul
    2 return1-n
  end
THEN

def move-string-right ( str len max-len -- new-str len )
  arg2 arg0 + arg1 - 1 - cell-size - cell-size pad-addr
  arg2 over arg1 copy
  dup arg1 null-terminate
  arg1 3 return2-n
end

( todo loaded-files needs to have a copy of the string )

def load-once ( path ++ ok? )
  arg0 loaded?
  IF true return1-1
  ELSE
    arg0 load IF
      arg0 *loaded-files* push-onto
      true exit-frame
    ELSE
      false return1-1
    THEN
  THEN
end

def require ( path ++ ok? )
  max-pathname stack-allot-zero max-pathname
  arg0 dup string-length
  *load-paths* @ *north-file-exts* @ find-file/6
  IF
    over max-pathname 4 overn 4 overn pathname-expand
    IF
      ( tighten the memory alloc )
      max-pathname move-string-right
      over move here
      load-once exit-frame
    ELSE
      s" Failed to expand path name: " error-string/2
      arg0 error-line
    THEN
  THEN false return1-1
end

def require-list
  arg0 0 ' require revmap-cons/3 exit-frame
end

def require[
  POSTPONE s[ require-list exit-frame
end
