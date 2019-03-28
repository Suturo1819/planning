(defpackage :cram-hsr-low-level
  (:nicknames :chll)
  (:use :roslisp :cl)
  (:export
   ;; navigation client
   #:init-nav-client
   #:get-nav-action-client
   #:make-nav-action-goal
   #:call-nav-action

   ;; move client 
   #:make-giskard-joints-action-client
   #:make-giskard-poses-action-client

   ;; perception client
   #:init-robosherlock-action-client ;; only for init function in main
   #:call-robosherlock-pipeline

   ;; prolog client
   #:with-safe-prolog
   #:object-name->class
   #:prolog-table-objects
   #:prolog-object-goal
   #:prolog-all-objects-in-shelf

   ;; joint state client
   #:get-current-joint-state

   ;; torso client
   #:call-move-torso-action
   ))
