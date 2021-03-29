;;; clockify.el --- description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 oxalorg
;;
;; Author: Mitesh <http://github/oxalorg>
;; Maintainer: John Doe <john@doe.com>
;; Created: February 24, 2021
;; Modified: February 24, 2021
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/oxalorg/emacs-clockify
;; Package-Requires: ((emacs 26.3) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  description
;;
;;; Code:

(require 'json)
(require 'request)

(defvar clockify-api-key)
(defvar clockify-workspace)
(defvar clockify-projects "")
(defvar clockify-project-client "")

(setq clockify-times '("00:00 AM" "01:00 AM" "01:00 PM" "02:00 AM" "02:00 PM"
                       "03:00 AM" "03:00 PM" "04:00 AM" "04:00 PM" "05:00 AM"
                       "05:00 PM" "06:00 AM" "06:00 PM" "07:00 AM" "07:00 PM"
                       "08:00 AM" "08:00 PM" "09:00 AM" "09:00 PM" "10:00 AM"
                       "10:00 PM" "11:00 AM" "11:00 PM" "12:00 AM" "12:00 PM"
                       "00:30 AM" "01:30 AM" "01:30 PM" "02:30 AM" "02:30 PM"
                       "03:30 AM" "03:30 PM" "04:30 AM" "04:30 PM" "05:30 AM"
                       "05:30 PM" "06:30 AM" "06:30 PM" "07:30 AM" "07:30 PM"
                       "08:30 AM" "08:30 PM" "09:30 AM" "09:30 PM" "10:30 AM"
                       "10:30 PM" "11:30 AM" "11:30 PM" "12:30 AM" "12:30 PM"))

(defun clockify-api (method path &optional data)
  (let ((response (request-response-data
                   (request
                     (concat "https://api.clockify.me/api/v1" path)
                     :type method
                     :data (json-encode data)
                     :parser 'json-read
                     :headers `(("Content-Type" . "application/json")
                                ("X-Api-Key" . ,clockify-api-key))
                     :sync t))))
    response))

(defun clockify-get-projects ()
  (interactive)
  (setq clockify-projects (clockify-api "GET" (concat "/workspaces/" clockify-workspace "/projects")))
  (setq clockify-project-client
        (mapcar (lambda (project)
                  (let ((clientName (cdr (assoc 'clientName project)))
                        (name (cdr (assoc 'name project)))
                        (id (cdr (assoc 'id project))))
                    (list clientName name id)))
                clockify-projects)))

(defun clockify-clock (selected-project start-time end-time)
  (interactive
   (list (completing-read
          "Choose clockify project: "
          (mapcar (lambda (project)
                    (concat
                     (nth 2 project)
                     " - "
                     (nth 0 project)
                     " / "
                     (nth 1 project)))
                  clockify-project-client))
         (completing-read "Start time (hh:mm:ss):" clockify-times nil t)
         (completing-read "End time (hh:mm:ss):" clockify-times nil t)))

  (let ((pid (car (split-string selected-project "\s")))
        (now (decode-time))
        (entry (format-time-string "%Y-%m-%dT%TZ" (current-time)))
        (start-utc (get-iso-utc-for-clock-time start-time))
        (end-utc (get-iso-utc-for-clock-time end-time)))
    (message "Here")
    (message pid)
    (message start-utc)
    (message end-utc)
    (clockify-api "POST" (concat "/workspaces/" clockify-workspace "/time-entries")
                  (list
                    (cons "start" start-utc)
                    (cons "end" end-utc)
                    (cons "projectId" pid)))))

(defun get-iso-utc-for-clock-time (time)
  (let ((split (split-string time "[\s:]"))
        (now (decode-time)))
    (setf (elt now 2) (if (string-equal (elt split 2) "PM")
                          (+ 12 (string-to-number (elt split 0)))
                        (string-to-number (elt split 0)))
          (elt now 1) (string-to-number (elt split 1))
          (elt now 0) 0)
    (format-time-string "%Y-%m-%dT%TZ"
                        (apply #'encode-time
                         (decode-time (apply #'encode-time now) "UTC")))))

(provide 'clockify)
;;; clockify.el ends here
