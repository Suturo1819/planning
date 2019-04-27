(in-package :plc)

;; offset fairly close, for perception
(defparameter *x-offset-perception* 0.5)
(defparameter *y-offset-perception* 0.8)

;; bigger offset allowing for space to move arm
(defparameter *x-offset-manipulation* 0.9)
(defparameter *y-offset-manipulation* 1.0)

(defparameter *height-offset* 0.35)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BASE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun pose-infront-shelf(&optional &key (manipulation NIL) (rotation NIL))
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

    (if rotation
        (setq result-pose (cram-tf:rotate-pose (cl-tf:pose->pose-stamped
                                                "map"
                                                (roslisp::ros-time)
                                                result-pose)
                                               :z (/ pi -2))))
    
    (format t "result: ~a" result-pose)
                                           
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
  (let* ((pose (plc::pose-stamped->transform
                (cl-tf2:lookup-transform
                 (plc:get-tf-listener)
                 "map"
                 object-frame
                 :timeout 5)))
         
         ;;obj relative to table
         (table-T-obj (cl-tf2:lookup-transform
                       (plc::get-tf-listener)
                       "environment/table_front_edge_center"
                       object-frame))
         
         (map-T-table (plc::pose-stamped->transform
                       (cl-tf2:lookup-transform
                        (plc::get-tf-listener)
                        "map"
                        "environment/table_front_edge_center")))

         (base-T-obj (plc::pose-stamped->transform
                      (cl-tf2:lookup-transform
                       (plc::get-tf-listener)
                       "base_footprint"
                       object-frame)))
         

         (x-diff-obj-table-edge (cl-tf:x (cl-tf:translation table-T-obj)))
         (y-diff-obj-table-edge (cl-tf:y (cl-tf:translation table-T-obj)))
        
         (result-pose (cl-tf:pose->transform
                       (cram-tf:translate-pose
                        (cl-tf:transform->pose
                         pose)
                         :x-offset (+ *x-offset-manipulation*
                                      x-diff-obj-table-edge)
                         :y-offset (- *x-offset-manipulation*
                                      y-diff-obj-table-edge)
                         :z-offset 0.0)))
         
         ;; normalize z rotation to prevent getting poses inside of walls
         (z (plc::normalize-euler (cl-tf:rotation table-T-obj)))
         
         (normalized-obj-rot (cl-tf:euler->quaternion
                              :ax 0.0
                              :ay 0.0
                              :az z))
         
         ;; (robot-rotation-map (cl-tf:transform* map-T-table
         ;;                                       (cl-tf:make-transform
         ;;                                        (cl-tf:make-identity-vector)
         ;;                                        normalized-obj-rot)))

         ;; map-T-obj = pose
         ;; map-T-base
         (map-T-base (plc::pose-stamped->transform
                      (cl-tf2:lookup-transform
                       (plc::get-tf-listener)
                       "map"
                       "base_footprint")))
         (robot-rotation-map 
                              (plc::calculate-look-towards-target
                               (plc::transform->pose-stamped pose)
                               (plc::transform->pose-stamped map-T-base)))
           
         ;; figure out (wh)y
         (diff-y (cl-tf:transform*
                  map-T-base
                  (cl-tf:make-transform
                   (cl-tf:make-3d-vector
                    (cl-tf:x (cl-tf:translation base-T-obj))
                    (cl-tf:y 0.0)
                    (cl-tf:z (cl-tf:translation base-T-obj)))
                   (cl-tf:rotation base-T-obj))))
         ) 

    (cl-tf:make-pose-stamped "map"
                             (roslisp:ros-time)
                             (cl-tf:make-3d-vector
                              (cl-tf:x (cl-tf:translation result-pose))
                              (if (< (cl-tf:y (cl-tf:translation result-pose)) 0.0)
                                  0.0
                                  (cl-tf:y (cl-tf:translation result-pose)))
                              0.0)
                             (cl-tf:orientation robot-rotation-map))))

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
         ;;TODO FIX THIS HARDCODED 0.2
         (result (/ (- shelf-height 0.2) 1.5)))

    (format t "pre result: ~a" result)
    (if (> result 0.65)
        (setq result  0.65)
        (if (< result 0.35)
            (setq result 0.0)))
    
    (format t "HEIGHT of shelf: ~a" shelf-height)
    result))

