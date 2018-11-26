(in-package :cl-user)
(defpackage tsumugu.web
  (:use :cl
        :caveman2
        :tsumugu.config
        :tsumugu.view
        :tsumugu.db
        :tsumugu.model
        :datafly
        :sxql
        :clack)
  (:export :*web*))
(in-package :tsumugu.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;;
;; Routing rules

(defroute "/" ()
  (let ((article-heads (article-head-list (list-articles))))
    (render #P"index.html" (list :article-heads article-heads))))
    ;;(format nil "heads: ~A" article-heads)))

(defun article-head-list (listed-articles)
  (mapcar
   #'(lambda (article)
       (list :title (getf article :title)
             :date (getf article :updated-at)
             :author (getf article :user-id)
             :tags (getf article :tags)
             :contents-head (getf article :contents)))
   listed-articles
   ))


(defroute "/articles" ()
  (let ((articles (list-articles)))
    (format nil "articles: ~A" articles)))



;; uploader such as image-files
;; [ref]
;; http://progn.hateblo.jp/entry/20170131/1485855797
;; https://github.com/edicl/flexi-streams/issues/28
;; 


(defroute "/post-form" ()
  (let ((form-html "
<form action=\"/post\" method=\"POST\" enctype=\"multipart/form-data\">
  <input type=\"text\" name=\"message\" value=\"message here\" />
  <input type=\"file\" name=\"file\" />
  <input type=\"submit\" value=\"Send\" />
</form>"))
    (format nil "~A" form-html)))


(defroute ("/post" :method :POST) (&key |file| |message|)
  (let* ((time (write-to-string (get-universal-time)))
         (fname (merge-pathnames
                 (format nil "~A.jpg" time)
                 *static-directory*)))
    #|
    (with-open-file (out fname
                         :direction :output
                         :element-type '(unsigned-byte 8)
                         :if-does-not-exist :create)
    (write-sequence (slot-value |file| 'flexi-streams::vector) out))
    |#
    (setf *sample-file* |file|)
    (setf *sample-message* |message|)
    (format nil "~A" |file|)))



(with-open-file (out-stream #P"~/Downloads/hoge.png"
                            :direction :output
                            :element-type '(unsigned-byte 8)
                            :if-does-not-exist :create
                            :if-exists :overwrite)
  (write-sequence (slot-value (car *sample-file*) 'flexi-streams::vector)
                  out-stream))

#|

(print *sample-file*)
;; (#<FLEXI-STREAMS::VECTOR-INPUT-STREAM {10028B5893}>
;;  #<HASH-TABLE :TEST EQUAL :COUNT 2 {10028B5393}>
;;  #<HASH-TABLE :TEST EQUAL :COUNT 2 {10028B4D43}>)

;; FLEXI-STREAMS::VECTOR-INPUT-STREAM



;; (print (flexi-streams::stream-file-position (car *sample-file*)))
;; (print (flexi-streams::stream-read-byte (car *sample-file*)))


(with-open-stream (s (car *sample-file*))
  (let (c)
    (loop for c = (read-byte s nil)
       while c
       do (format t "~S " c))))


(print (slot-value (car *sample-file*) 'flexi-streams::vector))
(write-sequence (slot-value (car *sample-file*) 'flexi-streams::vector) *standard-output*)

|#


;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
