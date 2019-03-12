;;; Contains all the temporarily hacked poses so that they are all in one place
;;; and one file and one does not have to browse through the plans to find them.
;;; Alternatively, this can be used as an alternative.

(in-package :pexe)

(defparameter *tf-listener* nil)

(defun get-tf-listener ()
  (unless *tf-listener*
    (setf *tf-listener* (make-instance 'cl-tf:transform-listener))
    (handler-case
     (cl-tf:lookup-transform *tf-listener* "map" "odom" :timeout 3)
     (CL-TRANSFORMS-STAMPED:TIMEOUT-ERROR
      () (roslisp:ros-warn (get-tf-listener) "tf-listener takes longer than 3 seconds to get odom in map."))))
  *tf-listener*)

(defun kill-tf-listener ()
  (setf *tf-listener* nil))

(roslisp-utilities:register-ros-cleanup-function kill-tf-listener)

(defun go-to-room-center ()
  (chll::call-nav-action -0.991062045097 0.265686005354 3.1))

(defun go-to-table ()
  (chll::call-nav-action -0.270028978586 -0.0241730213165 0))

(defun go-closer-to-table ()
  (chll::call-nav-action 0.0915691405535 0.0654886364937 0))

(defun go-to-shelf ()
  (chll::call-nav-action -0.334310114384 0.00131261348724 -1.6))

(defun navigation-tests ()
   ;; move close to the shelf and look at it
  (go-to-shelf)
  ;; move to the middle of the room
  (go-to-room-center))


;; TODO test this
;; test new pose
(defun grasp-test ()
  (cram-hsr-low-level::call-giskard-joints-grasping-action
   (grasp-obj-from-floor)
       (cl-tf:transform->pose 
        (cl-tf:transform*
         (cl-tf:transform-inv
          (cram-tf::lookup-transform cram-tf::*transformer* "map" "odom"))
         (grasp-obj-from-floor)))
       0.4
       0.1
       0.26
       "grip"))

(defun place-test ()
  (cram-hsr-low-level::call-giskard-joints-grasping-action
   (place-obj-on-table)
       (cl-tf:transform->pose 
        (cl-tf:transform*
         (cl-tf:transform-inv
          (cram-tf::lookup-transform cram-tf::*transformer* "map" "odom"))
         (place-obj-on-table)))
       0.4
       0.1
       0.26
       "place"))

(defun place-obj-on-table ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector 0.691284537315 0.040323138237 0.73)
   (cl-tf:make-identity-rotation)))

(defun grasp-obj-from-table ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector 0.76 0.0029 0.9)
   (cl-tf:make-identity-rotation)))

(defun grasp-obj-from-floor ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector 0.494331806898 -0.0414100885391 0.08)
   (cl-tf:make-identity-rotation)))


    
(defun closest-object-pose-on-table ()
  (let ((table-objects (chll:prolog-table-objects)))
    (if table-objects 
        (cl-tf:lookup-transform
         (get-tf-listener) 
         "map"
         (car (sort table-objects '<
                   :key (alexandria:compose 'cl-tf:v-norm
                                            (lambda (trans) (cl-tf:copy-3d-vector trans :z 0))
                                            'cl-tf:translation
                                            (lambda (tf-name)
                                              (cl-tf:lookup-transform (get-tf-listener) "base_footprint" tf-name :timeout 1))))))
        (roslisp:ros-warn (closest-object-pose-on-table) "There are no objects to investigate"))))
    
