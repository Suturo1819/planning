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
    (go-to-room-center)
    (move-to-home-pose)
    (pc::call-text-to-speech-action "Hello and Welcome to the Su Tu Ro presentation. .")

    ;;;;;;;;;;;;;;;;;;;;;;
    ;; shelf perception ;;
    (go-to-perceive-middle-shelf)
    (pc::call-text-to-speech-action "Let me see what we have in the shelf.")
    (chll:call-robosherlock-pipeline (vector "robocup_shelf_0"
                                             "robocup_shelf_1"
                                             "robocup_shelf_2"
                                             "robocup_shelf_3"
                                             "robocup_shelf_4"))
    (sleep 2)
    (let* ((perceived-objects (chll:prolog-all-objects-in-shelf))
           (text (if perceived-objects
                     (format nil "Oh boy, I can see objects."
                             (mapcar #'chll:object-name->class perceived-objects))
                     "There are no objects in the shelf.")))
      (pc::call-text-to-speech-action text))
    ;; shelf perception ;; 
    ;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; perceive table stuff ;;
    (go-closer-to-table) ;; if not greeting, go to table at least
    (chll::call-move-head-action (vector 0.0 -0.4))
    (pc::call-text-to-speech-action "Let's see what's on the table.")
    (chll:call-robosherlock-pipeline (vector "robocup_table"))
    (sleep 2)
    (let* ((perceived-objects (chll:prolog-table-objects))
          (text (if perceived-objects
                    ;; (format nil "Oh, I can see ~{~a~^, ~}."
                    ;;         (mapcar #'chll:object-name->class perceived-objects))
                    (format nil "I can see a total of: ~a, objects on the table." (length perceived-objects))
                    "I can't see any objects on the table.")))
      (pc::call-text-to-speech-action text))
    (chll::call-move-head-action (vector 0.0 0.1))
    ;; perceive table stuff ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; grasping from table ;;
    (let* ((all-table-objects (chll:prolog-table-objects))
         (closest-object (plc:frame-closest-to-robot all-table-objects))
         (closest-object-pose (cl-tf2:lookup-transform (plc:get-tf-listener)
                                                      "map" closest-object :timeout 5))
         (object-class (chll:object-name->class closest-object))
         (object-pose (cl-tf:make-pose (cl-tf:translation closest-object-pose)
                                       (cl-tf:rotation closest-object-pose)))
         (object-width 0.1)
         (object-height 0.2)
         (object-weight 0.4)
           (map-T-odom (cl-tf2:lookup-transform (plc:get-tf-listener) "map" "odom"))
         (odom-object-pose (cl-tf:transform->pose (cl-tf:transform*
                                                   (cl-tf:transform-inv map-T-odom)
                                                   (cl-tf:pose->transform object-pose)))))
    (cram-language:seq
      (pc::call-text-to-speech-action
       (format nil "I extracted all the information. I will try to grasp the ~a now." object-class))
      (go-to-table)
      ;; start Grasping
      ;; TODO test this
      (chll::call-giskard-joints-grasping-action object-pose odom-object-pose
                                                 1 object-width object-height "grip"))
      ;; grasping from table ;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; place object in shelf ;;
      (go-to-room-center)
      (pc::call-text-to-speech-action "I will try to place the object now.")
      (go-to-shelf)
      (chll::call-move-head-action (vector 0.0 -0.4))
      
      (let* ((goal-shelf (chll:prolog-object-goal closest-object))
             (goal-transform-stamped (cl-tf2:lookup-transform (plc:get-tf-listener) "map" goal-shelf :timeout 2))
             (goal-transform (cl-tf:make-transform (cl-tf:translation goal-transform-stamped)
                                                   (cl-tf:rotation goal-transform-stamped))))
        (cram-hsr-low-level::call-giskard-joints-grasping-action
         goal-transform
         (cl-tf:transform->pose
          (cl-tf:transform*
           (cl-tf:transform-inv
            (cram-tf::lookup-transform cram-tf::*transformer* "map" "odom"))
           goal-transform))
          0.4 0.07 0.26 "place"))
        ;; (place-test)
        )
      ;; place object in shelf ;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;(go-to-room-center)
    ;; go back to the center of the room
       

    (cram-language:par
      ;; (go-to-room-center)
      (pc::call-text-to-speech-action "This is all i can do for now. Thank you for you attention."))))

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

(defun roslaunch-execute-demo()
  (unless (eq (roslisp:node-status) :RUNNING)
    (roslisp-utilities:startup-ros :name "planning" :anonymous NIL))

  (chll::init-move-head-action-client)
  (chll::init-giskard-joints-action-client)
  (chll::init-move-torso-action-client)

  (sleep 5)
  (plc::with-hsr-process-modules
      (plc::go-to (plc::pose-infront-table :manipulation NIL) "table")    
      (plc::perceive-table)
      

      (plc::go-to (plc::pose-infront-table :manipulation T) "table")
      (plc::grasp-object)
    ))
  

(define-condition custom-error (cpl:simple-plan-failure) ((message :initarg :message :initform "" :reader message)))

;;TODO: error-class wieder erstellen ???
;; Extend this to cover different kind of failures.
(define-condition move-error (custom-error) ()
  (:report (lambda (condition stream)
             (format stream "move error: ~A~%"
                     (message condition)))))
