(in-package pc)

(defparameter *perceived-data* nil)
(defparameter *perception-subscriber* nil)

(defun init-perception-subscriber ()
  (setf *perceived-data* nil)
  (unless *perception-subscriber*
    (roslisp:unsubscribe *perception-subscriber*))
  (unless (eq (roslisp:node-status) :RUNNING)
    (roslisp:start-ros-node "perception-subscriber"))
  (setf *perception-subscriber*
        (subscribe "suturo_perception/object_detection"
                   "suturo_perception_msgs/ObjectDetectionData" 
                   (lambda (msg) (setf *perceived-data* msg)))))

(defun publish-dummy-message ()
  (let ((pub (advertise "suturo_perception/object_detection"
                        "suturo_perception_msgs/ObjectDetectionData"))
        (message (roslisp:make-msg "suturo_perception_msgs/ObjectDetectionData"
                                   name "BOX_1"
                                   pose (cl-tf:make-pose-stamped-msg 
                                         (cl-tf:make-pose (cl-tf:make-3d-vector 1.02 0.0 0.6)
                                                          (cl-tf:euler->quaternion :ax 1.0 :ay 0.09 :az 1.0))
                                         "map"
                                         (roslisp:ros-time))
                                   shape 1
                                   width 0.5
                                   height 0.4
                                   depth 0.3)))
    (roslisp:publish pub message)))

(defun get-perceived-data ()
  (unless *perceived-data*
    (roslisp:ros-warn perception-client "No data perceived jet. Starting the subscriber.")
    (init-perception-subscriber))
  (roslisp:with-fields (name (pose-msg pose) shape width height depth) *perceived-data*
    `((name . ,name)
      (pose-stamped . ,(cl-tf:from-msg pose-msg))
      (shape . ,shape)
      (width . ,width)
      (height . ,height)
      (depth . ,depth))))
