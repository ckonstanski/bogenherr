;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defclass general-pkg (record-pkg)
  ()
  (:documentation ""))

(defmethod get-about-us ((general-pkg general-pkg))
  (car (get-records general-pkg (make-instance 'about-us) nil)))

(defmethod get-testimonials ((general-pkg general-pkg))
  (car (get-records general-pkg (make-instance 'testimonials) nil)))
