" *              *
                
                
          XYX   
          YXY   
          XYX                
                
                
                
                
       YX       
       XY       
                
                
*              *" 16 17 make-static-world const> world0

" ****************
*       M      *
*    MMMM      *
*    T         *
*              *
*              *
*              *
*              *
D              *
D              *
*              *
*              *
*          X XX*
*          X   *
*          X   *
****************" 16 17 make-static-world const> world1

" ****************
*              *
*              *
*         XY   *
*         YX   *
*              *
*              *
*              *
*              *
*              *
*              *
*      YX      *
*      XY      *
*              *
*              *
****************" 16 17 make-static-world const> world2

" ****************
*    X         *
*   X          *
*  X           *
* X            *
*X             *
*              *
*              *
*              *
*              *
*            44*
*         33 44*
*      22 33 44*
*   11 22 33 44*
*00 11 22 33 44*
****************" 16 17 make-static-world const> world3

" ****************
*              *
*              *
*              *
*              *
*              *
*              *
*              *
*  123    456  *
*              *
*     7890     *
****************" 12 17 make-static-world const> world4

" *****************       ***
*   bAAAAb     BW          *
*   bbwwbb     BW          *
*   bbwwbb                 *
*   bbwwbb                 *
*              BW          X
*              BW          X
*              BW          X
*              BW          X
************   *************" 10 29 make-static-world const> world5

' world6 UNLESS
tmp" src/demos/tty/raycaster-00.map" drop allot-read-file drop
44 81 make-static-world const> world6
THEN

' world7 UNLESS
tmp" src/demos/tty/raycaster-01.map" drop allot-read-file drop
44 81 make-static-world const> world7
THEN

' world8 UNLESS
tmp" src/demos/tty/raycaster-08.map" drop allot-read-file drop
64 65 make-static-world const> world8
THEN

def world9-fn ( y x world -- cell )
  arg2 arg1 arg0 world-contains? IF
    arg2 arg0 World -> height @ 2 / - abs-int 8 int<
    arg1 arg0 World -> width @ 2 / - abs-int 8 int< and
    IF 98
    ELSE
      arg1 1 bsr arg0 World -> data @ mod 0 equals?
      arg2 1 bsr arg0 World -> data @ mod 0 equals? and
      IF 87
      ELSE 32
      THEN
    THEN
  ELSE 42
  THEN 3 return1-n
end

' world9-fn 4 128 128 make-world const> world9
