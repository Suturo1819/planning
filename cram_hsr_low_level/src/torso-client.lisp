(in-package :chll)

(defparameter *move-torso-action-timeout* 300.0 "in seconds")

(defun init-move-torso-action-client ()
  (cram-simple-actionlib-client:make-simple-action-client
   'move-torso-action
   "hsrb/arm_trajectory_controller/follow_joint_trajectory"
   "control_msgs/FollowJointTrajectoryAction"
   *move-torso-action-timeout*
   :initialize-now T)
  (roslisp:ros-info (torso-action) "torso action client created"))

;; NOTE most of these params have to be (vector ...)s 
(defun make-move-torso-action-goal (&key pos vel acc eff time)
  (actionlib:make-action-goal
      (cram-simple-actionlib-client::get-simple-action-client 'move-torso-action)
    trajectory
    (roslisp:make-message
     "control_msgs/FollowJointTrajectoryGoal"
     trajectory (roslisp:make-message
                 "trajectory_msgs/JointTrajectory"
                 joint_names (vector "arm_lift_joint"
                                     "arm_flex_joint"
                                     "arm_roll_joint"
                                     "wrist_flex_joint"
                                     "wrist_roll_joint")
                 points (vector
                         (roslisp:make-message
                          "trajectory_msgs/JointTrajectoryPoint"
                          positions pos
                          velocities vel
                          accelerations acc
                          effort eff
                          time_from_start  time))))))

(defun ensure-move-torso-goal-reached (status pos)
  (roslisp:ros-warn (move-torso) "Status ~a" status)
  status
  pos
  T)


(defun call-move-torso-action (pos vel)
  (multiple-value-bind (result status)
      (cram-simple-actionlib-client::call-simple-action-client
       'move-torso-action
       :action-goal (make-move-torso-action-goal
                     :pos pos
                     :vel vel
                     :acc (vector 0.1 0.1 0.0 0.0 0.0) ;; acceleration
                     :eff (vector 0.1 0.1 0.0 0.0 0.0) ;; effort
                     :time 3.0) ;; time
       :action-timeout *move-torso-action-timeout*)
    (roslisp:ros-info (move-torso) "move torso action finished")
    (ensure-move-torso-goal-reached status pos)
    (values result status)))

;;NOTE 0 0 is the deafault lookig straight position.
(defun test-move-torso ()
  (chll::call-move-torso-action (vector 0.2 -0.5 0.0 0.0 0.0)
                                (vector 0.0 0.0 0.0 0.0 0.0)))
