;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defgeneric copy-from-record (base-service record)
  (:documentation "Copies the fields from `record' to
`base-service'."))

(defgeneric copy-to-record (base-service record)
  (:documentation "Copies the fields from `base-service' to
`record'."))

(defgeneric sanitize-rest-json (rest-service)
  (:documentation ""))
