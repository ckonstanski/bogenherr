;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass users-service (auth-service)
  ((title :initarg :title
          :initform nil
          :accessor title))
  (:documentation ""))

(defun users-json ()
  (with-auth (instance users-service "users-view")
    (setf (title instance) "Users")))

(defclass users/view-service (users-service user)
  ((users :initarg :users
          :initform nil
          :accessor users)
   (location-p :initform nil))
  (:documentation ""))

(defun users-view-json ()
  (with-auth (instance users/view-service "users-view")
    (with-bogenherr-database
      (let ((auth-pkg (make-instance 'auth-pkg)))
        (setf (users instance) (get-all-users auth-pkg))))
    (sanitize-rest-json instance)
    (loop for user in (users instance) do
         (sanitize-json user))))

(defclass users/add-service (users/view-service)
  ((form :initarg :form
         :initform nil
         :accessor form))
  (:documentation ""))

(defun role-checkboxes (role-groups &optional active-role-groups)
  (remove-if 'null
             (mapcar (lambda (role-group)
                       (when (not (intersection `(,(name role-group)) `("_Public" "profile-admin") :test 'string=))
                         (let ((checked (when (intersection `(,(name role-group))
                                                            (mapcar (lambda (x)
                                                                      (name x))
                                                                    active-role-groups)
                                                            :test 'string=)
                                          '(:checked "checked" :value "on"))))
                           (remove-if 'null `(:name ,(format nil "chk_~a" (name role-group)) :label ,(name role-group) :field-type "checkbox" ,@checked)))))
                     role-groups)))

(defun users-add-json ()
  (with-auth (instance users/add-service "users-modify")
    (setf (title instance) "Users - Add")
    (with-bogenherr-database
      (let* ((auth-pkg (make-instance 'auth-pkg))
             (user (get-user))
             (role-groups (get-all-role-groups auth-pkg user)))
        (setf (form instance) (make-form "users-add-form"
                                         nil
                                         t
                                         `((:name "first_name" :label "First Name" :field-type "text" :required "required")
                                           (:name "last_name" :label "Last Name" :field-type "text" :required "required")
                                           (:name "email" :label "Email" :field-type "text" :required "required")
                                           ,@(role-checkboxes role-groups)
                                           (:label "Add User" :field-type "button" :onclick "on_users_add_submit_clicked()"))))))))

(defun users-add-submit-json (role_groups first_name last_name email)
  (declare (special role_groups first_name last_name email))
  (with-auth (instance users/add-service "users-modify")
    (with-bogenherr-database
      (let ((registration (make-instance 'registration)))
        (loop for param in (sb-introspect:function-lambda-list #'users-add-submit-json) do
             (setf (slot-value registration param) (symbol-value param)))
        (let* ((auth-pkg (make-instance 'auth-pkg))
               (id (insert-registration auth-pkg registration)))
          (setf registration (get-registration-by-id auth-pkg id)))
        (handler-case
            (let ((text-message (format nil
                                        "Hello ~a ~a and welcome to the ~a website!~%~%A user account registration has been created for you. It expires in 3 days.~%~%Please click the following link to complete the registration:~%~%~a://~a/register?hash=~a~%"
                                        (name *webapp*)
                                        (first_name registration)
                                        (last_name registration)
                                        (scheme *webapp*)
                                        (url *webapp*)
                                        (hash registration)))
                  (html-message (org-ckons-http::html5
                                 `(html
                                   ((p)
                                    ,(format nil
                                             "Hello ~a ~a and welcome to ~a!"
                                             (name *webapp*)
                                             (first_name registration)
                                             (last_name registration)))
                                   ((p) "A user account registration has been created for you. It expires in 3 days.")
                                   ((p) "Please click the following link to complete the registration:")
                                   ((p)
                                    ((a :href ,(format nil
                                                       "~a://~a/register?hash=~a"
                                                       (scheme *webapp*)
                                                       (url *webapp*)
                                                       (hash registration)))
                                     ,(format nil
                                              "~a://~a/register?hash=~a"
                                              (scheme *webapp*)
                                              (url *webapp*)
                                              (hash registration))))))))
              (org-ckons-core::sendmail (mail-mx *webapp*)
                                        (mail-info *webapp*)
                                        (email registration)
                                        (format nil "~a website registration" (name *webapp*))
                                        text-message
                                        :html-message html-message
                                        :reply-to (mail-postmaster *webapp*)
                                        :ssl (mail-ssl *webapp*)
                                        :authentication (mail-authentication *webapp*))
              (setf (session-value :message) (format nil "Email sent successfully to ~a" (email registration))))
          (error (e)
            (setf (session-value :errormsg) (format nil "Error sending email to ~a. Registration failed. ~a" (email registration) e))))))))

(defclass users/register-service (rest-service)
  ((title :initarg :title
          :initform nil
          :accessor title)
   (hash :initarg :hash
         :initform nil
         :accessor hash))
  (:documentation ""))

(defun users-register-json (hash)
  (with-noauth (instance users/register-service)
    (setf (title instance) "New User Registration")
    (setf (hash instance) hash)))

(defclass users/register/form-service (rest-service)
  ((form :initarg :form
         :initform nil
         :accessor form)
   (location-p :initform nil))
  (:documentation ""))

(defun users-register-form-json (hash)
  (with-noauth (instance users/register/form-service)
    (with-bogenherr-database
      (let* ((auth-pkg (make-instance 'auth-pkg))
             (registration (get-registration-by-hash auth-pkg hash)))
        (registrations-gc auth-pkg)
        (if registration
            (progn
              (setf (form instance)
                    (make-form "users-register-form"
                               nil
                               t
                               `((:name "hash" :field-type "hidden" :value ,(hash registration) :required "required")
                                 (:name "username" :label "Username" :field-type "text" :required "required")
                                 (:name "pwd" :label "Password" :field-type "password" :required "required")
                                 (:name "pwd2" :label "Password (again)" :field-type "password" :required "required")
                                 (:name "phone" :label "Phone" :field-type "text")
                                 (:label "Register" :field-type "button" :onclick "on_users_register_submit_clicked()"))))
              (setf (session-value :message) "Registered successfully."))
            (setf (session-value :errormsg) "Error: invalid registration."))))))

(defclass users/register/submit-service (rest-service)
  ((location-p :initform nil))
  (:documentation ""))

(defun users-register-submit-json (hash username pwd pwd2 phone)
  (with-noauth (instance users/register/submit-service)
    (with-bogenherr-database
      (let ((auth-pkg (make-instance 'auth-pkg))
            registration)
        (registrations-gc auth-pkg)
        (setf registration (get-registration-by-hash auth-pkg hash))
        (org-ckons-json::objects-to-json
         `(,(if registration
                (if (string= pwd pwd2)
                    (let ((user (make-instance 'user
                                               :username username
                                               :pwd pwd
                                               :first_name (first_name registration)
                                               :last_name (last_name registration)
                                               :email (email registration)
                                               :phone phone
                                               :active t)))
                      (if (insert-user auth-pkg user)
                          (progn
                            (loop for role-group in (union '("profile-admin")
                                                           (cl-ppcre:split "\\|" (role_groups registration))
                                                           :test 'string=) do
                                 (insert-user-role-group auth-pkg (make-instance 'user-role
                                                                                 :user_id (id user)
                                                                                 :role_group_name role-group)))
                            (delete-registration auth-pkg hash)
                            (setf (session-value :message) "Registration completed successfully."))
                          (setf (session-value :errormsg) "Error while completing registration.")))
                    (setf (session-value :errormsg) "Error: passwords do not match."))
                (setf (session-value :errormsg) "Error while completing registration."))))))))

(defclass users/modify-service (users/add-service)
  ()
  (:documentation ""))

(defun users-modify-json (id)
  (with-auth (instance users/modify-service "users-modify")
    (setf (title instance) "Users - Modify")
    (with-bogenherr-database
      (let* ((auth-pkg (make-instance 'auth-pkg))
             (me (get-user))
             (user (get-user-by-id auth-pkg id))
             (role-groups (get-all-role-groups auth-pkg me))
             (active-role-groups (get-active-role-groups auth-pkg user)))
        (if user
            (setf (form instance) (make-form "users-modify-form"
                                             nil
                                             t
                                             `((:name "id" :field-type "hidden" :value ,(id user) :required "required")
                                               (:name "username" :label "Username" :field-type "text" :value ,(username user) :required "required")
                                               (:name "first_name" :label "First Name" :field-type "text" :value ,(first_name user) :required "required")
                                               (:name "last_name" :label "Last Name" :field-type "text" :value ,(last_name user) :required "required")
                                               (:name "email" :label "Email" :field-type "text" :value ,(email user) :required "required")
                                               (:name "phone" :label "Phone" :field-type "text" :value ,(phone user))
                                               ,@(role-checkboxes role-groups active-role-groups)
                                               (:label "Modify User" :field-type "button" :onclick "on_users_modify_submit_clicked()"))))
            (setf (session-value :errormsg) "Error: could not modify user. Not found."))))))

(defun users-modify-submit-json (id role_groups username first_name last_name email phone)
  (declare (special role_groups username first_name last_name email phone))
  (with-auth (instance users/modify-service "users-modify")
    (with-bogenherr-database
      (let* ((auth-pkg (make-instance 'auth-pkg))
             (user (get-active-user-by-id auth-pkg id)))
        (if user
            (progn
              (loop for param in (remove-if (lambda (x)
                                              (intersection `(,x) '(id role_groups)))
                                            (sb-introspect:function-lambda-list #'users-modify-submit-json))
                    do (setf (slot-value user param) (symbol-value param)))
              (update-user auth-pkg user)
              (delete-role-groups auth-pkg user)
              (loop for role-group in (union '("profile-admin")
                                             (cl-ppcre:split "\\|" role_groups)
                                             :test 'string=) do
                   (insert-user-role-group auth-pkg (make-instance 'user-role
                                                                   :user_id (id user)
                                                                   :role_group_name role-group)))
              (setf (session-value :message) "User saved successfully."))
            (setf (session-value :errormsg) "An error occured."))))))

(defclass users/toggle-service (users/add-service)
  ()
  (:documentation ""))

(defun users-toggle-active-json (id)
  (with-auth (instance users/toggle-service "users-modify")
    (with-bogenherr-database
      (let* ((auth-pkg (make-instance 'auth-pkg))
             (user (get-user-by-id auth-pkg id)))
        (if user
            (if (= (id user) (id (get-user)))
                (setf (session-value :errormsg) "Error: you may not toggle your own active state.")
                (progn
                  (user-toggle-active auth-pkg user)
                  (setf (session-value :errormsg) nil)
                  (setf (session-value :message) "User active state toggled successfully.")))
            (setf (session-value :errormsg) "Error: could not toggle the active state of the user: not found."))))))

(defclass users/delete-service (users/add-service)
  ()
  (:documentation ""))

(defun users-delete-json (id)
  (with-auth (instance users/delete-service "users-modify")
    (with-bogenherr-database
      (let* ((auth-pkg (make-instance 'auth-pkg))
             (user (get-user-by-id auth-pkg id)))
        (if user
            (if (= (id user) (id (get-user)))
                (setf (session-value :errormsg) "Error: you may not delete yourself.")
                (progn
                  (deactivate-user auth-pkg user)
                  (setf (session-value :errormsg) nil)
                  (setf (session-value :message) "User deleted successfully.")))
            (setf (session-value :errormsg) "Error: could not delete user: not found."))))))
