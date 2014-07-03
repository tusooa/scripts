
(defvar text-alias-mode-keywords '())
(setq text-alias-mode-keywords
      `(("^#==?> +\\(layout\\|alias\\|block\\|end-block\\|def-var\\|eval-layout\\|eval-alias\\) " . font-lock-keyword-face)
        ("^#.*$" . font-lock-comment-face)))
(defvar text-alias-mode-hook '())
(define-derived-mode text-alias-mode fundamental-mode "T.Alias"
  "Major mode for editing text-alias.perl files"
  (set (make-local-variable 'font-lock-defaults) '(text-alias-mode-keywords)))
(defvar text-alias-mode-syntax-table '())
(setq text-alias-mode-syntax-table (make-syntax-table))
;      (let ((st (make-syntax-table)))
;            (modify-syntax-entry ?# "." st)
;            (modify-syntax-entry ?\n ">" st)
;            st))
(provide 'text-alias-mode)
