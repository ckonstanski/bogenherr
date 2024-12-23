;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass messages-service (auth-service)
  ((title :initarg :title
          :initform nil
          :accessor title)
   (form :initarg :form
         :initform nil
         :accessor form))
  (:documentation ""))

(defun messages-json ()
  (with-auth (instance messages-service "messages-view")
    (setf (title instance) "Messages Administration")
    (setf (form instance) (make-form "messages-select-mode-form"
                                     nil
                                     nil
                                     `((:name "read" :field-type "hidden" :required "required" :value ,(session-value :messages-read))
                                       (:label "View Unread" :field-type "button" :onclick "on_messages_mode_clicked('unread')")
                                       (:label "View Read" :field-type "button" :onclick "on_messages_mode_clicked('read')"))))))

(defclass messages/results-service (messages-service)
  ((results :initarg :results
            :initform nil
            :accessor results)
   (location-p :initform nil))
  (:documentation ""))

(defun messages-results-json (read)
  (with-auth (instance messages/results-service "messages-view")
    (when read (setf (session-value :messages-read) read))
    (with-bogenherr-database
      (let ((contact-pkg (make-instance 'contact-pkg)))
        (setf (results instance) (get-contact-us-posts contact-pkg
                                                       (id (get-user))
                                                       (string= (session-value :messages-read) "read")))))
    (sanitize-rest-json instance)
    (loop for result in (results instance) do
         (sanitize-json result))))

(defclass messages/mark-service (messages-service)
  ((location-p :initform nil))
  (:documentation ""))

(defun messages-mark-json (read id)
  (with-auth (instance messages/mark-service "messages-view")
    (with-bogenherr-database
      (handler-case
          (let ((contact-pkg (make-instance 'contact-pkg)))
            (mark-contact-us-post contact-pkg id (id (get-user)) (string= read "read"))
            (setf (session-value :message) (format nil "Message marked ~a successfully." read)))
        (error (e)
          (declare (ignore e))
          (setf (session-value :errormsg) (format nil "Error marking message ~a." read)))))))
