(in-package :plc)

(defun init-planning ()
  "Initialize all the interfaces from planning to other groups."

  (roslisp-utilities:startup-ros :name "planning_node" :anonymous nil)

  ;;Init all the action servers
  (pc:init-action-client) ;; for text-to-speech
  (chll:init-nav-client)
  (chll:make-giskard-joints-action-client)
  ;; (chll:make-giskard-poses-action-client)
  (roslisp:ros-info (plc) "All action server clients are set up.")) ;; for navigation
  
