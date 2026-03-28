;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :bogenherr)

(defmacro .base (&optional (start-url "/home"))
  `(org-ckons-http::html5
    `(html
      (head
       ((meta :name "viewport" :content "width=device-width, initial-scale=1, shrink-to-fit=no"))
       ((meta :charset "utf-8"))
       ((title) ,(title *webapp*))
       ,@(mapcar (lambda (css)
                   `((link :rel "stylesheet" :href ,(getf css :href) :integrity ,(getf css :integrity) :crossorigin ,(getf css :crossorigin))))
                 '((:href "https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" :integrity "sha384-xOolHFLEh07PJGoPkLv1IbcEPTNtaed2xpHsD9ESMhqIYd0nLMwNLD69Npy4HI+N" :crossorigin "anonymous")
                   (:href "/static/css/stylesheet.css" :crossorigin "anonymous")))
       ,@(mapcar (lambda (js)
                   `((script :type "text/javascript" :src ,(getf js :src) :integrity ,(getf js :integrity) :crossorigin ,(getf js :crossorigin))))
                 '((:src "https://code.jquery.com/jquery-3.7.1.slim.min.js" :integrity "ha256-kmHvs0B+OpCW5GVHUNjv9rOmY0IvSIRcf7zGUDTDQM8=" :crossorigin "anonymous")))
       ((script :type "text/javascript" :src "/cljs-out/dev-main.js")))
      ((body :onload ,(format nil "bogenherr.core.start(~a)" ,(if start-url
                                                                  (format nil "'~a'" start-url)
                                                                  "null")))
       ((div :id "app"))
       ,@(mapcar (lambda (js)
                   `((script :type "text/javascript" :src ,(getf js :src) :integrity ,(getf js :integrity) :crossorigin ,(getf js :crossorigin))))
                 '((:src "https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js" :integrity "sha384-Fy6S3B9q64WdZWQUiU+q4/2Lc9npb8tCaSX9FK7E8HnRr0Jz8D6OP9dO5Vg3Q9ct" :crossorigin "anonymous")))))))

(defmacro .location ()
  `(location-json location))

(defmacro .home-get ()
  `(home-json))

(defmacro .home-post ()
  `(home-json message errormsg))

(defmacro .menu ()
  `(menu-json))

(defmacro .menu-user ()
  `(menu-user-json))

(defmacro .login ()
  `(login-json))

(defmacro .login-authenticate ()
  `(login-authenticate-json username pwd))

(defmacro .login-forgot ()
  `(login-forgot-json))

(defmacro .logout ()
  `(logout-json))

(defmacro .profile ()
  `(profile-json))

(defmacro .profile-view ()
  `(profile-view-json))

(defmacro .profile-modify ()
  `(profile-modify-json))

(defmacro .profile-modify-submit ()
  `(profile-modify-submit-json id username first_name last_name email phone))

(defmacro .password ()
  `(password-json))

(defmacro .password-submit ()
  `(password-submit-json id pwd pwd2))

(defmacro .about-us ()
  `(about-us-json))

(defmacro .about-us-view ()
  `(about-us-view-json))

(defmacro .about-us-modify ()
  `(about-us-modify-json))

(defmacro .about-us-modify-submit ()
  `(about-us-modify-submit-json content))

(defmacro .gallery ()
  `(gallery-json))

(defmacro .gallery-view ()
  `(gallery-view-json))

(defmacro .gallery-add ()
  `(gallery-add-json))

(defmacro .gallery-add-submit ()
  `(gallery-add-submit-json description video_embed_url upload))

(defmacro .gallery-modify ()
  `(gallery-modify-json id))

(defmacro .gallery-modify-submit ()
  `(gallery-modify-submit-json id description video_embed_url upload))

(defmacro .gallery-delete ()
  `(gallery-delete-json id))

(defmacro .gallery-file-view ()
  `(gallery-file-view id))

(defmacro .testimonials ()
  `(testimonials-json))

(defmacro .testimonials-view ()
  `(testimonials-view-json))

(defmacro .testimonials-modify ()
  `(testimonials-modify-json))

(defmacro .testimonials-modify-submit ()
  `(testimonials-modify-submit-json content))

(defmacro .contact-us ()
  `(contact-us-json))

(defmacro .contact-us-view ()
  `(contact-us-view-json))

(defmacro .contact-us-email ()
  `(contact-us-email-json first_name last_name email phone comments))

(defmacro .messages ()
  `(messages-json))

(defmacro .messages-results ()
  `(messages-results-json read))

(defmacro .messages-mark ()
  `(messages-mark-json read id))

(defmacro .users ()
  `(users-json))

(defmacro .users-view ()
  `(users-view-json))

(defmacro .users-add ()
  `(users-add-json))

(defmacro .users-add-submit ()
  `(users-add-submit-json role_groups first_name last_name email))

(defmacro .users-register ()
  `(users-register-json hash))

(defmacro .users-register-form ()
  `(users-register-form-json hash))

(defmacro .users-register-submit ()
  `(users-register-submit-json hash username pwd pwd2 phone))

(defmacro .users-modify ()
  `(users-modify-json id))

(defmacro .users-modify-submit ()
  `(users-modify-submit-json id role_groups username first_name last_name email phone))

(defmacro .users-toggle-active ()
  `(users-toggle-active-json id))

(defmacro .users-delete ()
  `(users-delete-json id))

(define-endpoint ("/" :method :get) () .base)
(define-endpoint ("/location" :method :post) (&post (location :parameter-type 'string)) .location)
(define-endpoint ("/home" :method :get) () .home-get)
(define-endpoint ("/home" :method :post) (&post (message :parameter-type 'string) (errormsg :parameter-type 'string)) .home-post)
(define-endpoint ("/menu" :method :get) () .menu)
(define-endpoint ("/menu/user" :method :get) () .menu-user)
(define-endpoint ("/login" :method :get) () .login)
(define-endpoint ("/login/authenticate" :method :post) (&post (username :parameter-type 'string) (pwd :parameter-type 'string)) .login-authenticate)
(define-endpoint ("/login/forgot" :method :get) () .login-forgot)
(define-endpoint ("/logout" :method :get) () .logout)
(define-endpoint ("/profile" :method :get) () .profile)
(define-endpoint ("/profile/view" :method :get) () .profile-view)
(define-endpoint ("/profile/modify" :method :post) () .profile-modify)
(define-endpoint ("/profile/modify/submit" :method :post) (&post (id :parameter-type 'integer) (username :parameter-type 'string) (first_name :parameter-type 'string) (last_name :parameter-type 'string) (email :parameter-type 'string) (phone :parameter-type 'string)) .profile-modify-submit)
(define-endpoint ("/password" :method :get) () .password)
(define-endpoint ("/password/submit" :method :post) (&post (id :parameter-type 'integer) (pwd :parameter-type 'string) (pwd2 :parameter-type 'string)) .password-submit)
(define-endpoint ("/about-us" :method :get) () .about-us)
(define-endpoint ("/about-us/view" :method :get) () .about-us-view)
(define-endpoint ("/about-us/modify" :method :post) () .about-us-modify)
(define-endpoint ("/about-us/modify/submit" :method :post) (&post (content :parameter-type 'string)) .about-us-modify-submit)
(define-endpoint ("/gallery" :method :get) () .gallery)
(define-endpoint ("/gallery/view" :method :get) () .gallery-view)
(define-endpoint ("/gallery/add" :method :post) () .gallery-add)
(define-endpoint ("/gallery/add/submit" :method :post) (&post (description :parameter-type 'string) (video_embed_url :parameter-type 'string) (upload :parameter-type 'string)) .gallery-add-submit)
(define-endpoint ("/gallery/modify" :method :post) (&post (id :parameter-type 'integer)) .gallery-modify)
(define-endpoint ("/gallery/modify/submit" :method :post) (&post (id :parameter-type 'integer) (description :parameter-type 'string) (video_embed_url :parameter-type 'string) (upload :parameter-type 'string)) .gallery-modify-submit)
(define-endpoint ("/gallery/delete/:id" :method :delete) (&path (id 'integer)) .gallery-delete)
(define-endpoint ("/gallery/file/view/:id" :method :get) (&path (id 'integer)) .gallery-file-view)
(define-endpoint ("/testimonials" :method :get) () .testimonials)
(define-endpoint ("/testimonials/view" :method :get) () .testimonials-view)
(define-endpoint ("/testimonials/modify" :method :post) () .testimonials-modify)
(define-endpoint ("/testimonials/modify/submit" :method :post) (&post (content :parameter-type 'string)) .testimonials-modify-submit)
(define-endpoint ("/contact-us" :method :get) () .contact-us)
(define-endpoint ("/contact-us/view" :method :get) () .contact-us-view)
(define-endpoint ("/contact-us/email" :method :post) (&post (first_name :parameter-type 'string) (last_name :parameter-type 'string) (email :parameter-type 'string) (phone :parameter-type 'string) (comments :parameter-type 'string)) .contact-us-email)
(define-endpoint ("/messages" :method :get) () .messages)
(define-endpoint ("/messages/results" :method :post) (&post (read :parameter-type 'string)) .messages-results)
(define-endpoint ("/messages/mark" :method :post) (&post (read :parameter-type 'string) (id :parameter-type 'integer)) .messages-mark)
(define-endpoint ("/users" :method :get) () .users)
(define-endpoint ("/users/view" :method :get) () .users-view)
(define-endpoint ("/users/add" :method :post) () .users-add)
(define-endpoint ("/users/add/submit" :method :post) (&post (role_groups :parameter-type 'string) (first_name :parameter-type 'string) (last_name :parameter-type 'string) (email :parameter-type 'string)) .users-add-submit)
(define-endpoint ("/register/:hash" :method :get) (&path (hash 'string)) .base (format nil "/register/~a" hash))
(define-endpoint ("/users/register" :method :post) (&post (hash :parameter-type 'string)) .users-register)
(define-endpoint ("/users/register/form" :method :post) (&post (hash :parameter-type 'string)) .users-register-form)
(define-endpoint ("/users/register/submit" :method :post) (&post (hash :parameter-type 'string) (username :parameter-type 'string) (pwd :parameter-type 'string) (pwd2 :parameter-type 'string) (phone :parameter-type 'string)) .users-register-submit)
(define-endpoint ("/users/modify" :method :post) (&post (id :parameter-type 'integer)) .users-modify)
(define-endpoint ("/users/modify/submit" :method :post) (&post (id :parameter-type 'integer) (role_groups :parameter-type 'string) (username :parameter-type 'string) (first_name :parameter-type 'string) (last_name :parameter-type 'string) (email :parameter-type 'string) (phone :parameter-type 'string)) .users-modify-submit)
(define-endpoint ("/users/toggle-active" :method :post) (&post (id :parameter-type 'integer)) .users-toggle-active)
(define-endpoint ("/users/delete" :method :post) (&post (id :parameter-type 'integer)) .users-delete)
