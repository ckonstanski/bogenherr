;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(defpackage :bogenherr
  (:use :cl :cl-log :hunchentoot :org-ckons-sql))

(in-package :bogenherr)
