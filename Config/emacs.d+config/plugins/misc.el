(mapc 'require
      '(ibuffer redo fvwm-mode cmake-mode php-mode highlight-tail ;gentoo-syntax
                linum tramp haskell-mode)
)

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

; workgroups
;(setq wg-prefix-key (kbd "C-c C-w"))
;(wg-create-workgroup "tusooa")
;(workgroups-mode 100)
