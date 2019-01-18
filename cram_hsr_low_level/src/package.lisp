(defpackage :cram-hsr-low-level
  (:nicknames :chll)
  (:use :roslisp :cl)
  (:export
   init-nav-client
   get-nav-action-client
   make-nav-action-goal
   call-nav-action))
