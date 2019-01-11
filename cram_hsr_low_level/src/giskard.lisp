
(in-package :chll)

(defvar *giskard-action-client* nil)

(defparameter *giskard-action-timeout* 20.0 "in seconds")

(defun init-giskard-action-client ()
  (setf *giskard-action-client* (actionlib:make-action-client
                                 "do_move_joints"
                                 "move/DoMoveJointsAction"))
  (loop until
        (actionlib:wait-for-server *giskard-action-client*))
  (roslisp:ros-info (giskard-action-client)
                    "Giskard action client created."))

(defun destroy-giskard-action-client ()
  (setf *giskard-action-client* nil))

(roslisp-utilities:register-ros-cleanup-function destroy-giskard-action-client)

(defun get-action-client ()
  (when (null *giskard-action-client*)
    (init-giskard-action-client))
  *giskard-action-client*)

;; TODO: define goal
;(defun make-giskard-do-move-action-goal (text)
;  (actionlib:make-action-goal (get-action-client)
;    :data (make-message "move/DoMoveJointsAction"
;                        :goal_msg text
;                        :desired_joints_values nil)))

(defun make-do-move-joints-action-goal (text joint-values)
  (actionlib:make-action-goal (get-action-client)
    goal_msg text
    desired_joint_values joint-values))

(defun call-giskard-do-move-action (text)
  (multiple-value-bind (result status)
      (let ((actionlib:*action-server-timeout* 10.0))
        (actionlib:call-goal
         (get-action-client)
         (make-do-move-joints-action-goal text nil)))
    (roslisp:ros-info (giskard-action-client) "Do move joints action finished.")
    (values result status)))
