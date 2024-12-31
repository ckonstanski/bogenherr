;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defvar *user-session-mutex* (sb-thread:make-mutex :name "*user-session-mutex*"))

(defclass user-session-pkg (record-pkg)
  ()
  (:documentation "Database-backed user session API."))

(defmethod get-user-sessions ((user-session-pkg user-session-pkg))
  (get-records user-session-pkg (make-instance 'user-session) "sessionid ASC"))

(defmethod get-user-session ((user-session-pkg user-session-pkg) &optional (sessionid *sessionid*))
  (when sessionid
    (get-record user-session-pkg (make-instance 'user-session :sessionid sessionid))))

(defmethod update-timestamp ((user-session-pkg user-session-pkg) (user-session user-session))
  (setf (datetime user-session) (get-universal-time))
  (update-record user-session-pkg user-session))

(defmethod get-user-session-objects ((user-session-pkg user-session-pkg) (user-session user-session))
  (get-records user-session-pkg (make-instance 'user-session-object :user_session_id (id user-session)) "session_key ASC"))

(defmethod get-user-session-object ((user-session-pkg user-session-pkg) session-key)
  (when (and *sessionid* session-key)
    (let ((user-session (get-user-session user-session-pkg)))
      (when user-session
        (get-record user-session-pkg (make-instance 'user-session-object :user_session_id (id user-session) :session_key session-key))))))

(defmethod flush-user-session-object ((user-session-pkg user-session-pkg) session-key)
  (when (and *sessionid* session-key)
    (let ((user-session-object (get-user-session-object user-session-pkg session-key)))
      (when user-session-object
        (delete-record user-session-pkg user-session-object)))))

(defmethod create-user-session ((user-session-pkg user-session-pkg))
  (let* ((sessionid (org-ckons-session::generate-sessionid))
         (user-session (make-instance 'user-session :sessionid sessionid :datetime (get-universal-time))))
    (insert-record user-session-pkg user-session)
    sessionid))

(defun get-session-object (session-key)
  "Returns the object stored in the user session under the given
`session-key'."
  (with-bogenherr-database
    (let* ((user-session-pkg (make-instance 'user-session-pkg))
           (user-session-object (get-user-session-object user-session-pkg session-key))
           object)
      (when user-session-object
        (setf object (org-ckons-serializable::deserialize (serialization user-session-object)))
        (setf (org-ckons-session::*session-key object) session-key))
      object)))

(defun set-session-object (session-key object)
  "Sets the object into the user-session under the given
`session-key'. Will not write anything if the session given by
`*sessionid*' does not exist."
  (with-bogenherr-database
    (let* ((user-session-pkg (make-instance 'user-session-pkg))
           (user-session-object (get-user-session-object user-session-pkg session-key)))
      (if user-session-object
          ;; overwrite existing session object with current serialization
          (progn
            (setf (serialization user-session-object) (org-ckons-serializable::serialize object :package-name (package-name #.*package*)))
            (update-record user-session-pkg user-session-object))
          ;; insert a new object into the session
          (let ((user-session (get-user-session user-session-pkg)))
            (when user-session
              (setf user-session-object (make-instance 'user-session-object
                                                       :user_session_id (id user-session)
                                                       :session_key session-key
                                                       :serialization (org-ckons-serializable::serialize object :package-name (package-name #.*package*))))
              (insert-record user-session-pkg user-session-object)))))))

(defun flush-session-object (session-key)
  "Removes the object from the user session under the given
`session-key'."
  (with-bogenherr-database
    (let ((user-session-pkg (make-instance 'user-session-pkg)))
      (flush-user-session-object user-session-pkg *sessionid* session-key))))

(defun ensure-user-session-exists (&optional force-new-sessionid-p)
  "Ensures that the user has a valid sessionid cookie. Returns the
`sessionid'. If the session does exist, update its timestamp."
  (sb-thread:with-mutex (*user-session-mutex*)
    (run-garbage-collect-cycle)
    (with-bogenherr-database
      (let* ((user-session-pkg (make-instance 'user-session-pkg))
             (sessionid (when (not force-new-sessionid-p)
                          (org-ckons-session::get-sessionid-from-request)))
             (user-session (get-user-session user-session-pkg sessionid)))
        (if user-session
            (update-timestamp user-session-pkg user-session)
            (progn
              (setf sessionid (create-user-session user-session-pkg))
              (org-ckons-session::set-sessionid-cookie *header-register* sessionid)))
        sessionid))))

(defun run-garbage-collect-cycle ()
  "Goes through all the user sessions, expiring any that have remained
inactive for a period of time determined by the `*session-timeout*'
variable."
  (when (> (- (get-universal-time) org-ckons-session::*gc-last-cycle-timestamp*) org-ckons-session::*gc-interval*)
    (setf org-ckons-session::*gc-last-cycle-timestamp* (get-universal-time))
    (with-bogenherr-database
      (let ((user-session-pkg (make-instance 'user-session-pkg)))
        (loop for user-session in (get-user-sessions user-session-pkg) do
          (let ((inactive-time (- org-ckons-session::*gc-last-cycle-timestamp* (datetime user-session))))
            (when (and (> inactive-time org-ckons-session::*session-timeout*)
                       (sessionid user-session))
              (org-ckons-core::logger (format nil "Deleting expired session: id = [~a] ; sessionid = [~a]" (id user-session) (sessionid user-session)))
              (loop for user-session-object in (get-user-session-objects user-session-pkg user-session) do
                (delete-record user-session-pkg user-session-object))
              (delete-record user-session-pkg user-session))))))))
