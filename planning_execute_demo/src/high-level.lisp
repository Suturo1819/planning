(in-package :pexe)


;;before first time (plc::init-planning)
(defun demo-v4r-small (&key (robosherlock? :true))
  (plc::with-hsr-process-modules
    (drive-to-all-poses)
    (when (eq robosherlock? :true)
      (call-robosherlock-extract-msgs)
    )))




;;all the hardcoded poses, you can add more z= z-euler-angle
;;take a look in hsr_navigation/z-euler-orientation-of-hsr.png
(defparameter *spot-between-couch-shelf* '(-0.7 0.4 0)) ;table -1
(defparameter *spot-between-table-pc* '(-0.7 0.1 0)) ;;table-1
(defparameter *spot-table-1* '(0 0.1 0));;table 1
(defparameter *spot-table-2* '(0.5 0.1 0)) ;;right.down
(defparameter *spot-table-3-near-door* '(1.2 0.1 -1.5)) ;;table-1
(defparameter *spot-table-4* '(1.2 -0.8 -1.5)) ;;right-down
(defparameter *spot-table-5-near-wall* '(1.1 -1.5 3)) ;;table-2
(defparameter *spot-home-position* '(0.3 -1.5 1.5)) ;;front



;;driving to all poses you can add new poses here
;;new keys (e.g :table-1 :table-2 is in planning_common/src/process-modules.lisp
(defun drive-to-all-poses ()
  (loop for elem in (list `(,*spot-between-couch-shelf* :table-1)
                          `(,*spot-between-table-pc* :table-1)
                          `(,*spot-table-1* :table-1)
                          `(,*spot-table-2* :right-down-3)
                       `(,*spot-table-3-near-door* :table-1)
                       `(,*spot-table-4* :right-down-3)
                       `(,*spot-table-5-near-wall* :table-2)
                       `(,*spot-home-position* :table-3))
        do
           (cram-language:par(drive-to (first elem))
           ;;moving the head to the right very down
           ;;you can choose, right-down-1/2/3, left-down-1/2/3
           ;;or you can let it out complety
           (plc::move-head (second elem)))))

;;helper function to drive
(defun drive-to (pose-as-list)
  (chll::call-nav-action  (first pose-as-list) (second pose-as-list) (third pose-as-list)))

;;calling the robosherlock action client
(defun call-robosherlock-extract-msgs ()
  ;;init robosherlock action client look down for the innit function or left click + . 
  (roslisp:ros-info (init-clients) "init robosherlock action client")
  (init-robosherlock-action-client)

  ;;call-robosherlock-pipeline is the actual call
  ;;with-fields lets get a field from the msgs and we want the field = detectiondata
  (roslisp:with-fields (detectiondata) (call-robosherlock-pipeline)
    
    ;; detectiondata))

    ;; dectentiondata can now be used to get extracted more
    ;; from detectiondata we want depth heigh pose width
    ;; we saving those in a local variable under let
    
    (roslisp:with-fields (depth height pose width)  (aref detectiondata 0)
      (let* ((perception-pose pose)
             (?width width)
             (?depth depth)
             (?weight 1.2)
             (?height height)
             (?pose  (roslisp:with-fields (pose) perception-pose
                       (roslisp:with-fields (position orientation) pose
                         (cl-tf:make-pose (cl-tf:from-msg position)
                                          (cl-tf:from-msg orientation))))))
        (format t "~%robosherlock msgs width: ~a
robosherlock msgs depth: ~a
robosherlock msgs weight: ~a
robosherlock msgs height: ~a
robosherlock msgs pose:
~a " ?width ?depth ?weight ?height ?pose)))
    detectiondata))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Connecting to ROBOSHERLOCK ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;variables to save the client
(defvar *robosherlock-action-client* NIL)
(defparameter *robosherlock-action-timeout* 120.0 "in seconds")
(defvar *robosherlock-door-client* NIL)

;;for every action server the same -> just change the names and types
(defun init-robosherlock-action-client ()
  (roslisp:ros-info (robosherlock-client)
                    "Creating robosherlock action client for server 'extract_object_infos'.")
  (setf *robosherlock-action-client*
        (actionlib:make-action-client "extract_object_infos"
                                      "suturo_perception_msgs/ExtractObjectInfoAction"))
  (loop until (actionlib:wait-for-server *robosherlock-action-client*
                                         *robosherlock-action-timeout*))
  (roslisp:ros-info (robosherlock-client)
                    "Robosherlock action client for ~a created." "'extract_object_infos'"))

;;checking if a action-client already exist
(defun get-robosherlock-client ()
  (unless *robosherlock-action-client*
    (init-robosherlock-action-client))
  *robosherlock-action-client*)

;;calling robosherlock pipeline (Action call) depending on the server you need to change fields
(defun call-robosherlock-pipeline (&optional
                                     (regions-value (vector "robocup_table"))
                                     (visualisation-value 'False))
  (roslisp:ros-info (robosherlock-client) "Calling pipeline for regions ~a." regions-value)
  ;; actual call
  (format t "vector: ~a" regions-value)
  (actionlib:call-goal (chll::get-robosherlock-client)
                       (roslisp:make-message
                        "suturo_perception_msgs/ExtractObjectInfoGoal"
                        visualize visualisation-value
                        regions regions-value)
                       :timeout *robosherlock-action-timeout*
                       :result-timeout *robosherlock-action-timeout*))


         

