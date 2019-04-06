(in-package :plc)

;; offset fairly close, for perception
(defparameter *x-offset-perception* -0.4)
(defparameter *y-offset-perception* 0.6)

;; bigger offset allowing for space to move arm
(defparameter *x-offset-manipulation* -0.8)
(defparameter *y-offset-manipulation* 1.0)

(defun pose-infront-shelf(&key (manipulation NIL))
  "Calculates the pose for navigation to go to infront of the shelf.
If the manipulation parameter is set, the distance offset is higher
So that the robot can move his arm safely."
  (let* ((shelf (cl-tf2:lookup-transform
                 (plc:get-tf-listener)
                 "map"
                 "environment/shelf_base_center"
                 :timeout 5))
         (pose (cl-tf:make-pose
                (cl-tf:translation shelf)
                (cl-tf:rotation shelf)))
         
         (result-pose (cram-tf:translate-pose pose
                                              :x-offset 0.0
                                              :y-offset (if manipulation
                                                            *y-offset-manipulation*
                                                            *y-offset-perception*)
                                              :z-offset 0.0)))
    (cl-tf:make-pose-stamped "map"
                             (roslisp:ros-time)
                             (cl-tf:origin result-pose)
                             (cl-tf:orientation result-pose))))


(defun pose-infront-table(&key (manipulation NIL))
  "Calculates the pose for navigation to go to infront of the table.
If the manipulation parameter is set, the distance offset is higher
So that the robot can move his arm safely."
  (let* ((shelf (cl-tf2:lookup-transform
                 (plc:get-tf-listener)
                 "map"
                 "environment/table_front_edge_center"
                 :timeout 5))
         (pose (cl-tf:make-pose
                (cl-tf:translation shelf)
                (cl-tf:rotation shelf)))
         
         (result-pose (cram-tf:translate-pose pose
                                              :x-offset (if manipulation
                                                            *x-offset-manipulation*
                                                            *x-offset-perception*)
                                              :y-offset 0.0
                                              :z-offset 0.0)))
    (cl-tf:make-pose-stamped "map"
                             (roslisp:ros-time)
                             (cl-tf:origin result-pose)
                             (cl-tf:orientation result-pose))))
