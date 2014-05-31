; 来自 https://github.com/lilydjwg/colorizer
;      http://www.emacswiki.org/emacs/hexcolour.el
;      http://www.emacswiki.org/emacs/HexColour
; 及   http://www.emacswiki.org/emacs/hexrgb.el
(defvar colorize-mode nil)
(defvar hexcolor-keywords
        '(("#[abcdef[:digit:]]\\{3,6\\}"
           (0 (let ((colour (match-string-no-properties 0)))
                (if (or (= (length colour) 4)
                        (= (length colour) 7))
                    (put-text-property 
                     (match-beginning 0)
                     (match-end 0)
                     'face (list :background (match-string-no-properties 0)
                                 :foreground (if (>= (apply '+ (x-color-values 
                                                                (match-string-no-properties 0)))
                                                     (* (apply '+ (x-color-values "white")) .6))
                                                 "black" ;; light bg, dark text
                                               "white" ;; dark bg, light text
                                              )))))
              append))))
;(defun hexcolor-add-to-font-lock ()
;   (font-lock-add-keywords nil hexcolor-keywords))
;(font-lock-remove-keywords nil hexcolor-keywords)
;(add-hook 'css-mode-hook 'hexcolor-add-to-font-lock)
;(add-hook 'conf-space-mode-hook 'hexcolor-add-to-font-lock)
;(defun colorize-mode (&optional arg)
;  (interactive "P")
;  (setq colorize-mode
;        (if (null arg) (not colorize-mode)
;          (> (prefix-numeric-value arg) 0)))
;  (add-to-list 'minor-mode-alist '(colorize-mode " col"))
;  (cond (colorize-mode
;         (font-lock-add-keywords nil hexcolor-keywords t))
;        (t (font-lock-remove-keywords nil hexcolor-keywords))))
(define-minor-mode colorize-mode
  "" nil " col" nil
  (cond (colorize-mode
         (font-lock-add-keywords nil hexcolor-keywords t))
        (t (font-lock-remove-keywords nil hexcolor-keywords))))
(defun colorize-on ()
  (unless (minibufferp)
    (unless (string= major-mode "erc-mode") (colorize-mode 1)))); erc-mode里，会导致本来该有颜色的，没有颜色。原因未知。只能先去掉。
(define-globalized-minor-mode global-colorize-mode colorize-mode colorize-on)
(provide 'colorize)
