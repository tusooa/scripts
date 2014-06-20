(mapc 'require
      '(ibuffer redo fvwm-mode cmake-mode php-mode highlight-tail ;gentoo-syntax
                linum tramp colorize rainbow-identifiers rainbow-delimiters))

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
(global-rainbow-delimiters-mode t)
; 彩虹之色，见custom.el
; 由于本身有九个，所以我添加了浅绿和暗紫。
(setq rainbow-delimiters-alist
  '(;(html-mode .
    ;           (("<[A-Za-z0-9]\\([^>]*[^/>]\\|\\)>") .
    ;            ("</[^>]+>"))) ; will not work, because of the syntax table
    ;                             does not allow multi-chars delimiters
    (cperl-mode .
               (("(" "{") .
                (")" "}")))
    (all .
        (("(" "[" "{") .
         (")" "]" "}")))))
(defun rainbow-delimiters-escaped-char-predicate-perl (loc)
  (and (or (eq (char-after loc) ?\[)
               (eq (char-after loc) ?\])
               (eq (char-after loc) ?\()
               (eq (char-after loc) ?\)))
       (eq (char-before loc) ?$))) ; 忽略$[ $] $( $) 之类
                                   ; 的确有${[}，但是有人用吗？

(add-to-list 'rainbow-delimiters-escaped-char-predicate-list '(cperl-mode . rainbow-delimiters-escaped-char-predicate-perl))
(add-hook 'prog-mode-hook 'rainbow-identifiers-mode)
;颜色来自于孟塞尔颜色系统,见custom.el
;http://zh.wikipedia.org/wiki/%E5%AD%9F%E5%A1%9E%E5%B0%94%E9%A2%9C%E8%89%B2%E7%B3%BB%E7%BB%9F
