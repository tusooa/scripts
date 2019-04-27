
(set-fontset-font (frame-parameter nil 'font)
                  'han
                  "DejaVu Sans YuanTi Mono")
(setq
 ;; Don't yank at mouse cursor
 mouse-yank-at-point t
 default-major-mode 'text-mode
 kill-ring-max 200
 column-number-mode t
 require-final-newline t
 ;; suggest the keybinding for the command after 1s
 suggest-key-bindings 1
 ;; indent-tabs-mode  t 使用 TAB 作格式化字符  nil 使用空格作格式化字符
 indent-tabs-mode nil
 tab-always-indent nil
 tab-width 4
 ;; title
 frame-title-format "emacs : %b"

 user-full-name "ThisTusooa"
 user-mail-address "tusooa@vista.aero"
 browse-url-generic-program "/usr/bin/firefox"
 browse-url-browser-function 'browse-url-generic
 default-buffer-file-coding-system 'utf-8-unix)
                                        ;
  (if (eq system-type 'windows-nt)
    (setq browse-url-generic-program "C:\\Home\\Programs\\Mozilla-Firefox\\firefox.exe"))
(setq appsDir (if (eq system-type 'windows-nt)
                  "~/Apps/" "C:/Home/Code/scripts/"))
(mapc #'(lambda (x) (add-to-list 'auto-mode-alist x))
      `(
        ("~/.fvwm/\\(config\\|f\\..+\\)" . fvwm-mode)
        ("\\.fvwm\\'" . fvwm-mode)
;        ("/home/tusooa/\\(应用\\|Apps\\)/\\(源码\\|Source-Code\\)/GitHub/tusooa/Apps/Config/\\.fvwm\\+c.+" . fvwm-mode)
        ("\\.\\(perl\\)\\'" . perl-mode)
        ("\\.\\(p6\\|pm6\\)\\'" . perl6-mode)
        ("~/\\.config/Scripts/" . conf-unix-mode)
        (,(concat appsDir "Config/Scripts/") . conf-unix-mode)
        (,(concat appsDir "default-cfg/") . conf-unix-mode)
        ("\\.Xresource" . conf-xdefaults-mode)
        ("PKGBUILD" . shell-script-mode)
        ("CMakeLists\\.txt\\'" . cmake-mode)
        ("\\.cmake\\'" . cmake-mode)
        ("\\.php\\'" . php-mode)
        ("\\.inc\\'" . php-mode)
        ("\\.sawfish" . lisp-mode)
        ("\\.rep\\'" . lisp-mode)
        ("\\.zsh\\'" . shell-script-mode)
        ("\\..*rc\\'" . conf-space-mode)
        ("COMMIT_EDITMSG\\'" . git-commit-mode)
        ("\\.ta\\'" . prog-mode)
        ("\\.md\\'" . markdown-mode)
      )) ;/mapc
;(fset 'perl-mode 'cperl-mode)
;(add-to-list 'interpreter-mode-alist '("perl" . cperl-mode))
;(add-to-list 'interpreter-mode-alist '("perl5" . cperl-mode))
                                        ;(add-to-list 'interpreter-mode-alist '("miniperl" . cperl-mode))

(show-paren-mode 1)
(setq show-paren-style 'parentheses)
;; Force Unix line endings
(defun unixize ()
  (interactive)
  (let ((coding-str (symbol-name buffer-file-coding-system)))
    (when ;(and ;(not (string-match "\\(\\.\\(?:cmd\\|bat\\)\\|\\\\hosts\\)$" buffer-file-name))
               (string-match "-\\(?:dos\\|mac\\)$" coding-str);)
      (setq coding-str
            (concat (substring coding-str 0 (match-beginning 0)) "-unix"))
      (message "CODING: %s" coding-str)
      (set-buffer-file-coding-system (intern coding-str)) )))

(prefer-coding-system 'utf-8-unix)

;; Keybindings
(load "~/.emacs.d/config/0-base-functions.el")
(load "~/.emacs.d/config/keybindings.el")

;; I don't like undo-tree-mode, since it forces `C-x u' to
;; `undo-tree-visualize', which is undesirable.
(global-set-key (kbd "C-_") 'undo-tree-undo)
(global-set-key (kbd "C-x u") 'undo-tree-undo)
(global-set-key (kbd "C-x .") 'undo-tree-redo)
(global-set-key (kbd "C-x C-t") 'undo-tree-visualize)
(global-undo-tree-mode -1)

;; if we have a good emacs, we can use the built-in line number mode!
(if (> emacs-major-version 25)
    (global-display-line-numbers-mode t)
  (require 'linum)
  (global-linum-mode t))

;; colors like red or #ff0000
;; replaced by `rainbow-mode'
;; why it's not working?
;;(require 'colorize)
;;(spacemacs|diminish colorize-mode " c" " c")
;;(global-colorize-mode)
(require 'rainbow-mode)
(defun turn-on-rainbow-mode ()
  (unless (string= major-mode "erc-mode")
    (rainbow-mode 1)))
(define-globalized-minor-mode global-rainbow-mode rainbow-mode turn-on-rainbow-mode)
(global-rainbow-mode 1)

;;; give variable names different colors
(require 'rainbow-identifiers)
(defun tusooa-prog-mode-hook () (rainbow-identifiers-mode t))
(add-hook 'prog-mode-hook 'tusooa-prog-mode-hook)
;;(require 'color-identifiers-mode)
;;(defun tusooa-prog-mode-hook () (color-identifiers-mode 1))
;;(add-hook 'prog-mode-hook 'tusooa-prog-mode-hook)

(use-package pandoc-mode)

;; -)
(require 'moe-theme)
(moe-theme-set-color 'magenta)
(moe-dark)
;; (powerline-moe-theme)

(use-package wc-mode)

(server-start)
