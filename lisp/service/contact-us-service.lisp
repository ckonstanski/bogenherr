;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass contact-us-service (rest-service)
  ()
  (:documentation ""))

(defun contact-us-form ()
  (make-form "contact-us-form"
             nil
             t
             `((:name "first_name" :label "First Name" :field-type "text" :required "required")
               (:name "last_name" :label "Last Name" :field-type "text" :required "required")
               (:name "email" :label "Email" :field-type "text" :required "required")
               (:name "phone" :label "Phone" :field-type "text")
               (:name "comments" :label "Message" :field-type "textarea" :required "required")
               (:label "Submit" :field-type "button" :onclick "on_contact_us_email_submit_clicked()"))))

(defun contact-us-json ()
  (with-noauth (instance contact-us-service)
    t))

(defclass contact-us/view-service (contact-us-service)
  ((content :initarg :content
            :initform nil
            :accessor content)
   (form :initarg :form
         :initform nil
         :accessor form)
   (location-p :initform nil))
  (:documentation ""))

(defun contact-us-view-json ()
  (with-noauth (instance contact-us/view-service)
    (setf (form instance) (contact-us-form))))

(defclass contact-us/email-service (contact-us/view-service)
  ()
  (:documentation ""))

(defun contact-us-email-json (first_name last_name email phone comments)
  (declare (special first_name last_name email phone comments))
  (with-noauth (instance contact-us/email-service)
    (with-bogenherr-database
      (let ((contact-pkg (make-instance 'contact-pkg))
            (contact-us-post (make-instance 'contact-us-post)))
        (loop for param in (sb-introspect:function-lambda-list #'contact-us-email-json)
              do (setf (slot-value contact-us-post param) (symbol-value param)))
        (insert-contact-us-post contact-pkg contact-us-post)
        (handler-case
            (let ((text-message (format nil
                                        "A contact-us form submission was received.~%~%Name: ~a ~a~%Email: ~a~%Phone: ~a~%~%Message: ~a~%"
                                        (first_name contact-us-post)
                                        (last_name contact-us-post)
                                        (email contact-us-post)
                                        (phone contact-us-post)
                                        (comments contact-us-post)))
                  (html-message (org-ckons-http::html5
                                 `(html
                                   ((p) "A contact-us form submission was received.")
                                   ((p)
                                    ,(format nil
                                             "Name: ~a ~a<br/>Email: ~a<br/>Phone: ~a"
                                             (first_name contact-us-post)
                                             (last_name contact-us-post)
                                             (email contact-us-post)
                                             (phone contact-us-post)))
                                   ((p)
                                    ,(format nil "Message: ~a" (comments contact-us-post)))))))
              (org-ckons-core::sendmail (mail-mx *webapp*)
                                        (mail-postmaster *webapp*)
                                        (mail-info *webapp*)
                                        (format nil "~a contact-us form" (name *webapp*))
                                        text-message
                                        :html-message html-message
                                        :reply-to (mail-postmaster *webapp*)
                                        :ssl (mail-ssl *webapp*)
                                        :authentication (mail-authentication *webapp*))
              (setf (session-value :message) "Form submitted successfully."))
          (error (e)
            (declare (ignore e))
            (setf (session-value :errormsg) "Error submitting form.")))))))
