token-buffer-max 567 int>= [IF]
" [31m╔═════════════━━━━━━━━━━━━┅┅┅┅┅┅┅┅┅┅┅┅┄┄┄┄┄┄┄┄┄┄┄┄[39m
[31m║[39m [33;1m*[39;0m [1mNorth[0m     [36;1mhttps://sneakin.github.io/north-arm/[39;0m
[31m║[39m Copyright © 2020-2022 Nolan Eakins @ [1mSemanticGap™[0m
[31m║[39m All rights reserved.        [36;1msemanticgap.com[39;0m
[31m╚═════════════━━━━━━━━━━━━┅┅┅┅┅┅┅┅┅┅┅┅┄┄┄┄┄┄┄┄┄┄┄┄[39m"
[ELSE]
token-buffer-max 459 int>= [IF]
" ╔═════════════━━━━━━━━━━━━┅┅┅┅┅┅┅┅┅┅┅┅┄┄┄┄┄┄┄┄┄┄┄┄
║ * North     https://sneakin.github.io/north-arm/
║ Copyright © 2020-2022 Nolan Eakins @ SemanticGap™
║ All rights reserved.        semanticgap.com
╚═════════════━━━━━━━━━━━━┅┅┅┅┅┅┅┅┅┅┅┅┄┄┄┄┄┄┄┄┄┄┄┄"
[ELSE]
" Copyright (C) 2020-2022 Nolan Eakins, SemanticGap. All rights reserved.
https://github.com/sneakin/north-arm.git"
[THEN]
[THEN]

NORTH-STAGE 0 int> [IF] BUILD-COPYRIGHT poke [ELSE] set-BUILD-COPYRIGHT [THEN]

