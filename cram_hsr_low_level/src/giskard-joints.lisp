(in-package :chll)

(defparameter *giskard-joints-action-timeout* 300.0 "in seconds")

(defun init-giskard-joints-action-client ()
  (cram-simple-actionlib-client:make-simple-action-client
   'move-joints-action
   "do_move_joints"
   "suturo_manipulation_msgs/DoMoveJointsAction"
   *giskard-joints-action-timeout*
   :initialize-now T))

;; TODO check if this is needed.
;; (roslisp-utilities:register-ros-init-function make-giskard-joints-action-client)

(defun make-giskard-joints-action-goal (text &key
                                               (object-pose NIL) ; object pose in map
                                               (object-pose-to-odom NIL) ; object-pose in odom
                                               (weight NIL)
                                               (width NIL)
                                               (height NIL)
                                               (desired-joint-values NIL))
  ;; TODO: desired_joints_values are ignored for now, so moving is not possible
  desired-joint-values
  (actionlib:make-action-goal
      (cram-simple-actionlib-client::get-simple-action-client 'move-joints-action)
    goal_msg text
    object_pose (cl-tf:to-msg object-pose)
    object_pose_to_odom (cl-tf:to-msg object-pose-to-odom)
    weight weight
    width width
    height height))

(defun ensure-giskard-joints-grasping-input (object-pose object-pose-to-odom weight width height)
  ;; TODO: check if object-pose is possible to grasp, e.g. check if it is to wide
  (and object-pose
       object-pose-to-odom
       (<= 0 weight)
       (<= 0 width 0.2)
       (<= 0 height)))

(defun ensure-giskard-joints-move-input (desired-joint-values)
  ;; TODO: check if desired-joint-values are possible to reach, e.g. check if they are to high...
  desired-joint-values
  T)

(defun ensure-giskard-joints-grasping-goal-reached (status object-pose object-pose-to-odom weight width height)
  ;; TODO: check status if given object-pose is reached
  (roslisp:ros-debug (move-joints-action) "Ensure grasping-goal reached.\nStatus: ~a" status)
  ;; TODO: log everything
  object-pose
  object-pose-to-odom
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

(defun call-giskard-joints-grasping-action (object-pose object-pose-to-odom weight width height)
  (when (ensure-giskard-joints-grasping-input object-pose object-pose-to-odom  weight width height)
    (multiple-value-bind (result status)
      (cram-simple-actionlib-client::call-simple-action-client
       'move-joints-action
       :action-goal (make-giskard-joints-action-goal "grip" ;;definied in manipulation
                                                     :object-pose object-pose
                                                     :object-pose-to-odom object-pose-to-odom
                                                     :weight weight
                                                     :width width
                                                     :height height)
       :action-timeout *giskard-joints-action-timeout*)
      (roslisp:ros-info (move-joints-action) "do_move_joints grasp action finished.")
      (ensure-giskard-joints-grasping-goal-reached status object-pose object-pose-to-odom  weight width height)
      (values result status))))

(defun call-giskard-joints-move-action (desired-joint-values)
  (when (ensure-giskard-joints-move-input desired-joint-values)
    (multiple-value-bind (result status)
      (cram-simple-actionlib-client::call-simple-action-client
       'move-joints-action
       :action-goal (make-giskard-joints-action-goal "move"
                                                     :desired-joint-values desired-joint-values)
       :action-timeout *giskard-joints-action-timeout*)
      (roslisp:ros-info (move-joints-action) "do_move_joints move action finished.")
      (ensure-giskard-joints-move-goal-reached status desired-joint-values)
      (values result status))))

