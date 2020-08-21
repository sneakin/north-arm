: test-case
  CASE
  1 WHEN " one" error-line ;;
  2 WHEN " two" error-line ;;
  3 WHEN " three" error-line ;;
  " idk" error-line
  ESAC
  drop " done" error-line
;
