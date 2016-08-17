; highlight tabs in file
; 然而并不能用。
(defvar highlight-tab-mode nil)
(defface highlight-tab-face '((t (:background "#f02df0"))) "Face for highlight tab")
(defvar highlight-tab-keywords '())
(setq highlight-tab-keywords `(("\t" 0 highlight-tab-face t)))
(define-minor-mode highlight-tab-mode
  "" nil " Tab" nil
  (cond (highlight-tab-mode
         (font-lock-add-keywords nil highlight-tab-keywords))
        (t (font-lock-remove-keywords nil highlight-tab-keywords))))
(defun highlight-tab-on ()
    (highlight-tab-mode 1))
(define-globalized-minor-mode global-highlight-tab-mode highlight-tab-mode highlight-tab-on)
(provide 'highlight-tab)
