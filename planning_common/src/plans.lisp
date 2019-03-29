(in-package :plc)

(cpl:def-cram-function go-to (?pose ?text)
  "go to a predefined location"
  (cpl:seq
    (let* ((?to-say (concatenate 'string "I am going to the " ?text))
           (say-target (desig:a motion
                                (:type :say)
                                (:text ?to-say)))
           
           (move (desig:a motion
                          (:type :going)
                          (:target (desig:a location
                                            (:pose ?pose)))))
           (say-reached (desig:a motion
                                 (:type :say)
                                 (:text "I have reached my destination"))))
      
      (cram-executive:perform say-target)
      (cram-executive:perform move)
      (cram-executive:perform say-reached)


      )))
    
