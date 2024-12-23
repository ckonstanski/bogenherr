;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defgeneric get-site-file-path (webapp)
  (:documentation "Builds a full filesystem path to a webapp's site
file."))

(defgeneric get-pages-file-paths (webapp)
  (:documentation ""))
 
