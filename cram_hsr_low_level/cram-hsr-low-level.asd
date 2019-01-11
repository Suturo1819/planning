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
               control_msgs-msg
               move-msg)
  :components
  ((:module "src"
            :components
            ((:file "package")
             (:file "giskard" :depends-on ("package"))))))
