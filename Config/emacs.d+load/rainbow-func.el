(defun match-in-list (arg list &optional this rest)
  (and list
      (setq rest (cdr list)
            this (car list))
      (or (string-match-p this arg)
          (match-in-list arg rest))))
(provide 'rainbow-func)
