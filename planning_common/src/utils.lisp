(in-package :plc)

;;; TF ;;;
         
(defparameter *tf-listener* nil)

(defun get-tf-listener ()
  (unless *tf-listener*
    (setf *tf-listener* (make-instance 'cl-tf2:buffer-client))
    (handler-case
     (cl-tf2:lookup-transform *tf-listener* "map" "odom" :timeout 3)
     (CL-TRANSFORMS-STAMPED:TIMEOUT-ERROR
      () (roslisp:ros-warn (get-tf-listener) "tf-listener takes longer than 3 seconds to get odom in map."))))
  *tf-listener*)

(defun kill-tf-listener ()
  (setf *tf-listener* nil))

(roslisp-utilities:register-ros-cleanup-function kill-tf-listener)

;;; TRANSFORMS ;;;
(defun map-T-odom-pose (pose-map)
  (get-tf-listener)
  (let* ((map-T-odom (cl-tf2:lookup-transform (get-tf-listener) "map" "odom"))
         (pose-odom
           (cl-tf:transform->pose
            (cl-tf:transform*
             (cl-tf:transform-inv map-T-odom)
             (cl-tf:pose->transform pose-map)))))
    pose-odom))

(defun make-pose-stamped (x y euler-z &optional (frame-id "map"))
  (cl-tf:make-pose-stamped
                        frame-id
                        (roslisp::ros-time)
                        (cl-tf:make-3d-vector x y 0.0)
                        (cl-tf:euler->quaternion :ax 0.0 :ay 0.0 :az euler-z)))

;;; CLOSEST OBJECT ;;;
(defun frame-closest-to-robot (objects-list)
  ;; does not involve z-axis calculation
  (if objects-list
      (car (sort objects-list '<
                 :key (alexandria:compose
                       'cl-tf:v-norm
                       (lambda (trans) (cl-tf:copy-3d-vector trans :z 0))
                       'cl-tf:translation
                       (lambda (tf-name)
                         (cl-tf2:lookup-transform (get-tf-listener)
                                                 "base_footprint" tf-name :timeout 5)))))
      (roslisp:ros-warn (closest-object-pose-on-table) "There are no objects to investigate")))




