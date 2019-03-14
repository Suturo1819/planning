(in-package :pc)

(cram-prolog:def-fact-group available-hsrb-process-modules (available-process-module
                                                            matching-process-module)
  
  (cram-prolog:<- (available-process-module hsr-navigation-process-modules))
  (cram-prolog:<- (available-process-module hsr-motion-process-modules))
  (cram-prolog:<- (available-process-module hsr-say))
  (cram-prolog:<- (available-process-module hsr-say-action))
 
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
  
  (cram-prolog:<- (matching-process-module ?desig  hsr-motion-process-modules)
    (desig-prop ?desig (:type :gripping)))
  
  (cram-prolog:<- (matching-process-module ?desig  hsr-say-process-modules)
    (desig:desig-prop ?desig (:type :say)))

  (cram-prolog:<- (matching-process-module ?action-desig  hsr-say-action-process-modules)
    (desig:desig-prop ?action-desig (:type :say)))
  

  )
