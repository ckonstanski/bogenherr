;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defclass base-service ()
  ()
  (:documentation ""))

(defmacro loop-intersect-slots ((slot record other-object) &body body)
  `(loop for ,slot in (intersect-slots ,record (org-ckons-core::map-slot-names ,other-object)) do
        (when (slot-is-field-p ,slot)
          ,@body)))

(defmethod copy-from-record ((base-service base-service) (record record))
  (loop-intersect-slots (slot record base-service)
     (setf (slot-value base-service slot) (slot-value record slot))))

(defmethod copy-to-record ((base-service base-service) (record record))
  (loop-intersect-slots (slot record base-service)
     (setf (slot-value record slot) (slot-value base-service slot))))
