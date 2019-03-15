(in-package :plc)

(cram-prolog:def-fact-group hsr-action-designators (action-grounding)
  (cram-prolog:<- (desig:action-grounding ?desig (grasping))
    (spec:property ?desig (:type :grasping))
    (spec:property ?desig (:base-pose ?base-pose)) ;; Or location-desig
    (spec:property ?desig (:obj-pose ?obj-pose))) ;; or object desig

  (cram-prolog:<- (desig:action-grounding ?desig (perceiving ?base-pose ?head-pose))
    (spec:property ?desig (:type :perceiving))
    (spec:property ?desig (:base-pose ?base-pose)) ;;where robot should stand to perceive
    (spec:property ?desig (:head-pose ?head-pose)))

  (cram-prolog:<- (desig:action-grounding ?desig (perceiving))
    (spec:property ?desig (:type :perceiving))
    (spec:property ?desig (:base-pose ?base-pose)))

  ;;;;;;;;;;;;;;;;;;;;;; ARM ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (cram-prolog:<- (desig:action-grounding ?desig (grasping ?obj-desig))
    (spec:property ?desig (:type :grasping))
    (spec:property ?desig (:object ?obj-desig)) ;; can be a location desig
    )
 ;;;; OTHER

  (cram-prolog:<- (desig:action-grounding ?desig (say ?text))
    (desig:desig-prop ?desig (:type :say))
    (desig:desig-prop ?desig (:text ?text)))
  
  )

