(in-package :plc)

;; TODO still in progress
(cram-process-modules:def-process-module hsr-navigation (motion-designator)
  ;;;;;;;;;;;;;;;;;;;; BASE ;;;;;;;;;;;;;;;;;;;;;;;;
  (roslisp:ros-info (hsr-navigation-process-modules)
                    "hsr-navigation called with motion designator `~a'."
                    motion-designator)
  (destructuring-bind (command target) (desig:reference motion-designator)
    (ecase command
      ;;TODO differentiate types
      (going
       ;;(format t "COMMAND: ~a POSE: ~a" command (desig:reference target))
       (chll::call-nav-action-ps (desig:reference target))
       )))) ;;??? maybe add (desig:reference ..)

  ;;;;;;;;;;;;;;;;;;;; BODY ;;;;;;;;;;;;;;;;;;;;;;;;
(cram-process-modules:def-process-module hsr-motion (motion-designator)
  (roslisp:ros-info (hsr-motion-process-modules)
                    "hsr-motion called with motion designator `~a'."
                    motion-designator)
  (destructuring-bind (command pos) (desig:reference motion-designator)
    (if (typep pos 'sequence)
        (chll::call-move-head-action pos)
        (ecase pos
          (:front
           (chll::call-move-head-action (vector 0.0 0.0)))
          (:perceive
           (chll::call-move-head-action (vector 0.0 -0.4)))
          (:safe
           (chll::call-move-head-action (vector 0.0 0.1)))))))

  ;;;;;;;;;;;;;;;;;;;; SAY ;;;;;;;;;;;;;;;;;;;;;;;;
(cram-process-modules:def-process-module hsr-say (motion-designator)
  (roslisp:ros-info (hsr-say-process-modules)
                    "hsr-say-action called with motion designator `~a'."
                    motion-designator)
  (destructuring-bind (command text) (desig:reference motion-designator)
    ;(format t "command: ~a  text: ~a"command text)
    (ecase command
      (say
       (pc::call-text-to-speech-action text)))))

  ;;;;;;;;;;;;;;;;;;;; ARM ;;;;;;;;;;;;;;;;;;;;;;;;
(cram-process-modules:def-process-module hsr-arm-motion (motion-designator)
  (roslisp:ros-info (hsr-arm-motion-process-modules)
                    "hsr-arm-motion called with motion designator `~a'."
                    motion-designator)
  (destructuring-bind (command
                       ?pose
                      ;; ?pose-odom
                       ?weight
                       ?width
                       ?height
                       ?depth
                       ?top
                       ?side_right
                       ?side_left)
      (desig:reference motion-designator)
    (ecase command
      (grasping
       (chll::call-giskard-joints-grasping-action
        ?pose
        (plc::map-T-odom ?pose) ;;?pose-odom
        ?weight
        ?width
        ?height
        "grip" ;;obj pose /text
        ?depth
        ?top
        ?side_right
        ?side_left))
      
      (place
       (print "place"))
      )))


  ;;;;;;;;;;;;;;;;;;;; TESTS FOR DEBUGGING ;;;;;;;;;;;;;;;;;;;;;;;;
(defun test-head-motion ()
  (cram-language:top-level
    (cram-process-modules:with-process-modules-running (hsr-motion)
      (let ((look (desig:a motion
                              (:type :looking)
                              (:positions :front))))
        (cram-process-modules:pm-execute 'hsr-motion look)))))

(defun test-head-motion2 (?direction)
  (cram-language:top-level
    (cram-process-modules:with-process-modules-running (hsr-motion)
      (let ((look-at (desig:a motion
                              (:type :looking)
                              (:direction ?direction))))
        (cram-process-modules:pm-execute 'hsr-motion look-at)))))
                          
(defun test-move-base-motion (?pose)
  (cram-language:top-level
    (cram-process-modules:with-process-modules-running (hsr-navigation)
      (let ((going (desig:a motion
                              (:type :going)
                              (:target ?pose))))
        (cram-process-modules:pm-execute 'hsr-navigation going)))))


(defun test-say (?text)
  (cpl:top-level
    (cram-process-modules:with-process-modules-running (hsr-say)
      (let ((say          
              (desig:a motion
                       (:type :say)
                       (:text ?text))))
        (cram-process-modules:pm-execute 'hsr-say say)))))

(defun test-navigation-desig (?pose)
  (cpl:top-level
    (cram-process-modules:with-process-modules-running (hsr-navigation)
      (let ((going 
              (desig:a motion
                       (:type :going)
                       (:target (desig:a location
                                         (:pose ?pose))))))
        (cpl:seq
          (cram-process-modules:pm-execute 'hsr-navigation going))))))

(defmacro with-hsr-process-modules (&body body)
  `(cram-process-modules:with-process-modules-running
       (plc::hsr-navigation
        plc::hsr-motion
        plc::hsr-say
        plc::hsr-arm-motion)
     (cpl-impl::named-top-level (:name :top-level)
       ,@body)))

;; (defmacro with-hsr-proj-process-modules (&body body)
;;   `(cram-process-modules:with-process-modules-running
;;        (hsrb-proj::hsrb-proj-navigation
;;         hsrb-proj::hsrb-proj-torso
;;         hsrb-proj::hsrb-proj-ptu
;;         hsrb-proj::hsrb-proj-perception
;;         hsrb-proj::hsrb-proj-grippers)
;;      (cpl-impl::named-top-level (:name :top-level)
;;      ,@body)))


