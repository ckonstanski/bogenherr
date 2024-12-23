;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass registration (postgres-record)
  ((id :initarg :id
       :initform nil
       :accessor id)
   (hash :initarg :hash
         :initform nil
         :accessor hash)
   (first_name :initarg :first_name
               :initform nil
               :accessor first_name)
   (last_name :initarg :last_name
              :initform nil
              :accessor last_name)
   (email :initarg :email
          :initform nil
          :accessor email)
   (role_groups :initarg :role_groups
                :initform nil
                :accessor role_groups)
   (created :initarg :created
            :initform nil)
   (valid_for :initarg :valid_for
              :initform nil
              :accessor valid_for)
   (*table :initform "auth.registrations")
   (*where-expression :initform "id = ~a"))
  (:documentation "Holds the data for an auth.registrations type."))

(defmethod created ((registration registration))
  (slot-value registration 'created))

(defmethod (setf created) (value (registration registration))
  (handler-case
      (setf (slot-value registration 'created) (simple-date-to-date value))
    (error (e)
      (declare (ignore e))
      (setf (slot-value registration 'created) nil))))
