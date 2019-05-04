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
   

    ;;vanessa gaya hardcoded desperate robocup
     (let* ((?to-say "i am going to the shelf")
            (?pose (cl-tf:make-pose-stamped "map" 0 
                                            (cl-tf:make-3d-vector 0.53 1.1 0)
                                            (cl-tf:axis-angle->quaternion 
                                             (cl-tf:make-3d-vector 0 0 1)
                                             (cl-transforms:make-identity-rotation))))
                    
           (move (desig:a motion
                          (:type :going)
                          (:target (desig:a location
                                            (:pose ?pose))))))
      (cpl:seq
        (plc::say ?to-say)
        ;; (cram-executive:perform rotate) ;;TODO debug. calculate direction to face
        (cram-executive:perform move)))

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
