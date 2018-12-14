(in-package :pc)

(defun move-to-standard-pose (poseName)
  "moves to standard pose"
  (with-ros-node ("move-to-standard-pose")
    (if (not (wait-for-service "standard_poses" 10))
      (ros-warn nil "Timed out waiting for service standard_poses")
      (format t "~a"(call-service "standard_poses" 'standard_poses-srv:StandardPoses :poseName poseName)))))

