;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass logout-service (rest-service)
  ((location-p :initform nil))
  (:documentation ""))

(defun logout-json ()
  (with-noauth (instance logout-service)
    (set-user (make-default-user))
    (setf (location instance) "/home")
    (setf (message instance) "You are now logged out.")))
