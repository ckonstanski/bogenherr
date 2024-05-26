;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defclass about-us-service (rest-service)
  ()
  (:documentation ""))

(defun about-us-json ()
  (with-noauth (instance about-us-service)
    t))
