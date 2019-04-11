(in-package :chll)

(defvar *robot-joints* (cpl:make-fluent :name :robot-joints) "Current joint states of the robot")
(defparameter *joints-sub* nil)

(defun joints-callback (msg)
  (setf (cpl:value *robot-joints*) msg))

(defun init-joint-fluent ()
  (setf *joints-sub*
        (subscribe "hsrb/robot_state/joint_states"
                   "sensor_msgs/JointState" 
                   #'joints-callback
                   :max-queue-length 1)))

(defun get-current-joint-state (joint-name)
  (flet ((fl-joint-state (fluent)
           (aref
            (sensor_msgs-msg:position fluent)
            (position joint-name
                      (coerce (sensor_msgs-msg:name fluent) 'list)
                      :test #'string=))))
    (cpl:value (cpl:fl-funcall #'fl-joint-state *robot-joints*))))
    
