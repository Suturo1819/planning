(in-package :pexe)


(defparameter *shelf*
  (cl-tf:make-pose-stamped
   "map"
   (roslisp:ros-time)
   (cl-tf:make-3d-vector -0.5697101354598999d0 0.39473283290863037d0 0.0d0)
   (cl-tf:make-quaternion 0.0d0 0.0d0 -0.7173560857772827d0 0.6967067122459412d0)))


(defun execute-demo()
  (plc::with-hsr-process-modules
    ;;(plc::go-to (plc::pose-infront-shelf :manipulation T) "shelf")
    ;;(plc::grasp-object)
    ;;(plc::look :safe)
    ;;(plc::say "hello")
    ;;(plc::perceive-table)
    ))


(defun execute-demo-proj()
  (plc::with-hsr-proj-process-modules
      (plc::go-to (plc::pose-infront-shelf) "shelf")))