;; adapted from  cram/cram_pr2/cram_pr2_fetch_deliver_plans/src/fetch-and-deliver-plans.lisp 
(defun calculate-look-towards-target (look-pose-stamped robot-pose-stamped)
  "Given a `look-pose-stamped' and a `robot-pose-stamped',
calculate table-height new robot-pose-stamped, which is rotated with an angle to point towards
the `look-pose-stamped'."
  (let* ((world->robot-transform
           (cram-tf:pose-stamped->transform-stamped robot-pose-stamped "robot"))
         (robot->world-transform
           (cl-transforms:transform-inv world->robot-transform))
         (world->look-pose-origin
           (cl-transforms:origin look-pose-stamped))
         (look-pose-in-robot-frame
           (cl-transforms:transform-point
            robot->world-transform
            world->look-pose-origin))
         (rotation-angle
           (atan
            (cl-transforms:y look-pose-in-robot-frame)
            (cl-transforms:x look-pose-in-robot-frame))))
    (cram-tf:rotate-pose robot-pose-stamped :z rotation-angle)))

(defparameter *arm-offset* 0.8)
(defparameter *short-dist* 0.2)
;; use transform of tablecenter-T-obj
(defun calculate-possible-poses-from-obj (object-frame)
  ;;make list of poses
  (let* ((obj-transform (plc::pose-stamped->transform
                         (cl-tf2:lookup-transform
                          (plc::get-tf-listener)
                          "environment/table_front_edge_center"
                          object-frame)))


         (x (cl-tf:x (cl-tf:translation obj-transform)))
         (y (cl-tf:y (cl-tf:translation obj-transform)))
         (rotation (cl-tf:rotation obj-transform))

         (vector-list '())
         (poses-list '())
         (cut-poses '())
         (result-pose '())
         (map-T-table (plc::pose-stamped->transform
                       (cl-tf2:lookup-transform
                        (plc::get-tf-listener)
                        "map"
                        "environment/table_front_edge_center")))
         
         ;; the size of the table edge. 
         (edge-side
           (plc::pose-stamped->transform
            (cl-tf2:lookup-transform
             (plc::get-tf-listener)
             "environment/table_origin"
             "environment/table_front_edge_center")))
         
         ;; table-T-obj = (inv map-T-table) * map-T-obj
         (table-T-obj (cl-tf:transform*
                       (cl-tf:transform-inv
                        map-T-table)
                       obj-transform))
         
         (xt (cl-tf:x (cl-tf:translation map-T-table)))
         (yt (cl-tf:y (cl-tf:translation map-T-table))))
    
    (push (list (* 1.0 *short-dist*) 0.0 0.0) vector-list)
    (push (list (* -1.0 *short-dist*) 0.0 0.0) vector-list)
    (push (list 0.0 (* 1.0 *short-dist*) 0.0) vector-list)
    (push (list 0.0 (* -1.0 *short-dist*) 0.0) vector-list)


    ;; make list of transforms which are the offsets
    (setq poses-list (mapcar (lambda (vector)
                               (plc::vector->transform
                                vector
                                (cl-tf:make-identity-rotation))) vector-list))
    
    ;; multiply offset transform onto original object pose
    (setq poses-list (mapcar (lambda (transform)
                               (cl-tf:transform*
                                ;;map-T-table
                                ;;(cl-tf:transform-inv
                                 obj-transform;)
                                 (cl-tf:transform-inv
                                  transform)))
                             poses-list))
  
    (format t "poses list: ~a" poses-list)
    ;;cut poses which are far away from edge
    ;; list of transforms
    (setq result-pose (let* ((temp))
                        (mapcar (lambda (pose)
                                  (unless temp
                                    (setq temp pose))
                                  
                                  (if (< (cl-tf:x (cl-tf:translation
                                                   pose))
                                         (cl-tf:x (cl-tf:translation temp)))
                                      (setq temp pose)))
                                poses-list)
                        (cl-tf:transform*
                         map-T-table
                         temp)))

    (setq poses-list (mapcar (lambda (pose)
                               (plc::transform->pose-stamped
                                (cl-tf:transform*
                                 map-T-table
                                pose)))
                             poses-list))
    
    ;;(plc::spawn-4-markers poses-list)

     (planning-communication::publish-marker-pose (plc::transform->pose-stamped                                          
                                                    result-pose))
    result-pose
   ;; poses-list
   ;; edge-side
    ))
