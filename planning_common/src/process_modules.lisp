(in-package :plc)


;; TODO still in progress
(cram-process-modules:def-process-module hsr-navigation (motion-designator)

  ;;;;;;;;;;;;;;;;;;;; BASE ;;;;;;;;;;;;;;;;;;;;;;;;
  (roslisp:ros-info (hsr-navigation-process-modules)
                    "hsr-navigation called with motion designator `~a'."
                    motion-designator)
  (destructuring-bind (command x y angle) (reference motion-designator)
    (ecase command
      ;;TODO differentiate types
      (move-base
       (chll::call-nav-action x y angle)))))

  ;;;;;;;;;;;;;;;;;;;; BODY ;;;;;;;;;;;;;;;;;;;;;;;;
(cram-process-modules:def-process-module hsr-motion (motion-designator)
  (roslisp:ros-info (hsr-motion-process-modules)
                    "hsr-motion called with motion designator `~a'."
                    motion-designator)
  (destructuring-bind (command pos vel) (reference motion-designator)
    (ecase command
      (move-neck
       (chll::call-move-head-action pos vel )))))




  ;;;;;;;;;;;;;;;;;;;; TESTS ;;;;;;;;;;;;;;;;;;;;;;;;
(defun test-head-motion (?pos ?vel)
  (cram-language:top-level
    (cram-process-modules:with-process-modules-running (hsr-motion)
      (let ((look-at (desig:a motion
                              (:type :looking)
                              (:positions ?pos)
                              (:velocities ?vel))))
        (cram-process-modules:pm-execute 'hsr-motion look-at)))))
                          
(defun test-move-base-motion (?x ?y ?angle)
  (cram-language:top-level
    (cram-process-modules:with-process-modules-running (hsr-motion)
      (let ((look-at (desig:a motion
                              (:type :going)
                              (:x ?x)
                              (:y ?y)
                              (:angle ?angle))))
        (cram-process-modules:pm-execute 'hsr-motion look-at)))))


