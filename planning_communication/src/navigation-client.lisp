(in-package :pc)

(defvar *nav-client* nil)

(defun init-navigation-client ()
  (setf *nav-client* (actionlib:make-action-client
                      "/hsrb/omni_base_controller/follow_joint_trajectory"
                      "control_msgs/FollowJointTrajectory"))
  
  (roslisp:ros-info (navigation-action-client) "waiting for Navigation Action server...")

  (loop until
        (actionlib:wait-for-server *nav-client*))
  (roslisp:ros-info (navigation-action-client) "Navigation action client created."))

(defun get-navigation-action-client ()
  (when (null *nav-client*)
    (init-navigation-client))
  *nav-client*)

(defun make-navigation-action-goal (goal)
  ;; make sure a node is already up and running, if not, one is initialized here.
  (unless (eq roslisp::*node-status* :running)
    (roslisp:start-ros-node "navigation-action-lisp-client"))
  
  (actionlib:make-action-goal (get-navigation-action-client)
    goal))
    

  
