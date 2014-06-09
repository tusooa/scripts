(mapc 'require
      '(ibuffer redo fvwm-mode cmake-mode php-mode highlight-tail ;gentoo-syntax
                linum tramp haskell-mode colorize rainbow-delimiters))

; linum
(global-linum-mode t)
;这TM是干什么的啊
(defun no-linum (&rest ignore)
  (when linum-mode (linum-mode 0)))

; sudo编辑文件
(setq tramp-default-method "sudo")

(setq highlight-tail-colors '(("black" . 0)
                              ("#bc2525" . 25)
                              ("black" . 66))
      highlight-tail-posterior-type t
;      highlight-tail-const-width 20
)
(highlight-tail-mode t)
; outline
(setq outline-minor-mode-prefix [(control o)])
;(add-hook 'css-mode-hook #'(lambda () (hexcolour-mode t)))
; workgroups
;(setq wg-prefix-key (kbd "C-c C-w"))
;(wg-create-workgroup "tusooa")
;(workgroups-mode 100)

(global-colorize-mode t);例如#6cf这样的文字，显示对应的颜色。
;rainbow
; 把括号都给加上颜色
; https://github.com/luochen1990/rainbow (vim)
; https://duckduckgo.com/?q=Parentheses%20color+site%3Aemacswiki.org
; http://www.emacswiki.org/emacs/RainbowDelimiters
(global-rainbow-delimiters-mode)
; 彩虹之色，见custom.el
; 由于本身有九个，所以我添加了浅绿和暗紫。
