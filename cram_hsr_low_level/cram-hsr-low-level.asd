(defsystem cram-hsr-low-level
  :depends-on (roslisp
               roslisp-utilities
               cram-language
               cram-common-failures
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
             (:file "simple-actionlib-client" :depends-on ("package"))
             (:file "giskard-poses" :depends-on ("package" "simple-actionlib-client"))
             (:file "giskard-joints" :depends-on ("package" "simple-actionlib-client"))
             (:file "test-giskard" :depends-on ("package"))
             (:file "giskard" :depends-on ("package"))))))
