(in-package chll)

(defvar *robosherlock-action-client* nil)

(defparameter *robosherlock-action-timeout* 120.0 "in seconds")

(defun init-robosherlock-action-client ()
  (setf *robosherlock-action-client* (actionlib:make-action-client
                                      "hsr_perception"
                                      "suturo_perception_msgs/PerceiveAction"))
  (loop until
        (actionlib:wait-for-server *robosherlock-action-client*))
  (roslisp:ros-info (robosherlock-action-client)
                    "Robosherlock action client created."))

(defun kill-robosherlock-client ()
  (setf *robosherlock-action-client* nil))

(roslisp-utilities:register-ros-cleanup-function kill-robosherlock-client)

(defun get-robosherlock-client ()
  (unless *robosherlock-action-client*
    (init-robosherlock-action-client))
  *robosherlock-action-client*)

(defun call-robosherlock-pipeline (&optional (pipeline-name "table"))
  (actionlib:call-goal (get-robosherlock-client) 
                            (actionlib:make-action-goal (get-robosherlock-client)
                             pipeline pipeline-name)))
