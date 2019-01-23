(in-package :chll)

(defparameter *giskard-joints-action-timeout* 300.0 "in seconds")

(defun make-giskard-joints-action-client ()
  (make-simple-action-client
   'move-joints-action
   "do_move_joints" "move/DoMoveJointsAction"
   *giskard-joints-action-timeout*
   :initialize-now T))

;; (roslisp-utilities:register-ros-init-function make-giskard-joints-action-client)

(defun make-giskard-joints-action-goal (text &key
                                               (object-pose NIL)
                                               (weight NIL)
                                               (width NIL)
                                               (height NIL)
                                               (desired-joint-values NIL))
  ;; TODO: desired_joints_values are ignored for now, so moving is not possible
  desired-joint-values
  (actionlib:make-action-goal (get-simple-action-client 'move-joints-action)
    goal_msg text
    object_pose (cl-tf:to-msg object-pose)
    weight weight
    width width
    height height))

(defun ensure-giskard-joints-grip-input (object-pose weight width height)
  ;; TODO: check if object-pose is possible to grip, e.g. check if it is to wide
  object-pose
  weight
  width
  height
  T)

(defun ensure-giskard-joints-move-input (desired-joint-values)
  ;; TODO: check if desired-joint-values are possible to reach, e.g. check if they are to high...
  desired-joint-values
  T)

(defun ensure-giskard-joints-grip-goal-reached (status object-pose weight width height)
  ;; TODO: check status if given object-pose is reached
  (roslisp:ros-debug (move-joints-action) "Ensure grip-goal reached.\nStatus: ~a" status)
  ;; TODO: log everything
  object-pose
  weight
  width
  height
  T
)

(defun ensure-giskard-joints-move-goal-reached (status desired-joint-values)
  ;; TODO: check status if given desired-joint-valuesare reached
  (roslisp:ros-warn (move-joints-action) "Status: ~a" status)
  status
  desired-joint-values  
  T
)

(defun call-giskard-joints-grip-action (object-pose weight width height)
  (when (ensure-giskard-joints-grip-input object-pose weight width height)
    (multiple-value-bind (result status)
      (call-simple-action-client
       'move-joints-action
       :action-goal (make-giskard-joints-action-goal "grip"
                                                     :object-pose object-pose
                                                     :weight weight
                                                     :width width
                                                     :height height)
       :action-timeout *giskard-joints-action-timeout*)
      (roslisp:ros-info (move-joints-action) "do_move_joints grip action finished.")
      (ensure-giskard-joints-grip-goal-reached status object-pose weight width height)
      (values result status))))

(defun call-giskard-joints-move-action (desired-joint-values)
  (when (ensure-giskard-joints-move-input desired-joint-values)
    (multiple-value-bind (result status)
      (call-simple-action-client
       'move-joints-action
       :action-goal (make-giskard-joints-action-goal "move"
                                                     :desired-joint-values desired-joint-values)
       :action-timeout *giskard-joints-action-timeout*)
      (roslisp:ros-info (move-joints-action) "do_move_joints move action finished.")
      (ensure-giskard-joints-move-goal-reached status desired-joint-values)
      (values result status))))

