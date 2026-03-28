;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass password-service (auth-service user)
  ((form :initarg :form
         :initform nil
         :accessor form)
   (title :initarg :title
          :initform nil
          :accessor title))
  (:documentation ""))

(defun password-json ()
  (with-auth (instance password-service "profile-modify")
    (let ((user (get-user)))
      (setf (title instance) "Change Password")
      (setf (form instance) (make-form "password-form"
                                       nil
                                       t
                                       `((:name "id" :label "" :field-type "hidden" :value ,(id user) :required "required")
                                         (:name "pwd" :label "Password" :field-type "password" :required "required")
                                         (:name "pwd2" :label "Password (again)" :field-type "password" :required "required")
                                         (:label "Change Password" :field-type "button" :onclick "on_password_submit_clicked()")))))))

(defclass password/modify-service (password-service)
  ((form :initarg :form
         :initform nil
         :accessor form)
   (location-p :initform nil))
  (:documentation ""))

(defun password-submit-json (id pwd pwd2)
  (declare (special pwd pwd2))
  (with-auth (instance password/modify-service "profile-modify")
    (setf (title instance) "Change Password")
    (with-bogenherr-database
      (let ((user (get-user)))
        (if (and (= id (id user))
                 (string= pwd pwd2))
            (let ((auth-pkg (make-instance 'auth-pkg)))
              (loop for param in (remove-if (lambda (x)
                                              (intersection `(,x) '(id pwd2)))
                                            (sb-introspect:function-lambda-list #'password-submit-json))
                    do (setf (slot-value user param) (symbol-value param)))
              (update-password auth-pkg user)
              (set-user user)
              (setf (session-value :message) "Password saved successfully."))
            (setf (session-value :errormsg) "An error occured."))))))
