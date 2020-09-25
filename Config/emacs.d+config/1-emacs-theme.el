(require 'color-theme)
;(load-file "~/.emacs.d/themes/color-theme-blackboard.el")
(color-theme-initialize)
(require 'moe-theme)
(load-theme 'moe-dark t)
(set-face-attribute 'mode-line nil :background "#ffaf5f" :foreground "#b75f00")
(set-face-attribute 'mode-line-buffer-id nil :background "#ffaf5f" :foreground "#080808")
(set-face-attribute 'minibuffer-prompt nil :foreground "#080808" :background "#ffaf5f")
;(load-file "~/.emacs.d/themes/darkmate.el")
;(color-theme-darkmate)
; 光标不闪烁
(blink-cursor-mode -1)
; 光标黄色
;(set-cursor-color "yellow")
