(in-package :plc)

(defvar *object-dimensions* NIL)
(defvar *width-offset* 0.05)
;; TODO move this to knowledge:
(defvar *height-obj-in-gripper* NIL)
(defparameter *placing-z-offset* 0.05)
(defparameter *placing-x-offset* 0.0)
(defparameter *placing-y-offset* 0.1)


(cpl:def-cram-function go-to (?pose ?text)
  "go to a predefined location"
  ;;NOTE the publish-callange-step is done in the dynamic-poses.lisp
    (let* ((?to-say (concatenate 'string "I am going to the " ?text))
   
           (?rotation (plc::force-rotation ?pose))
           
           (rotate (desig:a motion
                            (:type :going)
                            (:target (desig:a location
                                              (:pose ?rotation)))))
           
           (move (desig:a motion
                          (:type :going)
                          (:target (desig:a location
                                            (:pose ?pose)))))
           (head-safe (desig:a motion
                               (:type :looking)
                               (:direction :safe))))
      (cpl:seq
        (plc::say ?to-say)
        ;; (cram-executive:perform rotate) ;;TODO debug. calculate direction to face
        (cram-executive:perform move)
        (cram-executive:perform head-safe)
        (plc::say "I have reached my destination"))))

;;; -----
(cpl:def-cram-function perceive-table ()
  "move head, torso and perceive"
  (pc::publish-challenge-step 3)
    (let* ((?height (plc::table-head-difference))
           
           (move-torso (desig:a motion
                                (:type :moving-torso)
                                (:height ?height)))
           
           
           (move-head (desig:a motion
                          (:type :looking)
                          (:direction :perceive-down)))
          
           
           (move-head-safe (desig:a motion
                          (:type :looking)
                          (:direction :safe))))
      
      (plc::perceive-high)
      (cpl:par
        (plc::say "I am going to perceive the table now. Moving my torso up.")
        (cram-executive:perform move-torso))
      (plc::go-to (plc::pose-infront-table :manipulation NIL) "table")
      (cpl:par
        (plc::say "Move torso complete. Moving head.")
        (cram-executive:perform move-head))
      
      (plc::say "Move head complete")
      (plc::perceive (vector "robocup_table"))
      (plc::go-to (plc::pose-infront-table :manipulation T) "step away from the table")
      (plc::base-pose)
      (cram-executive:perform move-head-safe)
      ))

;;assuming robot is already standing infront of the shelf
;;TODO
(cpl:def-cram-function perceive-shelf ()
  "move head, torso and perceive"
  (pc::publish-challenge-step 1)
  
  ;;middle
  (plc::perceive-high)
   (cpl:par
    (plc::say "moving torso slightly up")
    (plc::move-torso (plc::shelf-head-difference "2")))
   (plc::go-to (plc::pose-infront-shelf :manipulation NIL) "closer to the shelf")
   (cpl:par
     (plc::move-head :perceive-down)
     (plc::say "done moving"))
    (plc::perceive (vector "robocup_shelf_2"))
    (plc::move-head :safe)

    ;;low
   (plc::go-to (plc::pose-infront-shelf :manipulation T) "step away from the shelf")
   (plc::base-pose)
   (cpl:par
     (plc::move-torso (plc::shelf-head-difference "1"))
    ;;(plc::go-to (plc::pose-infront-shelf :manipulation NIL) "shelf")
     (plc::move-head :perceive-down))
    (plc::perceive (vector "robocup_shelf_1"))
    (plc::move-head :safe))




;; -----
(cpl:def-cram-function grasp-object (&optional ?modus)
  "grasp object"
  (pc::publish-challenge-step 4)
    (let* ((all-table-objects (chll:prolog-table-objects))
           (closest-object (plc:frame-closest-to-robot all-table-objects))
           (closest-object-pose (cl-tf2:lookup-transform (plc:get-tf-listener)
                                                         "map" closest-object :timeout 5))
           (object-class (chll:object-name->class closest-object))
           (?pose (cl-tf:make-pose (cl-tf:translation closest-object-pose)
                                   (cl-tf:rotation closest-object-pose)))
           (dimensions (chll::prolog-object-dimensions closest-object))

           (?weight 0.8)
           (?width (- (first dimensions) *width-offset*))
           (?depth (second dimensions))
           (?height (third dimensions))
           (?modus (if (equal ?modus NIL)
                       (if (< (third dimensions) 0.1)
                           (setq ?modus "TOP")
                           (setq ?modus "FRONT"))
                       ?modus))

           (grasp (desig:a motion
                           (:type :grasping)
                           (:pose ?pose)
                           (:weight ?weight)
                           (:width ?width)
                           (:height ?height)
                           (:depth ?depth)
                           (:modus ?modus)))
           (say-before (concatenate 'String "I am going to grasp the" object-class "now."))
           (say-after "done grasping"))
      
      (pc::publish-marker-pose ?pose)
      (setq *height-obj-in-gripper* ?height)
      (format t "Object Class: ~a" object-class)
      (setq *object-dimensions* dimensions)
      (planning-communication::publish-marker-pose ?pose)
      (cpl:par
        (plc::say say-before)
        (plc::move-head :safe))
      (cram-executive:perform grasp)
      (cpl:par
        (plc::move-head :safe)
        (plc::say say-after))))

;; FRONT TOP
(cpl:def-cram-function place-object (?modus ?shelf_floor)
  "place object"
  (pc::publish-challenge-step 6)
  (cpl:seq
    (let* ((pose-in-shelf (cl-tf2:lookup-transform (plc:get-tf-listener)
                                                   "map"
                                                   (concatenate
                                                    'String
                                                    "environment/shelf_floor_"
                                                    ?shelf_floor "_piece") :timeout 5))
           (pose-from-prolog (chll::prolog-object-goal-pose (chll::prolog-object-in-gripper)))

           (?pose (cl-tf:make-pose
                   (cl-tf:make-3d-vector (+ (first (car pose-from-prolog)) *placing-x-offset*)
                                         (+ (second (car pose-from-prolog)) *placing-y-offset*)
                                         (+ (third (car pose-from-prolog)) *placing-z-offset*))
                   (cl-tf:make-quaternion (first (second pose-from-prolog))
                                          (second (second pose-from-prolog))
                                          (third (second pose-from-prolog))
                                          (fourth (second pose-from-prolog)))))
        
           (?weight 0.7)
           (?width (first *object-dimensions*))
           (?depth 0.0)
           (?height *height-obj-in-gripper*)
           
           (place (desig:a motion
                              (:type :placing)
                              (:pose ?pose)
                              (:weight ?weight)
                              (:width ?width)
                              (:height ?height)
                              (:depth ?depth)
                              (:modus ?modus))))

      (if (>= (third *object-dimensions*)
                            (second *object-dimensions*))
                        (progn
                          (setq ?height (+ (third *object-dimensions*) *placing-z-offset*))
                          (setq ?depth (second *object-dimensions*)))
                        (progn
                          (setq ?height (+ (second *object-dimensions*) *placing-z-offset*))
                          (setq ?depth (third *object-dimensions*))))
      
      (pc::publish-marker-pose ?pose)
      (plc::say "I am going to place the object now.")
      (cram-executive:perform place)
      (plc::say "Done placing.")
      (format t "DESIG: ~a" place))))




;; minor plans /very basic ones

(cpl:def-cram-function move-head (?position)
  "moves head into the desired position. Accepts either a vector with two values,
or one of the following: :perceive :safe :front"  
    (let* ((look-at (desig:a motion
                             (:type :looking)
                             (:direction ?position))))
      
      (cram-executive:perform look-at)))

(cpl:def-cram-function say (?text)
  "speaks the given text"
  (pc::publish-robot-text ?text)
    (let* ((say-text (desig:a motion
                             (:type :say)
                             (:text ?text))))
      
      (cram-executive:perform say-text)))

(cpl:def-cram-function move-torso (?height)
  "moves torso to given height. keeps the arm out of sight." 
    (let* ((move-torso (desig:a motion
                             (:type :moving-torso)
                             (:height ?height))))

      (move-head :safe)
      (cram-executive:perform move-torso)))


;; for table call
(cpl:def-cram-function perceive (?surface)
  (let* ((perceive-desig (desig:a motion
                                  (:type :perceive)
                                  (:surface ?surface))))
    
    ;;(plc::move-head :perceive)
    (cpl:par (plc::say "Now, perceiving.")
      (cram-executive:perform perceive-desig))
;;    (sleep 10.0)
    (plc::say "Done perceiving.")))
    
(cpl:def-cram-function base-pose ()
  (pc::publish-challenge-step 0)
  (pc::publish-operator-text "Toya, please clean up the table")
  (let* ((?pose (cl-tf:make-identity-transform))
         (?nil NIL)
         (?zero 0.0)
         (perceive (desig:a motion
                         (:type :perceiving)
                         (:pose ?pose)
                         (:weight ?zero)
                         (:width ?zero)
                         (:height ?zero)
                         (:depth ?zero)
                         (:modus ?nil))))
    (cpl:par
      (plc::say "moving into base pose")
      (cram-executive:perform perceive))
    (plc::say "done moving into base pose")))

(cpl:def-cram-function perceive-high ()
  (let* ((?pose (cl-tf:make-identity-transform))
         (?nil NIL)
         (?zero 0.0)
         (perceive (desig:a motion
                         (:type :perceiving-high)
                         (:pose ?pose)
                         (:weight ?zero)
                         (:width ?zero)
                         (:height ?zero)
                         (:depth ?zero)
                         (:modus ?nil))))
    (cpl:par
      (plc::say "moving into perceive high pose.")
      (cram-executive:perform perceive))
    (plc::say "done moving into perceive high pose.")))

(cpl:def-cram-function perceive-side ()
  (let* ((?pose (cl-tf:make-identity-transform))
         (?nil NIL)
         (?zero 0.0)
         (perceive (desig:a motion
                         (:type :perceiving-side)
                         (:pose ?pose)
                         (:weight ?zero)
                         (:width ?zero)
                         (:height ?zero)
                         (:depth ?zero)
                         (:modus ?nil))))
    (cpl:par
      (plc::say "moving into perceive side pose.")
      (cram-executive:perform perceive))
    (plc::say "done moving into perceive side pose.")))
         
