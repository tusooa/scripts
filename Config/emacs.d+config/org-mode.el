; Org-mode
(require 'org)
(setq
 org-hide-leading-stars t
 org-log-done 'time)
(setKey 'global-set-key
        (list
         (list "\C-ca" 'org-agenda)))

;(define-skeleton 1forbidden
;  ""
;  "\n#+BEGIN_HTML\n<span style='background-color: #000'>\n"
;  _
;  "</span>\n#+END_HTML")
;(define-abbrev org-mode-abbrev-table "iforbidden" "" '1forbidden)
(defun insert-time-string (append)
  (insert (format-time-string "%Y,%-m,%-d (%u) %H,%M,%S" (current-time))
          " " append "\n"))
(defun date-start ()
  (interactive)
  (insert-time-string "始"))
(defun date-end ()
  (interactive)
  (insert-time-string "止"))
(defun date-now ()
  (interactive)
  (insert-time-string "此"))
(defun thistusooa-org-mode-hook ()
  (setKey 'local-set-key
          `((,(kbd "C-c C-s") date-start)
            (,(kbd "C-c C-e") date-end)
            (,(kbd "C-c C-n") date-now)))
  (abbrev-mode t))

(add-hook 'org-mode-hook 'thistusooa-org-mode-hook)


;; Save the org-agenda for display with conky
(defadvice org-save-all-org-buffers (after saveorgagenda activate)
  "save this output to my todo file"
  ;(get-buffer-create "todo")
  ;(with-current-buffer "todo"
  ;  (set-buffer-modified-p nil))
  (org-agenda-write (if (eq system-type 'windows-nt) "C:\\Home\\Documents\\todo" "~/todo"))
  ;(kill-buffer "todo")
  
  (message "wrote todo file"))

(setq org-agenda-files (if (eq system-type 'windows-nt)
                           '("c:/Home/Documents/todo.org")
                         '("~/Private/todo.org")))

(when nil
  (eval-after-load 'tex-mode
  (progn
    (define-skeleton LaTeX-enum
      "Insert an enumerate environment"
      "\n\\begin{enumerate}\n"
      _
      "\n\\end{enumerate}")
    (define-abbrev latex-mode-abbrev-table "-enum-" "" 'LaTeX-enum))))
