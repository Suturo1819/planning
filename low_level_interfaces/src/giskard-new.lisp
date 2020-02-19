(in-package :lli)

(defvar *giskard-new-client* nil)

(defparameter *giskard-new-action-timeout* 300.0)
    
(defun init-giskard-new-client ()
  (unless (eq roslisp::*node-status* :running)
    (roslisp:start-ros-node "giskard-new-client"))
  
  (setf *giskard-new-client*
        (cram-simple-actionlib-client:make-simple-action-client
         'move-action
         "giskardpy/command" ;; topic
         "giskard_msgs/MoveAction"
         *giskard-new-action-timeout*
         :initialize-now T)) ;; ActionName
  (roslisp:ros-info (giskard-new-client) "Giskard new action client created."))

(defun get-giskard-new-action-client ()
  "returns the navigation action client. If none exists yet, one will be created."
  (when (null *giskard-new-client*)
    (init-giskard-new-client))
  *giskard-new-client*)

(defun make-giskard-new-action-goal (pose-stamped-eef tip-link root-link)
  "creates a giskard action goal. Expects a `pose' as goal in odom frame.
CARE: the action has the gripper in mind. "
  ;; make sure a node is already up and running, if not, one is initialized here.
 ;; (roslisp:ros-info (giskard-new-client) "make giskard action goal")
  ;; put the msgs together here:
 
  ;;(actionlib-lisp:make-action-goal-msg *giskard-new-client*
  (actionlib:make-action-goal ;;(lli::get-giskard-new-action-client)
      (cram-simple-actionlib-client::get-simple-action-client 'move-action)
    ;;:goal_id 3
    ;;:goal_id (actionlib::make-goal-id)
     
    :type 2
    :cmd_seq (vector (roslisp:make-message
              "giskard_msgs/MoveCmd"
              :constraints (vector) ;; empty
              :joint_constraints (vector) ;; empty
              
              :cartesian_constraints (vector (roslisp:make-message
                                              "giskard_msgs/CartesianConstraint"
                                              :type "CartesianPosition"
                                              :root_link root-link
                                              :tip_link tip-link
                                              :goal (cl-transforms-stamped:to-msg pose-stamped-eef))
                                             
                                             (roslisp:make-message
                                              "giskard_msgs/CartesianConstraint"
                                              :type "CartesianOrientationSlerp"
                                              :root_link root-link
                                              :tip_link tip-link
                                              :goal  (cl-transforms-stamped:to-msg pose-stamped-eef)))
              
              :collisions (vector (roslisp:make-message
                                   "giskard_msgs/CollisionEntry"
                                   :type 1
                                   :body_b "hsrb"))))));) 




(defvar ?debug nil)
(defun call-giskard-new-action (pose-stamped &optional
                                               (tip_link "hand_palm_link")
                                               (root_link "odom"))
  ;(setf ?debug (make-giskard-new-action-goal pose-stamped tip_link root_link))
  (multiple-value-bind (result status)
      ;;(actionlib:call-goal
      (cram-simple-actionlib-client::call-simple-action-client
       'move-action
       :action-goal (make-giskard-new-action-goal pose-stamped tip_link root_link)
       :action-timeout *giskard-new-action-timeout*)
    (roslisp:ros-info (giskard-new-action-client) "giskard action finished.")
    (values result status)))



;; (defun test-hand ()
;;   (call-giskard-new-action 
;;       (cl-tf:make-pose-stamped
;;        "hand_palm_link"
;;        0.0
;;        (cl-tf:make-3d-vector -0.02 0.0 0.0)
;;        (cl-tf:make-identity-rotation)) "hand_palm_link" "odom"))

;; (defun test-base ()
;;   (let* ((pose-stamped (cl-tf:make-pose-stamped
;;                        "map"
;;                        0.0
;;                        (cl-tf:make-3d-vector -0.02 0.82 0.0)
;;                        (cl-tf:make-identity-rotation)))
         
;;          (pose (cl-tf:pose-stamped->pose pose-stamped))
         
;;          (map-T-odom (planning-common::map-T-odom-pose pose))
         
;;          (odom-T-base-link (planning-common::stuff-T-stuff
;;                             map-T-odom
;;                             "odom" "base_link"))
         

;;          (final-pose (cl-tf:pose->pose-stamped
;;                       "base_link"
;;                       0.0
;;                       (cl-tf:transform->pose
;;                         ;; odom-T-map
;;                         (cl-tf:transform-inv
;;                          (cl-tf:transform*
;;                           (cl-tf:pose->transform pose) ;; map-T-map
;;                           (cl-tf:pose->transform map-T-odom) ;; map-T-odom
;;                           ;:(cl-tf:pose->transform  odom-T-base-link);;)
;;                           )
;;                         )))))
;;      final-pose
;;          (call-giskard-new-action final-pose "base_link" "odom")
;;     ))
