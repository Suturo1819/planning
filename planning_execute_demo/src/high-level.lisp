(in-package :pexe)

(defun execute-demo()
  ;; GRIPPER START SIGNAL
  ;; (chll:init-gripper-tilt-fluent)
  ;; (cpl:wait-for (cpl:< chll:*start-signal-fluent* -1.7d0)) ;; CHANGE THIS THRESHOLD BASED ON PLOTJUGGLER DATA!!!
  ;; (chll:smash-into-appartment)
  
  (plc::with-hsr-process-modules
    ;; GO and PERCEIVE the  SHELF
    ;; BASE-POSE is nor PERCEIVE SIDE and called in the next plan
    (plc::perceive-shelf)
    
    ;; GO and PERCEIVE the TABLE
    ;;(plc::go-to (plc::calculate-possible-poses-from-obj "environment/table_front_edge_center" ) "table")
    (plc::perceive-table)   
    
    ;; GRASPING OBJECT
    ;; TODO LOOP this for all available objects on the table
    (loop while (not (eq (chll::prolog-table-objects) 1)) do
      ;; NOTE goto is now included in the plan
      (plc::grasp-object)

    ;; PLACING OBJECT
      (plc::go-to :to :SHELF :facing :SHELF :manipulation T)
      (plc::place-object "FRONT"))))


(defun execute-demo-proj()
  (plc::with-hsr-proj-process-modules
      (plc::go-to (plc::pose-infront-shelf) "shelf")))
