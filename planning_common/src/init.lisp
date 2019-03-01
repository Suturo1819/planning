(in-package :plc)

(defun init-planning (&rest ignore-clients)
  "Initialize all the interfaces from planning to other groups."
  ;;TODO CHECK AUF RUNNING
  (unless (eq (roslisp:node-status) :RUNNING)
    (roslisp-utilities:startup-ros :name "planning_node" :anonymous nil))
  ;; (cram-tf::init-tf)
  
  ;;Init all the action servers
  (pc::init-text-to-speech-action-client) ;; for text-to-speech
  (chll:init-nav-client)
  (unless (member 'manipulation ignore-clients)
    (chll::init-giskard-joints-action-client))

  ;; (chll:make-giskard-poses-action-client)
  ;; (pc:init-perception-subscriber)
  ;; TODO knowledge interface
  (roslisp:ros-info (plc) "All action clients are set up.")) ;; for navigation
  
