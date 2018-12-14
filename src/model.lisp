(in-package :cl-user)
(defpackage tsumugu.model
  (:use :cl :sxql)
  (:import-from :tsumugu.db
                :db
                :with-connection
                :with-transcation
                :write-contents-vector--to--db-directory
                :read-contents-vector--from--db-directory
                )
  (:import-from :datafly
                :execute
                :retrieve-all
                :retrieve-one)
  (:export :list-articles
           :write-file-to-uploader
           :read-file-from-uploader))
(in-package :tsumugu.model)


;; structure of DB

(defstruct observer)

(defun observer-hash->observer-struct (user-hash)
  "(user-hash::list||hash) -> Maybe (user::struct)"
  user-hash)


(defstruct article )

#|
(defun user-hash->user-struct (user-hash) ;; future name error
  "(article-hash::list||hash) -> Maybe (article::struct)"
  user-hash)
|#


;;;; observer

#|
(defun add-observer (user-name email password)
  (with-connection (db)
    (execute (insert-into :craftsmans
               (set= :name name
                     :email email
                     :password (cl-pass:hash password))))))
|#

;;;; article

(defparameter *num-show-list-articles* 10)
(defun list-articles ()
  (with-connection (db)
    (retrieve-all
     (select :*
       (from :article)
       (limit *num-show-list-articles*)
       ))))


;; (apply #'datafly:connect-toplevel (connection-settings :maindb))
#|
(defun articles* ()
  (datafly:retrieve-one
   (sxql:select :* (sxql:from :articles))))
|#



;;;; file uploader


(defun write-file-to-uploader (file_name-params file_data-params)
  (let ((db-safe-file-name (unsafe-filename->safe-filename
                            (car file_name-params)))
        ;; (procedure for-contents-type)
        (db-safe-vector (unsafe-contents-text->safe-contents-text
                         (slot-value (car file_data-params) 'flexi-streams::vector))))
    (write-contents-vector--to--db-directory
     db-safe-file-name db-safe-vector)))

(defun read-file-from-uploader (filename)
  "<on app.lisp (route ...... (ppcre:scan ... ) ...... ) >"
  nil)




;;;; injection
(defun unsafe-contents-text->safe-contents-text (unsafe-contents-text)
  unsafe-contents-text)

(defun safe-contents-text->unsafe-contents-text (safe-contents-text)
  safe-contents-text)


(defun unsafe-filename->safe-filename (filename)
  filename)

(defun safe-filename->unsafe-filename (safe-filename)
  safe-filename)
