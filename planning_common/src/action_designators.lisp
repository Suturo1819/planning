(in-package :pc)

(cram-prolog:def-fact-group hsr-action-designators (action-grounding)
  (cram-prolog:<- (desig:action-grounding ?desig (grasping))
    (desig:desig-prop ?desig (:type :grasping))
    (desig:desig-prop ?desig (:base-pose ?base-pose)) ;; Or location-desig
    (desig:desig-prop ?desig (:obj-pose ?obj-pose))) ;; or object desig
)
