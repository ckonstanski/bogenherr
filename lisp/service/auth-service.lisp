;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass auth-service (rest-service)
  ()
  (:documentation ""))

(defmethod initialize-instance :after ((auth-service auth-service) &key roles)
  (with-valid-user (session roles)
      (progn
        (setf (location auth-service) "/home")
        (setf (message auth-service) nil)
        (setf (errormsg auth-service) "You are not authorized to access this resource."))
    t))

(defmacro with-auth ((instance auth-service roles) &body body)
  `(let ((,instance (make-instance ',auth-service :roles ,roles)))
     (when (null (errormsg ,instance))
       ,@body)
     (when (location-p ,instance)
       (setf (session-value :message) nil)
       (setf (session-value :errormsg) nil))
     (org-ckons-json::objects-to-json `(,,instance))))

(defmacro with-auth-raw ((instance auth-service roles) &body body)
  `(let ((,instance (make-instance ',auth-service :roles ,roles)))
     (when (location-p ,instance)
       (setf (session-value :message) nil)
       (setf (session-value :errormsg) nil))
     (when (null (errormsg ,instance))
       ,@body)))

(defmacro with-noauth ((instance rest-service) &body body)
  `(let ((,instance (make-instance ',rest-service)))
     ,@body
     (when (location-p ,instance)
       (setf (session-value :message) nil)
       (setf (session-value :errormsg) nil))
     (org-ckons-json::objects-to-json `(,,instance))))

(defmacro with-noauth-raw ((instance rest-service) &body body)
  `(let ((,instance (make-instance ',rest-service)))
     (when (location-p ,instance)
       (setf (session-value :message) nil)
       (setf (session-value :errormsg) nil))
     ,@body))
