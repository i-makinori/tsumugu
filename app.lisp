(ql:quickload :tsumugu)

(defpackage tsumugu.app
  (:use :cl)
  (:import-from :lack.builder
                :builder)
  (:import-from :ppcre
                :scan
                :regex-replace)
  (:import-from :tsumugu.web
                :*web*)
  (:import-from :tsumugu.config
                :config
                :productionp
                :*static-directory*
                :*files-db-directory*))
(in-package :tsumugu.app)


(builder
 (:static
  :path (lambda (path)
          (if (ppcre:scan "^(?:/images/|/css/|/js/|/robot\\.txt$|/favicon\\.ico$)" path)
              path
              nil))
  :root *static-directory*)
 (:static
  :path (lambda (path)
          (if (ppcre:scan "^(?:/material/)" path)
              (format nil "/~A" (file-namestring path))
              nil))
  :root *files-db-directory*)
 (if (productionp)
     nil
     :accesslog)
 (if (getf (config) :error-log)
     `(:backtrace
       :output ,(getf (config) :error-log))
     nil)
 :session
 (if (productionp)
     nil
     (lambda (app)
       (lambda (env)
         (let ((datafly:*trace-sql* t))
           (funcall app env)))))
 *web*)

