;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass testimonials (postgres-record)
  ((id :initarg :id
       :initform nil
       :accessor id)
   (content :initarg :content
            :initform nil
            :accessor content)
   (*table :initform "general.testimonials")
   (*where-expression :initform "id = ~a"))
  (:documentation "Holds the data for a general.testimonials type."))
