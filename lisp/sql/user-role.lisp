;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass user-role (postgres-record)
  ((user_role_group_id :initarg :user_role_group_id
                       :initform nil
                       :accessor user_role_group_id)
   (user_id :initarg :user_id
            :initform nil
            :accessor user_id)
   (role_group_id :initarg :role_group_id
                  :initform nil
                  :accessor role_group_id)
   (role_group_name :initarg :role_group_name
                    :initform nil
                    :accessor role_group_name)
   (role_group_description :initarg :role_group_description
                           :initform nil
                           :accessor role_group_description)
   (role_group_role_id :initarg :role_group_role_id
                       :initform nil
                       :accessor role_group_role_id)
   (role_id :initarg :role_id
            :initform nil
            :accessor role_id)
   (role_name :initarg :role_name
              :initform nil
              :accessor role_name)
   (role_description :initarg :role_description
                     :initform nil
                     :accessor role_description)
   (*table :initform "auth.has_role(~a, '~a')")
   (*where-expression :initform nil))
  (:documentation "Holds the data for an auth.user_role_t type."))
