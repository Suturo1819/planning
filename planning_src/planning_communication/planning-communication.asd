(defsystem planning-communication
  :depends-on (roslisp
               cl-tf
               actionlib
               geometry_msgs-msg
               tmc_msgs-msg)
  :components
  ((:module "src"
            :components
            ((:file "package")
             (:file "test" :depends-on ("package"))))))
