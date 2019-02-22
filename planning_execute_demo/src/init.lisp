(in-package :pexe)

 
(defun main ()
  "Main function - Executing and planning robot behaviour on the top level"
  ;;driving and communication part
  ;; TODO check if a ros node is running?
  (cram-language:top-level
    (setf pc::*perception-subscriber* nil)
    (plc::init-planning)
    ;; (cpl:with-retry-counters ((retry-counter 2))
    ;;   (cpl:with-failure-handling
    ;;       (((or cpl:simple-plan-failure move-error) (error-object)
    ;;          (format t "An error happened: ~a~%" error-object)
    ;;          (roslisp::ros-info "Moving" "Trying to solve error.")
    ;;          (cpl:do-retry retry-counter
    (cram-language:par
      (go-to-room-center)
      (pc::call-text-to-speech-action "Good Morning."))
    
    (pc::call-text-to-speech-action "My name is Toya. The Suturo Members are working hard each day.")
    (cram-language:par
      (chll::call-nav-action -0.0238773822784 1.01167118549 1.5)
      (pc::call-text-to-speech-action "So i can finally serve you, or atleast grasp
 a something. I am brand new, so please don't be to hard to me.
If i do something wrong just correct me. Shall we try?"))

    (go-to-little-table)
    (pc::call-text-to-speech-action "I can't tell, what object this is. I  need to get closer")

    (go-closer-to-little-table)
    (pc::call-text-to-speech-action "Now i can finally identify.")

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
        (go-to-little-table)

        ;; start Grasping
        (chll::call-giskard-joints-grip-action vision-pose
                                               odom-object-pose
                                               1
                                               object-width
                                               object-height))

      ;; go back to the center of the room
      (cram-language:par
        (go-to-room-center)
        (pc::call-text-to-speech-action "This is all i can do for now. Thank you for you attention.")
      ))))

(define-condition custom-error (cpl:simple-plan-failure) ((message :initarg :message :initform "" :reader message)))

 ;;TODO: error-class wieder erstellen
(define-condition move-error (custom-error) ()
  (:report (lambda (condition stream)
             (format stream "move error: ~A~%"
                     (message condition)))))
