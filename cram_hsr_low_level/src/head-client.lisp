(in-package :chll)

(defparameter *move-head-action-timeout* 300.0 "in seconds")

(defun init-move-head-action-client ()
  (cram-simple-actionlib-client:make-simple-action-client
   'move-head-action
   "follow_joint_trajectory"
   "control_msgs/FollowJointTrajectoryAction"
   *head-action-timeout*
   :initialize-now T)
  (roslisp:ros-info (head-action) "head action client created"))

;; NOTE most of these params have to be (vector ...)s 
(defun make-move-head-action-goal (&key pos vel acc eff time)
  (actionlib:make-action-goal
      (cram-simple-actionlib-client::get-simple-action-client 'move-head-action)
    goal_msg (roslisp:make-message
              "trajectory_msgs/JointTrajectory"
              joint_names (vector "head_pan_joint" "head_tilt_joint")
              points (roslisp:make-message
                      "trajectory_msgs/JointTrajectoryPoint"
                      positions pos
                      velocities vel
                      accelerations acc
                      effort eff
                      time_from_start  time))))

(defun ensure-move-head-goal-reached (status pos)
  (roslisp:ros-warn (move-head) "Status ~a" status)
  status
  pos
  T)


(defun call-move-head-action (pos vel)
  (multiple-value-bind (result status)
      (cram-simple-actionlib-client::call-simple-action-client
       'move-head-action
       :action-goal (make-move-head-action-goal
                     :pos pos
                     :vel vel
                     :acc (vector 0.1 0.1) ;; acceleration
                     :eff (vector 0.1) ;; effort
                     :time 3.0) ;; time
       :action-timeout *move-head-action-timeout*)
    (roslisp:ros-info (move-head) "move head action finished")
    (ensure-move-head-goal-reached status pos)
    (values result status)))
