(when (not (eq system-type 'windows-nt)) ; 暂时在闻道死下不支持emms
(add-to-list 'load-path "~/.emacs.d/lisp-others/emms/lisp")
(mapc 'require 
      '(emms emms-playlist-mode emms-setup
             emms-i18n emms-history)
)
(emms-standard)
(emms-default-players)
;; Show the current track each time EMMS
(add-hook 'emms-player-started-hook 'emms-show)

(setq
    ;; starts to play a track with "NP : "
    emms-show-format "NP: %s"
;; When asked for emms-play-directory,
;; always start from this one 
    ;emms-source-file-default-directory "~/zic/"
;; Want to use alsa with mpg321 ? 
    emms-player-mpg321-parameters '("-o" "alsa")
    emms-player-list '(emms-player-mplayer emms-player-mplayer-playlist
                                           emms-player-mpg321)
    emms-source-file-default-directory "~/Media/Music/"
    emms-repeat-playlist t
    emms-playlist-sort-function
        'emms-playlist-sort-by-natural-order;排序:艺术家->专辑->序号
    ;emms-lyrics-display-on-modeline t
) ;/setq

(setKey 'global-set-key
        (list
         (list (kbd "C-c C-m s") 'emms-start)
         (list (kbd "C-c C-m l") 'emms)
         (list (kbd "C-c C-m p") 'emms-pause)
         (list (kbd "C-c C-m x") 'emms-stop)
         (list (kbd "C-c C-m a") 'emms-add-file)
        )
)
)
