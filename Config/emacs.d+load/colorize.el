; 来自 https://github.com/lilydjwg/colorizer
;      http://www.emacswiki.org/emacs/hexcolour.el
;      http://www.emacswiki.org/emacs/HexColour
; 及   http://www.emacswiki.org/emacs/hexrgb.el
(require 'cl)
(defun hexcolour-luminance (color)
  "Calculate the luminance of a color string (e.g. \"#ffaa00\", \"blue\").
  This is 0.3 red + 0.59 green + 0.11 blue and always between 0 and 255."
  (let* ((values (x-color-values color))
         (r (car values))
         (g (cadr values))
         (b (caddr values)))
    (floor (+ (* .3 r) (* .59 g) (* .11 b)) 256)))
(defvar colorize-mode nil)
(defvar hexcolor-keywords '())
(setq hexcolor-keywords
      `((,(concat "#[0-9a-fA-F]\\{3\\}[0-9a-fA-F]\\{3\\}?\\|" (regexp-opt (x-defined-colors) 'words))
         (0 (let
                ((color (match-string-no-properties 0)))
              (put-text-property
               (match-beginning 0) (match-end 0)
               'face `((:foreground ,(if (> 128.0 (hexcolor-luminance color))
                                         "white" "black"))
                       (:background ,color))))))))
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
    (unless (string= major-mode "erc-mode") (colorize-mode 1))); erc-mode里，会导致本来该有颜色的，没有颜色。原因未知。只能先去掉。
(define-globalized-minor-mode global-colorize-mode colorize-mode colorize-on)
(provide 'colorize)
