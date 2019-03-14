(in-package :pc)


;;; BASIC ;;;
(cpl:def-cram-function go-to-target (?pose)
  (cram-executive:perform
   (desig:a motion
            (:type :going)
            (:target (desig:a location
                              (pose ?pose))))))
   
(cpl:def-cram-function look-at (?direction)
  (cram-executive:perform
   (desig:a motion
            (:type :looking)
            (:direction ?direction))))

(cpl:def-cram-function move-neck (?position-vector)
  (cram-executive:perform
   (desig:a motion
            (:type :looking)
            (:position ?position-vector))))

(cpl:def-cram-function say (?text)
  (cram-executive:perform
   (desig:a motion
            (:type :say)
            (:text ?text))))

;;; LOCATION ;;;

;; creates a location designator for object pose
(cpl:def-cram-function object-location ()
  (let* ((?pose (cl-tf:transform->pose
                (pc::get-closest-object-pose-on-table))))
    (desig:a location (pose ?pose))))

;;; OBJECT ;;;

(cpl:def-cram-function object-data ()
  (let* ((?object (pc::get-closest-object-pose-on-table))
         (?obj-class (subseq
                      (cl-tf:child-frame-id ?object)
                      0
                      (position #\_ (cl-tf:child-frame-id ?object))))
         
         (?obj-pose-map (cl-tf:make-pose
                         (cl-tf:translation ?object)
                         (cl-tf:rotation ?object)))
         
         (?obj-pose-odom (pc::map-T-odom-pose ?obj-pose-map)))
         
    (desig:an object
              (:class ?obj-class)
              (:obj-pose-map (desig:a location
                                      (pose ?obj-pose-map)))
              (:obj-pose-odom (desig:a location
                                       (pose ?obj-pose-odom)))
              (:obj-weight 0.4)
              (:obj-widht 0.07) ;; TODO query from knowledge
              (:obj-height 0.26))))
               
;;; GRASPING ;;;              

;; (cpl:def-cram-function grasping (?obj-desig)
;;   (let* ((obj-pose-map (desig:desig-prop-value :obj-pose-map))
;;          (obj-pose-odom (desig:desig-prop-value :obj-pose-odom))
;;          (obj-weight (desig:desig-prop-value :obj-weight))
;;          (obj-width (desig:desig-prop-value :obj-width))
;;          (obj-height (desig:desig-prop-value :obj-height)))
    
;;     (cram-executive:perform
;;      (desig:a motion
;;               (:type :grasp)
;;               (:



;;;; TOP LEVEL ;;;;;
(cram-language:def-top-level-cram-function execute ()
  ;; TODO ensure node running etc.
  (let* ((?text "test"))
    (cram-process-modules:with-process-modules-running (hsr-say)
      (cram-process-modules:pm-execute-matching
       (desig:an action
                 (:type :say)
                 (:text ?text))))))
   
   
