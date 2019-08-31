(in-package :chll)

(defparameter *move-head-action-timeout* 300.0 "in seconds")
(defparameter *move-head-client* NIL)

(defun get-move-head-client ()
  (or *move-head-client*
      (init-move-head-action-client)))

(defun init-move-head-action-client ()
  (setf *move-head-client*
        (actionlib:make-action-client "hsrb/head_trajectory_controller/follow_joint_trajectory"
                                      "control_msgs/FollowJointTrajectoryAction"))
  (loop until (actionlib:wait-for-server *move-head-client*
                                         *move-head-action-timeout*))

  (roslisp:ros-info (head-action) "head action client created"))

;; NOTE most of these params have to be (vector ...)s 
(defun make-move-head-action-goal (&key pos vel acc eff time)
  (actionlib:make-action-goal
      (get-move-head-client)
      ;; (cram-simple-actionlib-client::get-simple-action-client 'move-head-action)
    trajectory (roslisp:make-message
                "control_msgs/FollowJointTrajectoryGoal"
                trajectory (roslisp:make-message
                            "trajectory_msgs/JointTrajectory"
                            joint_names (vector "head_pan_joint" "head_tilt_joint")
                            points (vector
                                    (roslisp:make-message
                                     "trajectory_msgs/JointTrajectoryPoint"
                                     positions pos
                                     velocities vel
                                     accelerations acc
                                     effort eff
                                     time_from_start time))))))

(defun ensure-move-head-goal-reached (status pos)
  (roslisp:ros-warn (move-head) "Status ~a" status)
  status
  pos
  T)


(defun call-move-head-action (pos)
  ;;  (format t "move head called with pos: ~a" pos)
   (multiple-value-bind (result status)
  (actionlib:call-goal (get-move-head-client)
                       (make-move-head-action-goal
                        :pos pos
                        :vel (vector 0.0 0.0)
                        :acc (vector 0.1 0.1) ;; acceleration
                        :eff (vector 0.1) ;; effort
                        :time 3.0)
                       :timeout *move-head-action-timeout*
                       :result-timeout *move-head-action-timeout*)
     (roslisp:ros-info (move-head) "move head action finished")
    (ensure-move-head-goal-reached status pos)
     (values result status)))

;;NOTE 0 0 is the deafault lookig straight position.
(defun test-move-head ()
  (chll::call-move-head-action (vector 0.5 0.5)))
