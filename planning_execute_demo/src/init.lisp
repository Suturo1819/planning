(in-package :pexe)

 
(defun main ()
  "Main function - Executing and planning robot behaviour on the top level"
  ;;driving and communication part
  ;; TODO check if a ros node is running?
  (unless (eq (roslisp:node-status) :RUNNING)
    (roslisp-utilities:startup-ros :name "planning" :anonymous NIL))
  
  (cram-language:top-level
   
    (plc::init-planning)

    ;;(greeting-introduction)
    (go-closer-to-table) ;; if not greeting, go to table at least
    (chll::call-move-head-action (vector 0.0 -0.2))
    
    (pc::call-text-to-speech-action
     "Calling the robo sherlok pipeline.")
     (chll:call-robosherlock-pipeline)
    
    (pc::call-text-to-speech-action
     "I am done with robo sherlock.")

    (chll::call-move-head-action (vector 0.0 0.1))
    
    (let* ((object-transform (plc::get-closest-object-pose-on-table))
           (object-class
             (subseq (cl-tf:child-frame-id object-transform) 0 (position #\_ (cl-tf:child-frame-id object-transform))))
           (object-pose (cl-tf:make-pose (cl-tf:translation object-transform)
                                         (cl-tf:rotation object-transform)))
           (object-width 0.1)
           (object-height 0.2)
           (object-weight 0.4)
           (map-T-odom (cl-tf:lookup-transform (plc::get-tf-listener) "map" "odom"))
           
           (odom-object-pose
             (cl-tf:transform->pose
              (cl-tf:transform*
               (cl-tf:transform-inv map-T-odom)
               (cl-tf:pose->transform object-pose)))))

      (cram-language:seq
        (pc::call-text-to-speech-action
         (format nil "I extracted all the information. I will try to grasp the ~a now." object-class))
        ;; grasping part first drive back otherwise not graspable
        ;; go back to standing infront of the little table 
        (go-to-table)

        ;; start Grasping
        ;; TODO test this
        (chll::call-giskard-joints-grasping-action object-pose
                                                   odom-object-pose
                                                   1
                                                   object-width
                                                   object-height
                                                   "grip"))
      ;;(go-to-room-center)
      (pc::call-text-to-speech-action "I will try to place the object now.")
      (go-to-shelf)
      (chll::call-move-head-action (vector 0.0 -0.2))
      (place-test)
      ;;(go-to-room-center)
      ;; go back to the center of the room
      (cram-language:par
       ;; (go-to-room-center)
        (pc::call-text-to-speech-action "This is all i can do for now. Thank you for you attention.")))))


(cpl:def-cram-function greeting-introduction ()
  "Driving around and saying stuff."
  (cram-language:par
    (go-to-room-center)
    (pc::call-text-to-speech-action "Good Morning."))
  (pc::call-text-to-speech-action
   "My name is Toya. The Suturo Members are working hard each day.")
  (cram-language:par
    (go-to-shelf)
    (pc::call-text-to-speech-action
     (format nil "~a ~a ~a"
             "So i can finally serve you, or atleast grasp something."
             "I am brand new, so please don't be to hard to me."
             "If i do something wrong just correct me. Shall we try?")))
  (go-to-table)
  (pc::call-text-to-speech-action "I can't tell, what object this is. I need to get closer")
  (go-closer-to-table)
  (pc::call-text-to-speech-action "Now i can finally identify."))


(define-condition custom-error (cpl:simple-plan-failure) ((message :initarg :message :initform "" :reader message)))

;;TODO: error-class wieder erstellen ???
;; Extend this to cover different kind of failures.
(define-condition move-error (custom-error) ()
  (:report (lambda (condition stream)
             (format stream "move error: ~A~%"
                     (message condition)))))
