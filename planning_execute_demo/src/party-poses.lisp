(in-package :pexe)

(defparameter poses-list
  (list
   ;;INFRONT DOOR
   (list :after-door (plc::make-pose-stamped 4.305 0.218 3.0))
   (list :infront-bar-door (plc::make-pose-stamped 2.548 1.274 1.5))
   (list :infront-bedroom-door (plc::make-pose-stamped 1.451 0.149 4.7))
   (list :infront-kitchen-door (plc::make-pose-stamped -2.514 0.0855 4.7))
   (list :infront-exit-door (plc::make-pose-stamped -2.008 5.319 1.5))
   (list :infront-kitchen-door-from-bedroom (plc::make-pose-stamped 0.991 -1.948 3.0))

   ;; generally IN-ROOM
   (list :in-bar (plc::make-pose-stamped 2.520 2.732 1.5))
   (list :in-bedroom (plc::make-pose-stamped 1.611 -1.99 4.7))
   (list :in-kitchen-from-bedroom (plc::make-pose-stamped -1.000 -1.935 3.0))
   (list :in-kitchen (plc::make-pose-stamped -2.535 -1.193 4.7))
   (list :in-living-room (plc::make-pose-stamped -1.5800 2.008 3.0))
   (list :in-hallway (plc::make-pose-stamped 2.48 0.667 3.0))

   ;;objects in BAR
   (list :infront-bar-cupboard (plc::make-pose-stamped 4.193 2.329 0.0))
   (list :infront-bar-sofa (plc::make-pose-stamped 3.6966 3.202 0.5))
   (list :infront-bar-bartable (plc::make-pose-stamped 2.426 4.196 2.0))

   ;;objects in BEDROOM
   (list :infront-bedroom-bed (plc::make-pose-stamped 1.883 -2.827 0.0))
   (list :infront-bedroom-desk (plc::make-pose-stamped 1.883 -2.827 4.7))
   (list :infront-bedroom-sidetable (plc::make-pose-stamped 3.69666 -1.765 0.0))

   ;;objects in KITCHEN
   (list :infront-kitchen-kitchencabinet (plc::make-pose-stamped -0.748 -2.6322 4.7))
   (list :infront-kitchen-dishwasher (plc::make-pose-stamped -1.460 -2.7756 4.7))
   (list :infront-kitchen-trashcan (plc::make-pose-stamped -1.129 -0.92033 6.))
   (list :infront-kitchen-kitchentable (plc::make-pose-stamped -2.708 -1.164 4.7))
   (list :infront-kitchen-cabinet (plc::make-pose-stamped -4.2144 -2.7022 3.2))
   (list :infront-kitchen-whitedrawer (plc::make-pose-stamped -4.025 -0.959 3.2))

   ;;objects in LIVINGROOM
   (list :infront-livingroom-bookcase (plc::make-pose-stamped 0.459 0.372 4.7))
   (list :infront-livingroom-sideboard (plc::make-pose-stamped 0.421 1.299 1.5))
   (list :infront-livingroom-lighttable (plc::make-pose-stamped -3.458 0.340 3.0))
   (list :infront-livingroom-tv (plc::make-pose-stamped 0.360 3.263 0.0))
   (list :infront-livingroom-tvtable (plc::make-pose-stamped 0.0269 4.361 0.0))
   (list :infront-livingroom-trashbin (plc::make-pose-stamped -0.879 5.156 0.0))
   (list :infront-livingroom-coathanger (plc::make-pose-stamped -1.144 4.992 1.5))
   (list :infront-livingroom-leftarmchair (plc::make-pose-stamped -1.909 3.969 2.5))
   (list :infront-livingroom-rightarmchair (plc::make-pose-stamped -3.315 2.38 0.0))
   (list :infront-livingroom-coffeetable (plc::make-pose-stamped -3.315 2.384 2.5))
   ;;CARE! Couch cannot be navigated to since it is behind the table
   (list :infront-livingroom-couch (plc::make-pose-stamped -3.7967 4.367 2.5))
   ))

