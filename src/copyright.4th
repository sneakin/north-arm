DEFINED? string-buffer-max IF string-buffer-max ELSE token-buffer-max THEN
dup 580 int>= IF
  drop
  " [31m╔═════════════━━━━━━━━━━━━┅┅┅┅┅┅┅┅┅┅┅┅┄┄┄┄┄┄┄┄┄┄┄┄┄┄[39m
[31m║[39m [33;1;4m*[39m North  [0;24m   [36;1mhttps://github.com/sneakin/north-arm/[39;0m
[31m║[39m Copyright © 2020-2025 Nolan Eakins @ [1mSemanticGap™[0m
[31m║[39m All rights reserved.        [36;1msemanticgap.com[39;0m
[31m╚═════════════━━━━━━━━━━━━┅┅┅┅┅┅┅┅┅┅┅┅┄┄┄┄┄┄┄┄┄┄┄┄┄┄[39m"
ELSE
  dup 473 int>= IF
    drop
    " ╔═════════════━━━━━━━━━━━━┅┅┅┅┅┅┅┅┅┅┅┅┄┄┄┄┄┄┄┄┄┄┄┄┄┄
║ * North     https://github.com/sneakin/north-arm/
║ Copyright © 2020-2025 Nolan Eakins @ SemanticGap™
║ All rights reserved.        semanticgap.com
╚═════════════━━━━━━━━━━━━┅┅┅┅┅┅┅┅┅┅┅┅┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
  ELSE
    drop
    " Copyright (C) 2020-2025 Nolan Eakins, SemanticGap. All rights reserved.
https://github.com/sneakin/north-arm.git"
  THEN
THEN

NORTH-STAGE 0 int> IF BUILD-COPYRIGHT poke ELSE set-BUILD-COPYRIGHT THEN

