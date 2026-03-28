;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass profile-service (auth-service user)
  ((title :initarg :title
          :initform nil
          :accessor title))
  (:documentation ""))

(defun profile-json ()
  (with-auth (instance profile-service "profile-modify")
    (setf (title instance) "Profile")
    (sanitize-rest-json instance)))

(defun profile-view-json ()
  (with-auth (instance profile-service "profile-modify")
    (let ((user (get-user)))
      (copy-from-record instance user))
    (sanitize-rest-json instance)))

(defclass profile/modify-service (profile-service)
  ((form :initarg :form
         :initform nil
         :accessor form)
   (location-p :initform nil))
  (:documentation ""))

(defun profile-modify-json ()
  (with-auth (instance profile/modify-service "profile-modify")
    (let ((user (get-user)))
      (sanitize-rest-json instance)
      (setf (title instance) "Profile - Modify")
      (setf (form instance) (make-form "profile-modify-form"
                                       nil
                                       t
                                       `((:name "id" :label "" :field-type "hidden" :value ,(id user) :required "required")
                                         (:name "username" :label "Username" :field-type "text" :value ,(username user) :required "required")
                                         (:name "first_name" :label "First Name" :field-type "text" :value ,(first_name user) :required "required")
                                         (:name "last_name" :label "Last Name" :field-type "text" :value ,(last_name user) :required "required")
                                         (:name "email" :label "Email" :field-type "text" :value ,(email user) :required "required")
                                         (:name "phone" :label "Phone" :field-type "text" :value ,(phone user))
                                         (:label "Modify Profile" :field-type "button" :onclick "on_profile_modify_submit_clicked()")))))))

(defun profile-modify-submit-json (id username first_name last_name email phone)
  (declare (special username first_name last_name email phone))
  (with-auth (instance profile/modify-service "profile-modify")
    (with-bogenherr-database
      (let ((user (get-user)))
        (if (= (id user) id)
            (let ((auth-pkg (make-instance 'auth-pkg)))
              (loop for param in (remove-if (lambda (x)
                                              (intersection `(,x) '(id)))
                                            (sb-introspect:function-lambda-list #'profile-modify-submit-json))
                    do (setf (slot-value user param) (symbol-value param)))
              (copy-from-record instance user)
              (update-user auth-pkg user)
              (set-user user)
              (setf (session-value :message) "Profile saved successfully."))
            (setf (session-value :errormsg) "An error occured."))))))
