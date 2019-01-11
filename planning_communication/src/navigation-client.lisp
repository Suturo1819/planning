(in-package :pc)

(defvar *nav-client* nil)

(defun init-navigation-client ()
  (setf *nav-client* (actionlib:make-action-client
                      "follow_joint_trajectory"
                      "control_msgs/FollowJointTrajectory"))
  
  (roslisp:ros-info (navigation-action-client) "waiting for Navigation Action server...")

  (loop until
        (actionlib:wait-for-server *nav-client*))
  (roslisp:ros-info (navigation-action-client) "Navigation action client created."))

(defun get-navigation-action-client ()
  (when (null *nav-client*)
    (init-navigation-client))
  *nav-client*)

