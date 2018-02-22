# -*- lisp -*-
``
(setq
 sense-graph-length 10
 sense-graph-min 40
 sense-graph-level-factor 1.6
 sense-graph-determine-level
 (lambda (d &optional cur-level cur-val)
   (#''init default vars``)
   (if (not (defined cur-level))
       (setq cur-level 1))
   (if (not (defined cur-val))
       (setq cur-val sense-graph-min))
   (#''trivial cases``)
   (if (= d 0) 0
     (if (< d 0) (- (sense-graph-determine-level (- d)))
       (if (< d cur-val) cur-level
         (sense-graph-determine-level
          d
          (+ 1 cur-level)
          (* sense-graph-level-factor cur-val))))))
 sense-graph-args
 (lambda (d level)
   (def level-maxval level-minval len-used)
   (if (< level 0)
       (sense-graph-args (- d) (- level))
     (setq level-maxval
           (int (+ (* sense-graph-min
                      (** sense-graph-level-factor
                          (- level 1)))))
           level-minval
           (int (+ (if (> level 1)
                       (* sense-graph-min
                          (** sense-graph-level-factor (- level 2)))
                     (#'' at lv1 the minimum is zero ``)
                     0)))
           len-used (int (* sense-graph-length
                            (/ (- d level-minval)
                               (- level-maxval level-minval)))))
     (list level-maxval len-used level-minval)))
 sense-graph
 (lambda (&optional d)
   (if (not (defined d))
       (setq d (sense)))
   (def cur-sense zero-point len-used level level-maxval level-minval level-args)
   (setq zero-point (conf "levels::sense::3"))
   (setq cur-sense (- d zero-point))
   (setq level (sense-graph-determine-level cur-sense))
   (if (< level 0)
       (progn
         (setq level-args (sense-graph-args cur-sense level)
               level-maxval (nth 0 level-args)
               len-used (nth 1 level-args))
         (concat "["
                 (x "_" (- sense-graph-length len-used)) (#''rest blank``)
                 (if (> len-used 0) "<") (#''arrow``)
                 (x "-" (- len-used 1)) (#''fill``)
                 "] \n" d " / " (#''current sense``)
                 (+ (- level-maxval) zero-point) (#''sense for next level``)
                 " Lv." level))
     (if (= level 0)
         (progn
           (concat "[" (x "_" sense-graph-length) "]" " Lv.0"))
       (setq level-args (sense-graph-args cur-sense level)
             level-maxval (nth 0 level-args)
             len-used (nth 1 level-args))
       (concat "[" (x "=" (- len-used 1)) (#''fill``)
               (if (> len-used 0) ">") (#''arrow``)
               (x "_" (- sense-graph-length len-used)) (#''rest blank``)
               "] \n" d " / " (#''cur sense``)
               (+ level-maxval zero-point) (#''sense for next lv``)
               " Lv." level)))))
(if Running
    (progn
      (setq sense (lambda () (nth 0 Args)))
      (setq conf (lambda (&rest ignore) 0))
      (say (sense-graph))
      ))
