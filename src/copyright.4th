token-buffer-max 320 int>= [IF]
" [1m[31;40m╔[37;40m Copyright © 2020-2021 Nolan Eakins, SemanticGap™. All rights reserved. [1m[31;40m╗[37;40m
[1m[31;40m╚[36;40m https://github.com/sneakin/north-arm.git [1m[31;40m║[36;40m      semanticgap.com        [1m[31;40m╝[0m"
[ELSE]
" ╔ Copyright © 2020-2021 Nolan Eakins, SemanticGap™. All rights reserved. ╗
╚ https://github.com/sneakin/north-arm.git ║      semanticgap.com        ╝"
[THEN]

NORTH-STAGE 0 int> [IF] BUILD-COPYRIGHT poke [ELSE] set-BUILD-COPYRIGHT [THEN]
