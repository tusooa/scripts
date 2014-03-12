(mapc 'require
      '(ibuffer redo fvwm-mode cmake-mode php-mode ;gentoo-syntax
                linum tramp haskell-mode)
)

; linum
(global-linum-mode t)
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
; outline
(setq outline-minor-mode-prefix [(control o)])

; workgroups
;(setq wg-prefix-key (kbd "C-c C-w"))
;(wg-create-workgroup "tusooa")
;(workgroups-mode 100)
