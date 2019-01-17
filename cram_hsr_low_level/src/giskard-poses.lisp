(in-package :chll)

(defparameter *giskard-poses-action-timeout* 20.0 "in seconds")

(defun make-giskard-poses-action-client ()
  (make-simple-action-client
   'move-poses-action
   "do_move_poses" "move/DoMovePosesAction"
   *giskard-poses-action-timeout*
   :initialize-now T))

(roslisp-utilities:register-ros-init-function make-giskard-poses-action-client)

(defun make-giskard-poses-action-goal (text &key poses object-pose)
  (actionlib:make-action-goal (get-action-client)
    goal_msg text
    list_poses (cl-tf:to-msg poses)
    object_pose (cl-tf:to-msg object-pose)))

(defun ensure-giskard-poses-grip-input (object-pose)
  ;; TODO
  object-pose
  T)

(defun ensure-giskard-poses-move-input (poses)
  ;; TODO
  poses
  T)

(defun ensure-giskard-poses-grip-goal-reached (status object-pose)
  ;; TODO
  status
  object-pose  
  T
  (when (eql status :timeout)
    (cpl:fail 'common-fail:actionlib-action-timed-out :description "do_move_poses grip action timed out"))
)

(defun ensure-giskard-poses-move-goal-reached (status poses)
  ;; TODO
  status
  poses  
  T
  (when (eql status :timeout)
    (cpl:fail 'common-fail:actionlib-action-timed-out :description "do_move_poses move action timed out"))
)

(defun call-giskard-poses-grip-action (object-pose)
  (when (ensure-giskard-poses-grip-input object-pose)
    (multiple-value-bind (result status)
      (call-simple-action-client
       'move-poses-action
       :action-goal (make-giskard-poses-action-goal "grip" :object-pose object-pose)
       :action-timeout *giskard-poses-action-timeout*)
      (roslisp:ros-info (move-poses-action) "do_move_poses grip action finished.")
      (ensure-giskard-poses-grip-goal-reached status object-pose)
      (values result status))))

(defun call-giskard-poses-move-action (poses)
  (when (ensure-giskard-poses-move-input poses)
    (multiple-value-bind (result status)
      (call-simple-action-client
       'move-poses-action
       :action-goal (make-giskard-poses-action-goal "move" :poses poses)
       :action-timeout *giskard-poses-action-timeout*)
      (roslisp:ros-info (move-poses-action) "do_move_poses move action finished.")
      (ensure-giskard-poses-move-goal-reached status poses)
      (values result status))))

