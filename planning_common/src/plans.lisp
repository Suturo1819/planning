(in-package :plc)

(cpl:def-cram-function go-to (?pose ?text)
  "go to a predefined location" 
  (cpl:seq
    (exe:perform (desig:a motion
                          (:type :say)
                          (:text ?text)))
    
    (exe:perform (desig:a motion
                          (:type :going)
                          (:target (desig:a location
                                            (:pose ?pose)))))
    (exe:perform (desig:a motion
                          (:type :say)
                          (:text ?text)))))
    
