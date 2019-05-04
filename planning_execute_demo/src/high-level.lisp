(in-package :pexe)

(defun execute-demo()
  ;; check if door is open and then enter
  (chll::call-robosherlock-door-pipeline)

  (plc::with-hsr-process-modules
    ;; pose to go through the door
    (chll::call-nav-action-ps (plc::make-pose-stamped 4.305 0.218 3.0))


    ))

(defun init-party ()
  (format t "make ros node")
  (roslisp-utilities:startup-ros :name "planning_node" :anonymous nil)
  (format t "done. init marker publisher")
  ;;init publisher
  (planning-communication::init-marker-publisher)



  )
