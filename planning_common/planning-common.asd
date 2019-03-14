(defsystem planning-common
  :depends-on (roslisp
               cram-language
               cl-tf
               actionlib
               geometry_msgs-msg
               tmc_msgs-msg
               planning-communication
               cram-hsr-low-level
               cram-prolog
               cram-designators
               cram-process-modules
               cram-language-designator-support
               cram-executive)
  :components
  ((:module "src"
    :components
    ((:file "package")
     (:file "init" :depends-on ("package"))
     (:file "designators" :depends-on ("package"))
     (:file "action_designators" :depends-on ("package"))
     (:file "process_modules" :depends-on ("package"
                                           "designators"))
     (:file "select_process_module" :depends-on ("package"
                                                 "process_modules"))
     (:file "high_level_plans" :depends-on ("package"
                                            "process_modules"
                                            "action_designators"
                                            "designators"))
     (:file "utils" :depends-on ("package"))))))
