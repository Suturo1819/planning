(in-package :pexe)

(defun execute-demo()
  ;; check if door is open and then enter
  (chll::call-robosherlock-door-pipeline)
  (plc::with-hsr-process-modules
    ;; pose to go through the door


    ))

(defun init-party ()
  (format t "make ros node")
  (roslisp-utilities:startup-ros :name "planning_node" :anonymous nil)
  (format t "done. init marker publisher")
  ;;init publisher
  (planning-communication::init-marker-publisher)
  (chll::init-sound-play-client)




  )
