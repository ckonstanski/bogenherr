;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defclass contact-pkg (record-pkg)
  ()
  (:documentation ""))

(defmethod get-contact-us-posts ((contact-pkg contact-pkg) user-id read-p)
  (let ((contact-us-post (make-instance 'contact-us-post)))
    (setf (*table contact-us-post) (format nil (*table contact-us-post) user-id (if read-p "t" "f")))
    (get-records contact-pkg contact-us-post nil)))

(defmethod insert-contact-us-post ((contact-pkg contact-pkg) (contact-us-post contact-us-post))
  (setf (*table contact-us-post) (format nil
                                                        "contact.insert_contact_us_post('~a', '~a', '~a', '~a', '~a')"
                                                        (first_name contact-us-post)
                                                        (last_name contact-us-post)
                                                        (email contact-us-post)
                                                        (phone contact-us-post)
                                                        (comments contact-us-post)))
  (caar (call-pg-function contact-pkg contact-us-post)))

(defmethod mark-contact-us-post ((contact-pkg contact-pkg) contact-us-post-id user-id read-p)
  (let ((contact-us-post (make-instance 'contact-us-post
                                        :*table (format nil
                                                        "contact.mark_contact_us_post(~a, ~a, '~a')"
                                                        contact-us-post-id
                                                        user-id
                                                        (if read-p "t" "f")))))
    (call-pg-function contact-pkg contact-us-post)))
