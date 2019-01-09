(defsystem cram-hsr-low-level
  :depends-on (roslisp
               roslisp-utilities
               cram-language
               cl-tf
               actionlib
               geometry_msgs-msg
               tmc_msgs-msg
               std_msgs-msg
               trajectory_msgs-msg
               standard_poses-srv)
  :components
  ((:module "src"
            :components
            ((:file "package")
             (:file "giskard" :depends-on ("package"))))))
