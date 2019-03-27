(in-package :pc)

(defparameter *perceived-data* nil)
(defparameter *perception-subscriber* nil)



(defun init-perception-subscriber ()
  (setf *perceived-data* nil)
  (setf *perception-subscriber*
        (subscribe "suturo_perception/object_detection"
                   "suturo_perception_msgs/ObjectDetectionData" 
                   (lambda (msg) (roslisp:with-fields (shape) msg
                                     (when (eq shape 2)
                                       (setf *perceived-data* msg)))))))

(defun cleanup-perception-subscriber ()
  (setf *perceived-data* nil)
  (roslisp:unsubscribe *perception-subscriber*))



(defun send-dummy-message ()
  (let ((pub (advertise "suturo_perception/object_detection"
                        "suturo_perception_msgs/ObjectDetectionData"))
        (message (roslisp:make-msg "suturo_perception_msgs/ObjectDetectionData"
                                   name "BOX_1"
                                   pose (cl-tf:make-pose-stamped-msg 
                                         (cl-tf:make-pose (cl-tf:make-3d-vector 1.02 0.0 0.6)
                                                          (cl-tf:euler->quaternion :ax 1.0 :ay 0.09 :az 1.0))
                                         "map"
                                         (roslisp:ros-time))
                                   shape 2
                                   width 0.5
                                   height 0.4
                                   depth 0.3)))
    (roslisp:publish pub message)))

(defun get-perceived-data ()
  (if *perceived-data*
      (roslisp:with-fields (name (pose-msg pose) shape width height depth) *perceived-data*
        (publish-pose (cl-tf:from-msg pose-msg))
        `((name . ,name)
          (pose-stamped . ,(cl-tf:from-msg pose-msg))
          (shape . ,shape)
          (width . ,width)
          (height . ,height)
          (depth . ,depth)))
      (roslisp:ros-warn perception-client "No cylinder perceived jet.")))

(defparameter *marker-publisher* nil)
(defun get-marker-publisher ()
  (unless *marker-publisher*
    (setf *marker-publisher*
          (roslisp:advertise "~location_marker" "visualization_msgs/Marker")))
  *marker-publisher*)

(defun publish-marker-pose (pose &key (parent "map") id)
  (let ((point (cl-transforms:origin pose))
        (rot (cl-transforms:orientation pose))
        (current-index 0))
    (roslisp:publish (get-marker-publisher)
                     (roslisp:make-message "visualization_msgs/Marker"
                                           (std_msgs-msg:stamp header) 
                                           (roslisp:ros-time)
                                           (std_msgs-msg:frame_id header)
                                           (typecase pose
                                             (cl-tf:pose-stamped (cl-tf:frame-id pose))
                                             (t parent))
                                           ns "goal_locations"
                                           id (or id (incf current-index))
                                           type (roslisp:symbol-code
                                                 'visualization_msgs-msg:<marker> :cylinder)
                                           action (roslisp:symbol-code
                                                   'visualization_msgs-msg:<marker> :add)
                                           (x position pose) (cl-transforms:x point)
                                           (y position pose) (cl-transforms:y point)
                                           (z position pose) (cl-transforms:z point)
                                           (x orientation pose) (cl-transforms:x rot)
                                           (y orientation pose) (cl-transforms:y rot)
                                           (z orientation pose) (cl-transforms:z rot)
                                           (w orientation pose) (cl-transforms:w rot)
                                           (x scale) 0.3
                                           (y scale) 0.3
                                           (z scale) 0.3
                                           (r color) 1.0
                                           (g color) 0.0
                                           (b color) 0.0
                                           (a color) 1.0))))

(roslisp-utilities:register-ros-init-function init-perception-subscriber)
(roslisp-utilities:register-ros-init-function get-marker-publisher)
(roslisp-utilities:register-ros-cleanup-function cleanup-perception-subscriber)
