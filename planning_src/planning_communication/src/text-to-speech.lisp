(in-package :pc)

(defvar *text-to-speech-publisher* nil)

(defun init () 
  (roslisp:start-ros-node "planning_communication")
  (setf *text-to-speech-publisher* (roslisp:advertise "/talk_request" "tmc_msgs/Voice")))

(defun publish-text-to-speech (text) 
  (publish *text-to-speech-publisher*
    (make-message "tmc_msgs/Voice"
      :language 1
      :sentence text)))
