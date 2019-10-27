
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["black" "firebrick1" "lime green" "gold1" "RoyalBlue3" "HotPink1" "dark turquoise" "white"])
 '(canlock-password "64af8575f06472636c3a0709394ee6a2eae4520d")
 '(cperl-highlight-variables-indiscriminately t)
 '(cperl-indent-level 4)
 '(custom-file "~/.emacs.d/config/custom.el")
 '(emojify-emoji-styles (quote (unicode)))
 '(emojify-program-contexts (quote (comments)))
 '(gnus-no-groups-message "-- No Groups --")
 '(gnus-permanently-visible-groups ".+")
 '(gnus-summary-gather-exclude-subject "^ *$\\|^(none)$")
 '(gnus-thread-operation-ignore-subject t)
 '(ibuffer-never-show-predicates (quote ("^\\*helm[- ]")) nil (ibuf-ext))
 '(ibuffer-saved-filter-groups nil)
 '(ibuffer-saved-filters
   (quote
    (("programming"
      (or
       (derived-mode . prog-mode)
       (mode . ess-mode)
       (mode . compilation-mode)))
     ("text document"
      (and
       (derived-mode . text-mode)
       (not
        (starred-name))))
     ("TeX"
      (or
       (derived-mode . tex-mode)
       (mode . latex-mode)
       (mode . context-mode)
       (mode . ams-tex-mode)
       (mode . bibtex-mode)))
     ("web"
      (or
       (derived-mode . sgml-mode)
       (derived-mode . css-mode)
       (mode . javascript-mode)
       (mode . js2-mode)
       (mode . scss-mode)
       (derived-mode . haml-mode)
       (mode . sass-mode)))
     ("gnus"
      (or
       (mode . message-mode)
       (mode . mail-mode)
       (mode . gnus-group-mode)
       (mode . gnus-summary-mode)
       (mode . gnus-article-mode))))))
 '(indent-tabs-mode nil)
 '(ispell-extra-args (quote ("--lang=en_CA")))
 '(ispell-program-name
   (if
       (eq system-type
           (quote windows-nt))
       "C:/Home/Programs/Aspell/bin/aspell.exe" "/usr/bin/aspell"))
 '(js-indent-level 2)
 '(magit-git-executable "C:/Home/Programs/Git/bin/git.exe")
 '(max-specpdl-size 3000)
 '(mouse-wheel-progressive-speed nil)
 '(mouse-wheel-scroll-amount (quote (1 ((shift) . 1) ((control)))))
 '(nyan-animate-nyancat nil)
 '(nyan-wavy-trail nil)
 '(org-startup-truncated nil)
 '(package-selected-packages
   (quote
    (editorconfig cmake-mode gnu-elpa-keyring-update dim delight nyan-mode emojify helm-files emms fvwm-mode color-theme egg mew pandoc-mode powerline moe-theme emoji-fontset wc-mode markdown-mode zlc flycheck-perl6 flycheck perl6-mode)))
 '(pop3-connection-type (quote ssl))
 '(powerline-default-separator nil)
 '(powerline-height nil)
 '(rainbow-identifiers-face-count 10)
 '(wc-modeline-format "✒❘%tww❘%tcc"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cperl-array-face ((t (:foreground "#FF6400" :underline t :weight normal))))
 '(cperl-hash-face ((t (:foreground "#FF6400" :underline t))))
 '(erc-input-face ((t (:foreground "brown"))))
 '(erc-my-nick-face ((t (:foreground "brown" :weight bold))))
 '(erc-nick-default-face ((t (:weight bold))))
 '(erc-pal-face ((t (:foreground "LightBlue" :weight bold))))
 '(font-lock-comment-face ((t (:foreground "#bb66ff" :slant normal))))
 '(git-commit-add-face ((t (:background "sea green" :foreground "snow" :weight normal))))
 '(git-commit-removal-face ((t (:background "brown" :foreground "snow" :weight normal))))
 '(helm-header ((t (:background "navajo white" :foreground "LightSalmon3"))))
 '(helm-selection ((t (:background "LightSalmon3"))))
 '(markdown-code-face ((t (:inherit ##))))
 '(mode-line ((t (:background "LightSalmon3" :foreground "white smoke" :box nil))))
 '(mode-line-buffer-id ((t (:foreground "navajo white" :box nil :weight bold))))
 '(mode-line-buffer-id-inactive ((t (:inherit mode-line-buffer-id :distant-foreground "dark salmon" :foreground "dark salmon"))))
 '(org-upcoming-deadline ((t (:foreground "orange"))))
 '(org-warning ((t (:background "PaleVioletRed4" :foreground "azure" :weight bold))))
 '(powerline-active0 ((t (:foreground "white smoke" :weight bold))))
 '(powerline-active1 ((t (:inherit mode-line :background "navajo white" :foreground "LightSalmon3"))))
 '(powerline-active2 ((t (:inherit mode-line :background "white smoke" :foreground "peru"))))
 '(powerline-inactive0 ((t (:inherit mode-line-inactive :background "gray31" :foreground "gainsboro"))))
 '(powerline-inactive1 ((t (:inherit mode-line-inactive :background "gray45" :foreground "#eeeeee"))))
 '(powerline-inactive2 ((t (:inherit mode-line-inactive :background "gray56" :foreground "#e4e4e4"))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "red" :weight bold))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "orange" :weight bold))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "yellow" :weight bold))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "green" :weight bold))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "DarkOliveGreen1" :weight bold))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "cyan" :weight bold))))
 '(rainbow-delimiters-depth-7-face ((t (:foreground "deep sky blue" :weight bold))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "magenta" :weight bold))))
 '(rainbow-delimiters-depth-9-face ((t (:foreground "light pink" :weight bold))))
 '(rainbow-delimiters-unmatched-face ((t (:background "red" :foreground "gray100" :weight bold))))
 '(rainbow-identifiers-identifier-1 ((t (:foreground "#c98286"))))
 '(rainbow-identifiers-identifier-10 ((t (:foreground "#c183a0"))))
 '(rainbow-identifiers-identifier-2 ((t (:foreground "#c58764"))))
 '(rainbow-identifiers-identifier-3 ((t (:foreground "#ad924b"))))
 '(rainbow-identifiers-identifier-4 ((t (:foreground "#8d9c55"))))
 '(rainbow-identifiers-identifier-5 ((t (:foreground "#5ca386"))))
 '(rainbow-identifiers-identifier-6 ((t (:foreground "#49a3a2"))))
 '(rainbow-identifiers-identifier-7 ((t (:foreground "#529ebd"))))
 '(rainbow-identifiers-identifier-8 ((t (:foreground "#8095c6"))))
 '(rainbow-identifiers-identifier-9 ((t (:foreground "#a88abd"))))
 '(show-paren-match ((t (:background "#6cf" :foreground "#eeeeee")))))
