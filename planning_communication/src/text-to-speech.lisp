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

;;action client

(defvar *text-to-speech-action-client* nil)

(defun init-text-to-speech-action-client ()
  (setf *text-to-speech-action-client* (actionlib:make-action-client
     "talk_request_action"
     "tmc_msgs/TalkRequestAction"))
  (loop until
    (actionlib:wait-for-server *text-to-speech-action-client*))
  (roslisp:ros-info (text-to-speech-action-client) 
                    "Text to speech action client created."))

(defun get-text-to-speech-action-client ()
  (when (null *text-to-speech-action-client*)
    (init-text-to-speech-action-client))
  *text-to-speech-action-client*)

(defun make-text-action-goal (text)
  (actionlib:make-action-goal (get-text-to-speech-action-client)
    :data (make-message "tmc_msgs/Voice"
      :interrupting nil
      :queueing nil
      :language 1
      :sentence text)))

(defun call-text-to-speech-action (text)
  (multiple-value-bind (result status)
      (let ((actionlib:*action-server-timeout* 10.0))
        (actionlib:call-goal
         (get-text-to-speech-action-client)
         (make-text-action-goal text)))
    (roslisp:ros-info (text-to-speech-action-client) "Text to speech action finished.")
    (values result status)))

