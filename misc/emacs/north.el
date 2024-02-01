(require 'forth-mode)
(load (concat (file-name-directory (or load-file-name buffer-file-name)) "sprites.elisp"))

(forth-syntax--define "\"" #'forth-syntax--state-string)
(forth-syntax--define "tmp\"" #'forth-syntax--state-string)
;;(forth-syntax--define "literal" #'forth-syntax--state-parsing-keyword)
(setf north-syntax--parsing-words (list "literal" "int32" "pointer" "offset"))
(setf north-syntax--defining-words (list "def" "defcol" "defop" "var>" "const>" "defvar>" "defconst>"))
(setf north-syntax--font-lock-keywords (list "!" "poke" "@" "peek" "[if]" "[unless]" "[else]" "[then]" "unless" "end" "endcol" "repeat-frame" "begin-frame" "end-frame" "exit-frame" "return0-n" "return1-n" "return2-n" "->" "." "when" ";;" "of-str"))

(dolist (w north-syntax--parsing-words)
  (forth-syntax--define w #'forth-syntax--state-parsing-word))

(dolist (w north-syntax--defining-words)
  (forth-syntax--define w #'forth-syntax--state-defining-word))

(dolist (w north-syntax--font-lock-keywords)
  (forth-syntax--define w #'forth-syntax--state-font-lock-keyword))

(defun forth-syntax--parse-tty-img (backward-regexp forward-regexp)
  (let ((pos (point)))
    (re-search-backward backward-regexp)
    ;;(forth-syntax--set-syntax (point) (1+ (point)) "|")
    (message (format "tty img %s %s" pos (point)))
    (goto-char pos)
    (cond ((re-search-forward forward-regexp nil t)
	   (message (format "tty img 2 %s %s" pos (point)))
	   ;;(forth-syntax--set-syntax (1- (point)) (point) "|")
	   ;;(process-buffer-tty-image pos (point))
	   ;;(font-lock-unfontify-region pos (point))
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
    (`(:list-intro . "s\\[") (* 5 forth-smie-basic-indent))
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

(add-to-list 'auto-mode-alist '("\\.\\(nth\\)\\'" . north-mode))

(provide 'north-mode)
