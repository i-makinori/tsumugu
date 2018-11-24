(in-package :cl-user)
(defpackage tsumugu.db
  (:use :cl)
  (:import-from :tsumugu.config
                :config)
  (:import-from :datafly
                :*connection*)
  (:import-from :cl-dbi
                :connect-cached)
  (:export :connection-settings
           :db
           :with-connection
           :with-transcation))
(in-package :tsumugu.db)

(defun connection-settings (&optional (db :maindb))
  (cdr (assoc db (config :databases))))

(defun db (&optional (db :maindb))
  (apply #'connect-cached (connection-settings db)))

(defmacro with-connection (conn &body body)
  `(let ((*connection* ,conn))
     ,@body))

(defmacro with-transaction (conn &body body)
  `(let ((*connection* ,conn))
     (with-transcation *connection*
       ,@body)))


;; (apply #'datafly:connect-toplevel (connection-settings :maindb))
#|
(defun articles* ()
  (datafly:retrieve-one
   (sxql:select :* (sxql:from :articles))))
|#
