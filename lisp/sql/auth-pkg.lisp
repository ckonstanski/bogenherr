;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defparameter *authenticated-user-session-key* "authenticated-user")

(defclass auth-pkg (record-pkg)
  ()
  (:documentation ""))

(defmethod insert-user ((auth-pkg auth-pkg) user)
  (setf (*table user) (format nil
                              "auth.insert_user('~a', '~a', '~a', '~a', '~a', '~a', '~a')"
                              (username user)
                              (pwd user)
                              (first_name user)
                              (last_name user)
                              (email user)
                              (phone user)
                              (active user)))
  (setf (id user) (caar (call-pg-function auth-pkg user)))
  (id user))

(defmethod update-user ((auth-pkg auth-pkg) user)
  (setf (*table user) (format nil
                              "auth.update_user(~a, '~a', '~a', '~a', '~a', '~a')"
                              (id user)
                              (username user)
                              (first_name user)
                              (last_name user)
                              (email user)
                              (phone user)))
  (caar (call-pg-function auth-pkg user)))

(defmethod get-all-active-users ((auth-pkg auth-pkg))
  (let ((user (make-instance 'user)))
    (setf (*table user) "auth.get_all_active_users()")
    (get-records auth-pkg user "first_name asc, last_name asc")))

(defmethod get-all-users ((auth-pkg auth-pkg))
  (let ((user (make-instance 'user)))
    (setf (*table user) "auth.get_all_users()")
    (get-records auth-pkg user "first_name asc, last_name asc")))

(defmethod get-active-user-by-username-pwd ((auth-pkg auth-pkg) username pwd)
  (let ((user (make-instance 'user)))
    (setf (*table user) (format nil
                                               "auth.get_active_user_by_username_pwd('~a', '~a')"
                                               username
                                               pwd))
    (get-record auth-pkg user)))

(defmethod get-active-user-by-id ((auth-pkg auth-pkg) id)
  (let ((user (make-instance 'user)))
    (setf (*table user) (format nil "auth.get_active_user_by_id(~a)" id))
    (get-record auth-pkg user)))

(defmethod get-user-by-id ((auth-pkg auth-pkg) id)
  (let ((user (make-instance 'user)))
    (setf (*table user) (format nil "auth.get_user_by_id(~a)" id))
    (get-record auth-pkg user)))

(defmethod user-toggle-active ((auth-pkg auth-pkg) (user user))
  (setf (*table user) (format nil "auth.user_toggle_active(~a)" (id user)))
  (call-pg-function auth-pkg user))

(defmethod deactivate-user ((auth-pkg auth-pkg) (user user))
  (setf (*table user) (format nil "auth.user_delete(~a)" (id user)))
  (call-pg-function auth-pkg user))

(defmethod get-all-roles ((auth-pkg auth-pkg) (user user))
  (let ((user-role (make-instance 'user-role
                                  :*table (format nil
                                                  "auth.get_all_roles_for_user(~a)"
                                                  (id user)))))
    (get-records auth-pkg user-role nil)))

(defmethod has-role ((auth-pkg auth-pkg) (user user) role)
  (let ((user-role (make-instance 'user-role)))
    (setf (*table user-role) (format nil (*table user-role) (id user) role))
    (get-record auth-pkg user-role)))

(defmethod get-all-role-groups ((auth-pkg auth-pkg) (user user))
  (let ((role-group (make-instance 'role-group)))
    (setf (*table role-group) (format nil (*table role-group) (id user)))
    (get-records auth-pkg role-group nil)))

(defmethod get-role-group-by-name ((auth-pkg auth-pkg) (user user) name)
  (find-if (lambda (x)
             (string= name (name x)))
           (get-all-role-groups auth-pkg user)))

(defmethod get-active-role-groups ((auth-pkg auth-pkg) (user user))
  (let ((role-group (make-instance 'role-group
                                   :*table (format nil
                                                   "auth.get_active_role_groups_for_user(~a)"
                                                   (id user)))))
    (get-records auth-pkg role-group nil)))

(defmethod insert-user-role-group ((auth-pkg auth-pkg) (user-role user-role))
  (setf (*table user-role) (format nil
                                                  "auth.insert_user_role_group(~a, '~a')"
                                                  (user_id user-role)
                                                  (role_group_name user-role)))
  (caar (call-pg-function auth-pkg user-role)))

(defmethod insert-registration ((auth-pkg auth-pkg) (registration registration))
  (setf (*table registration) (format nil
                                                     "auth.insert_registration('~a', '~a', '~a', '~a')"
                                                     (first_name registration)
                                                     (last_name registration)
                                                     (email registration)
                                                     (role_groups registration)))
  (setf (id registration) (caar (call-pg-function auth-pkg registration)))
  (id registration))

(defmethod delete-role-groups ((auth-pkg auth-pkg) user)
  (let ((role-group (make-instance 'role-group
                                   :*table (format nil
                                                   "auth.delete_role_groups_for_user(~a)"
                                                   (id user)))))
    (call-pg-function auth-pkg role-group)))

(defmethod get-registration-by-id ((auth-pkg auth-pkg) id)
  (let ((registration (make-instance 'registration
                                     :*table (format nil "auth.get_registration_by_id(~a)" id))))
    (get-record auth-pkg registration)))

(defmethod get-registration-by-hash ((auth-pkg auth-pkg) hash)
  (let ((registration (make-instance 'registration
                                     :*table (format nil "auth.get_registration_by_hash('~a')" hash))))
    (get-record auth-pkg registration)))

(defmethod registrations-gc ((auth-pkg auth-pkg))
  (let ((registration (make-instance 'registration :*table "auth.registrations_gc()")))
    (call-pg-function auth-pkg registration)))

(defmethod delete-registration ((auth-pkg auth-pkg) hash)
  (let ((registration (make-instance 'registration
                                     :*table (format nil "auth.delete_registration('~a')" hash))))
    (call-pg-function auth-pkg registration)))

(defmethod update-profile ((auth-pkg auth-pkg) (user user))
  (setf (*table user) (format nil
                                             "auth.update_profile(~a, '~a', '~a', '~a', '~a', '~a')"
                                             (id user)
                                             (username user)
                                             (first_name user)
                                             (last_name user)
                                             (email user)
                                             (phone user)))
  (call-pg-function auth-pkg user))

(defmethod update-password ((auth-pkg auth-pkg) (user user))
  (setf (*table user) (format nil "auth.update_password(~a, '~a')" (id user) (pwd user)))
  (call-pg-function auth-pkg user))

(defmacro with-valid-user ((session-name roles) error-body &body body)
  "Runs `body' if there is a valid authenticated `user' in the
`user-session' whose roles match `roles', otherwise runs
`error-body'. If a valid `user' exists, it will be bound to
`session-name'."
  `(let ((,session-name (get-session-object *authenticated-user-session-key*)))
     (if ,session-name
         (let* ((auth-pkg (make-instance 'auth-pkg))
                (has-all-roles-p (let ((has-all-roles-p t))
                                   (with-woodriverlessons-database
                                     (loop for role in (if (listp ,roles) ,roles (list ,roles)) do
                                          (when (not (has-role auth-pkg ,session-name role))
                                            (setf has-all-roles-p nil)))
                                     has-all-roles-p))))
           (if has-all-roles-p
               ,@body
               ,error-body))
         ,error-body)))

(defun make-default-user ()
  "Convenience function for making a new instance of `user' that has
its session key set to `authenticated-user', but has no privileges."
  (make-instance 'user
                 :*session-key *authenticated-user-session-key*
                 :id 0
                 :first_name "Guest"
                 :last_name "User"))

(defun ensure-user-exists ()
  "Ensures that there is an `authenticated-user' in the user session,
even if it's just a guest user."
  (let ((user (get-session-object *authenticated-user-session-key*)))
    (unless user
      (setf user (make-default-user))
      (set-user user))))

(defun get-user ()
  "Convenience function for getting the `authenticated-user' from user
session."
  (get-session-object *authenticated-user-session-key*))

(defun set-user (user)
  "Convenience function for setting the `authenticated-user' into the
user session."
  (setf (*table user) "auth.users")
  (setf (pwd user) nil)
  (set-session-object *authenticated-user-session-key* user))
