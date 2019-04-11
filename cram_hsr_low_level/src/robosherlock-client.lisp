(in-package chll)

(defvar *robosherlock-action-client* NIL)
(defparameter *robosherlock-action-timeout* 120.0 "in seconds")

(defun init-robosherlock-action-client ()
  (roslisp:ros-info (robosherlock-client)
                    "Creating robosherlock action client for server 'extract_object_infos'.")
  (setf *robosherlock-action-client*
        (actionlib:make-action-client "extract_object_infos" "suturo_perception_msgs/ExtractObjectInfoAction"))
  (loop until (actionlib:wait-for-server *robosherlock-action-client*
                                         *robosherlock-action-timeout*))
  (roslisp:ros-info (robosherlock-client)
                    "Robosherlock action client for ~a created." "'extract_object_infos'"))

(defun get-robosherlock-client ()
  (unless *robosherlock-action-client*
    (init-robosherlock-action-client))
  *robosherlock-action-client*)

(defun call-robosherlock-pipeline (&optional (regions-value '("robocup_table")) (visualisation-value 'False))
  (roslisp:ros-info (robosherlock-client) "Calling pipeline for regions ~{~a~^, ~}." regions-value)
  ;; actual call
  (actionlib:call-goal (get-robosherlock-client)
                       (actionlib:make-action-goal (get-robosherlock-client)
                         visualize visualisation-value
                         regions regions-value)
                       :timeout *robosherlock-action-timeout*
                       :result-timeout *robosherlock-action-timeout*))


#+old-perception-client-for-2-pipelines
(
(defvar *robosherlock-action-clients*
  (alexandria:alist-hash-table '((:table . NIL) (:shelf . NIL))))

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
  (roslisp:ros-info (robosherlock-client)
                    "Robosherlock action client for ~a created." pipeline-name))

(defun init-clients ()
  (init-robosherlock-action-client :table)
  (init-robosherlock-action-client :shelf))

(defun kill-robosherlock-clients ()
  (setf *robosherlock-action-clients*
        (alexandria:alist-hash-table '((:table . NIL) (:shelf . NIL)))))

;; (roslisp-utilities:register-ros-init-function init-clients)
(roslisp-utilities:register-ros-cleanup-function kill-robosherlock-clients)

(defun get-robosherlock-client (pipeline-name)
  (unless (gethash pipeline-name *robosherlock-action-clients*)
    (init-robosherlock-action-client pipeline-name))
  (gethash pipeline-name *robosherlock-action-clients*))

(defun call-robosherlock-pipeline (&optional (pipeline-name :table) (visualisation-value 'False))
  ;; key handling stuff
  (roslisp:ros-info (robosherlock-client) "Calling pipeline: ~a." pipeline-name)
  (let ((valid-pipelines (alexandria:hash-table-keys *robosherlock-action-clients*)))
    (unless (member pipeline-name valid-pipelines)
      (roslisp:ros-error (robosherlock-client)
                         "No pipeline with name ~a. ~a ~{~a~^, ~}." pipeline-name
                         "Valid pipelines are " valid-pipelines))
    ;; actual call
    (actionlib:call-goal (get-robosherlock-client pipeline-name)
                         (actionlib:make-action-goal (get-robosherlock-client pipeline-name)
                           visualisation visualisation-value)
                         :timeout 60 :result-timeout 60)))
)
