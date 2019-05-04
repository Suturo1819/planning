(in-package :chll)


;; dependencies: sound_play : sound_play-msg
;;               actionlib_lisp : actionlib
;;               roslisp : roslisp

(defvar *sound-play-client* nil)

(defun init-sound-play-client ()
  (setf *sound-play-client* (actionlib:make-action-client
                             "sound_play"
                             "sound_play/SoundRequestAction"))
  (roslisp:ros-info (sound-play)
                    "Waiting for sound_play action server...")
  ;; workaround for race condition in actionlib wait-for server
  (loop until (actionlib:wait-for-server *sound-play-client*))
  (roslisp:ros-info (sound-play)
                    "sound_play action client created."))

(defun get-sound-play-client ()
  (when (null *sound-play-client*)
    (init-sound-play-client))
  *sound-play-client*)

(defun make-sound-play-goal (say-string)
  (actionlib:make-action-goal
      (get-sound-play-client)
    (sound sound_request) (roslisp:symbol-code 'sound_play-msg:soundrequest :say)
    (command sound_request) (roslisp:symbol-code 'sound_play-msg:soundrequest :play_once)
    (volume sound_request) 1.0d0
    (arg sound_request) say-string))

(defun say (say-string)
  (unless (eq roslisp::*node-status* :running)
    (roslisp:start-ros-node "sound_play_lisp_client"))

  (multiple-value-bind (result status)
      (let ((actionlib:*action-server-timeout* 20.0))
        (actionlib:call-goal
         (get-sound-play-client)
         (make-sound-play-goal say-string)))
    (roslisp:ros-info (sound-play) "sound-play action finished.")
    (values result status)))


;; Example usage:
;; CL-USER> (say "hello there")
