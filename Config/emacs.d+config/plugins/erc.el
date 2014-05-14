(add-to-list 'load-path "/usr/share/emacs/site-lisp/erc/")
(require 'erc)

; disable linum mode in erc
(add-hook 'erc-mode-hook 'no-linum)
(add-hook 'erc-hook 'no-linum)
(add-hook 'erc-insert-pre-hook 'no-linum)
(setq erc-default-coding-system '(utf-8 . utf-8)
;       erc-enable-logging nil
;       erc-ignore-list (quote ("^ls\\(\\s+-[aA]\\)?$" "^while\\s+:\\s*;\\s*do\\s+ls\\(\\s+-[aA]\\)?\\s*;\\s*done$"))
;       erc-log-channels-directory "~/个人/记录/IRC/ERC"
      erc-nick "tusooa"
      erc-nick-uniquifier "-"
      erc-part-reason 'erc-part-reason-normal
      erc-port 8001
;       erc-prompt-for-channel-key nil
;       erc-query-display (quote window-noselect)
      erc-quit-reason 'erc-quit-reason-normal
;       erc-save-buffer-on-part t
;       erc-script-path nil
;       erc-server "irc.freenode.net"
       erc-startup-file-list (quote ("~/.emacs.d/.ercrc.el" "~/.emacs.d/.ercrc" "~/.ercrc.el" "~/.ercrc" ".ercrc.el" ".ercrc" "~/个人/账号/irc-login"))
      erc-try-new-nick-p t
      erc-user-full-name "tusooa"
      erc-interpret-mirc-color t
)
; 历史版本.简单地 /load ~/个人/账号/irc-login
;(require 'erc-join)
;(erc-autojoin-mode 1)
;(setq erc-autojoin-channels-alist
;      '(
;        ("freenode.net" "#perl-cn" "#tusooa");"#ubuntu-cn")
;      )
;)
(defun erc-remove-trailing-newlines (msg)
  (setq str (replace-regexp-in-string "\n+$" "" msg))
)
(add-hook 'erc-send-pre-hook 'erc-remove-trailing-newlines)
(add-hook 'erc-send-pre-hook 'no-linum)
; highlight nicknames
(and
 (require 'erc-highlight-nicknames)
 (add-to-list 'erc-modules 'highlight-nicknames)
 (erc-update-modules)
)
(require 'erc-nick-notify)

(defun erc-init ()
  (interactive)
  (erc :server "irc.freenode.net" :port erc-port :nick erc-nick)
)

