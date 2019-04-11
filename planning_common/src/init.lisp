(in-package :plc)

(defun init-planning ()
  "Initialize all the interfaces from planning to other groups."
  ;;TODO CHECK AUF RUNNING
  (unless (eq (roslisp:node-status) :RUNNING)
    (roslisp-utilities:startup-ros :name "planning_node" :anonymous nil))
  ;; (cram-tf::init-tf)
  
  ;;Init all the action servers
  (pc::init-text-to-speech-action-client) ;; for text-to-speech
  (chll:init-nav-client)
  (chll::init-move-head-action-client)
  (chll::init-giskard-joints-action-client)
  (chll:init-robosherlock-action-client :table)
  (chll:init-robosherlock-action-client :shelf)
  (chll::init-move-torso-action-client)

  ;; (chll:make-giskard-poses-action-client)
  ;; (pc:init-perception-subscriber)
  ;; TODO knowledge interface
  (roslisp:ros-info (init-planning-common) "All action clients are set up.")) ;; for navigation
  
(defun init-integration()
  (roslisp-utilities:startup-ros :name "planning_node" :anonymous nil)
  (print "init speech client")
  (pc::init-text-to-speech-action-client) ;; for text-to-speech
  (print "init navigation client")
  (chll:init-nav-client)
  (print "init moce-head client")
  (chll::init-move-head-action-client)
  (print "init giskard-joints")
  (chll::init-giskard-joints-action-client)
  (print "init move-torso client")
  (chll::init-move-torso-action-client))


