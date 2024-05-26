;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defclass testimonials-service (rest-service)
  ((title :initarg :title
          :initform nil
          :accessor title))
  (:documentation ""))

(defun testimonials-json ()
  (with-noauth (instance testimonials-service)
    (setf (title instance) "Testimonials")))

(defclass testimonials/view-service (testimonials-service)
  ((content :initarg :content
            :initform nil
            :accessor content)
   (form :initarg :form
         :initform nil
         :accessor form)
   (admin-p :initarg :admin-p
            :initform t
            :accessor admin-p)
   (location-p :initform nil))
  (:documentation ""))

(defun testimonials-view-json ()
  (with-noauth (instance testimonials/view-service)
    (with-valid-user (user "testimonials-modify")
        (setf (admin-p instance) nil)
      (setf (admin-p instance) t))
    (with-woodriverlessons-database
      (let* ((general-pkg (make-instance 'general-pkg))
             (testimonials (get-testimonials general-pkg)))
        (when testimonials
          (setf (content instance) (content testimonials)))))))

(defclass testimonials/modify-service (testimonials/view-service auth-service)
  ()
  (:documentation ""))

(defun testimonials-modify-json ()
  (with-auth (instance testimonials/modify-service "testimonials-modify")
    (setf (title instance) "Testimonials - Modify")
    (with-woodriverlessons-database
      (let* ((general-pkg (make-instance 'general-pkg))
             (testimonials (get-testimonials general-pkg))
             content)
        (when testimonials
          (setf content (content testimonials)))
        (setf (form instance) (make-form "testimonials-modify-form"
                                         nil
                                         nil
                                         `((:name "txt-content" :field-type "textarea" :value ,content)
                                           (:label "Modify" :field-type "button" :onclick "on_testimonials_modify_submit_clicked()"))))))))

(defun testimonials-modify-submit-json (content)
  (with-auth (instance testimonials/modify-service "testimonials-modify")
    (setf (title instance) "Testimonials - Modify")
    (with-woodriverlessons-database
      (let* ((general-pkg (make-instance 'general-pkg))
             (testimonials (get-testimonials general-pkg)))
        (when testimonials
          (setf (content testimonials) content)
          (update-record general-pkg testimonials))))
    (setf (content instance) content)
    (setf (session-value :message) "Testimonials text saved successfully.")))
