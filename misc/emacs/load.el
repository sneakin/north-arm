(mapcar #'(lambda (p) (load (format "%s%s" (file-name-directory (or load-file-name (buffer-file-name))) p)))
	'("helpers.el"
	  "north-mode.el"
	  "north.el"))
