;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(declaim (optimize (speed 0) (safety 3) (debug 3)))

(in-package :woodriverlessons)

(defmacro with-woodriverlessons-database (&body body)
  `(with-database (getf (databases *webapp*) :db-woodriverlessons) ,@body))

(defgeneric insert-user (auth-pkg user)
  (:documentation "Inserts a new user into the database."))

(defgeneric update-user (auth-pkg user)
  (:documentation "Updates a user in the database."))

(defgeneric get-all-active-users (record-pkg)
  (:documentation "Calls `get_all_active_users'."))

(defgeneric get-all-users (record-pkg)
  (:documentation "Calls `get_all_users'."))

(defgeneric get-active-user-by-username-pwd (record-pkg username pwd)
  (:documentation "Calls `get_active_user_by_username_pwd'."))

(defgeneric get-active-user-by-id (record-pkg id)
  (:documentation "Calls `get_active_user_by_id'."))

(defgeneric get-user-by-id (record-pkg id)
  (:documentation "Calls `get_user_by_id'."))

(defgeneric user-toggle-active (record-pkg user)
  (:documentation "Calls `user_toggle_active'."))

(defgeneric user-delete (record-pkg user)
  (:documentation "Calls `user_delete'."))

(defgeneric get-all-roles (record-pkg record)
  (:documentation "Returns all the roles for a `user'."))

(defgeneric has-role (record-pkg record role)
  (:documentation "Returns `t' when the user exists and has the
specified `role', `nil' otherwise."))

(defgeneric get-all-role-groups (auth-pkg user)
  (:documentation "Returns all the role-groups for a `user'."))

(defgeneric get-role-group-by-name (auth-pkg user name)
  (:documentation "Returns a role-group by `name' for a `user'."))

(defgeneric get-active-role-groups (auth-pkg user)
  (:documentation "Returns all the role-groups for a `user' that are
actually present in `auth.users_role_groups', in other words the
role-groups that are assigned to the user without any superuser
magic."))

(defgeneric insert-user-role-group (auth-pkg user-role)
  (:documentation "Idempotently inserts a new record into
auth.user_role_groups based on the user ID and the role group name."))

(defgeneric delete-role-groups (auth-pkg user)
  (:documentation "Delete all role-group assignments for a user."))

(defgeneric update-profile (record-pkg record)
  (:documentation ""))

(defgeneric update-password (auth-pkg user)
  (:documentation ""))

(defgeneric get-user-sessions (record-pkg)
  (:documentation "Gets all user session records."))

(defgeneric get-user-session (record-pkg &optional sessionid)
  (:documentation ""))

(defgeneric update-timestamp (record-pkg record)
  (:documentation "Updates the timestamp of the `user-session'."))

(defgeneric get-user-session-objects (record-pkg record)
  (:documentation "Get all user session objects associated with a user
session."))

(defgeneric get-user-session-object (record-pkg session-key)
  (:documentation ""))

(defgeneric flush-user-session-object (record-pkg session-key)
  (:documentation ""))

(defgeneric create-user-session (record-pkg)
  (:documentation "Creates a new user session and returns the
sessionid."))

(defgeneric get-about-us (record-pkg)
  (:documentation "Gets the one and only general.about_us record."))

(defgeneric get-testimonials (record-pkg)
  (:documentation "Gets the one and only general.testimonials record."))

(defgeneric get-contact-us-posts (record-pkg user-id read-p)
  (:documentation "Gets contact.contact_us_posts records."))

(defgeneric insert-contact-us-post (contact-pkg contact-us-post)
  (:documentation "Inserts a new contact-us post into
contact.contact_us_posts. Returns the ID of the new record."))

(defgeneric mark-contact-us-post (contact-pkg contact-us-post-id user-id read-p)
  (:documentation "Marks or unmarks a contact-us post as read."))

(defgeneric insert-registration (auth-pkg registration)
  (:documentation "Inserts a new registration into
auth.registrations. Returns the ID of the new record."))

(defgeneric get-registration-by-id (auth-pkg id)
  (:documentation "Gets the record from auth.registrations with the
given `id'."))

(defgeneric get-registration-by-hash (auth-pkg hash)
  (:documentation "Gets the record from auth.registrations with the
given `hash'."))

(defgeneric registrations-gc (auth-pkg)
  (:documentation "Garbage collects registrations that are more than 3
days old."))

(defgeneric delete-registration (auth-pkg hash)
  (:documentation "Deletes a registration with the given `hash'."))

(defgeneric event_date (record)
  (:documentation "Reader for the event_date field. Converts a
local-time::timestamp to a SQL date string."))

(defgeneric (setf event_date) (value record)
  (:documentation "Writer for the event_date field."))

(defgeneric submitted (record)
  (:documentation "Reader for the submitted field. Converts a
local-time::timestamp to a SQL date string."))

(defgeneric (setf submitted) (value record)
  (:documentation "Writer for the submitted field."))

(defgeneric created (record)
  (:documentation "Reader for the created field. Converts a
local-time::timestamp to a SQL date string."))

(defgeneric (setf created) (value record)
  (:documentation "Writer for the created field."))
