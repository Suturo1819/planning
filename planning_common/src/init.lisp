(in-package :plc)

(defun init-planning ()
  "Initialize all the interfaces from planning to other groups."
 ;;TODO CHECK AUF RUNNING
  (roslisp-utilities:startup-ros :name "planning_node" :anonymous nil)
  (cram-tf::init-tf)
  
  ;;Init all the action servers
  (pc::init-text-to-speech-action-client) ;; for text-to-speech
  (chll:init-nav-client)
  (chll::init-giskard-joints-action-client)

  ;; (chll:make-giskard-poses-action-client)
  ;; (pc:init-perception-subscriber)
  ;; TODO knowledge interface
  (roslisp:ros-info (plc) "All action server clients are set up.")) ;; for navigation
  
