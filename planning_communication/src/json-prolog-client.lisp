(in-package pc)

(alexandria:define-constant +knowrob-prefix+ "http://knowrob.org/kb/knowrob.owl#" :test 'string=)

(defun prolog-table-objects ()
  (prolog-objects-around-pose (cl-tf:make-pose (cl-tf:make-3d-vector 1 0 0.8)
                                               (cl-tf:make-identity-rotation))))

(defun prolog-objects-around-pose (pose &optional (threshold 0.3))
  (handler-case
      (with-slots (cl-tf:x cl-tf:y cl-tf:z) (cl-tf:origin pose)
        (json-prolog:prolog-simple
         (apply 'format nil
                "object_at(_, [map, _, [~a, ~a, ~a], [0, 0, 0, 1]], ~a, INST)"
                (mapcar (alexandria:rcurry 'coerce 'short-float) 
                        (list cl-tf:x cl-tf:y cl-tf:z threshold)))))
    (simple-error () (roslisp:ros-warn (prolog-table-objects) "No objects found"))))


(defun dummy-test ()
  "roslaunch object_state object_state.launch"
  (let ((mypose (cl-tf:make-pose (cl-tf:make-3d-vector 1 0 0.8)
                                 (cl-tf:make-identity-rotation))))
    (handler-case
        (and (json-prolog:prolog-simple "spawn_on_table")
             (prolog-objects-around-pose mypose))
    (simple-error () 
      (roslisp:ros-warn (dummy-test) "Something went wrong")))))
