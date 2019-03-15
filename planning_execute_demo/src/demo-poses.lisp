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
   (grasp-from-shelf)
       (cl-tf:transform->pose 
        (cl-tf:transform*
         (cl-tf:transform-inv
          (cram-tf::lookup-transform cram-tf::*transformer* "map" "odom"))
         (grasp-from-shelf)))
       0.4
       0.08
       0.26
       "grip"))


(defun place-test ()
  (cram-hsr-low-level::call-giskard-joints-grasping-action
   (grasp-from-shelf)
       (cl-tf:transform->pose 
        (cl-tf:transform*
         (cl-tf:transform-inv
          (cram-tf::lookup-transform cram-tf::*transformer* "map" "odom"))
         (grasp-from-shelf)))
       0.4
       0.07
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

(defun grasp-from-shelf ()
  (cl-tf:make-transform
   (cl-tf:make-3d-vector -0.272928059101 -0.656896412373 0.85)
   (cl-tf:make-identity-rotation)))



