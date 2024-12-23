;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass user (org-ckons-session::session-object postgres-record)
  ((id :initarg :id
       :initform nil
       :accessor id)
   (username :initarg :username
             :initform nil
             :accessor username)
   (pwd :initarg :pwd
        :initform nil
        :accessor pwd)
   (first_name :initarg :first_name
               :initform nil
               :accessor first_name)
   (last_name :initarg :last_name
              :initform nil
              :accessor last_name)
   (email :initarg :email
          :initform nil
          :accessor email)
   (phone :initarg :phone
          :initform nil
          :accessor phone)
   (active :initarg :active
           :initform nil
           :accessor active)
   (created :initarg :created
            :initform nil)
   (*table :initform "auth.users")
   (*where-expression :initform "id = ~a")
   (org-ckons-session::*session-key :initform "user"))
  (:documentation "Holds the data for a user record."))

(defmethod created ((user user))
  (slot-value user 'created))

(defmethod (setf created) (value (user user))
  (handler-case
      (setf (slot-value user 'created) (simple-date-to-date value))
    (error (e)
      (declare (ignore e))
      (setf (slot-value user 'created) nil))))

(defmethod sanitize-json ((user user))
  (setf (pwd user) nil)
  (call-next-method))
