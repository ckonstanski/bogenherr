;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :cl)

(defpackage :bogenherr-system (:use :cl :asdf))
(in-package :bogenherr-system)

(defmacro do-defsystem (&key name version maintainer author description long-description depends-on components)
  `(defsystem ,name
     :name ,name
     :version ,version
     :maintainer ,maintainer
     :author ,author
     :description ,description
     :long-description ,long-description
     :depends-on ,(eval depends-on)
     :components ,components))

(defparameter *quicklisp-packages* '(cl-ppcre cl-smtp hunchentoot cl-log ironclad cl-markdown tmpdir))
(defparameter *asdf-packages* '(org-ckons-core org-ckons-http org-ckons-json org-ckons-file org-ckons-serializable org-ckons-session org-ckons-condition org-ckons-sql))
(defparameter *all-packages* (append *quicklisp-packages* *asdf-packages*))

(loop for pkg in *quicklisp-packages* do
  (ql:quickload (symbol-name pkg)))

(do-defsystem :name "bogenherr"
  :version "1"
  :maintainer "Carlos Konstanski <me@ckons.org>"
  :author "Carlos Konstanski <me@ckons.org>"
  :description "bogenherr"
  :long-description "bogenherr is a web application written in Common Lisp based on the Hunchentoot web server. The client-side code is written in ClojureScript. Purpose: public website for Violin and Viola Lessons in Pocatello ID."
  :depends-on *all-packages*
  :components ((:module core
                :components ((:file "core")))
               (:module sql
                :depends-on (core)
                :components ((:file "generics")
                             (:file "user-session" :depends-on ("generics"))
                             (:file "user-session-pkg" :depends-on ("generics" "user-session"))
                             (:file "user" :depends-on ("generics"))
                             (:file "role-group" :depends-on ("generics"))
                             (:file "user-role" :depends-on ("generics"))
                             (:file "registration" :depends-on ("generics"))
                             (:file "about-us" :depends-on ("generics"))
                             (:file "testimonials" :depends-on ("generics"))
                             (:file "contact-us" :depends-on ("generics"))
                             (:file "gallery" :depends-on ("generics"))
                             (:file "auth-pkg" :depends-on ("user-session-pkg" "user" "role-group" "user-role" "registration"))
                             (:file "general-pkg" :depends-on ("about-us" "testimonials" "gallery"))
                             (:file "contact-pkg" :depends-on ("contact-us"))))
               (:module service
                :depends-on (sql)
                :components ((:file "generics")
                             (:file "base-service")
                             (:file "rest-service" :depends-on ("base-service"))
                             (:file "auth-service" :depends-on ("rest-service"))
                             (:file "generic-form" :depends-on ("rest-service"))
                             (:file "menu-service" :depends-on ("base-service"))
                             (:file "home-service" :depends-on ("rest-service"))
                             (:file "login-service" :depends-on ("generic-form" "rest-service"))
                             (:file "logout-service" :depends-on ("rest-service"))
                             (:file "profile-service" :depends-on ("generic-form" "auth-service"))
                             (:file "password-service" :depends-on ("generic-form" "auth-service"))
                             (:file "about-us-service" :depends-on ("generic-form" "auth-service"))
                             (:file "gallery-service" :depends-on ("generic-form" "auth-service"))
                             (:file "testimonials-service" :depends-on ("generic-form" "auth-service"))
                             (:file "contact-us-service" :depends-on ("generic-form" "auth-service"))
                             (:file "users-service" :depends-on ("generic-form" "auth-service"))
                             (:file "messages-service" :depends-on ("generic-form" "auth-service"))))
               (:module webapps
                :depends-on (service)
                :components ((:file "generics")
                             (:file "webapp-loader" :depends-on ("generics"))
                             (:module bogenherr
                              :depends-on ("webapp-loader")
                              :components ((:file "site")))))))
