;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defclass user-session (postgres-record)
  ((id :initarg :id
       :initform nil
       :accessor id)
   (sessionid :initarg :sessionid
              :initform nil
              :accessor sessionid)
   (datetime :initarg :datetime
             :initform nil
             :accessor datetime)
   (*table :initform "auth.user_sessions")
   (*where-expression :initform "id = ~a"))
  (:documentation "Holds the data for a auth.user_session record."))

(defclass user-session-object (postgres-record)
  ((id :initarg :id
       :initform nil
       :accessor id)
   (user_session_id :initarg :user_session_id
                    :initform nil
                    :accessor user_session_id)
   (session_key :initarg :session_key
                :initform nil
                :accessor session_key)
   (serialization :initarg :serialization
                  :initform nil
                  :accessor serialization)
   (*table :initform "auth.user_session_objects")
   (*where-expression :initform "id = ~a"))
  (:documentation "Holds the data for a auth.user_session record."))
