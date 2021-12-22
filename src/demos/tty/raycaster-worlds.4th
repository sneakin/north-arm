" *              *
                
                
          XYX   
          YXY   
          XYX                
                
                
                
                
       YX       
       XY       
                
                
*              *" 16 17 make-world const> world0

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
****************" 16 17 make-world const> world1

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
****************" 16 17 make-world const> world2

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
****************" 16 17 make-world const> world3

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
****************" 12 17 make-world const> world4

" *****************       ***
*    AAAA      BW          *
*    bwwb      BW          *
*    bwwb                  *
*    bwwb                  *
*              BW          X
*              BW          X
*              BW          X
*              BW          X
************   *************" 10 29 make-world const> world5

' world6 [UNLESS]
tmp" src/demos/tty/raycaster-00.map" drop allot-read-file drop
44 81 make-world const> world6
[THEN]

' world7 [UNLESS]
tmp" src/demos/tty/raycaster-01.map" drop allot-read-file drop
44 81 make-world const> world7
[THEN]
