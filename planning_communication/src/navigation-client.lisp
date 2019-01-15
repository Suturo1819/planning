(in-package :pc)

(defvar *nav-client* nil)

(defun init-navigation-client ()
  (setf *nav-client* (actionlib:make-action-client
                      "/move_base/move" ;; maybe needs hsrb/ before move_base
                      "move_base_msgs/MoveBaseAction"))
  
  (roslisp:ros-info (navigation-action-client) "waiting for Navigation Action server...")

  (loop until
        (actionlib:wait-for-server *nav-client*))
  (roslisp:ros-info (navigation-action-client) "Navigation action client created."))

(defun get-navigation-action-client ()
  (when (null *nav-client*)
    (init-navigation-client))
  *nav-client*)

(defun make-navigation-action-goal (pose-stamped-goal)
  ;; make sure a node is already up and running, if not, one is initialized here.
  (roslisp:ros-info (navigation-action-client) "make navigation action goal")
  (unless (eq roslisp::*node-status* :running)
    (roslisp:start-ros-node "navigation-action-lisp-client"))
  
  (actionlib:make-action-goal (get-navigation-action-client)
    target-pose pose-stamped-goal))

(defun call-navigation-action (x y euler-z)
  "Calles the navigation action. Expected: x y coordinates within map, and
euler-z gives the rotation around the z axis."
  (unless (eq roslisp::*node-status* :running)
    (roslisp:start-ros-node "navigation-action-lisp-client"))

  (multiple-value-bind (result status)
      (let ((actionlib:*action-server-timeout* 10.0)
            (the-goal (cl-tf:to-msg
                       (cl-tf:make-pose-stamped
                        "map"
                        (roslisp::ros-time)
                        (cl-tf:make-3d-vector x y 0.0)
                        (cl-tf:euler->quaternion :ax 0.0 :ay 0.0 :az euler-z)))))
        (actionlib:call-goal
         (get-action-client)
         (make-navigation-action-goal the-goal)))
    (roslisp:ros-info (navigation-action-client) "Navigation action finished.")
(values result status)))

  
