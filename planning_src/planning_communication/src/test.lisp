(in-package :pc)

(defvar *text-to-speech-publisher* nil)

(defun init () 
  (roslisp:start-ros-node "planning-communication")
  (setf *text-to-speech-publisher* (roslisp:advertise "/talk_request" "tmc_msgs/Voice")))

(defun publish-text-to-speech () )
