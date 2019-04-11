(in-package :plc)

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
      (cram-executive:perform say-safe)
      (cram-executive:perform move-head-safe))))

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

           (?weight 0.4)
           (?width 0.055)
           (?height 0.195)
           (?depth 0.2)
           (grasp (desig:a motion
                              (:type :grasping)
                              (:pose ?pose)
                              (:weight ?weight)
                              (:width ?width)
                              (:height ?height)
                              (:depth ?depth)
                              (:modus ?modus)))
           (say-move-arm (desig:a motion
                                (:type :say)
                                (:text "I am going to grasp the object now.")))
           (done (desig:a motion
                                (:type :say)
                                (:text "Done grasping."))))
      
      (cram-executive:perform say-move-arm)
      (cram-executive:perform grasp)
      (cram-executive:perform done))))

;; FRONT TOP
(cpl:def-cram-function place-object (?modus ?shelf_floor)
  "grasp object"
  (cpl:seq
    (let* (
           (pose-in-shelf (cl-tf2:lookup-transform (plc:get-tf-listener)
                                                   "map" (concatenate
                                                          'String
                                                          "environment/shelf_floor_"
                                                          ?shelf_floor "_piece") :timeout 5))
           (?pose (cl-tf:make-pose (cl-tf:translation pose-in-shelf)
                                       (cl-tf:rotation pose-in-shelf)))

           (?weight 0.4)
           (?width 0.055)
           (?height 0.195)
           (?depth 0.2)
           (grasp (desig:a motion
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
      
      (cram-executive:perform say-move-arm)
      (cram-executive:perform grasp)
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

