;;; Adapted from https://github.com/cram2/cram/blob/master/cram_boxy/cram_boxy_designators/src/motions.lisp
;;; use these instead: https://github.com/cram2/cram/tree/master/cram_pr2/cram_pr2_fetch_deliver_plans/src
(in-package :plc)
;; TODO Adapt to HSR

(def-fact-group hsrb-motion-designators (desig:motion-grounding)
  ;; for each kind of motion define a desig

  ;;;;;;;;;;;;;;;;;;;; BASE ;;;;;;;;;;;;;;;;;;;;;;;;
  (<- (desig:motion-grounding ?designator (move-base goal-pose))
    (property ?designator (:type :going))
    (property ?designator (:target ?location-designator))
    (desig:designator-groundings ?location-designator ?poses)
    (member ?pose ?poses))

  ;;;;;;;;;;;;;;;;;;;; NECK ;;;;;;;;;;;;;;;;;;;;;;;;

  ;; looking at?
  (<- (desig:motion-grounding ?designator (move-neck ?joint-angles-list))
    (property ?designator (:type :looking))
    (property ?designator (:configuration ?joint-angles-list)))

  ;;;;;;;;;;;;;;;;;;;; TORSO ;;;;;;;;;;;;;;;;;;;;;;;;

  ;; move robot up and down
  (<- (desig:motion-grounding ?designator (move-neck ?joint-angles-list))
    (property ?designator (:type :move-up))
    (property ?designator (:configuration ?joint-angles-list)))

    ;; move robot up and down
  (<- (desig:motion-grounding ?designator (move-neck ?joint-angles-list))
    (property ?designator (:type :move-down))
    (property ?designator (:configuration ?joint-angles-list)))

  ;;;;;;;;;;;;;;;;;;;; GRIPPER ;;;;;;;;;;;;;;;;;;;;;;;;

  (<- (desig:motion-grounding ?designator (move-gripper-joint :open))
    (property ?designator (:type :opening)))

  (<- (desig:motion-grounding ?designator (move-gripper-joint :close))
    (property ?designator (:type :closing)))

  (<- (desig:motion-grounding ?designator (move-gripper-joint :grip NIL ?effort))
    (property ?designator (:type :gripping))
    (once (or (property ?designator (:effort ?effort))
              (equal ?effort nil))))

  (<- (desig:motion-grounding ?designator (move-gripper-joint nil ?position NIL))
    (property ?designator (:type :moving-gripper-joint))
    (property ?designator (:joint-angle ?position)))

  
)
