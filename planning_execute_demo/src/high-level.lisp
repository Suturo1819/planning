(in-package :pexe)

(defun execute-demo()

  ;;(chll::call-robosherlock-door-pipeline)
  ;; GRIPPER START SIGNAL
  ;; (chll:init-gripper-tilt-fluent)
  ;; (cpl:wait-for (cpl:< chll:*start-signal-fluent* -1.7d0)) ;; CHANGE THIS THRESHOLD BASED ON PLOTJUGGLER DATA!!!
  ;; (chll:smash-into-appartment)
 
  (plc::with-hsr-process-modules
    ;;(chll::call-nav-action-ps (plc::make-pose-stamped 4.305 0.218 3.0))

    ;;go through the door
    ;;(plc::make-pose-stamped 4.305 0.218 3.0)

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





(defun small-demo-basic-functions ()
  ;;go to navigation goal hardcoded pose -a bit further away to percieve
  ;;toya looking from the side 
  (chll::call-nav-action  -0.95 0.61 -1.7)
  ;;arm away
  (plc::perceive-side)
  (plc::move-torso 0.2)  
  ;;mmove head keys: right-down-2, left-down-2 ........ angle changes with number)
  (plc::move-head :right-down-2)

   


        (roslisp:with-fields (detectiondata) (chll:call-robosherlock-pipeline) 

          (roslisp:with-fields (depth height pose width)  (aref detectiondata 1)
            (let* ((perception-pose pose)
                   (?width width)
                   (?depth depth)
                   (?weight 1.2)
                   (?height height)
                   (?pose  (roslisp:with-fields (pose) perception-pose
                             (roslisp:with-fields (position orientation) pose
                               (cl-tf:make-pose (cl-tf:from-msg position)
                                                (cl-tf:from-msg orientation)))))
    
         
           (grasp (desig:a motion
                           (:type :grasping)
                           (:pose ?pose)
                           (:weight ?weight)
                           (:width ?width)
                           (:height ?height)
                           (:depth ?depth)
                           (:modus "FRONT"))))

            (chll::call-nav-action  -0.48 0.69 -3.20)

      (cpl:par
        (plc::move-head :safe)
        (cram-executive:perform grasp))))))
    
