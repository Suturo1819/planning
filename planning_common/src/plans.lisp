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
           (say-reached (desig:a motion
                                 (:type :say)
                                 (:text "I have reached my destination"))))
      
      (cram-executive:perform say-target)
      (cram-executive:perform rotate)
      (cram-executive:perform move)
      (cram-executive:perform say-reached))))

;;; -----
(cpl:def-cram-function perceive-table (?pos ?height)
  "move head, torso and perceive"
  (cpl:seq
    (let* ((say-move-torso (desig:a motion
                                (:type :say)
                                (:text "I am going to perceive the table now. Moving my torso up.")))
           
           (move-torso (desig:a motion
                                (:type :move-torso)
                                (:height ?height)))
           
           (say-move-head (desig:a motion
                                 (:type :say)
                                 (:text "Move torso complete. Moving head.")))
           
           (move-head (desig:a motion
                          (:type :looking)
                          (:direction ?pos)))
           
           (say-reached (desig:a motion
                                 (:type :say)
                                 (:text "Move head complete. Perceiving..."))))
      
      (cram-executive:perform say-move-torso)
      (cram-executive:perform move-torso)
      (cram-executive:perform say-move-head)
      (cram-executive:perform move-head)
      (cram-executive:perform say-reached))))

;; -----
(cpl:def-cram-function grasp-object ()
  "grasp object"
  (cpl:seq
    (let* ((?pose (pexe::grasp-obj-from-floor-2))
           (?weight 0.4)
           (?width 0.055)
           (?height 0.195)
           (?depth 0.2)
           (?top 'false)
           (?side_right 'false)
           (?side_left 'false)
           (grasp (desig:a motion
                              (:type :grasping)
                              (:pose ?pose)
                              (:weight ?weight)
                              (:width ?width)
                              (:height ?height)
                              (:depth ?depth)
                              (:top ?top)
                              (:side_right ?side_right)
                              (:side_left ?side_left))))
      
      (cram-executive:perform grasp))))
                              
(cpl:def-cram-function look (?position)
  "grasp object"
  (cpl:seq
    (let* ((look-at (desig:a motion
                             (:type :looking)
                             (:direction ?position))))
      
      (cram-executive:perform look-at))))
