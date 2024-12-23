;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defclass gallery (postgres-record)
  ((id :initarg :id
       :initform nil
       :accessor id)
   (description :initarg :description
                :initform nil
                :accessor description)
   (filename :initarg :filename
             :initform nil
             :accessor filename)
   (mime_type :initarg :mime_type
              :initform nil
              :accessor mime_type)
   (video_embed_url :initarg :video_embed_url
                    :initform nil
                    :accessor video_embed_url)
   (content :initarg :content
            :initform nil
            :accessor content)
   (created :initarg :created
            :initform nil
            :accessor created)
   (modified :initarg :modified
             :initform nil
             :accessor modified)
   (*table :initform "general.gallery")
   (*where-expression :initform "id = ~a"))
  (:documentation "Holds the data for a general.gallery type."))
