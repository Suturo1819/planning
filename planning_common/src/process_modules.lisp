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
      (move-base
       (chll::make-nav-action-goal target))))) ;;??? maybe add (desig:reference ..)

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

(cram-process-modules:def-process-module hsr-say (action-designator)
  (roslisp:ros-info (hsr-say-process-modules)
                    "hsr-say-action called with action designator `~a'."
                    action-designator)
  (destructuring-bind (command text) (desig:reference action-designator)
    ;(format t "command: ~a  text: ~a"command text)
    (ecase command
      (say
       (pc::call-text-to-speech-action text)))))

  ;;;;;;;;;;;;;;;;;;;; ARM ;;;;;;;;;;;;;;;;;;;;;;;;
(cram-process-modules:def-process-module hsr-arm-motion (motion-designator)
  (roslisp:ros-info (hsr-arm-motion-process-modules)
                    "hsr-arm-motion called with motion designator `~a'."
                    motion-designator)
  (destructuring-bind (command map odom weight width height) (desig:reference motion-designator)
    (ecase command
      (grasp
       (chll::call-giskard-joints-grasping-action map odom weight width height "grip"))
      (place
       (chll::call-giskard-joints-grasping-action map odom weight width height "place")))))


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
    (cram-process-modules:with-process-modules-running (hsr-motion)
      (let ((going (desig:a motion
                              (:type :going)
                              (:target (desig:a location
                                                (pose ?pose))))))
        (cram-process-modules:pm-execute 'hsr-motion going)))))


(defun test-say (?text)
  (cpl:top-level
    (let ((say
            (cram-process-modules:with-process-modules-running (hsr-say)
              (desig:an action
                        (:type :say)
                        (:text ?text)))))
      (cram-process-modules:pm-execute 'hsr-say say))))
