;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defclass general-pkg (record-pkg)
  ()
  (:documentation ""))

(defmethod get-about-us ((general-pkg general-pkg))
  (get-record general-pkg (make-instance 'about-us)))

(defmethod get-testimonials ((general-pkg general-pkg))
  (get-record general-pkg (make-instance 'testimonials)))

(defmethod get-gallery ((general-pkg general-pkg) id)
  (let ((gallery (make-instance 'gallery :*table (format nil "general.get_gallery(~a)" id))))
    (get-record general-pkg gallery)))

(defmethod get-galleries ((general-pkg general-pkg))
  (let ((gallery (make-instance 'gallery :*table (format nil "general.get_galleries()"))))
    (get-records general-pkg gallery nil)))

(defmethod insert-gallery ((general-pkg general-pkg) (gallery gallery))
  (setf (*table gallery) (format nil
                                 "general.insert_gallery('~a', '~a', '~a', '~a')"
                                 (description gallery)
                                 (filename gallery)
                                 (mime_type gallery)
                                 (content gallery)))
  (setf (id gallery) (caar (call-pg-function general-pkg gallery)))
  (id gallery))

(defmethod update-gallery ((general-pkg general-pkg) (gallery gallery))
  (setf (*table gallery) (format nil
                                 "general.update_gallery(~a, '~a', '~a', '~a', '~a')"
                                 (id gallery)
                                 (description gallery)
                                 (filename gallery)
                                 (mime_type gallery)
                                 (content gallery)))
  (caar (call-pg-function general-pkg gallery)))
