(in-package :pexe)

 
(defun main ()
  "Main function - Executing and planning robot behaviour on the top level"
  ;;driving and communication part
  ;; TODO check if a ros node is running?
  (unless (eq (roslisp:node-status) :RUNNING)
    (roslisp-utilities:startup-ros :name "planning-main"))
  
  (cram-language:top-level
    (setf pc::*perception-subscriber* nil)
    (plc::init-planning)

    (greeting-introduction)

    ;; TODO this needs to be replaced with a query of KNOWLEDGE
    ;;perception call and extracting
    (let* ((vision-data (pc:get-perceived-data))
           (vision-pose-stamped
             (cdr (assoc 'pc:pose-stamped vision-data)))
           (vision-pose
             (cl-tf:pose-stamped->pose vision-pose-stamped))
           (object-width
             (cdr (assoc 'pc:width vision-data)))
           (object-height
             (cdr (assoc 'pc:height vision-data)))
           (map-T-odom (cram-tf::lookup-transform cram-tf::*transformer* "map" "odom"))
           
           (odom-object-pose
             (cl-tf:transform->pose
              (cl-tf:transform*
               (cl-tf:transform-inv map-T-odom)
               (cl-tf:pose->transform vision-pose)))))

      (cram-language:par
        (pc::call-text-to-speech-action "I extracted all the information. I will try to grasp now.")
        ;; grasping part first drive back otherwise not graspable
        ;; go back to standing infront of the little table 
        (go-to-table)

        ;; start Grasping

        (chll::call-giskard-joints-grasping-action vision-pose
                                                   odom-object-pose
                                                   1
                                                   object-width
                                                   object-height))

      ;; go back to the center of the room
      (cram-language:par
        (go-to-room-center)
        (pc::call-text-to-speech-action "This is all i can do for now. Thank you for you attention.")))))


(cram-language:def-cram-function greeting-introduction ()
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
