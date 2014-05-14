; key-bindings

(setKey 'global-set-key
        (list
         ; C-t 设置标记
         (list (kbd "C-t") 'set-mark-command)
         ; C-x b => CRM bufer list
         ;(list "\C-xb" 'electric-buffer-list)
         ; \e9nd, 原来C-.就是redo,总是习惯按C-x .，改了。
         (list (kbd "C-x .") 'redo)
         ; 代码缩进
         (list (kbd "M-q") 'indent-region)
         (list (kbd "C-c r") 'delete-region)
         (list (kbd "C-c l") 'copy-line)
         (list (kbd "C-c e") 'erc-init)
;         (list (kbd "C-c t") 'twit)
;         (list (kbd "C-c m") (lambda () (interactive) (countup 'gnus "gnus")))
         (list (kbd "C-c i") 'info)
         (list (kbd "C-x C-e") 'eval-buffer)
         (list (kbd "C-c p") 'replace-string)
         (list (kbd "C-c g") 'replace-regexp)
         (list (kbd "C-x C-b") 'ibuffer)
;         (list (kbd "C-c o") (lambda () (interactive) (find-file "~/个人/todo.org")))
;         (list (kbd "<S-mouse-2>") 'mouse-yank-at-click)
;         (list (kbd "<mode-line> <S-mouse-2>") 'describe-mode)
        ) ;/list --- is arg of setKey
) ;/setKey

(defun notice-server-edit ()
  (interactive)
  (unless (string= (read-from-minibuffer "Quit server edit?(n for no) ") "n")
      (server-edit)
  )
)

(defun my-server-switch-hook ()
  (when (current-local-map)
    (use-local-map (copy-keymap (current-local-map)))
  )
  (when server-buffer-clients
    (local-set-key (kbd "C-x k") 'notice-server-edit)
  )
) ;/defun my-server-switch-hook

(add-hook 'server-switch-hook
          (lambda () (my-server-switch-hook))
)
