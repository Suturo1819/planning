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
    (ecase command
      (move-neck
       (chll::call-move-head-action pos))
      (look-at
       (ecase pos
         (:front
          (chll::call-move-head-action (vector 0.0 0.0))))))))

  ;;;;;;;;;;;;;;;;;;;; SAY ;;;;;;;;;;;;;;;;;;;;;;;;
;; (cram-process-modules:def-process-module hsr-say (motion-designator)
;;   (roslisp:ros-info (hsr-say-process-modules)
;;                     "hsr-say-motion called with motion designator `~a'."
;;                     motion-designator)
;;   (destructuring-bind (command text) (desig:reference motion-designator)
;;     (format t "command: ~a  text: ~a"command text)
;;     (ecase command
;;       (say
;;        (pc::call-text-to-speech-action text)))))

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
(cram-process-modules:def-process-module hsr-arm-motion (action-designator)
  (roslisp:ros-info (hsr-arm-motion-process-modules)
                    "hsr-arm-motion called with motion designator `~a'."
                    action-designator)
  (destructuring-bind (command obj-desig) (desig:reference action-designator)
   (let* (;(type (desig:desig-prop-value :type  action-designator))
          (?obj-desig obj-desig))
     (ecase command
       (grasping
        (chll::call-giskard-joints-grasping-action
         (car (desig:desig-prop-values ?obj-desig :obj-pose-map))
         (car (desig:desig-prop-values ?obj-desig :obj-pose-odom))
         (car (desig:desig-prop-values ?obj-desig :obj-weight))
         (car (desig:desig-prop-values ?obj-desig :obj-width))
         (car (desig:desig-prop-values ?obj-desig :obj-height))
         "grip"))
      
      (placing
       (chll::call-giskard-joints-grasping-action
        (desig:desig-prop-values ?obj-desig :obj-pose-map )
        (desig:desig-prop-values ?obj-desig :obj-pose-odom )
        (car (desig:desig-prop-values ?obj-desig :obj-weight ))
        (car (desig:desig-prop-values ?obj-desig :obj-width ))
        (car (desig:desig-prop-values ?obj-desig :obj-height ))
        "place"))))))


  ;;;;;;;;;;;;;;;;;;;; TESTS FOR DEBUGGING ;;;;;;;;;;;;;;;;;;;;;;;;
(defun test-head-motion (?pos)
  (cram-language:top-level
    (cram-process-modules:with-process-modules-running (hsr-motion)
      (let ((look-at (desig:a motion
                              (:type :looking)
                              (:positions ?pos))))
        (cram-process-modules:pm-execute 'hsr-motion look-at)))))

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

