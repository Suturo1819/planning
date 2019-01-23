(defpackage :planning-communication
  (:nicknames :pc)
  (:use :roslisp :cl)
  (:export
   init-action-client
   get-action-client
   make-next-action-goal
   call-text-to-speech-action
   init-perception-subscriber
   publish-dummy-message
   get-perceived-data))
