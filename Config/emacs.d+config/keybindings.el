; key-bindings

(setKey 'global-set-key
        `(
         ; C-t 设置标记
         (,(kbd "C-t") set-mark-command)
         ; C-x b => CRM bufer list
         ;(,"\C-xb" 'electric-buffer-list)
         ; \e9nd, 原来C-.就是redo,总是习惯按C-x .，改了。
         (,(kbd "C-x .") redo)
         ; 代码缩进
         (,(kbd "M-q") indent-region)
         (,(kbd "C-c r") delete-region)
         (,(kbd "C-c l") copy-line)
         (,(kbd "C-c e") erc-init)
;         (,(kbd "C-c t") 'twit)
;         (,(kbd "C-c m") (lambda () (interactive) (countup 'gnus "gnus")))
         (,(kbd "C-c i") info)
         (,(kbd "C-x C-e") eval-buffer)
         (,(kbd "C-c p") replace-string)
         (,(kbd "C-c g") replace-regexp)
         (,(kbd "C-x C-b") ibuffer)
         ; colorize ansi sequences
         (,(kbd "C-c C-c") (lambda () (interactive) (ansi-color-apply-on-region (point-min) (point-max))))))
;         (,(kbd "C-c o") (lambda () (interactive) (find-file "~/个人/todo.org")))
;         (,(kbd "<S-mouse-2>") 'mouse-yank-at-click)
;         (,(kbd "<mode-line> <S-mouse-2>") 'describe-mode)


(defun notice-server-edit ()
  (interactive)
  (unless (string= (read-from-minibuffer "Quit server edit?(n for no) ") "n")
      (server-edit)))

(defun thistusooa-server-switch-hook ()
  (when (current-local-map)
    (use-local-map (copy-keymap (current-local-map))))
  (when server-buffer-clients
    (local-set-key (kbd "C-x k") 'notice-server-edit)))

(add-hook 'server-switch-hook
          'thistusooa-server-switch-hook)
