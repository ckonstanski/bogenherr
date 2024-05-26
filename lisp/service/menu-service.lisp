;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defparameter *menu-config* '((:id "a_menu_home" :label "Home" :handler "/home" :permissions "_Public")
                              (:id "a_menu_about_us" :label "About the Studio" :handler "/about-us" :permissions "_Public")
                              ;;(:id "a_menu_testimonials" :label "Testimonials" :handler "/testimonials" :permissions "_Public")
                              (:id "a_menu_contact_us" :label "Contact Me" :handler "/contact-us" :permissions "_Public")
                              (:id "a_menu_messages" :label "Messages" :handler "/messages" :permissions "messages-view")
                              (:id "a_menu_users" :label "Users" :handler "/users" :permissions "users-view")))

(defparameter *menu-user-config* '((:id "a_menu_login" :label "Login" :handler "/login" :permissions "_Public")
                                   (:id "a_menu_profile" :label "Edit Profile" :handler "/profile" :permissions "_Public")
                                   (:id "a_menu_password" :label "Change Password" :handler "/password" :permissions "_Public")
                                   (:id "a_menu_logout" :label "Logout" :handler "/logout" :permissions "_Public")))

(defclass menuitem ()
  ((id :initarg :id
       :initform nil
       :accessor id)
   (label :initarg :label
          :initform nil
          :accessor label)
   (handler :initarg :handler
            :initform nil
            :accessor handler)
   (permissions :initarg :permissions
                :initform nil
                :accessor permissions)
   (children :initarg :children
             :initform nil
             :accessor children))
  (:documentation ""))

(defclass menu-service (base-service)
  ((menuitems :initarg :menuitems
              :initform nil
              :accessor menuitems)
   (location-p :initarg :location-p
               :initform nil
               :accessor location-p))
  (:documentation ""))

(defclass menu-user-service (menu-service)
  ((label :initarg :label
          :initform nil
          :accessor label)
   (location-p :initarg :location-p
               :initform nil
               :accessor location-p))
  (:documentation ""))

(defmethod initialize-instance :after ((menu-service menu-service) &key user menu-config)
  (with-woodriverlessons-database
    (let ((auth-pkg (make-instance 'auth-pkg))
          (user-logged-in-p (and user (not (= (id user) 0))))
          roles)
      (setf roles (when user (get-all-roles auth-pkg user)))
      (setf (menuitems menu-service)
            (remove-if (lambda (menuitem)
                         (find-if (lambda (x)
                                    (string= (id menuitem) x))
                                  (if user-logged-in-p
                                      '("a_menu_login")
                                      '("a_menu_logout" "a_menu_profile" "a_menu_password"))))
                       (mapcar (lambda (x)
                                 (make-instance 'menuitem
                                                :id (getf x :id)
                                                :label (getf x :label)
                                                :handler (getf x :handler)
                                                :permissions (getf x :permissions)))
                               (remove-if 'null (mapcar (lambda (x)
                                                          (when (find-if (lambda (y)
                                                                           (string= (getf x :permissions) y))
                                                                         (mapcar (lambda (z)
                                                                                   (role_name z))
                                                                                 roles))
                                                            x))
                                                        menu-config))))))))

(defun menu-json ()
  (org-ckons-json::objects-to-json `(,(make-instance 'menu-service
                                                     :user (get-user)
                                                     :menu-config *menu-config*))))

(defun menu-user-json ()
  (let* ((user (get-user))
         (instance (make-instance 'menu-user-service
                                  :user user
                                  :menu-config *menu-user-config*)))
    (setf (label instance) (if user
                               (format nil "~a ~a" (first_name user) (last_name user))
                               "No User Found"))
    (org-ckons-json::objects-to-json `(,instance))))
