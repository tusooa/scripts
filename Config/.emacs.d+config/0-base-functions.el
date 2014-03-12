; base functions

(defun setKey (bindFunc keyList)
  "set key in keyList."
  (mapcar (lambda (list)
            (let (
                  (key (car list))
                  (keyFunc (car (last list)))
                 ) ;var
                 (funcall bindFunc key keyFunc)
            ) ;/let
           ) ;/lambda
          keyList ;is arg of mapcar
  ) ;/mapcar
) ;/defun setKey

(defun usePlugins (func plugins)
  "require plugins"
  (mapcar
   (lambda (plugin) (funcall func plugin)) ;/lambda
   plugins
  ) ;/mapcar
) ;/defun

(defun chomp (str)
  "Chomp leading and tailing whitespace from STR."
  (while (string-match "\\`\n+\\|^\\s-+\\|\\s-+$\\|\n+\\'"
                       str)
    (setq str (replace-match "" t t str)))
  str
)
