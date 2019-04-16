(in-package :pexe)


(defparameter *shelf*
  (cl-tf:make-pose-stamped
   "map"
   (roslisp:ros-time)
   (cl-tf:make-3d-vector -0.5697101354598999d0 0.39473283290863037d0 0.0d0)
   (cl-tf:make-quaternion 0.0d0 0.0d0 -0.7173560857772827d0 0.6967067122459412d0)))


(defun execute-demo()
  (plc::with-hsr-process-modules
    (plc::go-to (plc::pose-infront-table :manipulation NIL) "table")
    (plc::say "Now, Perceiving")
    (plc::move-head :perceive)
    (chll:call-robosherlock-pipeline (vector "robocup_table"))
    (sleep 10.0)
    (plc::say "done, Perceiving")
    (plc::go-to (plc::pose-infront-table :manipulation T) "table")
    
    ;;TODO DO THIS SOMWHERE ELSE QUCIK HACK VANESSA
    (let* ((all-table-objects (chll:prolog-table-objects))
           (closest-object (plc:frame-closest-to-robot all-table-objects))
           (closest-object-pose (cl-tf2:lookup-transform (plc:get-tf-listener)
                                                         "map" closest-object :timeout 5))
           (object-class (chll:object-name->class closest-object))
           (pose (cl-tf:make-pose (cl-tf:translation closest-object-pose)
                                   (cl-tf:rotation closest-object-pose))))
      (planning-communication::publish-marker-pose pose))
    (plc::grasp-object "FRONT")
    (plc::move-head :safe)
    ;;(plc::perceive-table)
    (plc::go-to (plc::pose-infront-shelf :manipulation T) "shelf")
    
     ;;TODO DO THIS SOMWHERE ELSE QUCIK HACK VANESSA
     (let* ((pose-in-shelf (cl-tf2:lookup-transform (plc:get-tf-listener)
                                                   "map" (concatenate
                                                          'String
                                                          "environment/shelf_floor_"
                                                          "1" "_piece") :timeout 5))
           (pose (cl-tf:make-pose (cl-tf:translation pose-in-shelf)
                                  (cl-tf:rotation pose-in-shelf))))
       (planning-communication::publish-marker-pose pose))
    
    (plc::place-object "FRONT" "1"))
   (plc::with-hsr-process-modules
    (plc::go-to (plc::pose-infront-table :manipulation NIL) "table")
    (plc::say "Now, Perceiving")
    (plc::move-head :perceive)
    (chll:call-robosherlock-pipeline (vector "robocup_table"))
    (sleep 10.0)
    (plc::say "done, Perceiving")
     (plc::go-to (plc::pose-infront-table :manipulation T) "table")
     ;;TODO DO THIS SOMWHERE ELSE QUCIK HACK VANESSA
    (let* ((all-table-objects (chll:prolog-table-objects))
           (closest-object (plc:frame-closest-to-robot all-table-objects))
           (closest-object-pose (cl-tf2:lookup-transform (plc:get-tf-listener)
                                                         "map" closest-object :timeout 5))
           (object-class (chll:object-name->class closest-object))
           (pose (cl-tf:make-pose (cl-tf:translation closest-object-pose)
                                   (cl-tf:rotation closest-object-pose))))
      (planning-communication::publish-marker-pose pose))
    (plc::grasp-object "FRONT")
    (plc::move-head :safe)
    ;;(plc::perceive-table)
     (plc::go-to (plc::pose-infront-shelf :manipulation T) "shelf")
       ;;TODO DO THIS SOMWHERE ELSE QUCIK HACK VANESSA
     (let* ((pose-in-shelf (cl-tf2:lookup-transform (plc:get-tf-listener)
                                                   "map" (concatenate
                                                          'String
                                                          "environment/shelf_floor_"
                                                          "1" "_piece") :timeout 5))
           (pose (cl-tf:make-pose (cl-tf:translation pose-in-shelf)
                                  (cl-tf:rotation pose-in-shelf))))
       (planning-communication::publish-marker-pose pose))
    (plc::place-object "FRONT" "2")
    ))


(defun execute-demo-proj()
  (plc::with-hsr-proj-process-modules
      (plc::go-to (plc::pose-infront-shelf) "shelf")))
