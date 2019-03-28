(in-package chll)

(defvar *robosherlock-action-clients*
  (alexandria:alist-hash-table '((:table . NIL) (:shelf . NIL))))

(defparameter *robosherlock-action-timeout* 300.0 "in seconds")

(defun init-robosherlock-action-client (pipeline-name)
  ;; pipeline-name must be either :table or :shelf
  (let ((server-name (format nil "hsr_perception_~a"
                             (string-downcase (string pipeline-name))))
        (action-name (format nil "suturo_perception_msgs/Perceive~aAction"
                             (string-capitalize (string pipeline-name)))))
    (setf (gethash pipeline-name *robosherlock-action-clients*)
          (actionlib:make-action-client server-name action-name))
    (loop until
          (actionlib:wait-for-server (gethash pipeline-name *robosherlock-action-clients*)
                                     *robosherlock-action-timeout*)))
  (roslisp:ros-info (robosherlock-action-client)
                    "Robosherlock action client for ~a created." pipeline-name))

(defun kill-robosherlock-clients ()
  (setf *robosherlock-action-clients*
        (alexandria:alist-hash-table '((:table . NIL) (:shelf . NIL)))))

(roslisp-utilities:register-ros-cleanup-function kill-robosherlock-clients)

(defun get-robosherlock-client (pipeline-name)
  (unless (gethash pipeline-name *robosherlock-action-clients*)
    (init-robosherlock-action-client pipeline-name))
  (gethash pipeline-name *robosherlock-action-clients*))

(defun call-robosherlock-pipeline (&optional (pipeline-name :table) (visualisation-value 'False))
  ;; key handling stuff
  (let ((valid-pipelines (alexandria:hash-table-keys *robosherlock-action-clients*)))
    (unless (member pipeline-name valid-pipelines)
      (roslisp:ros-error (call-robosherlock-pipeline)
                         "No pipeline with name ~a. ~a ~{~a~^, ~}." pipeline-name
                         "Valid pipelines are " valid-pipelines))
    ;; actual call
    (actionlib:call-goal (get-robosherlock-client pipeline-name)
                         (actionlib:make-action-goal (get-robosherlock-client pipeline-name)
                           visualisation visualisation-value))))
