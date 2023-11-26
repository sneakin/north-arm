;;; north-mode.el: Adds North keywords to forth-mode.
;;; Contains forth-mode code, so this file ~north-mode.el~ is licensed under the GPL.

(require 'forth-mode)
(load (concat (file-name-directory (or load-file-name buffer-file-name)) "sprites.elisp"))

(forth-syntax--define "\"" #'forth-syntax--state-string)
(forth-syntax--define "tmp\"" #'forth-syntax--state-string)
;;(forth-syntax--define "literal" #'forth-syntax--state-parsing-keyword)
(setf north-syntax--parsing-words (list "literal" "int32" "pointer" "offset"))
(setf north-syntax--defining-words (list "def" "defcol" "defop" "var>" "const>" "defvar>" "defconst>" "alias>" "defalias>"))
(setf north-syntax--font-lock-keywords (list "[if]" "[unless]" "[else]" "[then]" "unless" "end" "endcol" "endop" "repeat-frame" "begin-frame" "end-frame" "->" "." "when" ";;" "of-str"))
(setf north-syntax--font-lock-builtins (list "argn" "set-argn" "localn" "set-localn" "repeat-frame" "recurse" "return" "return0" "return1" "return0-n" "return1-n" "return2-n" "drop-locals" "exit-frame" "exec" "exec-abs" "exec-cs" "!" "poke" "@" "peek"))

(dolist (w north-syntax--parsing-words)
  (forth-syntax--define w #'forth-syntax--state-parsing-word))

(dolist (w north-syntax--defining-words)
  (forth-syntax--define w #'forth-syntax--state-defining-word))

(dolist (w north-syntax--font-lock-keywords)
  (forth-syntax--define w #'forth-syntax--state-font-lock-keyword))

;;; Has to be patched to keep the font-lock-face property of tty-img's.
(defun forth-syntax-propertize (start end)
  (save-excursion
    ;; sneakin: this is the troublesome line
    ;;(remove-text-properties start end '(font-lock-face))
    (let* ((guess (forth-syntax--guess-state start))
	   (state (cdr guess)))
      ;;(message "forth-syntax-propertize: %s %s %s" start end guess)
      (goto-char (car guess))
      (while (< (point) end)
	(let ((start (point)))
	  (setq state (funcall state))
	  (cl-assert (< start (point))))))))

(defun forth-syntax--word-state (font-lock-face)
  (let ((start forth-syntax--current-word-start))
    (put-text-property start (point) 'font-lock-face font-lock-face)
    (forth-syntax--state-normal)))

(defun forth-syntax--state-builtin ()
  (forth-syntax--word-state font-lock-builtin-face))

(defun forth-syntax--state-number ()
  (forth-syntax--word-state font-lock-constant-face))

(dotimes (i 4)
  (forth-syntax--define (format "arg%i" i) #'forth-syntax--state-builtin)
  (forth-syntax--define (format "set-arg%i" i) #'forth-syntax--state-builtin)
  (forth-syntax--define (format "local%i" i) #'forth-syntax--state-builtin)
  (forth-syntax--define (format "set-local%i" i) #'forth-syntax--state-builtin))

(mapcar #'(lambda (i) (forth-syntax--define i #'forth-syntax--state-builtin))
	north-syntax--font-lock-builtins)

(defun forth-syntax--parse-tty-img (backward-regexp forward-regexp)
  (let ((pos (point)))
    (re-search-backward backward-regexp)
    ;;(forth-syntax--set-syntax (point) (1+ (point)) "|")
    (message (format "tty img %s %s" pos (point)))
    (goto-char pos)
    (cond ((re-search-forward forward-regexp nil t)
	   (message (format "tty img 2 %s %s" pos (point)))
	   ;;(message (format "tty img 2 %s %s %s" pos (point) (buffer-substring pos (point))))
	   ;;(forth-syntax--set-syntax (1- (point)) (point) "|")
	   ;;(process-buffer-tty-image (- pos 15) (point))
	   ;;(font-lock-unfontify-region pos (point))
	   ;;(set-text-properties pos (point) `(font-lock-face (:foreground "red") fontified t))
	   (goto-char (point))
	   #'forth-syntax--state-normal)
	  (t
	   (goto-char (point-max))
	   #'forth-syntax--state-eob))))

(defmacro forth-syntax--define-tty-img-state (begin end)
  (let ((fname (intern (concat "forth-syntax--state-" begin))))
    `(defun ,fname ()
       (forth-syntax--parse-tty-img ,(concat (regexp-quote begin) "\\=")
				    ,(regexp-quote end)))))

(forth-syntax--define-tty-img-state "tty-img[" "]")
(forth-syntax--define "tty-img[" #'forth-syntax--state-tty-img\[ )

(defconst NORTH-DECIMAL-REGEXP "\\([0-9]+\\([.][0-9]+\\)?\\)")
(defconst NORTH-HEXADECIMAL-REGEXP "\\([0#]x[0-9A-Fa-f]+\\([.][0-9A-Fa-f]+\\)?\\)")
(defconst NORTH-NUMBER-REGEXP (concat "[-+]?\\(" NORTH-DECIMAL-REGEXP "\\|" NORTH-HEXADECIMAL-REGEXP "\\)"))

(defun forth-syntax--state-normal ()
  (let ((start (forth-syntax--skip-word)))
    (cond ((= start (point))
	   #'forth-syntax--state-eob)
	  (t
	   (forth-syntax--set-word-syntax start (point))
	   (let* ((word (buffer-substring-no-properties start (point)))
		  (parser (forth-syntax--lookup word)))
	     (cond (parser
		    (setq forth-syntax--current-word-start start)
		    (funcall parser))
		   (t
		    ;; My addition to match numbers:
		    (when (eq 0 (string-match NORTH-NUMBER-REGEXP word))
			(setq forth-syntax--current-word-start start)
			(forth-syntax--word-state font-lock-constant-face))
		      #'forth-syntax--state-normal)))))))

(defvar north-smie--grammar
  (smie-prec2->grammar
   (smie-bnf->prec2
    '((control
       ("[if]" words "[else]" words "[then]")
       ("[if]" words "[then]")
       ("[unless]" words "[else]" words "[then]")
       ("[unless]" words "[then]")
       ("unless" words "else" words "then")
       ("unless" words "then")
       ("def" words "end")
       ("defcol" words "endcol")
       ("defop" words "endop")
       ("begin-frame" words "end-frame")
       ("case" words "esac")
       ("when" words ";;")
       ("of-str" words "endof")
       ("dotimes[" words "]dotimes")
       ("s[" words "]")
       ("tty-img[" words "]")
       ;; forth
       ("if" words "else" words "then")
       ("if" words "then")
       ("begin" words "while" words "repeat")
       ("begin" words "until")
       ("begin" words "again")
       ("?of" words "endof")
       ("of" words "endof")
       ("case" words "endcase")
       ("?do" words "loop")
       ("?do" words "+loop")
       ("do" words "loop")
       ("do" words "+loop")
       ("begin-structure" words "end-structure")
       (":" words ";")
       (":noname" words ";"))
      (words)))))

(defun north-smie--indentation-rules (kind token)
  (pcase (cons kind token)
    (`(:elem . args)
     (cond ((smie-rule-prev-p ":" "def" "defcol" "defop" "s\\[")
            (- (+ (save-excursion
		    (forth-smie--backward-token)
		    (current-column))
                  forth-smie-basic-indent)
               (current-column)))
           (t 0)))
    (`(:after . "def") (* 2 forth-smie-basic-indent))
    (`(:list-intro . "def") nil)
    (`(:after . "defop") (* 2 forth-smie-basic-inzdent))
    (`(:list-intro . "defop") nil)
    (`(:after . "defcol") (* 2 forth-smie-basic-indent))
    (`(:list-intro . "defcol") nil)
    (`(:after . "tty-img[") 0)
    (`(:list-intro . "tty-img[") nil)
    (`(:after . "s\\[")               (* 5 forth-smie-basic-indent))
    (`(:list-intro . "s\\[") (* 6 forth-smie-basic-indent))
    (_ (forth-smie--indentation-rules kind token))))

(defun north-smie-setup ()
  (smie-setup north-smie--grammar #'north-smie--indentation-rules
	      :forward-token #'forth-smie--forward-token
	      :backward-token #'forth-smie--backward-token))

(provide 'north-smie)

(defun north-outline-mode ()
  (interactive)
  (outline-minor-mode)
  (setf outline-regexp "\\(def\\|:\\|.*\\(alias\\|const\\|var\\)>\\)"))

(defun north-beginning-of-defun (arg) (forth-beginning-of-defun arg))

(define-derived-mode north-mode forth-mode "North"
		     "Major mode for editing North files."
		     :syntax-table forth-mode-syntax-table
  (setq-local beginning-of-defun-function #'north-beginning-of-defun)
  (setq-local comment-start-skip "[(\\][ \t*]+")
  (setq-local comment-start "( ")
  (setq-local comment-end " )")
  (setq-local comment-region-function #'forth-comment-region)
  (north-smie-setup)
  (north-outline-mode))

(add-to-list 'auto-mode-alist '("\\.\\(4th\\|nth\\)\\'" . north-mode))

(provide 'north-mode)