(defun which-room-i (x)
  (case x
    (:infront-kitchen-kitchencabinet :kitchen)
    (:infront-kitchen-dishwasher :kitchen)
    (:infront-kitchen-trashcan :kitchen)
    (:infront-kitchen-kitchentable :kitchen)
    (:infront-kitchen-cabinet :kitchen) 
    (:infront-kitchen-whitedrawer :kitchen)
    (:infront-bedroom-bed :bedroom)
    (:infront-bedroom-desk :bedroom)
    (:infront-bedroom-sidetable :bedroom)
    (:infront-bar-cupboard :bar)
    (:infront-bar-sofa :bar)
    (:infront-bar-bartable :bar)
    (:in-bar :bar)
    (:in-bedroom :bedroom)
    (:in-kitchen-from-bedroom :kitchen)
    (:in-kitchen :kitchen)
    (:in-living-room :living)
    (:in-hallway :hallway)
    (:after-door :hallway)
    (:infront-bar-door :bar)
    (:infront-bedroom-door :bedroom)
    (:infront-kitchen-door :kitchen)
    (:infront-exit-door :exit-door)
    (:infront-kitchen-door-from-bedroom :bedroom)
    (:infront-livingroom-bookcase :living)
    (:infront-livingroom-sideboard :living)
    (:infront-livingroom-lighttable :living)
    (:infront-livingroom-tv  :living)
    (:infront-livingroom-tvtable :living)
    (:infront-livingroom-trashbin :living)
    (:infront-livingroom-coathanger :living)
    (:infront-livingroom-leftarmchair :living)
    (:infront-livingroom-rightarmchair :living)
    (:infront-livingroom-coffeetable :living)
    ;;CARE! Couch cannot be navigated to since it is behind the table
    (:infront-livingroom-couch :living)
    ))

(defun route (start end)
  (case start
    (:kitchen (case end
                (:bedroom "you are in the, :kitchen go to, :trash can then through the, :door to your, :right and then you have entered the, :bedroom")
                (:hallway "you are in the, :kitchen go to, :trash can then through the, :door to your, :right and then you have entered the, :bedroom and you can go to the, :door on your, :left")
                (:living "you are in the, :kitchen look for the, :kitchen-table then you can see the, :doorway, you must enter this.")
                (:bar "you are in the, :kitchen go to, :trash can then through the, :door to your, :right and then you have entered the, :bedroom and you can go to the, :door on your, :left on the other, :side you see the, :door for the bedroom, :enter it")))))
                 
    
  
  
  

(defun where-is-person ()
  (let ((base-pose (cl-tf:lookup-transform (get-tf-listener-tmp) "base_footprint" "map" :timeout 2)))
    (car (first (sort poses-list #'< :key
                      (lambda (pose)
                        (cl-tf:v-norm (cl-tf:origin (cl-tf:transform
                                                     base-pose
                                                     (car (cdr pose)))))))))))


(defparameter *tf-listener-tmp* nil)

(defun get-tf-listener-tmp ()
  (unless *tf-listener-tmp*
    (setf *tf-listener-tmp* (make-instance 'cl-tf2:buffer-client))
    (handler-case
     (cl-tf2:lookup-transform *tf-listener-tmp* "map" "odom" :timeout 3)
      (CL-TRANSFORMS-STAMPED:TRANSFORM-STAMPED-ERROR () (roslisp:ros-warn (get-tf-listener) "tf-listener takes longer than 20 seconds to get odom in map."))
      (CL-TRANSFORMS-STAMPED:TIMEOUT-ERROR
       () (roslisp:ros-warn (get-tf-listener) "tf-listener takes longer than 20 seconds to get odom in map."))))
  *tf-listener-tmp*)








;;access list:
;;(planning-communication::publish-marker-pose (cdr (assoc :after-door poses-list)))
                          


;;(cl-tf:lookup-transform (get-tf-listener) "map" "base_footprint" :timeout 2)

                     
