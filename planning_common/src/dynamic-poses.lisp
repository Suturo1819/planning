(in-package :plc)

;; offset fairly close, for perception
(defparameter *x-offset-perception* 0.5)
(defparameter *y-offset-perception* 0.7)

;; bigger offset allowing for space to move arm
(defparameter *x-offset-manipulation* 0.9)
(defparameter *y-offset-manipulation* 0.9)

(defparameter *height-offset* 0.2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BASE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun pose-infront-shelf(&key (manipulation NIL))
  "Calculates the pose for navigation to go to infront of the shelf.
If the manipulation parameter is set, the distance offset is higher
So that the robot can move his arm safely."
  (pc::publish-challenge-step 5)
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
  (pc::publish-challenge-step 2)
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


(defun pose-infront-object (object-frame)
  (format t "Object: ~a" object-frame)
  (let* ((obj-pose (cl-tf2:lookup-transform
                    (plc:get-tf-listener)
                    "map"
                    object-frame
                    :timeout 5))
         
         (pose (cl-tf:make-pose
                (cl-tf:translation obj-pose)
                (cl-tf:rotation obj-pose)))
         
         ;;obj relative to table
         (table-T-obj (cl-tf2:lookup-transform
                       (plc::get-tf-listener)
                       "environment/table_front_edge_center"
                       object-frame))
         
         (map-T-table-orig (cl-tf2:lookup-transform
                            (plc::get-tf-listener)
                            "map"
                            "environment/table_front_edge_center"))
         
         (map-T-table (cl-tf:make-transform
                       (cl-tf:translation map-T-table-orig)
                       (cl-tf:rotation map-T-table-orig)))

         (x-diff-obj-table-edge (cl-tf:x (cl-tf:translation table-T-obj)))
         (y-diff-obj-table-edge (cl-tf:y (cl-tf:translation table-T-obj)))
        
         (result-pose (cram-tf:translate-pose pose
                                              :x-offset (+ *x-offset-manipulation*
                                                           x-diff-obj-table-edge)
                                              :y-offset 0.0
                                              :z-offset 0.0))
         
         (z (plc::normalize-euler (cl-tf:rotation table-T-obj)))
         
         (normalized-obj-rot (cl-tf:euler->quaternion
                              :ax 0.0
                              :ay 0.0
                              :az z))
         
         (robot-rotation-map (cl-tf:transform* map-T-table
                                               (cl-tf:make-transform
                                                (cl-tf:make-identity-vector)
                                                normalized-obj-rot)))
         (temp (cram-tf:translate-pose pose
                                       :x-offset 0.0
                                       :y-offset (+ *x-offset-manipulation*
                                                     x-diff-obj-table-edge)
                                       :z-offset 0.0))
         (diff-y (- (cl-tf:y (cl-tf:origin pose))
                    (cl-tf:y (cl-tf:origin temp)))))
    
    (setq result-pose (cram-tf:translate-pose result-pose
                                              :x-offset 0.0
                                              :y-offset diff-y
                                              :z-offset 0.0)) 
                             
  (cl-tf:make-pose-stamped "map"
                           (roslisp:ros-time)
                           (cl-tf:make-3d-vector (cl-tf:x (cl-tf:origin result-pose))
                                                 (if (< (cl-tf:y (cl-tf:origin result-pose)) 0.0)
                                                     0.0
                                                     (cl-tf:y (cl-tf:origin result-pose)))
                                                 0.0)
                           (cl-tf:rotation robot-rotation-map))))

;;;;;;;;;;;;;;;;;;;;;;;;;;; HEAD ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun table-head-difference( )
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
