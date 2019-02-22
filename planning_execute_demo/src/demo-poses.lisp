;;; Contains all the temporarily hacked poses so that they are all in one place
;;; and one file and one does not have to browse through the plans to find them.
;;; Alternatively, this can be used as an alternative.

(in-package :pexe)

(defun go-to-room-center ()
  (chll::call-nav-action -0.0844728946686 0.0405520200729 0.0))

(defun go-to-little-table ()
  (chll::call-nav-action -0.0844728946686 0.0405520200729 3))

(defun go-closer-to-little-table ()
  (chll::call-nav-action -0.4 0.0157970905304 3))

(defun go-to-shelf ()
  (chll::call-nav-action -0.0238773822784 1.01167118549 1.5))

(defun navigation-tests ()
   ;; move close to the shelf and look at it
  (go-to-shelf)
  ;; move to the middle of the room
  (go-to-room-center))
