(in-package :cl-user)
(defpackage tsumugu.view
  (:use :cl)
  (:import-from :tsumugu.config
                :*template-directory*)
  (:import-from :caveman2
                :*response*
                :response-headers)
  (:import-from :djula
                :add-template-directory
                :compile-template*
                :render-template*
                :*djula-execute-package*)
  (:import-from :datafly
                :encode-json)
  (:export :render
           :render-json
           :render-blob-page))
(in-package :tsumugu.view)

(djula:add-template-directory *template-directory*)

(defparameter *template-registry* (make-hash-table :test 'equal))

(defun render (template-path &optional env)
  (let ((template (gethash template-path *template-registry*)))
    (unless template
      (setf template (djula:compile-template* (princ-to-string template-path)))
      (setf (gethash template-path *template-registry*) template))
    (apply #'djula:render-template*
           template nil
           env)))

(defun render-json (object)
  (setf (getf (response-headers *response*) :content-type) "application/json")
  (encode-json object))

;;
;; blobs
(defun render-blob-page (title contents)
  (render #P"blob_template.html"
          (list :page-title (format nil "~A " title)
                :page-contents (format nil "~A" contents))))


;;
;; Execute package definition

(defpackage tsumugu.djula
  (:use :cl)
  (:import-from :tsumugu.config
                :config
                :appenv
                :developmentp
                :productionp)
  (:import-from :caveman2
                :url-for))

(setf djula:*djula-execute-package* (find-package :tsumugu.djula))

