(in-package :cl-user)
(defpackage tsumugu.db
  (:use :cl)
  (:import-from :tsumugu.config
                :config
                :*database-path*
                :*files-db-directory*)
  (:import-from :datafly
                :*connection*)
  (:import-from :cl-dbi
                :connect-cached)
  (:export :connection-settings
           :db
           :with-connection
           :with-transcation
           :*database-path*
           :*files-db-directory*
           ;;
           :write-contents-vector--to--db-directory
           :read-contents-vector--from--db-directory
           :db-contents))

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




;; I/O file contents to files-db-directory

(defun write-contents-vector--to--db-directory (filename contents-vector)
  ;; future : (filename contens procedure
  ;; prorecure :: (\stream -> write-procedure)
  ;; return IO
  (let* ((file-path (merge-pathnames (format nil "~A" filename)
                                    *files-db-directory*)))
    (with-open-file (out-stream file-path
                                :direction :output
                                :element-type '(unsigned-byte 8)
                                :if-does-not-exist :create
                                :if-exists :supersede)
      (write-sequence contents-vector out-stream)
      t)))

(defun db-contents ()
  (mapcar #'file-namestring
          (uiop:directory-files *files-db-directory*)))
