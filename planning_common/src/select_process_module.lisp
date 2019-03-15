(in-package :plc)

(cram-prolog:def-fact-group available-hsrb-process-modules (available-process-module
                                                            matching-process-module)
  
  (cram-prolog:<- (available-process-module hsr-navigation-process-modules))
  (cram-prolog:<- (available-process-module hsr-motion-process-modules))
  (cram-prolog:<- (available-process-module hsr-say-process-modules))
  (cram-prolog:<- (available-process-module hsr-arm-motion-process-modules))
 
  (cram-prolog:<- (matching-process-module ?desig  hsr-navigation-process-modules)
    (desig-prop ?desig (:type :going)))

  
  (cram-prolog:<- (matching-process-module ?desig  hsr-motion-process-modules)
    (desig-prop ?desig (:type :looking)))

  (cram-prolog:<- (matching-process-module ?desig  hsr-motion-process-modules)
    (desig-prop ?desig (:type :moving-torso)))

  (cram-prolog:<- (matching-process-module ?desig  hsr-motion-process-modules)
    (desig-prop ?desig (:type :opening)))
  
  (cram-prolog:<- (matching-process-module ?desig  hsr-motion-process-modules)
    (desig-prop ?desig (:type :closing)))
  
  (cram-prolog:<- (matching-process-module ?desig  hsr-arm-motion-process-modules)
    (desig-prop ?desig (:type :grasping)))
  
  ;; (cram-prolog:<- (matching-process-module ?desig  hsr-say-process-modules)
  ;;   (desig:desig-prop ?desig (:type :say)))

  (cram-prolog:<- (matching-process-module ?desig  hsr-say-process-modules)
    (desig:desig-prop ?desig (:type :say)))
  )
