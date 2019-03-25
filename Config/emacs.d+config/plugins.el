(add-to-load-path (list (directory-files "~/.emacs.d/lisp-others" t "^[^\\.]") "~/.emacs.d/lisp-others/" "/usr/share/emacs/site-lisp/gentoo-syntax/"))
(mapc 'load (directory-files "~/.emacs.d/config/plugins/" t "^[a-zA-Z0-9].*.el$"))
  

