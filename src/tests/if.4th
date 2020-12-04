1 IF 2 THEN 2 assert-equals
1 0 IF 2 THEN 1 assert-equals

0 1 IF 2 ELSE 3 THEN 2 assert-equals 0 assert-equals
1 0 IF 2 ELSE 3 THEN 3 assert-equals 1 assert-equals

10 0 IF
  0 1 IF 2 ELSE 3 THEN 2 assert-equals 0 assert-equals
  1 0 IF 2 ELSE 3 THEN 3 assert-equals 1 assert-equals
THEN 10 assert-equals
