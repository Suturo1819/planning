(in-package :plc)

;;launch ros node first with:
;; (roslisp-utilities:startup-ros :name "planning_node" :anonymous nil)

(defparameter *poses-list* (list
                            (make-pose-stamped -1.63 0.005 1.5)
                            (make-pose-stamped -1.19 0.98 1.5)
                            (make-pose-stamped -0.97 1.99 1.5)
                            (make-pose-stamped -0.98 2.99 1.5)
                            (make-pose-stamped -0.58 3.96 1.5)
                            (make-pose-stamped -0.29 4.96 0.8)
                            (make-pose-stamped -0.18 6.13 0.0)))


(defun inspection ()
  (chll::init-nav-client)
  (mapcar (lambda (pose-stamped)
            (chll::call-nav-action-ps pose-stamped))
          *poses-list*))

(defun viz-inspection ()
  (pc::get-marker-publisher)
  (mapcar (lambda (pose-stamped)
            (planning-communication::publish-marker-pose pose-stamped :g 1.0)
            (sleep 2.0))
          *poses-list*))


(defun make-pose-stamped (x y zeuler)
  (cl-tf:make-pose-stamped
   "map"
   (roslisp::ros-time)
   (cl-tf:make-3d-vector x y 0.0)
   (cl-tf:euler->quaternion :ax 0.0 :ay 0.0 :az zeuler)))

