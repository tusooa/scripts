;;; erc-nick-notify.el --- Notify popup for ERC

;; Filename: erc-nick-notify.el
;; Description: Notify popup for ERC
;; Author: Andy Stewart lazycat.manatee@gmail.com
;; Maintainer: Andy Stewart lazycat.manatee@gmail.com
;; Copyright (C) 2008, 2009, Andy Stewart, all rights reserved.
;; Created: 2008-12-04 12:47:28
;; Version: 0.2.1
;; Last-Updated: 2009-01-31 10:47:32
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/erc-nick-notify.el
;; Keywords: erc, notify
;; Compatibility: GNU Emacs 23.0.60.1
;;
;; Features that might be required by this library:
;;
;; `erc'
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Notify popup for ERC
;;
;; This extension use `notify-send' for notify.
;; So make you have install `notify-send' in your system.
;;

;;; Installation:
;;
;; Put erc-nick-notify.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'erc-nick-notify)
;;
;; No need more.

;;; Customize:
;;
;; `erc-nick-notify-delay'
;; The delay time that between two messages.
;; `erc-nick-notify-cmd'
;; The command that use for notify.
;; `erc-nick-notify-icon'
;; The file name of icon display.
;; `erc-nick-notify-timeout'
;; The timeout in milliseconds at which to expire the notification.
;; `erc-nick-notify'
;; The urgency level.
;; `erc-nick-notify-category'
;; The notification category.
;;
;; All of the above can be customize by:
;;      M-x customize-group RET erc-nick-notify RET
;;

;;; Change log:
;;
;; 2009/01/31
;;      Fix doc.
;;
;; 2008/12/21
;;      Fix `void-variable' bug.
;;
;; 2008/12/08
;;      Add customize support.
;;
;; 2008/12/04
;;      First released.
;;

;;; Acknowledgements:
;;
;;
;;

;;; TODO
;;
;;
;;

;;; Require
(require 'erc)

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Customize ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defgroup erc-nick-notify nil
  "Notify popup for ERC."
  :group 'erc)

(defcustom erc-nick-notify-delay '(0 5 0)
  "The delay time that between two message.
Default is 5 minutes."
  :type 'list
  :group 'erc-nick-notify)

(defcustom erc-nick-notify-cmd '("notice-msg") ;changed
  "The command that use for notify."
  :type 'list
  :group 'erc-nick-notify)

(defcustom erc-nick-notify-icon "info"
  "Specifies an icon filename or stock icon to display."
  :type 'string
  :group 'erc-nick-notify)

(defcustom erc-nick-notify-timeout 10000
  "Specifies the timeout in milliseconds at which to expire the notification."
  :type 'number
  :group 'erc-nick-notify)

(defcustom erc-nick-notify-urgency "low"
  "Specifies the urgency level (low, normal, critical)."
  :type 'string
  :group 'erc-nick-notify)

(defcustom erc-nick-notify-category "im.received"
  "Specifies the notification category."
  :type 'string
  :group 'erc-nick-notify)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Variable ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar erc-nick-notify-last '(0 0 0)
  "The last time that receive message.")

(defvar erc-nick-notify-buffer nil
  "The buffer name of last notify me.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Interactive Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun erc-nick-notify-jump-last-channel ()
  "Jump to last channel that notify me."
  (interactive)
  (if erc-nick-notify-buffer
      (switch-to-buffer erc-nick-notify-buffer)
    (message "Nobody notify you in IRC.")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Utilities Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun erc-nick-notify ()
  "Notify me when my nick show up.
This function should be in the insert-post-hook."
  (let ((now (current-time)))
    (when (time-less-p erc-nick-notify-delay
                       (time-since erc-nick-notify-last))
      (setq erc-nick-notify-last now)
      (goto-char (point-min))
      (when (re-search-forward
             (concat "\\("
                     "\\(<\\([^>]*\\)>\\)" ; <someone> "<nickname>"
                     "\\|" ;; 匹配只以《一个》*开头加一空格再接任意个非空字母开头(nick) 可能有bug "* nickname"
"\\([^\\*]\\* \\([^\\(" (regexp-quote (erc-current-nick)) "\\)][^ ]*\\)\\)"
;; todo 不匹配自己说的话 或者 /me 正则表达式不行?
;; "\\|"
;; "\\(\\* " (regexp-quote (erc-current-nick)) "\\)"
"\\|"
"\\(-\\([^-]*\\)-\\)" ;匹配 notice 信息中本昵称 "-nickname-"
                      ;估计有bug.要是 `-nick-name-'
                     "\\)" ;; 此()匹配各种类发消息的nickname
                     "\\(.*" (regexp-quote (erc-current-nick)) ".*\\)")
;      (when (re-search-forward
;             (concat "\\("
;                     "\\(<\\([^>]*\\)>\\)" ; <someone>
;                     "\\|"
;                     ;; Don't match if we're saying something
;                     "\\(\\* " (regexp-quote (erc-current-nick)) "\\)"
;                     "\\)"
;                     "\\(.*" (regexp-quote (erc-current-nick)) ".*\\)")
             nil t)
        (let ((msg
               (concat
                (when
                    (> (length (match-string-no-properties 2)) 0)
                  (concat "<" (match-string-no-properties 3)
                              ">\n"))
                    (when (> (length (match-string-no-properties 5)) 0) ; /me 信息包含的send nick
                      (concat "<* " (match-string-no-properties 5)
                              ">\n"))
                    (when (> (length (match-string-no-properties 6)) 0) ; /notice 信息包含的send nick
                      (concat "-" (match-string-no-properties 6)
                              "-\n"))
                    (match-string-no-properties 8))))
          (setq erc-nick-notify-buffer (buffer-name))
          (let ((erc-nick-notify-command-sequence
                (append
;                 (if (stringp erc-nick-notify-cmd)
;                     (list erc-nick-notify-cmd)
                   erc-nick-notify-cmd;)
                 (list (if (boundp 'msg)
                     msg "Empty message")))))
            (apply 'start-process "erc-nick-notify" nil erc-nick-notify-command-sequence))
;          (start-process
;           "erc-nick-notify" nil erc-nick-notify-cmd
;           "-i" erc-nick-notify-icon
;           "-t" (int-to-string
;                 erc-nick-notify-timeout)
;           "-u" erc-nick-notify-urgency
;           "-c" erc-nick-notify-category
;           "--" erc-nick-notify-buffer
;           (if (boundp 'msg)
;               msg ""))
;          (shell-command
;           (concat erc-nick-notify-cmd
;                  " -i " erc-nick-notify-icon
;                  " -t " (int-to-string
;                  erc-nick-notify-timeout)
;                  " -u " erc-nick-notify-urgency
;                  " -c " erc-nick-notify-category
;                  " -- "
;                   " '" erc-nick-notify-buffer "'"
;                   " '" (match-string 3) "'" (shell-quote-argument (match-string 4)))
          )))))

;; Add `erc-nick-notify' to `erc-insert-post-hook'
(add-hook 'erc-insert-post-hook 'erc-nick-notify)

(provide 'erc-nick-notify)

;;; erc-nick-notify.el ends here

;;; LocalWords:  erc cmd im msg lt
