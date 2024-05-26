;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defclass about-us-service (rest-service)
  ()
  (:documentation ""))

(defun about-us-json ()
  (with-noauth (instance about-us-service)
    t))

(defclass about-us/view-service (about-us-service)
  ((content :initarg :content
            :initform nil
            :accessor content)
   (admin-p :initarg :admin-p
            :initform nil
            :accessor admin-p)
   (location :initform nil))
  (:documentation ""))

(defun about-us-view-json ()
  (with-noauth (instance about-us/view-service)
    (with-valid-user (user "about-us-modify")
        (setf (admin-p instance) nil)
      (setf (admin-p instance) t))
    (with-woodriverlessons-database
      (let* ((general-pkg (make-instance 'general-pkg))
             (about-us (get-about-us general-pkg)))
        (when about-us
          (setf (content instance) (content about-us)))))))

(defclass about-us/modify-service (about-us/view-service auth-service)
  ((form :initarg :form
         :initform nil
         :accessor form)
   (admin-p :initform t)
   (location-p :initform nil))
  (:documentation ""))

(defun about-us-modify-json ()
  (with-auth (instance about-us/modify-service "about-us-modify")
    (with-woodriverlessons-database
      (let* ((general-pkg (make-instance 'general-pkg))
             (about-us (get-about-us general-pkg)))
        (setf (form instance) (make-form "about-us-modify-form"
                                         nil
                                         nil
                                         `((:label "Content" :name "txt-content" :field-type "textarea" :value ,(content about-us) :required "required")
                                           (:label "Modify" :field-type "button" :onclick "on_about_us_modify_submit_clicked()"))))))))

(defun about-us-modify-submit-json (content)
  (with-auth (instance about-us/modify-service "about-us-modify")
    (with-woodriverlessons-database
      (let* ((general-pkg (make-instance 'general-pkg))
             (about-us (get-about-us general-pkg)))
        (when about-us
          (setf (content about-us) content)
          (update-record general-pkg about-us))))
    (setf (content instance) content)
    (setf (message instance) "About Us text saved successfully.")))
