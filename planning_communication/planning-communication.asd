(defsystem planning-communication
  :depends-on (roslisp
               cram-language
               cl-tf
               actionlib
               geometry_msgs-msg
               tmc_msgs-msg
               standard_poses-srv)
  :components
  ((:module "src"
            :components
            ((:file "package")
             (:file "text-to-speech" :depends-on ("package"))
             (:file "move-to-standard-poses" :depends-on ("package"))))))
