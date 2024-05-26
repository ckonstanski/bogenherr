;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defmacro .base (&optional (onload-fn "goto_location('/home')"))
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
       ((script :type "text/javascript" :src "/static/js/cljs/main.js")))
      ((body :onload ,(format nil "woodriverlessons.core.~a" ,onload-fn))
       ((div :class "container-fluid")
        ((div :class "row banner")
         ((div :class "col banner-title") "Violin and Viola Lessons in the Wood River Valley")
         ((div :id "menu-user" :class "col" :style "text-align: right;")))
        ((div :id "menu" :class "well"))
        ((div :id "location" :style "display: none"))
        ((div :id "errormsg"))
        ((div :id "message"))
        ((div :id "body"))
        ,@(mapcar (lambda (js)
                    `((script :type "text/javascript" :src ,(getf js :src) :integrity ,(getf js :integrity) :crossorigin ,(getf js :crossorigin))))
                  '((:src "https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js" :integrity "sha384-Fy6S3B9q64WdZWQUiU+q4/2Lc9npb8tCaSX9FK7E8HnRr0Jz8D6OP9dO5Vg3Q9ct" :crossorigin "anonymous"))))))))

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

(defmacro .contact-us-modify ()
  `(contact-us-modify-json))

(defmacro .contact-us-modify-submit ()
  `(contact-us-modify-submit-json content))

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

(define-endpoint :get "/" () .base)
(define-endpoint :post "/location" ((location :parameter-type 'string)) .location)
(define-endpoint :get "/home" () .home-get)
(define-endpoint :post "/home" ((message :parameter-type 'string) (errormsg :parameter-type 'string)) .home-post)
(define-endpoint :get "/menu" () .menu)
(define-endpoint :get "/menu/user" () .menu-user)
(define-endpoint :get "/login" () .login)
(define-endpoint :post "/login/authenticate" ((username :parameter-type 'string) (pwd :parameter-type 'string)) .login-authenticate)
(define-endpoint :get "/login/forgot" () .login-forgot)
(define-endpoint :get "/logout" () .logout)
(define-endpoint :get "/profile" () .profile)
(define-endpoint :get "/profile/view" () .profile-view)
(define-endpoint :post "/profile/modify" () .profile-modify)
(define-endpoint :post "/profile/modify/submit" ((id :parameter-type 'integer) (username :parameter-type 'string) (first_name :parameter-type 'string) (last_name :parameter-type 'string) (email :parameter-type 'string) (phone :parameter-type 'string)) .profile-modify-submit)
(define-endpoint :get "/password" () .password)
(define-endpoint :post "/password/submit" ((id :parameter-type 'integer) (pwd :parameter-type 'string) (pwd2 :parameter-type 'string)) .password-submit)
(define-endpoint :get "/about-us" () .about-us)
(define-endpoint :get "/about-us/view" () .about-us-view)
(define-endpoint :post "/about-us/modify" () .about-us-modify)
(define-endpoint :post "/about-us/modify/submit" ((content :parameter-type 'string)) .about-us-modify-submit)
(define-endpoint :get "/testimonials" () .testimonials)
(define-endpoint :get "/testimonials/view" () .testimonials-view)
(define-endpoint :post "/testimonials/modify" () .testimonials-modify)
(define-endpoint :post "/testimonials/modify/submit" ((content :parameter-type 'string)) .testimonials-modify-submit)
(define-endpoint :get "/contact-us" () .contact-us)
(define-endpoint :get "/contact-us/view" () .contact-us-view)
(define-endpoint :post "/contact-us/email" ((first_name :parameter-type 'string) (last_name :parameter-type 'string) (email :parameter-type 'string) (phone :parameter-type 'string) (comments :parameter-type 'string)) .contact-us-email)
(define-endpoint :post "/contact-us/modify" () .contact-us-modify)
(define-endpoint :post "/contact-us/modify/submit" ((content :parameter-type 'string)) .contact-us-modify-submit)
(define-endpoint :get "/messages" () .messages)
(define-endpoint :post "/messages/results" ((read :parameter-type 'string)) .messages-results)
(define-endpoint :post "/messages/mark" ((read :parameter-type 'string) (id :parameter-type 'integer)) .messages-mark)
(define-endpoint :get "/users" () .users)
(define-endpoint :get "/users/view" () .users-view)
(define-endpoint :post "/users/add" () .users-add)
(define-endpoint :post "/users/add/submit" ((role_groups :parameter-type 'string) (first_name :parameter-type 'string) (last_name :parameter-type 'string) (email :parameter-type 'string)) .users-add-submit)
(define-endpoint :get "/register" ((hash :parameter-type 'string)) .base (format nil "goto_register('~a') " hash))
(define-endpoint :post "/users/register" ((hash :parameter-type 'string)) .users-register)
(define-endpoint :post "/users/register/form" ((hash :parameter-type 'string)) .users-register-form)
(define-endpoint :post "/users/register/submit" ((hash :parameter-type 'string) (username :parameter-type 'string) (pwd :parameter-type 'string) (pwd2 :parameter-type 'string) (phone :parameter-type 'string)) .users-register-submit)
(define-endpoint :post "/users/modify" ((id :parameter-type 'integer)) .users-modify)
(define-endpoint :post "/users/modify/submit" ((id :parameter-type 'integer) (role_groups :parameter-type 'string) (username :parameter-type 'string) (first_name :parameter-type 'string) (last_name :parameter-type 'string) (email :parameter-type 'string) (phone :parameter-type 'string)) .users-modify-submit)
(define-endpoint :post "/users/toggle-active" ((id :parameter-type 'integer)) .users-toggle-active)
(define-endpoint :post "/users/delete" ((id :parameter-type 'integer)) .users-delete)
