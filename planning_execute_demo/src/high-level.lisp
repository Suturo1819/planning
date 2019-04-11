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
    (plc::say "Now Perceiving")
    (plc::move-head :perceive)
    (chll:call-robosherlock-pipeline (vector "robocup_table"))
    (sleep 10.0)
    (plc::say "done Perceiving")
    (plc::go-to (plc::pose-infront-table :manipulation T) "table")
    (plc::grasp-object "FRONT")
    (plc::move-head :safe)
    ;;(plc::perceive-table)
    (plc::go-to (plc::pose-infront-shelf :manipulation T) "shelf")
    (plc::place-object "FRONT" "1")
    ))


(defun execute-demo-proj()
  (plc::with-hsr-proj-process-modules
      (plc::go-to (plc::pose-infront-shelf) "shelf")))
