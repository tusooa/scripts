;(mapc 'use-package
;      '(ibuffer
;        redo
;        fvwm-mode
;        cmake-mode
;        php-mode
;        highlight-tail
;       ;gentoo-syntax
;        tramp
;        colorize
;        rainbow-identifiers
;        rainbow-delimiters
;        text-alias-mode
;        git-commit-mode))

(use-package ibuffer :ensure t)
(use-package undo-tree :ensure t
             :config
             (global-undo-tree-mode 1)
             (define-key undo-tree-map (kbd "C-_") 'undo-tree-undo)
             (define-key undo-tree-map (kbd "C-x u") 'undo-tree-undo)
             (define-key undo-tree-map (kbd "C-x .") 'undo-tree-redo)
             (define-key undo-tree-map (kbd "C-.") 'undo-tree-redo)
             (define-key undo-tree-map (kbd "C-x C-t") 'undo-tree-visualize))

(use-package fvwm-mode :ensure t)
(use-package cmake-mode :ensure t)
(require 'highlight-tail)
(use-package tramp :ensure t)
(use-package rainbow-mode :ensure t
  :config
  (defun turn-on-rainbow-mode ()
  (unless (string= major-mode "erc-mode")
    (rainbow-mode 1)))
  (define-globalized-minor-mode global-rainbow-mode rainbow-mode turn-on-rainbow-mode)
  (global-rainbow-mode 1))
(use-package rainbow-identifiers :ensure t)
(use-package rainbow-delimiters :ensure t)
(require 'text-alias-mode)
(require 'git-commit-mode)

; line numbers
(if (> emacs-major-version 25)
    (global-display-line-numbers-mode t)
  (use-package linum :ensure t)
  (global-linum-mode t))
;这是干什么的啊
(defun no-linum (&rest ignore)
  (when linum-mode (linum-mode 0)))

; sudo编辑文件
(setq tramp-default-method "sudo")

(setq highlight-tail-colors '(("black" . 0)
                              ("#750e49" . 25)
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

;rainbow
; 把括号都给加上颜色
; https://github.com/luochen1990/rainbow (vim)
; https://duckduckgo.com/?q=Parentheses%20color+site%3Aemacswiki.org
; http://www.emacswiki.org/emacs/RainbowDelimiters
;(global-rainbow-delimiters-mode t)
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

;(add-to-list 'rainbow-delimiters-escaped-char-predicate-list '(perl-mode . rainbow-delimiters-escaped-char-predicate-perl))
(defun thistusooa-prog-mode-hook ()
  (rainbow-delimiters-mode t)
  (rainbow-identifiers-mode t))
(add-hook 'prog-mode-hook 'thistusooa-prog-mode-hook)
;; for unknown reasons c++ mode is not inherited from prog mode any more.
(add-hook 'c++-mode-hook 'thistusooa-prog-mode-hook)
;颜色来自于孟塞尔颜色系统,见custom.el
;http://zh.wikipedia.org/wiki/%E5%AD%9F%E5%A1%9E%E5%B0%94%E9%A2%9C%E8%89%B2%E7%B3%BB%E7%BB%9F
(defun thistusooa-git-commit-mode-hook ()
  (if (eq system-type 'windows-nt)
      (set-buffer-file-coding-system 'utf-8-unix)))
(add-hook 'git-commit-mode-hook 'thistusooa-git-commit-mode-hook)

;(require 'use-package)
(let ((p6-lib (if (eq system-type 'windows-nt) "c:/Home/Code/scripts/libp6" "/home/tusooa/Apps/libp6")))
  (setenv "PERL6LIB" (if (getenv "PERL6LIB")
                         (concat (getenv "PERL6LIB") ";" p6-lib)
                       p6-lib)))

;(use-package perl6-mode :ensure t)

(use-package flycheck :ensure t :config
(defun enable-flycheck-in-prog ()
  (flycheck-mode t))
(add-hook 'prog-mode-hook 'enable-flycheck-in-prog)

(use-package flycheck-perl6))
(use-package helm :ensure t :config
  (global-set-key (kbd "M-x") #'helm-M-x)
  (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
  (global-set-key (kbd "C-x C-f") #'helm-find-files)
  (helm-mode 1)
  (define-key helm-map (kbd "TAB") #'helm-execute-persistent-action)
  (define-key helm-map (kbd "<tab>") #'helm-execute-persistent-action)
  (define-key helm-map (kbd "C-z") #'helm-select-action))

; is buggy.
;(require 'zlc)
;(zlc-mode t)

;(let ((map minibuffer-local-map))
;  ;;; like menu select
;  (define-key map (kbd "<down>")  'zlc-select-next-vertical)
;  (define-key map (kbd "<up>")    'zlc-select-previous-vertical)
;  (define-key map (kbd "<right>") 'zlc-select-next)
;  (define-key map (kbd "<left>")  'zlc-select-previous)
;  (define-key map (kbd "C-n")  'zlc-select-next-vertical)
;  (define-key map (kbd "C-p")    'zlc-select-previous-vertical)
;  (define-key map (kbd "M-f") 'zlc-select-next)
;  (define-key map (kbd "M-b")  'zlc-select-previous)
;  ;;; reset selection
;  (define-key map (kbd "C-c") 'zlc-reset)
;  )

(use-package editorconfig :ensure t :config
(editorconfig-mode 1))

(use-package delight :ensure t
  :config
  (defun flycheck-status (&optional status)
    (let ((s (or status flycheck-last-status-change)))
      (cond
       ((eq s 'not-checked) "⭘")
       ((eq s 'no-checker) "∄")
       ((eq s 'running) "🚋")
       ((eq s 'errored) "🇽")
       ((eq s 'finished)
        (let-alist (flycheck-count-errors flycheck-current-errors)
          (if (or .error .warning)
              (format "❌%s❘⚠%s" (or .error 0) (or .warning 0))
            "✔")))
       ((eq s 'interrupted) "⭼")
       ((eq s 'suspicious) "⯑"))))

  (delight
   '((editorconfig-mode " 🖋" editorconfig)
     (highlight-tail-mode " 🐁" highlight-tail)
     (helm-mode " →" helm)
     (flycheck-mode (:eval (concat " 🕊❘" (flycheck-status))) flycheck)
     (flyspell-mode " ⎀" flyspell)
     (rainbow-mode " 🌈")
     (eldoc-mode " 🛈" eldoc)
     (abbrev-mode " ⋯" abbrev)
     (overwrite-mode " ⌦" t)
     (isearch-mode " 🔎" t)
     (help-mode "㉄" :major)
     (emacs-lisp-mode "EL" :major)
     (undo-tree-mode " ᛦ" undo-tree)))
  (require 'delight-powerline))

(use-package powerline :ensure t :config
  (powerline-default-theme)
  (powerline-reset))

(use-package emojify :ensure t :config
  (global-emojify-mode 1))

;;(use-package nyan-mode :ensure t :config
;;  (nyan-mode 1))
(load-file "~/Code/nyan-mode/nyan-mode.el")
(nyan-mode 1)

(use-package rjsx-mode :ensure t :config
  (add-to-list 'auto-mode-alist
               '("\\.js\\'" . rjsx-mode)))

(use-package markdown-mode :ensure t)
