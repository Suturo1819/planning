;;; Contains all the temporarily hacked poses so that they are all in one place
;;; and one file and one does not have to browse through the plans to find them.
;;; Alternatively, this can be used as an alternative.

(in-package :pexe)
;;; NOTE Everythign noted here should be resolved automatically at run time in the future.


(defun go-to-room-center ()
  (chll::call-nav-action  -0.991062045097 0.265686005354 3.1))

(defun go-to-table ()
  (chll::call-nav-action  -0.270028978586 -0.0241730213165 0))

(defun go-closer-to-table ()
  (chll::call-nav-action  0.0915691405535 0.0654886364937 0))

(defun go-to-shelf ()
  (chll::call-nav-action  -0.56971013546  0.394732832909 -1.6))




;; TODO test this
;; test new pose
(defun grasp-test ()
  (cram-hsr-low-level::call-giskard-joints-grasping-action
   (grasp-from-shelf-high)
       (cl-tf:transform->pose 
        (cl-tf:transform*
         (cl-tf:transform-inv
          (cram-tf::lookup-transform cram-tf::*transformer* "map" "odom"))
         (grasp-from-shelf-high)))
         0.4    ;; 0.4    ;;  0.4
         0.08    ;;  0.085  ;; 0.10   ;;  0.08
         0.26   ;; 0.085  ;; 0.21   ;;  0.26
       "grip"))


(defun place-test ()
  (cram-hsr-low-level::call-giskard-joints-grasping-action
   (grasp-from-shelf-very-low)
       (cl-tf:transform->pose 
        (cl-tf:transform*
         (cl-tf:transform-inv
          (cram-tf::lookup-transform cram-tf::*transformer* "map" "odom"))
         (grasp-from-shelf-very-low)))
       0.4
       0.07
       0.26
       "place"))

(defun grasp-test-top ()
  (cram-hsr-low-level::call-giskard-joints-grasping-action
   (grasp-obj-from-table)
       (cl-tf:transform->pose 
        (cl-tf:transform*
         (cl-tf:transform-inv
          (cram-tf::lookup-transform cram-tf::*transformer* "map" "odom"))
         (grasp-obj-from-table)))
         0.4    ;; 0.4    ;;  0.4
         0.055    ;;  0.085  ;; 0.10   ;;  0.08
         0.195   ;; 0.085  ;; 0.21   ;;  0.26
       "grip"))

(defun place-obj-on-table ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector 0.691284537315 0.040323138237 0.73)
   (cl-tf:make-identity-rotation)))

(defun grasp-obj-from-table ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector 0.76 0.0029 0.83) ;; hight table + half obj.
   (cl-tf:make-identity-rotation)))

(defun grasp-obj-from-floor ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector 0.494331806898
                         -0.0414100885391
                         0.08)
   (cl-tf:make-identity-rotation)))

(defun grasp-from-shelf-middle ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector -0.272928059101
                         -0.656896412373
                         0.85)
   (cl-tf:make-identity-rotation)))

(defun grasp-from-shelf-very-low ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector -0.325987935066
                         -0.608862876892
                         0.07)
   (cl-tf:make-identity-rotation)))

(defun grasp-from-shelf-low ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector -0.325987935066
                         -0.608862876892
                         0.42)
   (cl-tf:make-identity-rotation)))

(defun place-on-shelf-high ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector -0.325987935066
                         -0.608862876892
                         1.16)
   (cl-tf:make-identity-rotation)))

(defun grasp-from-shelf-high ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector -0.325987935066
                         -0.608862876892
                         1.29)
   (cl-tf:make-identity-rotation)))

(defun top-grasp-floor ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector 0.293501168489
                         0.0614272356033
                         0.195)
   (cl-tf:make-identity-rotation)))

;;; testing ;;;
(defparameter *test-pose*
  (cl-tf::make-pose-stamped
   "map"
   (roslisp:ros-time)
   (cl-tf:make-3d-vector -0.270028978586 -0.0241730213165 0.0)
   (cl-tf:euler->quaternion :ax 0.0 :ay 0.0 :az 0.0)))

(defparameter *test-pose2*
  (cl-tf::make-pose-stamped
   "map"
   (roslisp:ros-time)
   (cl-tf:make-3d-vector 0.0915691405535 0.065488636493 0.0)
   (cl-tf:euler->quaternion :ax 0.0 :ay 0.0 :az 0.0)))
