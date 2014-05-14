(add-to-list 'load-path "~/.emacs.d/lisp-others/")
(add-to-list 'load-path "/usr/share/emacs/site-lisp/gentoo-syntax/")
(mapc 'load (directory-files "~/.emacs.d/config/plugins/" t "^[a-zA-Z0-9].*.el$"))

