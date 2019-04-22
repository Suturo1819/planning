(in-package :chll)

(alexandria:define-constant +knowrob-prefix+
  "http://knowrob.org/kb/knowrob.owl#" :test 'string=)
(alexandria:define-constant +hsr-objects-prefix+
  "http://www.semanticweb.org/suturo/ontologies/2018/10/objects#" :test 'string=)
(alexandria:define-constant +robocup-prefix+
  "http://knowrob.org/kb/robocup.owl#" :test 'string=)
(alexandria:define-constant +srld-prefix+
  "http://knowrob.org/kb/srdl2-comp.owl#" :test 'string=)


(defmacro with-safe-prolog (&body body)
  `(handler-case
      ,@body
     (simple-error ()
       (roslisp:ros-error (json-prolog-client) "Json prolog client error. Check your query again."))
     (SB-KERNEL:CASE-FAILURE ()
       (roslisp:ros-error (json-prolog-client) "Startup your rosnode first"))
     (ROSLISP::ROS-RPC-ERROR ()
       (roslisp:ros-error (json-prolog-client) "Is the json_prolog server running?"))))


(defun knowrob-symbol->string (knowrob-symbol) 
  (string-trim "'" (subseq (write-to-string knowrob-symbol)
                           (1+ (position #\# (write-to-string knowrob-symbol)))
                           (- (length (write-to-string knowrob-symbol)) 2))))


(defun object-name->class (object-name)
  (subseq object-name 0 (position #\_ object-name)))


(defun prolog-table-objects ()
  ;; gives the list of all objects on the table
  (roslisp:ros-info (json-prolog-client) "Getting objects on the table.")
  (let* ((raw-response (with-safe-prolog
                         (json-prolog:prolog `(and ("table_surface" ?table)
                                                   ("objects_on_surface" ?instances ?table))
                                             :package :chll)))
         (instances (if (eq raw-response 1)  NIL (cdr (assoc '?instances (cut:lazy-car raw-response))))))
    (if instances
        (mapcar #'knowrob-symbol->string instances)
        (roslisp:ros-warn (json-prolog-client) "Query didn't reach any solution."))))


(defun prolog-object-goal (object-name)
  ;; gives the goal shelf (tf-frame) for an object name
  (roslisp:ros-info (json-prolog-client) "Getting goal floor for object ~a." object-name)
  (let* ((knowrob-name (format nil "~a~a" +hsr-objects-prefix+ object-name))
         (rdf-urdf (format nil "~aurdfName" +srld-prefix+))
         (raw-response (with-safe-prolog
                         (json-prolog:prolog `(and ("object_goal_surface" ,knowrob-name ?surface)
                                                   ("rdf_has_prolog" ?surface ,rdf-urdf ?urdfname))
                                             :package :chll)))
         (surface (if (eq raw-response 1) NIL (cdr (assoc '?urdfname (cut:lazy-car raw-response))))))
    (if surface
        (format nil "environment/~a" (string-trim "'" surface))
        (roslisp:ros-warn (json-prolog-client) "Query didn't reach any solution."))))

(defun prolog-object-goal-pose (object-name)
  ;; gives the goal shelf (tf-frame) for an object name
  (roslisp:ros-info (json-prolog-client) "Getting goal floor for object ~a." object-name)
  (let* ((knowrob-name (format nil "~a~a" +hsr-objects-prefix+ object-name))
         (raw-response (with-safe-prolog
                         (json-prolog:prolog-1 `("object_goal_pose" ,knowrob-name ?pose)
                                             :package :chll)))
         (goal-pose (if (eq raw-response 1) NIL (cdr (assoc '?pose (cut:lazy-car raw-response))))))
    (or goal-pose
        (roslisp:ros-warn (json-prolog-client) "Query didn't reach any solution."))))

(defun prolog-all-objects-in-shelf ()
  ;; gives the goal shelf (tf-frame) for an object name
  (roslisp:ros-info (json-prolog-client) "Getting all objects in shelf.")
  (let* ((raw-response (with-safe-prolog
                         (json-prolog:prolog `(and ("all_objects_in_whole_shelf" ?instances)
                                                   ("member" ?instance ?instances))
                                             :package :chll)))
         (instances (if (eq raw-response 1)  NIL (cdr (assoc '?instances (cut:lazy-car raw-response))))))
    (if instances
        (mapcar #'knowrob-symbol->string instances)
        (roslisp:ros-warn (json-prolog-client) "Query didn't reach any solution."))))

(defun prolog-object-dimensions (object-name)
  ;; returns the dimensions of an object as list with '(depth width height)
  (roslisp:ros-info (json-prolog-client) "Getting dimensions for object ~a." object-name)
  (let* ((knowrob-name (format nil "~a~a" +hsr-objects-prefix+ object-name))
         (dimension-term (format nil "~aboundingBoxSize" +knowrob-prefix+))
         (raw-response (with-safe-prolog
                         (json-prolog:prolog `("rdf_has_prolog" ,knowrob-name ,dimension-term ?dim)
                                             :package :chll)))
         (dimensions (if (eq raw-response 1) NIL (cdr (assoc '?dim (cut:lazy-car raw-response))))))
    (or dimensions
        (roslisp:ros-warn (json-prolog-client) "Query didn't reach any solution."))))

(defun prolog-object-in-gripper ()
  ;; returns the dimensions of an object as list with '(depth width height)
  (roslisp:ros-info (json-prolog-client) "Getting object in gripper.")
  (let* ((raw-response (with-safe-prolog
                         (json-prolog:prolog-1 `(and ("gripper" ?gripper)
                                                     ("objects_on_surface" ?instances ?gripper)
                                                     ("member" ?instance ?instances))
                                               :package :chll)))
         (instance (if (eq raw-response 1) NIL (cdr (assoc '?instance (cut:lazy-car raw-response))))))
    (if instance
        (knowrob-symbol->string instance)
        (roslisp:ros-warn (json-prolog-client) "Query didn't reach any solution."))))



#+not-used
(defun prolog-objects-around-pose (pose &optional (threshold 0.3))
  (handler-case
      (mapcar (alexandria:compose 'knowrob-symbol->string 'cdr (alexandria:curry 'assoc '|?Instance|))
              (cut:force-ll
               (with-slots (cl-tf:x cl-tf:y cl-tf:z) (cl-tf:origin pose)
                 (json-prolog:prolog-simple
                  (apply 'format nil
                                 "hsr_existing_object_at(_, [map, _, [~a, ~a, ~a], [0, 0, 0, 1]], ~a, Instance)"
                                 (mapcar (alexandria:rcurry 'coerce 'short-float) 
                                         (list cl-tf:x cl-tf:y cl-tf:z threshold)))
                  :package :chll))))
    (simple-error ()
      (roslisp:ros-warn (prolog-table-objects) "Json prolog client error. Query invalid."))
    (SB-KERNEL:CASE-FAILURE ()
      (roslisp:ros-warn (prolog-table-objects) "Startup your rosnode first"))
    (ROSLISP::ROS-RPC-ERROR ()
      (roslisp:ros-warn (prolog-table-objects) "Is the json_prolog server running?"))))

