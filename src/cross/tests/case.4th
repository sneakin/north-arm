: test-case
  CASE
  1 WHEN s" one" write-string/2 ;;
  2 WHEN s" two" write-string/2 ;;
  3 WHEN s" three" write-string/2 ;;
  s" idk" write-string/2
  ESAC
  drop s" done" write-string/2
;
