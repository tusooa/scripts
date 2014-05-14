; Org-mode
(require 'org)
(defun org-config ()
  (setq
   org-hide-leading-stars t
   org-log-done 'time
  ) ;/setq
  (setKey 'global-set-key
          (list
           (list "\C-ca" 'org-agenda)
          ) ;/list--is arg of setKey
  ) ;/setKey
  (define-skeleton 1forbidden
    "文字里的禁止事项.黑色背景"
    ""
    "\n#+BEGIN_HTML\n<span style='background-color: #000'>\n"
    _
    "</span>\n#+END_HTML"
  )
  (define-abbrev org-mode-abbrev-table "iforbidden" "" '1forbidden)
)
(org-config)
