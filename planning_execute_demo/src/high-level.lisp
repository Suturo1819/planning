(in-package :pexe)


(defparameter *shelf*
  (cl-tf:make-pose-stamped
   "map"
   (roslisp:ros-time)
   (cl-tf:make-3d-vector -0.5697101354598999d0 0.39473283290863037d0 0.0d0)
   (cl-tf:make-quaternion 0.0d0 0.0d0 -0.7173560857772827d0 0.6967067122459412d0)))


(defun execute-demo()
  (plc::with-hsr-process-modules
    ;; GO and PERCEIVE the  SHELF
    (plc::go-to (plc::pose-infront-shelf :manipulation T) "shelf")
    (plc::perceive-shelf)
    
    ;; GO and PERCEIVE the TABLE
    (plc::go-to (plc::pose-infront-table :manipulation NIL) "table")    
    (plc::perceive-table)   
    
    ;; GRASPING OBJECT
    ;; TODO LOOP this for all available objects on the table
    (loop while (not (eq (chll::prolog-table-objects) 1)) do
      (plc::go-to (plc::pose-infront-table :manipulation T) "table")
      (plc::grasp-object)

    ;; PLACING OBJECT
      (plc::go-to (plc::pose-infront-shelf :manipulation T) "shelf")
      (plc::place-object "FRONT" "2"))))


(defun execute-demo-proj()
  (plc::with-hsr-proj-process-modules
      (plc::go-to (plc::pose-infront-shelf) "shelf")))
