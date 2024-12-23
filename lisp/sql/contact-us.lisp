;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass contact-us (postgres-record)
  ((id :initarg :id
       :initform nil
       :accessor id)
   (content :initarg :content
            :initform nil
            :accessor content)
   (*table :initform "contact.contact_us")
   (*where-expression :initform "id = ~a"))
  (:documentation "Holds the data for a contact.contact_us type."))

(defclass contact-us-post (postgres-record)
  ((id :initarg :id
       :initform nil
       :accessor id)
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
   (submitted :initarg :submitted
              :initform nil)
   (comments :initarg :comments
             :initform nil
             :accessor comments)
   (*table :initform "contact.get_contact_us_posts_by_id_and_read(~a, '~a')")
   (*where-expression :initform nil))
  (:documentation "Holds the data for a contact.contact_us_posts type."))

(defmethod submitted ((contact-us-post contact-us-post))
  (slot-value contact-us-post 'submitted))

(defmethod (setf submitted) (value (contact-us-post contact-us-post))
  (handler-case
      (setf (slot-value contact-us-post 'submitted) (simple-date-to-date value))
    (error (e)
      (declare (ignore e))
      (setf (slot-value contact-us-post 'submitted) nil))))
