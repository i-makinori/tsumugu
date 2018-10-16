
(in-package :cl-user)
(ql:quickload :caveman2)

(defpackage caveman2-test
  (:use :cl :caveman2))

(in-package :caveman2-test)


;;  (defparameter *application-root* (asdf:system-source-directory :caveman2-sample))


(defparameter *app* (make-instance '<app>))

@route GET "/"
(defun index ()
  (render #P"index.tmpl"))

(defun test ()
  (print "hoge"))
