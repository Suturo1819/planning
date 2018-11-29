(in-package :planning-communication)

(defvar *text-to-speech-publisher*)

(defun init () 
  (start-ros-node "planning-communication")
  (setf *text-to-speech-publisher* (advertise "/talk_request" "tmc_msgs/Voice")))

(defun publish-text-to-speech () )
