(in-package :chll)

(defvar *robosherlock-action-client* NIL)
(defparameter *robosherlock-action-timeout* 120.0 "in seconds")
(defvar *robosherlock-door-client* NIL)


(defun init-robosherlock-action-client ()
  (roslisp:ros-info (robosherlock-client)
                    "Creating robosherlock action client for server 'extract_object_infos'.")
  (setf *robosherlock-action-client*
        (actionlib:make-action-client "extract_object_infos"
                                      "suturo_perception_msgs/ExtractObjectInfoAction"))
  (loop until (actionlib:wait-for-server *robosherlock-action-client*
                                         *robosherlock-action-timeout*))
  (roslisp:ros-info (robosherlock-client)
                    "Robosherlock action client for ~a created." "'extract_object_infos'"))

(defun get-robosherlock-client ()
  (unless *robosherlock-action-client*
    (init-robosherlock-action-client))
  *robosherlock-action-client*)

(defun call-robosherlock-pipeline (&optional
                                     (regions-value (vector "robocup_table"))
                                     (visualisation-value 'False))
  (roslisp:ros-info (robosherlock-client) "Calling pipeline for regions ~a." regions-value)
  ;; actual call
  (format t "vector: ~a" regions-value)
  (actionlib:call-goal (chll::get-robosherlock-client)
                       (roslisp:make-message
                        "suturo_perception_msgs/ExtractObjectInfoGoal"
                        visualize visualisation-value
                        regions regions-value)
                       :timeout *robosherlock-action-timeout*
                       :result-timeout *robosherlock-action-timeout*))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;here the pipeline for door shut/closed starts;;;;;;;;



(defun init-robosherlock-door-action-client ()
  (roslisp:ros-info (robosherlock-client)
                    "Creating robosherlock action client for server 'analye_shelf_status'.")
  (setf *robosherlock-door-client*
        (actionlib:make-action-client "/analyze_shelf_status"
                                      "suturo_perception_msgs/AnalyzeShelfStatusAction"))
  (loop until (actionlib:wait-for-server *robosherlock-door-client*
                                         *robosherlock-action-timeout*))
  (roslisp:ros-info (robosherlock-client)
                    "Robosherlock door action client for ~a created." "'analye_shelf_status'"))

(defun destroy-door-action-client ()
  (setf *robosherlock-door-client* nil))

(defun get-robosherlock-door-client ()
  (unless *robosherlock-door-client*
    (init-robosherlock-door-action-client))
  *robosherlock-door-client*)

(roslisp-utilities:register-ros-cleanup-function destroy-door-action-client)



(defun call-robosherlock-door-pipeline ()
  "loops till door open"
  (pc:publish-operator-text "Toya is the door open?")
  (roslisp:ros-info (robosherlock-client) "Calling pipeline for door.")
  ;; actual call
  (roslisp:with-fields (door_open)
      (actionlib:call-goal (chll::get-robosherlock-door-client)
                           (actionlib:make-action-goal
                               (chll::get-robosherlock-door-client))
                             :timeout *robosherlock-action-timeout*)
    (if door_open
        (pc:publish-robot-text "The door is open Operator we can continute.")
        (progn
          (sleep 1)
          (call-robosherlock-door-pipeline)))
    door_open))



