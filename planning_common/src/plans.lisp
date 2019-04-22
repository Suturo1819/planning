(in-package :plc)

(defvar *object-dimensions* NIL)

(cpl:def-cram-function go-to (?pose ?text)
  "go to a predefined location"
  (cpl:seq
    (let* ((?to-say (concatenate 'string "I am going to the " ?text))
           (say-target (desig:a motion
                                (:type :say)
                                (:text ?to-say)))
           
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
                               (:direction :safe)))
           
           (say-reached (desig:a motion
                                 (:type :say)
                                 (:text "I have reached my destination"))))
      
      (cram-executive:perform say-target)
     ;; (cram-executive:perform rotate) ;;TODO debug. calculate direction to face
      (cram-executive:perform move)
      (cram-executive:perform head-safe)
      (cram-executive:perform say-reached))))

;;; -----
(cpl:def-cram-function perceive-table ()
  "move head, torso and perceive"
  (cpl:seq
    (let* ((say-move-torso (desig:a motion
                                (:type :say)
                                (:text "I am going to perceive the table now. Moving my torso up.")))
           
           (?height (plc::table-head-difference))
           
           (move-torso (desig:a motion
                                (:type :moving-torso)
                                (:height ?height)))
           
           (say-move-head (desig:a motion
                                 (:type :say)
                                 (:text "Move torso complete. Moving head.")))
           
           (move-head (desig:a motion
                          (:type :looking)
                          (:direction :perceive)))
             
           (say-reached (desig:a motion
                                 (:type :say)
                                 (:text "Move head complete. Perceiving...")))
      ;; TODO add perception call here
           (say-safe (desig:a motion
                                 (:type :say)
                                 (:text "Perceiving complete. Moving into default position.")))
           
           (move-head-safe (desig:a motion
                          (:type :looking)
                          (:direction :safe))))
      
      (cram-executive:perform say-move-torso)
      (cram-executive:perform move-torso)
      (cram-executive:perform say-move-head)
      (cram-executive:perform move-head)
      (cram-executive:perform say-reached)
      (chll:call-robosherlock-pipeline (vector "robocup_table"))
      (cram-executive:perform say-safe)
      (cram-executive:perform move-head-safe))))

;;assuming robot is already standing infront of the shelf
;;TODO
(cpl:def-cram-function perceive-shelf ()
  "move head, torso and perceive"
  (cpl:seq
    ;;(cram-executive:perform stuff)
    ;;EXE
    ;;highest
    (plc::perceive-high)
    (plc::say "moving torso up")
    (plc::move-torso (plc::shelf-head-difference "3"))
    (plc::go-to (plc::pose-infront-shelf :manipulation NIL) "shelf")
    (plc::move-head :perceive)
    (plc::perceive (vector "robocup_shelf_3"))
    (plc::move-head :safe)
    
    ;;middle
    (plc::move-torso (plc::shelf-head-difference "2"))
    (plc::move-head :perceive)
    (plc::perceive (vector "robocup_shelf_2"))
    (plc::move-head :safe)

    ;;low
    (plc::go-to (plc::pose-infront-shelf :manipulation T) "shelf")
    (plc::base-pose)
    (plc::move-torso (plc::shelf-head-difference "1"))
    (plc::go-to (plc::pose-infront-shelf :manipulation NIL) "shelf")
    (plc::move-head :perceive)
    (plc::perceive (vector "robocup_shelf_1"))
    (plc::move-head :safe)))




