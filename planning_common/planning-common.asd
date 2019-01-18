(defsystem planning-common
  :depends-on (roslisp
               cram-language
               cl-tf
               actionlib
               geometry_msgs-msg
               tmc_msgs-msg
               planning-communication
               cram-hsr-low-level)
  :components
  ((:module "src"
    :components
    ((:file "package")
     (:file "init" :depends-on ("package"))))))
