(defsystem planning-communication
  :depends-on (roslisp
               cram-language
               cl-tf
               actionlib
               geometry_msgs-msg
               tmc_msgs-msg
)
  :components
  ((:module "src"
            :components
            ((:file "package")
             (:file "text-to-speech" :depends-on ("package"))))))
