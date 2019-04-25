(in-package :plc)

;; offset fairly close, for perception
(defparameter *x-offset-perception* 0.4)
(defparameter *y-offset-perception* 0.6)

;; bigger offset allowing for space to move arm
(defparameter *x-offset-manipulation* 0.8)
(defparameter *y-offset-manipulation* 1.0)

(defparameter *height-offset* 0.2)

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


(defun table-head-difference()
  (let* ((table-pos (cl-tf2:lookup-transform
                      (plc:get-tf-listener)
                      "map"
                      "environment/table_front_edge_center"
                      :timeout 5))
         (table-height (cl-tf2:z
                        (cl-tf2:translation table-pos)))
         
         (head-pos (cl-tf2:lookup-transform
                      (plc:get-tf-listener)
                      "map"
                      "head_pan_link"
                      :timeout 5))
         (head-height (cl-tf2:z
                       (cl-tf2:translation head-pos)))
         ;; abs ensures number stays positive
         (diff (- table-height head-height)))
    
    (format t "diff: ~a" (+ diff *height-offset*))
    (+ diff *height-offset*)))


(defun shelf-head-difference ( shelf-level )
  (let* ((shelf-pos (cl-tf2:lookup-transform
                      (plc:get-tf-listener)
                      "map"
                      (concatenate
                       'String
                       "environment/shelf_floor_"
                       shelf-level
                       "_piece")
                      :timeout 5))
         (shelf-height (cl-tf2:z
                        (cl-tf2:translation shelf-pos)))
         
         (head-pos (cl-tf2:lookup-transform
                      (plc:get-tf-listener)
                      "map"
                      "head_pan_link"
                      :timeout 5))
         (head-height (cl-tf2:z
                       (cl-tf2:translation head-pos)))
         (result (/ (- shelf-height *height-offset*) 1.5)))

    (format t "pre result: ~a" result)
    (if (> result 0.65)
        (setq result  0.65)
        (if (< result 0.35)
            (setq result 0.0)))
    
    (format t "HEIGHT of shelf: ~a" shelf-height)
    result))
