(in-package chll)

(alexandria:define-constant +knowrob-prefix+ "http://knowrob.org/kb/knowrob.owl#" :test 'string=)

(defun knowrob-symbol->string (knowrob-symbol)
  (subseq (write-to-string knowrob-symbol)
          (1+ (position #\# (write-to-string knowrob-symbol)))
          (- (length (write-to-string knowrob-symbol)) 3)))

(defun prolog-table-objects ()
  (prolog-objects-around-pose (cl-tf:make-pose (cl-tf:make-3d-vector 0.7 0 0.8)
                                               (cl-tf:make-identity-rotation))))

(defun prolog-objects-around-pose (pose &optional (threshold 0.3))
  (handler-case
      (mapcar (alexandria:compose 'knowrob-symbol->string 'cdr (alexandria:curry 'assoc '|?Instance|))
              (cut:force-ll
               (with-slots (cl-tf:x cl-tf:y cl-tf:z) (cl-tf:origin pose)
                 (json-prolog:prolog-simple
                  (format nil "~a~a~a"
                          "belief_existing_objects(Objectlist),"
                          "member(Instance,Objectlist),"
                          (apply 'format nil
                                 "belief_existing_object_at(_, [map, _, [~a, ~a, ~a], [0, 0, 0, 1]], ~a, Instance)"
                                 (mapcar (alexandria:rcurry 'coerce 'short-float) 
                                         (list cl-tf:x cl-tf:y cl-tf:z threshold))))
                  :package :chll))))
    (simple-error ()
      (roslisp:ros-warn (prolog-table-objects) "Json prolog client error. Query invalid."))
    (SB-KERNEL:CASE-FAILURE ()
      (roslisp:ros-warn (prolog-table-objects) "Startup your rosnode first"))
    (ROSLISP::ROS-RPC-ERROR ()
      (roslisp:ros-warn (prolog-table-objects) "Is the json_prolog server running?"))))
