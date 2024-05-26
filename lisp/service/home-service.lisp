;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defclass home-service (rest-service)
  ((content :initarg :content
            :initform nil
            :accessor content))
  (:documentation ""))

(defmethod initialize-instance :after ((home-service home-service) &key)
  t)

(defun home-json (&optional message errormsg)
  (with-noauth (instance home-service)
    (when (not (org-ckons-core::null-or-empty-p message)) (setf (message instance) message))
    (when (not (org-ckons-core::null-or-empty-p errormsg)) (setf (errormsg instance) errormsg))))
