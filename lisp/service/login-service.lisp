;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass login-service (rest-service)
  ((form :initarg :form
         :initform nil
         :accessor form)
   (title :initarg :title
          :initform nil
          :accessor title))
  (:documentation ""))

(defclass login-forgot-service (login-service)
  ()
  (:documentation ""))

(defmethod initialize-instance :after ((login-service login-service) &key)
  (setf (title login-service) "Login")
  (setf (form login-service) (make-form "login-form"
                                        nil
                                        t
                                        '((:name "username" :label "Username" :field-type "text" :required "required")
                                          (:name "pwd" :label "Passworda" :field-type "password" :required "required")
                                          (:label "Login" :field-type "button" :onclick "on_login_submit_clicked()")))))

(defmethod initialize-instance :after ((login-forgot-service login-forgot-service) &key)
  (setf (title login-forgot-service) "Reset Password")
  (setf (form login-forgot-service) (make-form "login-forgot-form"
                                               nil
                                               t
                                               '((:name "username" :label "Username" :field-type "text" :required "required")
                                                 (:label "Send password reset email" :field-type "button" :onclick "on_login_forgot_submit_clicked()")))))

(defun login-json ()
  (with-noauth (instance login-service)
    t))

(defun login-forgot-json ()
  (with-noauth (instance login-forgot-service)
    t))

(defclass login-authenticate-service (rest-service)
  ((location-p :initform nil))
  (:documentation ""))

(defun login-authenticate-json (username pwd)
  (with-noauth (instance login-authenticate-service)
    (if (or (org-ckons-core::null-or-empty-p username)
            (org-ckons-core::null-or-empty-p pwd))
        (setf (session-value :errormsg) "Login failed.")
        (with-bogenherr-database
          (let* ((auth-pkg (make-instance 'auth-pkg))
                 (user (get-active-user-by-username-pwd auth-pkg username pwd)))
            (cond (user
                   (set-user user)
                   (setf (session-value :message) "Successfully logged in.")
                   (setf (session-value :errormsg) nil))
                  (t
                   (setf (session-value :message) nil)
                   (setf (session-value :errormsg) "Login failed."))))))
    (setf (message instance) (session-value :message))
    (setf (errormsg instance) (session-value :errormsg))))
