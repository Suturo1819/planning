(in-package :pexe)

(defun execute-demo()

  (chll::call-robosherlock-door-pipeline)
  ;; GRIPPER START SIGNAL
  ;; (chll:init-gripper-tilt-fluent)
  ;; (cpl:wait-for (cpl:< chll:*start-signal-fluent* -1.7d0)) ;; CHANGE THIS THRESHOLD BASED ON PLOTJUGGLER DATA!!!
  ;; (chll:smash-into-appartment)
 
  (plc::with-hsr-process-modules
    (chll::call-nav-action-ps (plc::make-pose-stamped 4.305 0.218 3.0))

    ;;go through the door
    (plc::make-pose-stamped 4.305 0.218 3.0)

    (plc::perceive-shelf)
    (plc::perceive-table)
    
    ;; GRASPING OBJECT
    ;; TODO LOOP this for all available objects on the table
    (loop while (not (eq (chll::prolog-table-objects) 1)) do
      ;; NOTE goto is now included in the plan
      (plc::grasp-object)

    ;; PLACING OBJECT
      (plc::go-to :to :SHELF :facing :SHELF :manipulation T)
      (plc::place-object "FRONT"))))

