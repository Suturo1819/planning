(in-package :pc)

(cram-prolog:def-fact-group available-hsrb-process-modules (available-process-module
                                                  matching-process-module)
  (cram-prolog:<- (available-process-module hsr-navigation-process-modules))
  (cram-prolog:<- (available-process-module hsr-motion-process-modules))
 
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
    (desig-prop ?desig (:type :gripping))))
