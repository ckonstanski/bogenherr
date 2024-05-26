;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defvar *acceptor* nil)
(defvar *dispatch-table* '(#'dispatch-easy-handlers #'default-dispatcher))
(defvar *webapps* (make-hash-table :test 'equal))
(defvar *webapp* nil)
(defvar *uri* nil)
(defvar *header-register* nil)
(defvar *sessionid* nil)
(defparameter *port* 3012)
(defparameter *server-root* (namestring (asdf:system-relative-pathname (intern (package-name #.*package*)) "./"))
  "The location of the web server root on the filesystem.")

(defclass webapp ()
  ((name :initarg :name
         :initform nil
         :accessor name
         :documentation "The name of the webapp as used in the code. A
string used as the key to any webapp config lookup.")
   (scheme :initarg :scheme
           :initform nil
           :accessor scheme)
   (url :initarg :url
        :initform nil
        :accessor url
        :documentation "The domain portion of the URL to the
root of the webapp.")
   (document-root :initarg :document-root
                  :initform nil
                  :accessor document-root
                  :documentation "The absolute filesystem path to the
webapp's top-level directory which is inside the webapps folder.")
   (title :initarg :title
          :initform nil
          :accessor title
          :documentation "The default title that shows up in
the browser title bar.")
   (meta-description :initarg :meta-description
          :initform nil
          :accessor meta-description
          :documentation "The text that goes into the META DESCRIPTION
tag, and anywhere else we want to put this text so that it will show
up in Google.")
   (databases :initarg :databases
              :initform nil
              :accessor databases)
   (mail-mx :initarg :mail-mx
            :initform nil
            :accessor mail-mx)
   (mail-from :initarg :mail-from
              :initform nil
              :accessor mail-from)
   (mail-postmaster :initarg :mail-postmaster
                    :initform nil
                    :accessor mail-postmaster)
   (mail-webmaster :initarg :mail-webmaster
                   :initform nil
                   :accessor mail-webmaster)
   (mail-info :initarg :mail-info
              :initform nil
              :accessor mail-info)
   (mail-login-notify :initarg :mail-login-notify
                      :initform nil
                      :accessor mail-login-notify)
   (mail-authentication :initarg :mail-authentication
                        :initform nil
                        :accessor mail-authentication)
   (mail-ssl :initarg :mail-ssl
             :initform nil
             :accessor mail-ssl))
  (:documentation ""))

(defmethod get-site-file-path ((webapp webapp))
  (format nil "~a/site" (document-root webapp)))

(defmethod get-pages-file-paths ((webapp webapp))
  (mapcar (lambda (pages-file)
            (ppcre:regex-replace-all "\\.lisp$" (format nil "~a" pages-file) ""))
          (remove-if (lambda (x) (equal x "shared"))
                     (org-ckons-core::shell-wrapper (format nil "find '~a' -maxdepth 1 -type f -iname 'pages*.lisp' |sort" (document-root webapp))))))

(defun make-server-path (relative-path)
  "Makes a relative filesystem path into a full one, using
`*server-root*' as the base."
  (make-document-root-path *server-root* relative-path))

(defun make-document-root-path (document-root relative-path)
  "Makes a relative filesystem path into a full one, using
`document-root' as the base."
  (concatenate 'string document-root relative-path))

(defun make-webapp-path (relative-path)
  "Makes an absolute filesystem path to a location in the webapps
folder."
  (concatenate 'string *server-root* "webapps/" relative-path))

(defun get-options-files ()
  (mapcar (lambda (webapp-directory)
            (format nil "~a/conf/options.lisp" webapp-directory))
          (remove-if (lambda (x) (or (org-ckons-core::match-it "webapps/$" x)
                                     (org-ckons-core::match-it "webapps/shared$" x)
                                     (org-ckons-core::match-it "webapps/CVS$" x)
                                     (org-ckons-core::match-it "webapps/\\.$" x)
                                     (org-ckons-core::match-it "webapps/\\.\\.$" x)))
                     (org-ckons-core::shell-wrapper (format nil "find '~a' -maxdepth 1 -type d |sort" (make-webapp-path ""))))))

(defun set-webapp (webapp)
  "Sets a `webapp' object in `*webapps*'. The lookup key is the webapp
name. If a webapp already exists under this key, it gets overwritten
with the new one."
  (setf (gethash (name webapp) *webapps*) webapp))

(defun get-webapp (key)
  "Gets the webapp object stored under the key `key'."
  (gethash key *webapps*))

(defun populate-webapps ()
  (loop for options-file in (get-options-files) do
       (with-open-file (input options-file :direction :input)
         (let* ((form (read input)))
           (set-webapp (make-instance 'webapp
                                      :name (getf form :name)
                                      :scheme (getf form :scheme)
                                      :url (getf form :url)
                                      :document-root (make-webapp-path (getf form :document-root))
                                      :title (getf form :title)
                                      :meta-description (getf form :meta-description)
                                      :databases (getf form :databases)
                                      :mail-mx (getf form :mail-mx)
                                      :mail-from (getf form :mail-from)
                                      :mail-postmaster (getf form :mail-postmaster)
                                      :mail-webmaster (getf form :mail-webmaster)
                                      :mail-info (getf form :mail-info)
                                      :mail-login-notify (getf form :mail-login-notify)
                                      :mail-authentication (getf form :mail-authentication)
                                      :mail-ssl (getf form :mail-ssl)))))))

(defun woodriverlessons ()
  "Call this to start the server."
  (when (null *acceptor*)
    (let ((package (string-downcase (package-name #.*package*))))
      (populate-webapps)
      (setf (log-manager) (make-instance 'log-manager :message-class 'formatted-message))
      (start-messenger 'text-file-messenger :filename (format nil "/var/log/lisp/~a.log" package))
      (setf *session-secret* (org-ckons-session::generate-sessionid))
      (populate-webapps)
      (setf *acceptor* (start (make-instance 'easy-acceptor
                                             :port *port*
                                             :document-root (make-server-path (format nil "webapps/~a/" package))
                                             :name (format nil "~a-acceptor" package)))))))

(defmacro with-request-wrapper (uri page-function &rest args)
  (let ((package (string-downcase (package-name #.*package*))))
    `(let (output)
       (let* ((*webapp* (get-webapp ,package))
              (*uri* ,uri)
              (*header-register* (make-instance 'org-ckons-session::header-register))
              (*sessionid* (progn
                             (run-garbage-collect-cycle)
                             (ensure-user-session-exists))))
         (ensure-user-exists)
         (setf output (,page-function ,@args))
         (org-ckons-session::ship-headers *header-register*))
       output)))

(defmacro define-endpoint (request-type uri var-list page-function &rest args)
  "Does the grunt work of creating an `easy-handler' for each page you
wish to publish."
  (let ((name (gensym)))
    `(progn
       (org-ckons-core::logger (format nil "Publishing page. URL = [~a]" ,uri))
       (define-easy-handler (,name :uri ,uri :default-request-type ,request-type)
           ,var-list
         (with-request-wrapper ,uri ,page-function ,@args)))))
