(in-package :pexe)

(defun execute-demo()

  ;;(lli:call-robosherlock-door-pipeline)
  ;; GRIPPER START SIGNAL
  ;; (lli:init-gripper-tilt-fluent)
  ;; (cpl:wait-for (cpl:< lli::*start-signal-fluent* -1.7d0)) ;; CHANGE THIS THRESHOLD BASED ON PLOTJUGGLER DATA!!!
  ;; (lli:smash-into-appartment)
 
  (plc::with-hsr-process-modules
    ;;(lli:call-nav-action-ps (plc::make-pose-stamped 4.305 0.218 3.0))

    ;;go through the door
    ;;(plc::make-pose-stamped 4.305 0.218 3.0)

    (plc::perceive-shelf)
    ;; this is necessary for navigation TODO remove if possible
    (plc::go-to :to :SHELF :facing :SHELF :manipulation T)
    ;;(plc::go-to :to :TABLE :facing :TABLE :manipulation NIL)
    ;;(plc::turn :LEFT)
    (plc::say "I'm going to the table")
    (lli:call-nav-action  -0.174 0.668 2.80)
    (lli:call-nav-action  -0.877 0.632 2.80)
    (plc::perceive-table)
    
    ;; GRASPING OBJECT
    ;; LOOP this for all available objects on the table
    (loop while (not (eq (lli:prolog-table-objects) 1)) do
      ;; NOTE goto is now included in the plan
      (plc::grasp-object)

    ;; PLACING OBJECT
      (plc::go-to :to :SHELF :facing :SHELF :manipulation T)
      (plc::place-object "FRONT"))
    (plc::say "I'm done.")))

