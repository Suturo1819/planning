(in-package :pc)

(defvar *challenge-step* nil)
(defvar *robot-text* nil)
(defvar *operator-text* nil)

(defun viz-box-init ()
  (setf *challenge-step* (roslisp:advertise "/challenge_step" "std_msgs/UInt32"))
  (setf *robot-text* (roslisp:advertise "/robot_text" "std_msgs/String"))
  (setf *operator-text* (roslisp:advertise "/operator_text" "std_msgs/String")))
        

(defun publish-challenge-step (step)
  (roslisp:publish *challenge-step*
                   (roslisp:make-message "std_msgs/UInt32" 
                                         :data step)))

(defun publish-robot-text (text)
  (roslisp:publish *robot-text*
                   (roslisp:make-message "std_msgs/String" 
                                         :data text)))

(defun publish-operator-text (text)
  (roslisp:publish *operator-text*
                   (roslisp:make-message "std_msgs/String" 
                                         :data text)))
	
;; rostopic pub /challenge_step std_msgs/UInt32 "data: 0" --once
;; rostopic pub /robot_text std_msgs/String "data: 'Hello operator'" --once
;; rostopic pub /operator_text std_msgs/String "data: 'Robot, follow me'" --once
;; rostopic pub /robot_text std_msgs/String "data: 'OK, I will follow you'" --once;
;; rostopic pub /challenge_step std_msgs/UInt32 "data: 1" --once
