(in-package :chll)

(defun make-test-object-pose (x y z)
  ;; TODO: include orientation in params
  (cl-tf:make-pose (cl-tf:make-3d-vector x y z)
                   (cl-tf:make-identity-rotation)))

(defun make-test-pose-stamped (link-name x y z)
  ;; TODO: include orientation in params
  (cl-tf:make-pose-stamped link-name
                           (roslisp:ros-time)
                           (cl-tf:make-3d-vector x y z)
                           (cl-tf:make-identity-rotation)))

(defun make-test-single-move-pose (link-name x y z)
  (list (make-test-pose-stamped link-name x y z)))

(defun make-test-single-move-joint ())

(defun make-test-move-poses ())

(defun make-test-move-joints ())

(defun test-single-move-pose (&optional (link-name "wrist-roll-link")
                                (x 0.2)
                                (y 0)
                                (z 0.4))
  (call-giskard-poses-move-action (make-test-single-move-pose link-name x y z)))

(defun test-single-move-joint ())

(defun test-move-poses ())

(defun test-move-joints ())

(defun test-grip-pose ())

(defun test-grip-joint ())
