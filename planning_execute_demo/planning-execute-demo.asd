(defsystem planning-execute-demo
  :depends-on (roslisp
               cram-language
               cl-tf
               actionlib
               geometry_msgs-msg
               tmc_msgs-msg
               planning-communication
               cram-hsr-low-level
               planning-common
               suturo_manipulation_msgs-msg)
  :components
  ((:module "src"
    :components
    ((:file "package")
     (:file "demo-poses" :depends-on ("package"))
     (:file "high-level" :depends-on ("package"))))))
