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
           :read-contents-vector--from--db-directory))

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
                                :if-does-not-exist :create)
      (write-sequence contents-vector out-stream))))

(defun read-contents-vector--from--db-directory (filename)
  ;; future : (filename procedure)
  ;; prorecure :: (\stream -> read-procedure)
  ;; return maybe(values contents-vector [maybe-contents-types])
  (let ((file-path (merge-pathnames (format nil "~A" filename)
                                    *files-db-directory*)))
    (with-open-file (read-stream file-path
                                 :direction :input
                                 :element-type '(unsigned-byte 8)
                                 :if-does-not-exist nil)
      (let* ((buf (make-array (file-length read-stream) :element-type '(unsigned-byte 8))))
        (read-sequence buf read-stream)
        buf))))

;; (print (read-contents-vector--from--db-directory "this_file_will___.txt"))





;; (apply #'datafly:connect-toplevel (connection-settings :maindb))
#|
(defun articles* ()
  (datafly:retrieve-one
   (sxql:select :* (sxql:from :articles))))
|#
