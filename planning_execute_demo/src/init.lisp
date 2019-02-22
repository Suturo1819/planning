(in-package :pexe)

 
(defun main ()
  "Main function - Executing and planning robot behaviour on the top level"
  ;;driving and communication part
  (roslisp:start-ros-node "planning-main") ;;aendern zu with ros node
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
      (chll::call-nav-action -0.0844728946686 0.0405520200729 0.0)
      (pc::call-text-to-speech-action "Good Morning."))
    (pc::call-text-to-speech-action "My name is Toya. The Suturo Members are working hard each day.")
    (cram-language:par
      (chll::call-nav-action -0.0238773822784 1.01167118549 1.5)
      (pc::call-text-to-speech-action "So i can finall serve you, or atleast grab a something. I am brand new, so please don't be to hard to me. If i do something wrong just correct me. Shall we try?"))
    (chll::call-nav-action -0.0844728946686 0.0405520200729 3)
    (pc::call-text-to-speech-action "I can't tell, what object this is. I  need to get closer")
    (chll::call-nav-action -0.4 0.0157970905304 3)
    (pc::call-text-to-speech-action "Now i can finally identify.")
    
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
        ;;grasping part first drive back otherwise not grapable
        (chll::call-nav-action -0.0844728946686 0.0405520200729 3)
        (chll::call-giskard-joints-grip-action vision-pose odom-object-pose 1 object-width object-height))

      ;;driving and end-part 
      (cram-language:par
        (chll::call-nav-action -0.0844728946686 0.0405520200729 0.0)
        (pc::call-text-to-speech-action "This is all i can do for now. Thank you for you attention.")
      ))))

(defun main-dummy ()
  "Main function - Executing and planning robot behaviour on the top level dummy without driving and hardcoded coords "
  ;;driving and communication part
  (roslisp:start-ros-node "planning-main") ;;aendern zu with ros node
  (cram-language:top-level
    (setf pc::*perception-subscriber* nil)
    (plc::init-planning)
    ;; (cpl:with-retry-counters ((retry-counter 2))
    ;;   (cpl:with-failure-handling
    ;;       (((or cpl:simple-plan-failure move-error) (error-object)
    ;;          (format t "An error happened: ~a~%" error-object)
    ;;          (roslisp::ros-info "Moving" "Trying to solve error.")
    ;;          (cpl:do-retry retry-counter
    ;; (cram-language:par
    ;;   (chll::call-nav-action -0.0844728946686 0.0405520200729 0.0)
    ;;   (pc::call-text-to-speech-action "Good Morning."))
    ;; (pc::call-text-to-speech-action "My name is Toya. The Suturo Members are working hard each day.")
    ;; (cram-language:par
    ;;   (chll::call-nav-action -0.0238773822784 1.01167118549 1.5)
    ;;   (pc::call-text-to-speech-action "So i can finall serve you, or atleast grab a something. I am brand new, so please don't be to hard to me. If i do something wrong just correct me. Shall we try?"))
    ;; (chll::call-nav-action -0.0844728946686 0.0405520200729 3)
    ;; (pc::call-text-to-speech-action "I can't tell, what object this is. I  need to get closer")
    (chll::call-nav-action -0.4 0.0157970905304 3)
    (pc::call-text-to-speech-action "Now i can finally identify.")
  ;;perception call and extracting
    (let* ((vision-data (pc:get-perceived-data))
           (vision-pose-stamped
             (cdr (assoc 'pc:pose-stamped vision-data)))
           (vision-pose
             (cl-tf:pose-stamped->pose vision-pose-stamped))
           (object-width
             (cdr (assoc 'pc:width vision-data)))
           (object-height
             (cdr (assoc 'pc:height vision-data))))
      (cram-language:par
        (pc::call-text-to-speech-action "I extracted all the information. I will try to grap now.")
        ;;graping part first drive back otherwise not grapable
        (chll::call-nav-action -0.0844728946686 0.0405520200729 3)
        ;; (chll::call-giskard-joints-grip-action vision-pose 1 object-width object-height)
        ;;funktioniert mit falscher location hihi
        (chll::call-giskard-joints-grip-action (chll::make-test-object-pose 1.02 0 0.6) 1 0.09 1))

      ;;driving and end-part 
      ;; (cram-language:par
      ;;   (chll::call-nav-action -0.0844728946686 0.0405520200729 0.0)
      ;;   (pc::call-text-to-speech-action "This is all i can do for now. Thank you for you attention.")
      )))


(define-condition custom-error (cpl:simple-plan-failure) ((message :initarg :message :initform "" :reader message)))

 ;;TODO: error-class wieder erstellen
(define-condition move-error (custom-error) ()
  (:report (lambda (condition stream)
             (format stream "move error: ~A~%"
                     (message condition)))))
