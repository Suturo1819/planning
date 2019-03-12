;;; Adapted from https://github.com/cram2/cram/blob/master/cram_boxy/cram_boxy_designators/src/motions.lisp
;;; use these instead: https://github.com/cram2/cram/tree/master/cram_pr2/cram_pr2_fetch_deliver_plans/src
(in-package :plc)
;; TODO Adapt to HSR

(cram-prolog:def-fact-group hsr-motion-designators (desig:motion-grounding)
  ;; for each kind of motion define a desig

  ;;;;;;;;;;;;;;;;;;;; BASE ;;;;;;;;;;;;;;;;;;;;;;;;
  (cram-prolog:<- (desig:motion-grounding ?designator (move-base goal-pose))
    (desig:desig-prop ?designator (:type :going))
    (desig:desig-prop ?designator (:target ?location-designator))
    (desig:designator-groundings ?location-designator ?poses)
    (member ?pose ?poses))

  (cram-prolog:<- (desig:motion-grounding ?designator (move-base goal-pose))
    (desig:desig-prop ?designator (:type :going))
    (desig:desig-prop ?designator (:target ?location)))
  
  (cram-prolog:<- (desig:motion-grounding ?designator (move-base goal-pose))
    (desig:desig-prop ?designator (:type :going))
    (desig:desig-prop ?designator (:x ?x))
    (desig:desig-prop ?designator (:y ?y))
    (desig:desig-prop ?designator (:angle ?angle)))
  ;;;;;;;;;;;;;;;;;;;; TORSO ;;;;;;;;;;;;;;;;;;;;;;;;

  ;; move robot up and down
  (cram-prolog:<- (desig:motion-grounding ?designator (move-torso ?joint-angles-list))
    (desig:desig-prop ?designator (:type :moving-torso))
    ;;(desig:desig-prop ?designator (:configuration ?joint-angles-list))
    )
  
  ;;;;;;;;;;;;;;;;;;;; NECK ;;;;;;;;;;;;;;;;;;;;;;;;

  ;; looking at?
  (cram-prolog:<- (desig:motion-grounding ?designator (move-neck ?pos-vector ?vel-vector))
    (desig:desig-prop ?designator (:type :looking))
    (desig:desig-prop ?designator (:positions ?pos-vector))
    (desig:desig-prop ?designator (:velocities ?vel-vector))
    )
  
  ;;;;;;;;;;;;;;;;;;;; GRIPPER ;;;;;;;;;;;;;;;;;;;;;;;;

  (cram-prolog:<- (desig:motion-grounding ?designator (move-gripper-joint :open))
    (desig:desig-prop ?designator (:type :opening)))

  (cram-prolog:<- (desig:motion-grounding ?designator (move-gripper-joint :close))
    (desig:desig-prop ?designator (:type :closing)))

;;  (cram-prolog:<- (desig:motion-grounding ?designator (move-gripper-joint :grip NIL ?effort))
;;    (desig:desig-prop ?designator (:type :gripping))
;;    (once (or (desig:desig-prop ?designator (:effort ?effort))
;;              (equal ?effort nil))))

;;  (cram-prolog:<- (desig:motion-grounding ?designator (move-gripper-joint nil ?position NIL))
;;    (desig:desig-prop ?designator (:type :moving-gripper-joint))
;;    (desig:desig-prop ?designator (:joint-angle ?position)))

  (cram-prolog:<- (desig:motion-grounding ?designator (move-gripper-joint :grip NIL ?effort))
    (or (desig:desig-prop ?motion-designator (:type :gripping))
        (desig:desig-prop ?motion-designator (:type :moving-gripper-joint))
        (and (desig:desig-prop ?motion-designator (:gripper ?_))
             (or (desig:desig-prop ?motion-designator (:type :opening))
                 (desig:desig-prop ?motion-designator (:type :closing))))))
  
  
)
