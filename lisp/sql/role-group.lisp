;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass role-group (postgres-record)
  ((user_role_group_id :initarg :user_role_group_id
                       :initform nil
                       :accessor user_role_group_id)
   (user_id :initarg :user_id
            :initform nil
            :accessor user_id)
   (role_group_id :initarg :role_group_id
                  :initform nil
                  :accessor role_group_id)
   (name :initarg :name
         :initform nil
         :accessor name)
   (description :initarg :description
                :initform nil
                :accessor description)
   (*table :initform "auth.get_all_role_groups_for_user(~a)")
   (*where-expression :initform nil))
  (:documentation "Holds the data for an auth.role_group_t type."))
