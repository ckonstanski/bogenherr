;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass gallery-service (auth-service)
  ((admin-p :initarg :admin-p
            :initform nil
            :accessor admin-p))
  (:documentation ""))

(defun gallery-json ()
  (with-noauth (instance gallery-service)
    (with-valid-user (user "gallery-modify")
        (setf (admin-p instance) nil)
      (setf (admin-p instance) t))))

(defclass gallery/view-service (gallery-service)
  ((results :initarg :results
            :initform nil
            :accessor results)
   (location-p :initform nil))
  (:documentation ""))

(defun gallery-view-json ()
  (with-noauth (instance gallery/view-service)
    (with-valid-user (user "gallery-modify")
        (setf (admin-p instance) nil)
      (setf (admin-p instance) t))
    (with-bogenherr-database
      (let ((general-pkg (make-instance 'general-pkg)))
        (setf (results instance) (get-galleries general-pkg))))
    (setf (message instance) (session-value :message))
    (sanitize-rest-json instance)
    (loop for gallery in (results instance)
          do (sanitize-json gallery))))

(defclass gallery/add-modify-delete-service (gallery/view-service)
  ((form :initarg :form
         :initform nil
         :accessor form))
  (:documentation ""))

(defun gallery-add-json ()
  (with-auth (instance gallery/add-modify-delete-service "gallery-modify")
    (setf (form instance) (make-form "gallery-add-form"
                                     nil
                                     t
                                     `((:name "description" :label "Description" :field-type "textarea")
                                       (:name "video_embed_url" :label "Video embed URL" :field-type "text")
                                       (:name "upload" :label "Image" :field-type "file")
                                       (:label "Add Gallery" :field-type "button" :onclick "on_gallery_add_submit_clicked()"))))))

(defun gallery-add-submit-json (description video_embed_url upload)
  (declare (special description video_embed_url))
  (with-auth (instance gallery/add-modify-delete-service "gallery-modify")
    (with-bogenherr-database
      (let ((general-pkg (make-instance 'general-pkg))
            (gallery (make-instance 'gallery))
            (tmp-filepath (first upload))
            (orig-filename (second upload))
            new-filepath)
        (loop for param in (remove-if (lambda (x)
                                        (intersection `(,x) `(upload)))
                                      (sb-introspect:function-lambda-list #'gallery-add-submit-json))
              do (setf (slot-value gallery param) (symbol-value param)))
        (when upload
          (let ((tmpdir (tmpdir:mkdtemp :prefix "bogenherr-gallery-")))
            (setf new-filepath (format nil "~a~a" tmpdir (file-namestring tmp-filepath)))
            (fad:copy-file tmp-filepath new-filepath)
            (setf (filename gallery) orig-filename)
            (setf (mime_type gallery) (org-ckons-file::get-mime-type new-filepath))
            (setf (content gallery) (org-ckons-file::file-as-hex new-filepath))))
        (insert-gallery general-pkg gallery)
        (setf (session-value :message) "Gallery added successfully.")))))

(defun gallery-modify-json (id)
  (with-auth (instance gallery/add-modify-delete-service "gallery-modify")
    (with-bogenherr-database
      (let* ((general-pkg (make-instance 'general-pkg))
             (gallery (get-gallery general-pkg id)))
        (if gallery
            (setf (form instance) (make-form "gallery-modify-form"
                                             nil
                                             t
                                             `((:name "id" :field-type "hidden" :value ,(id gallery) :required "required")
                                               (:name "description" :label "Description" :value ,(description gallery) :field-type "textarea")
                                               (:name "video_embed_url" :label "Video embed URL" :field-type "text" :value ,(video_embed_url gallery))
                                               (:name "upload" :label "Image/Video" :field-type "file")
                                               (:label "Modify Gallery" :field-type "button" :onclick "on_gallery_modify_submit_clicked()"))))
            (setf (session-value :errormsg) "Error: could not modify gallery. Not found."))))))

(defun gallery-modify-submit-json (id description video_embed_url upload)
  (declare (special description video_embed_url))
  (with-auth (instance gallery/add-modify-delete-service "gallery-modify")
    (with-bogenherr-database
      (let* ((general-pkg (make-instance 'general-pkg))
            (gallery (get-gallery general-pkg id)))
        (if gallery
            (let ((tmp-filepath (first upload))
                  (orig-filename (second upload))
                  new-filepath)
              (loop for param in (remove-if (lambda (x)
                                              (intersection `(,x) `(upload)))
                                            (sb-introspect:function-lambda-list #'gallery-add-submit-json))
                    do (setf (slot-value gallery param) (symbol-value param)))
              (when upload
                (let ((tmpdir (tmpdir:mkdtemp :prefix "bogenherr-gallery-")))
                  (setf new-filepath (format nil "~a~a" tmpdir (file-namestring tmp-filepath)))
                  (fad:copy-file tmp-filepath new-filepath)
                  (setf (filename gallery) orig-filename)
                  (setf (mime_type gallery) (org-ckons-file::get-mime-type new-filepath))
                  (setf (content gallery) (org-ckons-file::file-as-hex new-filepath))))
              (update-gallery general-pkg gallery)
              (setf (session-value :message) "Gallery saved successfully."))
            (setf (session-value :errormsg) "An error occurred."))))))

(defun gallery-delete-json (id)
  (with-auth (instance gallery/add-modify-delete-service "gallery-modify")
    (with-bogenherr-database
        (let* ((general-pkg (make-instance 'general-pkg))
               (gallery (get-gallery general-pkg id)))
          (if gallery
              (progn
                (delete-record general-pkg gallery)
                (setf (session-value :message) "Gallery deleted successfully."))
              (setf (session-value :errormsg) "Error: could not delete gallery. Not found."))))))

(defun gallery-file-view (id)
  (with-noauth-raw (instance gallery/view-service)
    (with-bogenherr-database
      (let* ((general-pkg (make-instance 'general-pkg))
             (gallery (get-gallery general-pkg id)))
        (when gallery
          (setf (org-ckons-session::content-type *header-register*) (mime_type gallery))
          (ironclad:hex-string-to-byte-array (content gallery)))))))
