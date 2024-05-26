;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defclass rest-service (base-service)
  ((location :initarg :location
             :initform nil
             :accessor location)
   (location-p :initarg :location-p
               :initform t
               :accessor location-p)
   (errormsg :initarg :errormsg
             :initform nil
             :accessor errormsg)
   (message :initarg :message
            :initform nil
            :accessor message))
  (:documentation ""))

(defmethod initialize-instance :after ((rest-service rest-service) &key)
  (when (location-p rest-service)
    (if (message rest-service)
        (setf (session-value :message) (message rest-service))
        (setf (message rest-service) (session-value :message)))
    (if (errormsg rest-service)
        (setf (session-value :errormsg) (errormsg rest-service))
        (setf (errormsg rest-service) (session-value :errormsg)))
    (when (null (location rest-service))
      (setf (location rest-service) (type-to-path rest-service)))))

(defun location-json (&optional (location "/home"))
  (format nil "{\"location\":\"~a\"}" location))

(defun type-to-path (rest-type)
  (concatenate 'string "/" (ppcre:regex-replace "-service$" (string-downcase (type-of rest-type)) "")))

(defmethod sanitize-rest-json ((rest-service rest-service))
  (loop for slot in (intersection '(org-ckons-session::*session-key *table *where-expression pwd)
                                  (org-ckons-core::map-slot-names rest-service)) do
       (setf (slot-value rest-service slot) nil)))