;; -----
(cpl:def-cram-function grasp-object (?modus)
  "grasp object"
  (cpl:seq
    (let* ((all-table-objects (chll:prolog-table-objects))
           (closest-object (plc:frame-closest-to-robot all-table-objects))
           (closest-object-pose (cl-tf2:lookup-transform (plc:get-tf-listener)
                                                         "map" closest-object :timeout 5))
           (object-class (chll:object-name->class closest-object))
           (?pose (cl-tf:make-pose (cl-tf:translation closest-object-pose)
                                   (cl-tf:rotation closest-object-pose)))
           (dimensions (chll::prolog-object-dimensions closest-object))

           (?weight 0.8)
           (?width (first dimensions))
           (?depth (second dimensions))
           (?height (third dimensions))
           
          
           (grasp (desig:a motion
                              (:type :grasping)
                              (:pose ?pose)
                              (:weight ?weight)
                              (:width ?width)
                              (:height ?height)
                              (:depth ?depth)
                              (:modus ?modus)))
           (say-before "I am going to grasp the object now.")
           (say-after "done grasping"))
      
      (setq *object-dimensions* dimensions)
      (planning-communication::publish-marker-pose ?pose)
      (plc::say say-before)
      (plc::move-head :safe)
      (cram-executive:perform grasp)
      (plc::say say-after))))

;; FRONT TOP
(cpl:def-cram-function place-object (?modus ?shelf_floor)
  "place object"
  (cpl:seq
    (let* ((pose-in-shelf (cl-tf2:lookup-transform (plc:get-tf-listener)                                                   "map" (concatenate
                                                          'String
                                                          "environment/shelf_floor_"
                                                          ?shelf_floor "_piece") :timeout 5))
           (?pose (cl-tf:make-pose (cl-tf:translation pose-in-shelf)
                                       (cl-tf:rotation pose-in-shelf)))


           (?weight 0.7)
           (?width (first *object-dimensions*))
           (?depth NIL)
           (?height NIL)
           
           (place (desig:a motion
                              (:type :placing)
                              (:pose ?pose)
                              (:weight ?weight)
                              (:width ?width)
                              (:height ?height)
                              (:depth ?depth)
                              (:modus ?modus)))
           (say-move-arm (desig:a motion
                                (:type :say)
                                (:text "I am going to place the object now.")))
           (done (desig:a motion
                                (:type :say)
                                (:text "Done placing."))))

      (if (>= (third *object-dimensions*)
                            (second *object-dimensions*))
                        (progn
                          (setq ?height (third *object-dimensions*))
                          (setq ?depth (second *object-dimensions*)))
                        (progn
                          (setq ?height (second *object-dimensions*))
                          (setq ?depth (third *object-dimensions*))))
      
      (cram-executive:perform say-move-arm)
      (cram-executive:perform place)
      (cram-executive:perform done))))




;; minor plans /very basic ones

(cpl:def-cram-function move-head (?position)
  "moves head into the desired position. Accepts either a vector with two values,
or one of the following: :perceive :safe :front"
  (cpl:seq
    (let* ((look-at (desig:a motion
                             (:type :looking)
                             (:direction ?position))))
      
      (cram-executive:perform look-at))))

(cpl:def-cram-function say (?text)
  "speaks the given text"
  (cpl:seq
    (let* ((say-text (desig:a motion
                             (:type :say)
                             (:text ?text))))
      
      (cram-executive:perform say-text))))

(cpl:def-cram-function move-torso (?height)
  "moves torso to given height. keeps the arm out of sight."
  (cpl:seq
    (let* ((move-torso (desig:a motion
                             (:type :moving-torso)
                             (:height ?height))))

      (move-head :safe)
      (cram-executive:perform move-torso))))


;; for table call
(cpl:def-cram-function perceive (?surface)
  (let* ((perceive-desig (desig:a motion
                                  (:type :perceive)
                                  (:surface ?surface)))
         (say-before "Now, perceiving.")
         (say-after "Done, perceiving."))
    
    (plc::move-head :perceive)
    (say say-before)
    (cram-executive:perform perceive-desig)
    (say say-after)))
    
(cpl:def-cram-function base-pose ()
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

    (plc::say "moving into base pose")
    (cram-executive:perform perceive)
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

    (plc::say "moving into perceive high pose.")
    (cram-executive:perform perceive)
    (plc::say "done moving into perceive high pose.")))
         
