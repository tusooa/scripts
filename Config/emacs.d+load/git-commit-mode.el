(defface git-commit-filename-face '((t (:foreground "white" :weight bold))) "")
(defface git-commit-removal-face '((t (:foreground "red"))) "")
(defface git-commit-add-face '((t (:foreground "green"))) "")
(defvar git-commit-filename-face 'git-commit-filename-face)
(defvar git-commit-removal-face 'git-commit-removal-face)
(defvar git-commit-add-face 'git-commit-add-face)
(defvar git-commit-mode-keywords '())
(setq git-commit-mode-keywords
      `(("^#\\(\\+\\+\\+\\|---\\) .*$" . git-commit-filename-face)
        ("^#\\+.*$" . git-commit-add-face)
        ("^#-.*$" . git-commit-removal-face)
        ("^#.*$" . font-lock-comment-face)))
(defvar git-commit-mode-hook '())
(define-derived-mode git-commit-mode fundamental-mode "Commit-Msg"
  "Major mode for editing git-commit.perl files"
  (set (make-local-variable 'font-lock-defaults) '(git-commit-mode-keywords)))
(defvar git-commit-mode-syntax-table '())
(setq git-commit-mode-syntax-table
      (let ((table (make-syntax-table)))
        (modify-syntax-entry ?\" "w" table)
        ;(modify-syntax-entry ?# )
        table))

(provide 'git-commit-mode)
